#!/bin/bash

# Function to "correct" the input
correct_input() {
  case $1 in
    "gray"|"gr"|"g")
      echo "gray"
      ;;
    "blue_red"|"blue"|"bl"|"b"|"re"|"r")
      echo "blue_red"
      ;;
    *)
      echo ""
      ;;
  esac
}

# Check if no arguments are provided
if [ $# -eq 0 ]; then
    echo "No input was provided. Please provide an input. ( OPTIONS: gray / blue_red )"
  exit 1
fi

# Attempt to correct the input
corrected_input=$(correct_input $1)

if [ -z "$corrected_input" ]; then
  echo "Unknown input. Please use either 'action1' or 'action2'."
  exit 1
fi

# Check the value of the first argument and perform actions based on it
case $1 in
  "gray")
    hyprctl hyprpaper wallpaper "DP-1, /home/admin/WallPapers/gray_tower.png"
    hyprctl hyprpaper wallpaper "HDMI-A-1, /home/admin/WallPapers/left_gray_tower.png"
    ;;
  "blue_red")
    hyprctl hyprpaper wallpaper "DP-1, /home/admin/WallPapers/redblue.png"
    hyprctl hyprpaper wallpaper "HDMI-A-1, /home/admin/WallPapers/blue_red.png"
    ;;
  *)
    hyprctl hyprpaper wallpaper "DP-1, /home/admin/WallPapers/redblue.png"
    hyprctl hyprpaper wallpaper "HDMI-A-1, /home/admin/WallPapers/blue_red.png"
    ;;
esac

