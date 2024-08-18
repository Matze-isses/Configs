#!/bin/bash

folder="$HOME/Pictures/screenshots_uni"
mkdir -p "$folder"

timestamp=$(date +%Y%m%d%H%M%S)
filename="screenshot_$timestamp.png"
filepath="$folder/$filename"

# File to store persistent variables
vars_file="$HOME/.screenshot_vars"

# Load the variables from the file if it exists
if [ -f "$vars_file" ]; then
    source "$vars_file"
fi

case "$1" in
    d)
        grim -g "$(slurp)" - | tee "$filepath" | wl-copy
        sleep 0.5
        hyprctl dispatch movefocus r
        wtype -M ctrl V -s 100 -m ctrl

        sleep 0.5
        wtype -P tab -s 100 -p tab 

        sleep 0.5
        hyprctl dispatch movefocus l
        sleep 0.5
        ;;
    t)
        QUESTION="$(slurp)"
        echo "QUESTION='$QUESTION'" > "$vars_file"
        ;;
    b)
        ANSWERE="$(slurp)"
        echo "ANSWERE='$ANSWERE'" >> "$vars_file"
        ;;
    q) 
        grim -g "$(slurp)" - | tee "$filepath" | wl-copy
        sleep 0.5
        hyprctl dispatch movefocus r
        wtype -M ctrl V -s 100 -m ctrl
        sleep 0.25

        sleep 0.5
        hyprctl dispatch movefocus l
        sleep 0.5
        ;;
    a) 
        grim -g "$(slurp)" - | tee "$filepath" | wl-copy
        sleep 0.5
        hyprctl dispatch movefocus r
        wtype -M ctrl V -s 100 -m ctrl

        sleep 0.5
        wtype -P tab -s 100 -p tab 

        sleep 0.5
        hyprctl dispatch movefocus l
        sleep 0.5
        ;;
    n)
        grim -g "$QUESTION" - | tee "$filepath" | wl-copy

        sleep 0.5
        wtype -M ctrl V -s 100 -m ctrl
        wtype -P tab -s 100 -p tab 
        grim -g "$ANSWERE" - | tee "$filepath" | wl-copy

        sleep 0.5
        wtype -M ctrl V -s 100 -m ctrl

        sleep 0.2
        hyprctl dispatch movefocus l

        sleep 0.5
        wtype -P space -s 100 -p space

        sleep 0.5
        hyprctl dispatch movefocus r
        # wtype -M ctrl -P return -s 100 -m ctrl
    ;;
esac
