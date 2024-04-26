#!/bin/bash


# Check if no arguments are provided
if [ $# -eq 0 ]; then
    echo "No input was provided. Please provide an input. ( OPTIONS: gray / blue_red )"
  exit 1
fi


# Check the value of the first argument and perform actions based on it
case $1 in
  "gray")
    hyprctl hyprpaper wallpaper "DP-1, /home/admin/WallPapers/gray_tower.png"
    hyprctl hyprpaper wallpaper "HDMI-A-1, /home/admin/WallPapers/left_gray_tower.png"
    ;;
  "grayer")
    hyprctl hyprpaper wallpaper "DP-1, /home/admin/WallPapers/gray_tower.png"
    hyprctl hyprpaper wallpaper "HDMI-A-1, /home/admin/WallPapers/left_gray_tower.png"
    ;;
  "blue_red")
    hyprctl hyprpaper wallpaper "DP-1, /home/admin/WallPapers/redblue.png"
    hyprctl hyprpaper wallpaper "HDMI-A-1, /home/admin/WallPapers/blue_red.png"
    ;;
  "red_blue")
    hyprctl hyprpaper wallpaper "DP-1, /home/admin/WallPapers/silent.png"
    hyprctl hyprpaper wallpaper "HDMI-A-1, /home/admin/WallPapers/less_but_good_project.png"
    ;;
  *)
    hyprctl hyprpaper wallpaper "DP-1, /home/admin/WallPapers/redblue.png"
    hyprctl hyprpaper wallpaper "HDMI-A-1, /home/admin/WallPapers/blue_red.png"
    ;;
esac

