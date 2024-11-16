import subprocess
import os
import socket


def get_client_param(client_str):
    param = [item.replace('\n', '') for item in client_str.split(r"\n\t")[1:-1]]
    return {line[:line.find(":")]: line[line.find(":")+2:] for line in param}


def get_clients():
    args = ["hyprctl", "clients"]
    result = subprocess.run(args, capture_output=True)
    return str(result.stdout).split(r"\n\n")


def get_active_window():
    clients = get_clients()
    active_window = get_client_param(clients[2])

def get_number_clients(monitor: str = ""):
    clients = get_clients()
    summed = 0
    for client in clients:
        param = get_client_param(client)
        if "monitor" not in param:
            continue
        summed += 1 if monitor == "" or param["monitor"] == monitor else 0
    
    return summed

get_active_window()
print(f"{get_number_clients()} {get_number_clients('1')} {get_number_clients('0')}")



