import subprocess


def get_client_param(client_str):
    param = [item.replace('\n', '') for item in client_str.split(r"\n\t")[1:-1]]
    return {line[:line.find(":")]: line[line.find(":")+2:] for line in param}


def get_active_window():
    print("\n" * 10)
    args = ["hyprctl", "clients"]
    result = subprocess.run(args, capture_output=True)
    output = str(result.stdout)
    clients = output.split(r"\n\n")
    print(clients[0])


get_active_window()
