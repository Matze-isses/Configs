import sys
import subprocess
import os
import json
import datetime


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

        for i in range(datetime.datetime.now().weekday()):
            past_day = datetime.datetime.now() - datetime.timedelta(days=i+1)

            if past_day.strftime("%A") not in self.data[self.week_number]:
                past_day = past_day.strftime("%A")
                required = self.data[self.week_number]["Requirements"]
                self.data[self.week_number][past_day] = {
                    "Laufen": [0],
                    "Schreiben": [0]
                }

        self.current_data = self.data[self.week_number]

    def send_notify(self, notification, notification_type=1, color='25dfdf'):
        subprocess.run(["hyprctl", "notify", str(notification_type), '5000', 'rgb(' + color + ')', notification])

    def transform_saved(self, item):
        return item if type(item) is int else (int(item) if type(item) is str else sum(item))

    def _get_past_results(self):
        perf_past = {key: - 6 * self.transform_saved(value) for key, value in self.data[str(int(self.week_number)-1)]["Requirements"].items()}
        for key, value in self.data[str(int(self.week_number)-1)].items():
            if key == "Requirements": continue
            for goal, num in value.items():
                perf_past[goal] += self.transform_saved(num)
        return perf_past

    def add_data(self, selected_option, number):
        weekday = str(datetime.datetime.now().strftime("%A"))

        if self.week_number not in self.data:
            if int(self.week_number)-1 in self.data:
                perf_past = self._get_past_results()
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
        past_perf = self._get_past_results()

        string = "\n\n" + " " * 30 + "Goals" + 30 * " " + "\n"
        string +=         " " * 26 + "---=======---" + 26 * " " + "\n\n"
        string += "Current Goals are given by:\n"

        requirements = self.current_data["Requirements"]
        for req, num in self.current_data["Requirements"].items():
            string += " " * 4 + f"{req:<10s}: {int(num):>2d}\n"

        string += "\n\n" + " " * 30 + "Results" + 30 * " " + "\n"
        string +=          " " * 29 + "=========" + 29 * " " + "\n\n"

        current_perf = {}
        for day, progress_day in self.current_data.items():
            if day == "Requirements": continue

            string += f"    {day+':':10s}\n"
            string += " " * (21) + "+-------+--------+--------++-------+\n"

            for key, value_list in progress_day.items():
                today_done = sum(value_list) # type: ignore
                total = int(past_perf[key]) + today_done - int(requirements[key])
                print("TODAY", today_done)
                print("BEFORE", past_perf[key])

                string += f"        {key + ':':<12s} | {int(today_done):^ 5d} | {int(past_perf[key]):^6d} | {int(requirements[key]):^ 6d} || {int(total):> 5d} |\n"

                past_perf[key] = total

            string += " " * (21) + "+-------+--------+--------++-------+\n"

            string += "\n\n"

        with open(self.path_summery, 'w') as f:
            f.write(string)

        self.send_notify("  Created and Saved overview file to the markdown file")
        self.send_to_drive(self.path_summery, self.path_summery_remote)
        self.send_notify("  Uploaded Overview")

        return string

if __name__ == "__main__":
    handler = GoalsHandler()

    if sys.argv[1] == "test":
        handler.generate_overview()
        sys.exit(1)

    if sys.argv[1] == "set_required":
        handler.add_required_for_week()
        sys.exit(1)

    elif len(sys.argv) < 3 < 4 < len(sys.argv):
        print("You need to input 4 ")
        sys.exit(1)

    selected_option = sys.argv[1]
    number = int(sys.argv[2])
    handler.add_data(selected_option, number)

