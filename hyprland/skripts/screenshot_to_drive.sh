#!/bin/bash

weekday=$(date +%A)
week_number=$(date +"%V")
input=$(zenity --entry --text="Enter your input:" --title="Input Dialog" --width=300 --height=100)
fixed_string="Ziele"

# Check if the user clicked "Cancel"
if [ $? -eq 1 ]; then
    echo "User canceled the input."
    exit 1
fi


timestamp=$(date +%Y%m%d%H%M%S)

if [ "$input" = "$fixed_string" ]; then
    filename="$input-Woche-$week_number.png"
    REMOTE="remote:/Ziele/"
else
    filename="$input.png"
    REMOTE="remote:/Ziele/Nachweise/Matthis/Aktuell/$weekday-$week_number/"
fi
# Define variables
MOUNT_POINT="/home/admin/drive_goals/"
LOCAL_DIR_PATH="$HOME/Pictures/proofs/$weekday-$week_number"
LOCAL_SCREENSHOT_PATH="$LOCAL_DIR_PATH/$filename"  # Replace this with your desired path


mkdir -p $LOCAL_DIR_PATH
sleep 0.25
grim -g "$(slurp)" "$LOCAL_SCREENSHOT_PATH"
sleep 0.25

if ! rclone lsd "$REMOTE"; then
    echo "Folder '$REMOTE' does not exist. Creating now..."
    rclone mkdir "$remote_name:$folder_path"
fi

# Upload the data to Google Drive
rclone copy "$LOCAL_SCREENSHOT_PATH" "$REMOTE" --progress
file_count=$(rclone ls "$REMOTE" | wc -l)

if [ -d "$LOCAL_DIR_PATH" ]; then
  # Count the number of files in the directory
  hyprctl notify 0 5000 'rgb(43c175)' "  Directory '$LOCAL_DIR_PATH' exists with $file_count files."
else
  # Print 0 if the directory does not exist
  hyprctl notify 0 5000 'rgb(A00505)' "Directory '$LOCAL_DIR_PATH' does not exist"
fi
