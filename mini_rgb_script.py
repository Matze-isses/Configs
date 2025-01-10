from collections import deque
import threading 
import socket
import subprocess
import re
import sys
import time
from typing import Union

from openrgb import OpenRGBClient
from openrgb.utils import RGBColor, DeviceType

last_values = deque([], maxlen=100)
client = OpenRGBClient()
fan_devices = client.devices
connection = ("127.0.0.1", 8749)

def get_cpu_temp():
    output = subprocess.check_output(["sensors"]).decode()

    for line in output.split("\n"):

        if "Package id 0: " in line:
            temp_str = re.search(r'Package id 0:\s+\+(\d+\.+\d+)°', line)
            if temp_str is None:
                print("WARNING TEMPERATURE NOT FOUND")
                return 20.0
            temp_str = temp_str.group(1)
            last_values.append(float(temp_str))
            return sum(last_values) / len(last_values)
    return 0.0

def temp_to_color(temp_c):
    top_red, top_blue, top_green = 60, 45, 30 
    max_value = 80

    if top_blue >= temp_c > top_green:
        r= 0
        b = (top_blue - temp_c)/(top_blue - top_green) * 200
        g = (temp_c - top_green) / (top_blue - top_green) * 200
    elif top_red >= temp_c > top_blue:
        g = 0
        max_diff = top_red - top_blue 
        temp_diff = 1 - (top_red - temp_c) / max_diff
        r = temp_diff * 200
        b = (1 - temp_diff) * 200
    elif max_value >= temp_c >= top_red:
        r = 200
        max_diff = (max_value - top_red)
        temp_diff = (max_value - temp_c) / max_diff
        g = 200 * (1 - temp_diff)
        b = g
    else:
        max_diff = 100 - max_value
        temp_diff = (temp_c - max_diff) / max_diff
        g = b = r = 200 * (1 - temp_diff)


    r = int(max(r, 0))
    g = int(max(g, 0))
    b = int(max(b, 0))
    return r, g, b

def set_color_all(color_hex):
    subprocess.call(["openrgb", "-c", color_hex])

def set_color_server(r, g, b):
    # Connect to the OpenRGB server
    for device in fan_devices:
        device.set_color(RGBColor(r, g, b))

class RGBHandler:

    def __init__(self) -> None:
        self.stop_update = threading.Event()
        self.changing_thread: Union[threading.Thread, None] = None 

    def continous_update(self, event):
        print("Started subthread")

        while not event.is_set():
            temp = get_cpu_temp()
            r, g, b = temp_to_color(temp)
            set_color_server(r, g, b)
            print("Temperatur: ", temp)

    def handle_client(self, conn):
        data = conn.recv(1024 * 8).decode('utf-8')

        if self.changing_thread is not None:
            self.stop_update.set()
            self.changing_thread.join()

        if len(data) == 6:
            self.stop_update.set()
            set_color_all(data)
        elif data == "temp":
            self.stop_update.set()
            r, g, b = temp_to_color(get_cpu_temp())
            set_color_server(r, g, b)
        elif data == "Temp":
            if self.changing_thread is None:
                self.stop_update = threading.Event()
                self.changing_thread = threading.Thread(target=self.continous_update, args=(self.stop_update, )).start()

        conn.sendall(b'FINISHED')

    def main(self):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.bind(connection)
        s.listen(5)
        while True:
            conn, addr = s.accept()
            threading.Thread(target=self.handle_client, args=(conn, )).start()


if len(sys.argv) <= 1: 
    server = RGBHandler()
    server.main()
else:
    host, port = connection

    client_message = f'{sys.argv[1]}'.encode('utf-8')

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((host, port))
    
    s.sendall(client_message)
    resp = s.recv(1024 * 8).decode('utf-8')

    s.close()

