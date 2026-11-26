#!/bin/sh
# Power menu in rofi. Destructive choices ask for a second confirmation (default: No).
ROFI="rofi -dmenu -i -no-custom"

confirm() {
    answer=$(printf 'Không\nCó\n' | $ROFI -p "$1?" -theme-str 'window { width: 280px; } listview { lines: 2; }')
    [ "$answer" = "Có" ]
}

choice=$(printf '%s\n' "Khóa màn hình" "Đăng xuất" "Ngủ" "Khởi động lại" "Tắt máy" \
    | $ROFI -p "power" -theme-str 'window { width: 320px; } listview { lines: 5; }')

case "$choice" in
    "Khóa màn hình") "$HOME/.config/i3/lock.sh" ;;
    "Đăng xuất")     confirm "Đăng xuất" && i3-msg exit ;;
    "Ngủ")           systemctl suspend ;;
    "Khởi động lại") confirm "Khởi động lại" && systemctl reboot ;;
    "Tắt máy")       confirm "Tắt máy" && systemctl poweroff ;;
esac
