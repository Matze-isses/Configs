import sys
import subprocess
import os
import json
import datetime


def main():
    if len(sys.argv) < 3 < 4 < len(sys.argv):
        print("You need to input 4 ")
        sys.exit(1)
    
    try: 
        selected_option = sys.argv[1]
        number = int(sys.argv[2]) 
    except Exception: 
        print("The number must be a positive integer!!!")
        sys.exit(1)

    week_number = str(datetime.datetime.now().isocalendar()[1] if len(sys.argv) != 4 else sys.argv[3])

    # Validate that week_number and number are integers
    try:
        number = int(number)
    except ValueError:
        print("Error: week_number and number must be integers.")
        sys.exit(1)

    # Path to the JSON file for the current week
    json_dir = "/home/admin/data/goals/"
    json_file = os.path.join(json_dir, f"goal_data.json")

    # Create the directory for JSON files if it doesn't exist
    os.makedirs(json_dir, exist_ok=True)

    # Initialize or load the JSON data
    if os.path.exists(json_file):
        with open(json_file, 'r') as f:
            try:
                data = json.load(f)
            except json.JSONDecodeError:
                print(f"Error: JSON file {json_file} is malformed.")
                sys.exit(1)
    else:
        data = {week_number: {}}

    weekday = datetime.datetime.now().strftime("%A")

    if week_number not in data: 
        data[week_number] = {}
        data[week_number][weekday] = {}

    if weekday not in data[week_number]:
        data[week_number][weekday] = {}

    # Update the data
    if selected_option in data[week_number][weekday]:
        data[week_number][weekday][selected_option].append(number)
    else:
        data[week_number][weekday][selected_option] = [number]

    # Save the JSON data
    with open(json_file, 'w') as f:
        json.dump(data, f, indent=4)

    result = subprocess.run(['hyprctl', 'notify', str(2), str(5), "rgb(#12f268)", "Added Progress to current weeks goals! Now starting to upload markdown results file."], capture_output=True, text=True)
    string = f"Summary for achiving the goals:\n"

    for day, progress_day in data[week_number].items():
        string += f"    {day+':':10s}\n"
        for key, value_list in progress_day.items():
            string += f"        {key + ':':<12s} {sum(value_list)}\n"

    with open(json_dir + "Summary.md", 'w') as f:
        f.write(string) 

if __name__ == "__main__":
    main()
