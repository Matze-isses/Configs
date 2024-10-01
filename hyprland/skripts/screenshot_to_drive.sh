#!/bin/bash

# Get current weekday and week number
weekday=$(date +%A)
week_number=$(date +"%V")

# Define options for the combobox
options=("Laufen" "Schreiben" "Ziele")

# Display combobox using rofi
selected_option=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "Select an option or enter your own:")

# If user cancels or closes the dialog
if [ -z "$selected_option" ]; then
    echo "No option selected. Exiting."
    exit 1
fi

# Prompt for number input, only digits allowed
number=$(rofi -dmenu -p "Please enter a number:")

# Validate that input is a number
while ! [[ "$number" =~ ^[0-9]+$ ]]; do
    rofi -e "Invalid input. Please enter a valid number."
    number=$(rofi -dmenu -p "Please enter a number:")
done

# Save the number locally (e.g., to a file)
echo "$number" > "$HOME/.saved_number"

# Set filename based on option and number
FILENAME="${selected_option}_${number}.png"

# Define paths
REMOTE="remote:/Ziele/Nachweise/Matthis/Week-$week_number/$weekday/"
LOCAL_DIR="$HOME/Pictures/proofs/$weekday-$week_number/"
LOCAL_FILE="${LOCAL_DIR}${FILENAME}"

# Create local directory if it doesn't exist
mkdir -p "$LOCAL_DIR"

# Take screenshot
sleep 0.25
grim -g "$(slurp)" "$LOCAL_FILE"
sleep 0.25

# Notify user about the upload attempt
hyprctl notify 0 5000 'rgb(43c175)' "Uploading screenshot ($FILENAME) to remote $REMOTE"

if ! rclone lsd "$REMOTE" >/dev/null 2>&1; then
    hyprctl notify 0 5000 'rgb(43c175)' "Remote directory '$REMOTE' does not exist. Creating it now."
    echo "Folder '$REMOTE' does not exist. Creating now..."
    rclone mkdir "$REMOTE" --progress
fi

# Upload the screenshot to Google Drive, overwrite if exists
rclone copy "$LOCAL_FILE" "$REMOTE" --progress

# Check if the upload was successful
if [ $? -eq 0 ]; then
    # Get the number of files in the remote directory
    file_count=$(rclone ls "$REMOTE" | wc -l)
    hyprctl notify 0 5000 'rgb(43c175)' "Successfully uploaded '$FILENAME' to $REMOTE (Total files: $file_count)"
else
    hyprctl notify 0 5000 'rgb(FF0000)' "Failed to upload '$FILENAME' to $REMOTE"
    echo "Error: Failed to upload '$FILENAME' to '$REMOTE'"
    exit 1
fi

# Call the Python script to update the JSON file
# Ensure conda is initialized
eval "$(conda shell.bash hook)"

# Run the Python script within the 'default' conda environment
conda run -n default python3 "$HOME/configs/update_week_data.py" "$selected_option" "$number"

# Check if the Python script executed successfully
if [ $? -eq 0 ]; then
    hyprctl notify 0 2000 'rgb(43c175)' "Updated week data with $selected_option: $number"
else
    hyprctl notify 0 5000 'rgb(FF0000)' "Failed to update week data with $selected_option: $number"
    echo "Error: Failed to update week data."
    exit 1
fi

rclone copy "/home/admin/data/goals/Summary.md" "remote:/Ziele/Nachweise/Matthis/Week-$week_number/" --progress --ignore-times --no-update-modtime

hyprctl notify 2 2000 'rgb(61ff05)' "Updated the Summary!"

