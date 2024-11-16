import collections
import traceback
import subprocess
from itertools import product
import datetime
from typing import Union
import json
import sys
import re
import os

days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
req = {"Laufen": 5, "Schreiben": 2}


class GoalsHandler:
    def __init__(self, base_dir: str = "/home/admin/data/goals/"):
        self.path_data = base_dir + "goal_data.json"
        self.path_summery = base_dir + "Summary.md"
        self.week_number = int(datetime.datetime.now().isocalendar()[1])
        self.path_summery_remote = f"remote:/Ziele/Nachweise/Matthis/Week-{self.week_number}/Summary.md"
        self.path_current_remote = f"remote:/Ziele/Nachweise/Matthis/Week-{self.week_number}/{datetime.datetime.now().strftime('%A')}/"
        self.data = {}
        self.load()
        self.data[self.week_number] = self.get_results(self.week_number)
        self.save()

    def send_notify(self, notification, notification_type=1, color='25dfdf'):
        subprocess.run(["hyprctl", "notify", str(notification_type), '5000', 'rgb(' + color + ')', notification])
        print(notification)

    def transform_saved(self, item):
        return item if type(item) is int else (int(item) if type(item) is str else sum(item))

    @staticmethod
    def search_for_requirements_in_files(files):
        results = {key: 0 for key in req.keys()}
        for file in files:
            # Match the filename pattern: word_digits.png
            try:
                match = re.match(r'(\w+)_(\d+)\.png', file)
                if match is None:
                    continue

                key = match.group(1)
                value = int(match.group(2))
                if key in req:
                    results[key] += value
            except Exception as e:
                print(f"Error with search in files {e}")
            

        return results

    def get_results(self, week_number: int):
        # Define the path to the current week's directory on Google Drive
        week_path = f'remote:/Ziele/Nachweise/Matthis/Week-{week_number}/'

        if week_number not in self.data:
            self.data[week_number] = self.data
        # List the day subdirectories in the current week's directory
        days_output = subprocess.check_output(['rclone', 'lsf', '--dirs-only', week_path], encoding='utf-8', timeout=30)
        days = days_output.strip().split('\n')
        print(days)

        result_dict = {}

        for day in days:
            print(day)
            day = day.strip('/')
            day_path = week_path + day + "/"
            print(day_path)

            # List the files in the day's subdirectory
            files_output = subprocess.check_output(['rclone', 'lsf', day_path], encoding='utf-8', timeout=30)
            files = files_output.strip().split('\n')
            print(files)
            result_day = self.search_for_requirements_in_files(files)
            result_dict[day] = result_day

        return result_dict

    def add_data(self, selected_option, number):
        weekday = str(datetime.datetime.now().strftime("%A"))

        if self.week_number not in self.data:
            if int(self.week_number)-1 in self.data:
                perf_past = self.get_results(int(self.week_number)-1)
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

        self.generate_overview()
        self.save()
        self.check_num_files()

    def add_required_for_week(self):
        self.data[self.week_number]["Requirements"][sys.argv[2]] = sys.argv[3]
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

    def load(self):
        # Save the JSON self.data
        with open(self.path_data, 'r') as f:
            self.data = {int(key): values for key, values in json.load(f).items()}
            return self.data

    def save(self):
        # Save the JSON self.data
        with open(self.path_data, 'w') as f:
            json.dump({int(key): values for key, values in self.data.items()}, f, indent=4)

    @staticmethod
    def get_results_of_week(week_data: dict, subtract_required: bool = True):
        result = {key: 0 for key in req.keys()}
        needed = [(key, value) for key, value in req.items()]
        days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

        for day, (opt, requirement) in product(days, needed):
            if day not in week_data or opt not in week_data[day]:
                result[opt] -= requirement
            else:
                result[opt] += week_data[day][opt] - requirement

            if not subtract_required:
                result[opt] += requirement

        return result

    def get_prior_results(self, week_num: Union[int, None] = None):
        """
        :param week_num: if None then the current week is used as reference
        """
        results = {key: 0 for key in req.keys()}
        week_num = self.week_number if week_num is None else week_num 
        
        for week, items in self.data.items(): 
            if week >= week_num:
                continue
            for key, value in self.get_results_of_week(items).items():
                results[key] += value
        return results

    def generate_overview(self):
        string = "\n\n" + " " * 30 + "Goals" + 30 * " " + "\n"
        string +=         " " * 26 + "---=======---" + 26 * " " + "\n\n"
        string += "Current Goals are given by:\n"
        string += "\n\n" + " " * 30 + "Results" + 30 * " " + "\n"
        string +=          " " * 29 + "=========" + 29 * " " + "\n\n"

        current_data = self.data[self.week_number]
        print(f"Current Week: {current_data}")
        past_perf = self.get_prior_results()
        print(f"Past Performance: {past_perf}")
        todays_perf = {}

        for day in days:
            string += f"    {day+':':10s}\n"
            string += " " * (21) + "+------+-----------+----------++-------+\n"
            string += " " * (21) + "| Done | Past Done | Required || Total |\n"
            string += " " * (21) + "+------+-----------+----------++-------+\n"

            # handles the items per day
            for key, value in req.items():
                if day not in current_data:
                    print(key, day, current_data)
                    perf = 0
                elif key not in current_data[day]:
                    print(key)
                    perf = 0
                else:
                    print("in data")
                    perf = current_data[day][key]
                print(perf)
                
                today_done = sum(perf) if type(perf) is list else perf 
                done_before = past_perf[key]
                past_perf[key] += today_done - value
                string += f"        {key + ':':<12s} | {int(today_done):^ 4d} | {int(done_before):^9d} | {int(value):^ 8d} || {int(past_perf[key]):> 5d} |\n"
                if day == str(datetime.datetime.now().strftime("%A")):
                    todays_perf = past_perf.copy()

                print("TODAY", today_done)
                print("BEFORE", past_perf[key])

            print(string)

            string += "\n\n"

        with open(self.path_summery, 'w') as f:
            f.write(string)

        self.send_notify("  Created and Saved overview file to the markdown file")
        self.send_to_drive(self.path_summery, self.path_summery_remote)
        self.send_notify(f"  Uploaded Overview {format(todays_perf)}")

        return string

    def stats_now(self):
        past_perf = self.get_prior_results()
        current_data = self.data[self.week_number]
        for day in days:
            for key, value in req.items():
                perf = 0 if day not in current_data or key not in current_data[day] else current_data[day][key]

                today_done = sum(perf) if type(perf) is list else perf 
                done_before = past_perf[key]
                past_perf[key] += today_done - value

                if day == str(datetime.datetime.now().strftime("%A")):
                    self.send_notify("\n".join([f" {key}: {value}" for key, value in past_perf]))
                    return


if __name__ == "__main__":
    handler = GoalsHandler()
    if sys.argv[0] == "just_print":
        print(f"stats")
        handler.stats_now()
        sys.exit(1)
    try:
        selected_option = sys.argv[1]
        number = int(sys.argv[2])
        handler.add_data(selected_option, number)

        handler.generate_overview()
    except Exception:
        traceback.print_exc()

    handler.generate_overview()
    handler.save()
