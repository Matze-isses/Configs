import subprocess
import datetime
import json
import sys
import re
import os


class GoalsHandler:
    def __init__(self, base_dir: str = "/home/admin/data/goals/"):
        self.path_data = base_dir + "goal_data.json"
        self.path_summery = base_dir + "Summary.md"
        self.week_number = str(datetime.datetime.now().isocalendar()[1])
        self.path_summery_remote = f"remote:/Ziele/Nachweise/Matthis/Week-{self.week_number}/Summary.md"
        self.path_current_remote = f"remote:/Ziele/Nachweise/Matthis/Week-{self.week_number}/{datetime.datetime.now().strftime('%A')}/"

        if os.path.exists(self.path_data):
            with open(self.path_data, 'r') as f:
                try:
                    self.data = json.load(f)
                except json.JSONDecodeError:
                    self.send_notify("Cannot open json file", color='c14371')
                    sys.exit(1)
        else:
            self.data = {self.week_number: {}}

        if self.week_number not in self.data:
            self.data[self.week_number] = {}

        for i in range(datetime.datetime.now().weekday()):
            past_day = datetime.datetime.now() - datetime.timedelta(days=i+1)

            if past_day.strftime("%A") not in self.data[self.week_number]:
                past_day = past_day.strftime("%A")
                if "Requirements" not in self.data[self.week_number]:
                    self.data[self.week_number]["Requirements"] = {"Laufen": 5, "Schreiben": 2}

                required = self.data[self.week_number]["Requirements"]
                self.data[self.week_number][past_day] = {"Laufen": 0, "Schreiben": 0 }

        self.current_data = self.data[self.week_number]

    def send_notify(self, notification, notification_type=1, color='25dfdf'):
        subprocess.run(["hyprctl", "notify", str(notification_type), '5000', 'rgb(' + color + ')', notification])
        print(notification)

    def transform_saved(self, item):
        return item if type(item) is int else (int(item) if type(item) is str else sum(item))

    def get_results(self, week_number: str):
        # Define the path to the current week's directory on Google Drive
        week_path = f'remote:/Ziele/Nachweise/Matthis/Week-{week_number}/'

        if week_number not in self.data:
            self.data[week_number] = {}
        print(week_path)

        # List the day subdirectories in the current week's directory
        days_output = subprocess.check_output(['rclone', 'lsf', '--dirs-only', week_path], encoding='utf-8', timeout=30)
        days = days_output.strip().split('\n')
        print(days)

        result_dict = {"Schreiben": 0, "Laufen": 0}
        required = self.data[week_number]["Requirements"] if "Requirements" in self.data[week_number] else {"Laufen": 5, "Schreiben": 2}
        without_loss = {}

        day_to_int = {day: i for i, day in enumerate(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']) if i <= datetime.datetime.now().weekday() or self.week_number != week_number}

        for day in days:
            if day not in self.data[week_number]:
                self.data[week_number][day[:-1]] = {}

            print(day)
            day = day.strip('/')
            day_path = week_path + day + "/"
            print(day_path)

            # List the files in the day's subdirectory
            files_output = subprocess.check_output(['rclone', 'lsf', day_path], encoding='utf-8', timeout=30)
            files = files_output.strip().split('\n')
            print(files)
            
            for file in files:
                # Match the filename pattern: word_digits.png
                match = re.match(r'(\w+)_(\d+)\.png', file)

                if match:
                    word = match.group(1)
                    digits = int(match.group(2))

                    if word not in without_loss:
                        without_loss[word] = []

                    without_loss[word].append(digits)

                    if day in day_to_int:
                        adjusted_value = digits - required[word]
                    else:
                        adjusted_value = digits

                    try:
                        day_to_int.pop(day)
                    except Exception:
                        pass

                    print(adjusted_value, "     " + word + "     ", result_dict)
                    
                    # Add the adjusted value to the dictionary
                    if word not in result_dict:
                        result_dict[word] = adjusted_value
                    else:
                        result_dict[word] += adjusted_value

                    if word not in self.data[week_number][day]:
                        self.data[week_number][day][word] = adjusted_value
                    else:
                        self.data[week_number][day][word] += adjusted_value

        for day in day_to_int.keys():
            for word in required:
                print(day)
                print(word)
                if day not in self.data[week_number] or word not in self.data[week_number][day] or self.data[week_number][day][word] == [0]:
                    result_dict[word] -= required[word]

                if day not in self.data[week_number]:
                    self.data[week_number][day] = {key: - value for key, value in required.items()}

                if word not in self.data[week_number][day] or self.data[week_number][day][word] == [0]:
                    self.data[week_number][day][word] = [0]


                print(result_dict[word])
                print(required)
                print(self.data[week_number][day][word])

        # Print the resulting dictionary
        return result_dict, without_loss

    def add_data(self, selected_option, number):
        weekday = str(datetime.datetime.now().strftime("%A"))

        if self.week_number not in self.data:
            if int(self.week_number)-1 in self.data:
                perf_past = self.get_results(str(int(self.week_number)-1))[0]
            else:
                self.current_data = {
                    "Requirements": {"Laufen": 5, "Schreiben": 4}
                }
                return

            self.current_data = {
                "Requirements": {"Laufen": 5, "Schreiben": 4},
                "week_before": perf_past
            }
            self.current_data[weekday] = {}

        if weekday not in self.current_data:
            self.current_data[weekday] = {}

        # Update the self.data
        if selected_option in self.current_data[weekday]:
            self.current_data[weekday][selected_option].append(number)
        else:
            self.current_data[weekday][selected_option] = [number]

        self.generate_overview()
        self.save()
        self.check_num_files()

    def add_required_for_week(self):
        self.current_data["Requirements"][sys.argv[2]] = sys.argv[3]
        self.save()

    def send_to_drive(self, path_local, path_remote):
        subprocess.run(["rclone", "copy", path_local, path_remote, "--progress", "--ignore-times", "--no-update-modtime"], capture_output=True)

    def create_remote_dir(self):
        result = subprocess.check_output(["rclone", "mkdir", self.path_current_remote, "--progress"], encoding='utf-8', timeout=30)
        print(len(result.split("\n"))-1)
        self.check_num_files()

    def check_num_files(self):
        result = subprocess.check_output(["rclone", "lsf", self.path_current_remote], encoding='utf-8', timeout=30)
        found_files = len(result.split("\n"))-1
        self.send_notify(f'   Found {found_files} files within the remote')

    def save(self):
        # Save the JSON self.data
        self.data[self.week_number] = self.current_data
        with open(self.path_data, 'w') as f:
            json.dump(self.data, f, indent=4)

    def generate_overview(self):
        past_perf = self.get_results(str(int(self.week_number)-1))[0]

        string = "\n\n" + " " * 30 + "Goals" + 30 * " " + "\n"
        string +=         " " * 26 + "---=======---" + 26 * " " + "\n\n"
        string += "Current Goals are given by:\n"

        current_data = self.data[self.week_number]
        requirements = current_data["Requirements"]
        for req, num in current_data["Requirements"].items():
            string += " " * 4 + f"{req:<10s}: {int(num):>2d}\n"

        string += "\n\n" + " " * 30 + "Results" + 30 * " " + "\n"
        string +=          " " * 29 + "=========" + 29 * " " + "\n\n"

        for day, progress_day in current_data.items():
            if day == "Requirements": 
                continue

            string += f"    {day+':':10s}\n"
            string += " " * (21) + "+------+-----------+----------++-------+\n"
            string += " " * (21) + "| Done | Past Done | Required || Total |\n"
            string += " " * (21) + "+------+-----------+----------++-------+\n"

            # handles the items per day 
            for key, value_list in progress_day.items():
                today_done = sum(value_list) if type(value_list) is list else value_list
                total = int(past_perf[key]) + today_done - int(requirements[key])

                string += f"        {key + ':':<12s} | {int(today_done):^ 4d} | {int(past_perf[key]):^9d} | {int(requirements[key]):^ 8d} || {int(total):> 5d} |\n"

                print("TODAY", today_done)
                print("BEFORE", past_perf[key])

                past_perf[key] = total

            print(string)

            string += "\n\n"

        with open(self.path_summery, 'w') as f:
            f.write(string)

        self.send_notify("  Created and Saved overview file to the markdown file")
        self.send_to_drive(self.path_summery, self.path_summery_remote)
        self.send_notify("  Uploaded Overview")

        return string

def main():
    # Define the path to the current week's directory on Google Drive
    week_number = str(datetime.datetime.now().isocalendar()[1])
    week_path = f'remote:/Ziele/Nachweise/Matthis/Week-{week_number}/'
    print(week_path)

    # List the day subdirectories in the current week's directory
    days_output = subprocess.check_output(['rclone', 'lsf', '--dirs-only', week_path], encoding='utf-8', timeout=30)
    days = days_output.strip().split('\n')
    print(days)

    result_dict = {}
    without_loss = {}

    for day in days:
        day = day.strip('/')
        day_path = week_path + day + "/"
        print(day_path)

        # List the files in the day's subdirectory
        files_output = subprocess.check_output(['rclone', 'lsf', day_path], encoding='utf-8', timeout=30)
        print(files_output)
        files = files_output.strip().split('\n')

        for file in files:
            # Match the filename pattern: word_digits.png
            match = re.match(r'(\w+)_(\d+)\.png', file)

            if match:
                word = match.group(1)
                digits = int(match.group(2))

                if word not in without_loss:
                    without_loss[word] = []

                without_loss[word].append(digits)
                adjusted_value = digits - 2

                # Add the adjusted value to the dictionary
                if word in result_dict:
                    result_dict[word] += adjusted_value
                else:
                    result_dict[word] = adjusted_value

    # Print the resulting dictionary
    return result_dict, without_loss

def extract_day_number(day_name):
    """
    Extracts the day number from the subdirectory name.
    Assumes the subdirectory name is in 'YYYY-MM-DD' format.
    """
    try:
        date_obj = datetime.datetime.strptime(day_name, '%A')
        # Get the day of the month as the day number
        return date_obj.day
    except ValueError:
        # Return 0 if the date format does not match
        return 0

def testfkt():
    results, lossless = main()

if __name__ == "__main__":
    handler = GoalsHandler()

    if sys.argv[1] == "test":
        handler.generate_overview()
        sys.exit(1)

    if sys.argv[1] == "set_required":
        handler.add_required_for_week()
        sys.exit(1)

    selected_option = sys.argv[1]
    number = int(sys.argv[2])
    handler.add_data(selected_option, number)

    handler.generate_overview()
    results_old = handler.get_results(str(int(handler.week_number)-1))[0]
    results, without_loss = handler.get_results(handler.week_number)
    results["Schreiben"] += results_old["Schreiben"]
    results["Laufen"] += results_old["Laufen"]
    handler.send_notify(f" The current results are\n Laufen:    {results['Laufen']}\n Schreiben: {results['Schreiben']}")
