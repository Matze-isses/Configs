
#!/bin/bash
folder="$HOME/Pictures/screenshots"
mkdir -p "$folder"
timestamp=$(date +%Y%m%d%H%M%S)
filename="screenshot_$timestamp.png"
filepath="$folder/$filename"

grim -g "$(slurp -d)" - | tee "$filepath" | wl-copy
