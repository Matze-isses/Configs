
#!/bin/bash
folder="$HOME/Pictures/screenshots"
mkdir -p "$folder"
timestamp=$(date +%Y%m%d%H%M%S)
filename="screenshot_$timestamp.png"
filepath="$folder/$filename"

grim -g "$(slurp)" "$filepath" && sleep 1 && xclip -selection clipboard -t image/png -i "$filepath"
