# Check the value of the first argument and perform actions based on it
case $1 in
    "d")
        hyprctl keyword input:kb_variant dvorak
        ;;
    "q")
        hyprctl keyword input:kb_variant querty
        ;;
esac
