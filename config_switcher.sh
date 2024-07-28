#!/bin/bash

# Function to create a symlink, removing the old one if it exists
create_symlink() {
    # Remove the existing symlink if it exists
    [ -L "$2" ] && rm "$2"
    # Create a new symlink
    ln -s "$1" "$2"
}


case $1 in
    -c)
        create_symlink "$HOME/configs/hyprland/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
        create_symlink "$HOME/configs/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
        create_symlink "$HOME/configs/tofi/config" "$HOME/.config/tofi/config"
        ;;
    *)
        echo "Invalid option: Possibilities are: \n    -c ==> create"
        exit 1
        ;;
esac
