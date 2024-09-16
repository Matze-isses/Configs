#!/bin/bash

weekday=$(date +%A)
week_number=$(date +"%V")
REMOTE="remote:/Ziele/"
FIXED="Ziele"

input=$(zenity --entry --text="Enter your input:" --title="Input Dialog" --width=300 --height=100)

# Check if the user clicked "Cancel"
if [ $? -eq 1 ]; then
    echo "User canceled the input."
    exit 1
fi


timestamp=$(date +%Y%m%d%H%M%S)

if [ "$input" = "$FIXED" ]; then
    filename="Woche-$week_number.png"
    REMOTE="remote:/Ziele/Mathe_Mann_Matthis/"
else
    filename="$input.png"
    REMOTE="remote:/Ziele/Nachweise/Matthis/Week-$week_number/$weekday/"
fi
# Define variables
MOUNT_POINT="/home/admin/drive_goals/"

if [-n "$1"]; then
    LOCAL_FILE="$HOME/Pictures/proofs/$weekday-$week_number/$filename"  # Replace this with your desired path
    sleep 0.25
    grim -g "$(slurp)" "$LOCAL_FILE"
    sleep 0.25

else
    hyprctl notify 0 5000 'rgb(43c175)' "Started upload of file $1"
    LOCAL_FILE="$1"
fi


if ! rclone lsd "$REMOTE"; then
    hyprctl notify 0 5000 'rgb(43c175)' "  Remote dir '$REMOTE' does not exist! Creating new one!"
    echo "Folder '$REMOTE' does not exist. Creating now..."
    rclone mkdir "$REMOTE"
fi

# Upload the data to Google Drive
rclone copy "$LOCAL_FILE" "$REMOTE" --progress

file_count=$(rclone ls "$REMOTE" | wc -l)
hyprctl notify 0 5000 'rgb(43c175)' "Uploaded $file_count files to that remote directory ($REMOTE)"

