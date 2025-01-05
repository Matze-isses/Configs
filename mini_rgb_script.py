import subprocess
import time

def get_cpu_temp():
    output = subprocess.check_output(["sensors"]).decode()
    for line in output.split("\n"):
        if "Package id 0:" in line:
            temp_str = line.split()[3].strip("+°C")
            return float(temp_str)
    return 0.0

def temp_to_color(temp_c):
    min_temp, max_temp = 20.0, 50.0
    temp_c = max(min_temp, min(temp_c, max_temp))
    ratio = (temp_c - min_temp) / (max_temp - min_temp)
    r = 30 + int((100 * ratio))
    g = 30
    b = 30 + int(100 * (1 - ratio))
    return r, g, b

while True:
    t = get_cpu_temp()
    r, g, b = temp_to_color(t)
    color_hex = f"{r:02x}{g:02x}{b:02x}"
    print(f"Temperature: {t}")
    print(f"Color:       {color_hex}")
    time.sleep(0.5)
    subprocess.call(["liquidctl", "-n", "1", "set", "sync", "color", "super-fixed"] + [color_hex[:6]] * 30)
    subprocess.call(["liquidctl", "-n", "2", "set", "sync", "color", "super-fixed"] + [color_hex[:6]] * 30)
