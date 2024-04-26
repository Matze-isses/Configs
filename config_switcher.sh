#!/bin/bash

# Function to create a symlink, removing the old one if it exists
create_symlink() {
    # Remove the existing symlink if it exists
    [ -L "$2" ] && rm "$2"
    # Create a new symlink
    ln -s "$1" "$2"
}


case $1 in
    -h)
        read -p "-> Possibilities: (1: [PC] | 2: Laptop): " user_input
        case $user_input in
            "PC")
                create_symlink "$HOME/configs/hyprland/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
                create_symlink "$HOME/configs/hyprland/hyprpaper.conf" "$HOME/.config/hypr/hyprpaper.conf"
                ;;
            "1")
                create_symlink "$HOME/configs/hyprland/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
                create_symlink "$HOME/configs/hyprland/hyprpaper.conf" "$HOME/.config/hypr/hyprpaper.conf"
                ;;
            "Laptop")
                create_symlink "$HOME/configs/hyprland/hyprland_laptop.conf" "$HOME/.config/hypr/hyprland.conf"
                create_symlink "$HOME/configs/hyprland/hyprpaper_laptop.conf" "$HOME/.config/hypr/hyprpaper.conf"
                ;;
            "2")
                create_symlink "$HOME/configs/hyprland/hyprland_laptop.conf" "$HOME/.config/hypr/hyprland.conf"
                create_symlink "$HOME/configs/hyprland/hyprpaper_laptop.conf" "$HOME/.config/hypr/hyprpaper.conf"
                ;;
            *)
                create_symlink "$HOME/configs/hyprland/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
                create_symlink "$HOME/configs/hyprland/hyprpaper.conf" "$HOME/.config/hypr/hyprpaper.conf"
                ;;
        esac
        ;;
    -a)
        read -p "-> Possibilities: (1: [PC] | 2: Laptop): " user_input
        case $user_input in
            "PC")
                create_symlink "$HOME/configs/hyprland/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
                create_symlink "$HOME/configs/hyprland/hyprpaper.conf" "$HOME/.config/hypr/hyprpaper.conf"
                create_symlink "$HOME/configs/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
                create_symlink "$HOME/configs/tofi/config" "$HOME/.config/tofi/config"
                ;;
            "1")
                create_symlink "$HOME/configs/hyprland/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
                create_symlink "$HOME/configs/hyprland/hyprpaper.conf" "$HOME/.config/hypr/hyprpaper.conf"
                create_symlink "$HOME/configs/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
                create_symlink "$HOME/configs/tofi/config" "$HOME/.config/tofi/config"
                ;;
            "Laptop")
                create_symlink "$HOME/configs/hyprland/hyprland_laptop.conf" "$HOME/.config/hypr/hyprland.conf"
                create_symlink "$HOME/configs/hyprland/hyprpaper_laptop.conf" "$HOME/.config/hypr/hyprpaper.conf"
                create_symlink "$HOME/configs/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
                create_symlink "$HOME/configs/tofi/config" "$HOME/.config/tofi/config"
                ;;
            "2")
                create_symlink "$HOME/configs/hyprland/hyprland_laptop.conf" "$HOME/.config/hypr/hyprland.conf"
                create_symlink "$HOME/configs/hyprland/hyprpaper_laptop.conf" "$HOME/.config/hypr/hyprpaper.conf"
                create_symlink "$HOME/configs/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
                create_symlink "$HOME/configs/tofi/config" "$HOME/.config/tofi/config"
                ;;
            *)
                create_symlink "$HOME/configs/hyprland/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
                create_symlink "$HOME/configs/hyprland/hyprpaper.conf" "$HOME/.config/hypr/hyprpaper.conf"
                create_symlink "$HOME/configs/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
                create_symlink "$HOME/configs/tofi/config" "$HOME/.config/tofi/config"
                ;;
        esac
        ;;
    *)
        echo "Invalid option: $OPTARG" 1>&2
        exit 1
        ;;
esac
