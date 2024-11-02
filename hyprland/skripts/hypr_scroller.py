import subprocess
import os
import socket


def get_client_param(client_str):
    param = [item.replace('\n', '') for item in client_str.split(r"\n\t")[1:-1]]
    return {line[:line.find(":")]: line[line.find(":")+2:] for line in param}


def get_active_window():
    args = ["hyprctl", "clients"]
    result = subprocess.run(args, capture_output=True)
    output = str(result.stdout)
    clients = output.split(r"\n\n")
    print(clients[0])
    active_window = get_client_param(clients[2])
    print(active_window)


get_active_window()
print("\n\n")
socket_path = os.environ["XDG_RUNTIME_DIR"] + "/hypr/" + os.environ["HYPRLAND_INSTANCE_SIGNATURE"] + "/.socket.sock"
print(socket_path)

# Create a socket and connect to the path
with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client_socket:
    client_socket.connect(socket_path)

    while True:
        # Receive data from the socket
        data = client_socket.recv(1024)
        print(data.decode("utf-8"))


