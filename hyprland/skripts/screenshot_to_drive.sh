#!/bin/bash

# Define variables
REMOTE="remote:/Ziele/Nachweise/Matthis/Aktuell/"
MOUNT_POINT="/home/admin/drive_goals/"
LOCAL_DIR_PATH="$HOME/Pictures/screenshots/$weekday"
LOCAL_SCREENSHOT_PATH="$LOCAL_DIR_PATH/$filename"  # Replace this with your desired path

input=$(zenity --entry --text="Enter your input:" --title="Input Dialog" --width=300 --height=100)

# Check if the user clicked "Cancel"
if [ $? -eq 1 ]; then
    echo "User canceled the input."
    exit 1
fi
user_input="$input"

timestamp=$(date +%Y%m%d%H%M%S)
filename="screenshot_($user_input)_$timestamp.png"

weekday=$(date +%A)
mkdir -p "$HOME/Pictures/screenshots/$weekday"


grim -g "$(slurp)" "$LOCAL_SCREENSHOT_PATH"
sleep 0.25
xclip -selection clipboard -t image/png -i "$LOCAL_SCREENSHOT_PATH"


if [ -d "$LOCAL_DIR_PATH" ]; then
  # Count the number of files in the directory
  file_count=$(find "$LOCAL_DIR_PATH" -type f | wc -l)
  hyprctl notify 0 5000 'rgb(43c175)' "  Directory '$LOCAL_DIR_PATH' exists with $file_count files."
else
  # Print 0 if the directory does not exist
  hyprctl notify 0 5000 'rgb(A00505)' "Directory '$LOCAL_DIR_PATH' does not exist"
fi

rclone mount --allow-non-empty $REMOTE $MOUNT_POINT &


sleep 5
cp -r "$LOCAL_DIR_PATH" "$MOUNT_POINT"
