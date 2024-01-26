source /etc/environment

./change_conf_util.sh "/home/admin/own_configs/kitty/kitty.conf" " " "cursor" "$COLOR_foreground"
./change_conf_util.sh "/home/admin/own_configs/kitty/kitty.conf" " " "foreground" "$COLOR_sub_foreground"
./change_conf_util.sh "/home/admin/own_configs/kitty/kitty.conf" " " "background" "$COLOR_transparency_background"
./change_conf_util.sh "/home/admin/own_configs/kitty/kitty.conf" " " "background_opacity" "$THEME_transparency"
./change_conf_util.sh "/home/admin/own_configs/kitty/kitty.conf" " " "font_size" "$THEME_font_size_m"

