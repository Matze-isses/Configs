file="$HOME/.is_laptop"

# Check if the file exists and has the content 'true'
if [[ -f "$file" ]] && grep -qx 'true' "$file"; then
    # Change the keyboard layout to Dvorak
    setxkbmap dvorak
fi
