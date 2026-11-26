#!/bin/sh
# Toggle Do Not Disturb for xfce4-notifyd (replaces the old dunst pause key).
cur=$(xfconf-query -c xfce4-notifyd -p /do-not-disturb 2>/dev/null)
if [ "$cur" = "true" ]; then
    xfconf-query -c xfce4-notifyd -p /do-not-disturb -n -t bool -s false
    notify-send "Thông báo" "Đã bật lại thông báo"
else
    notify-send "Thông báo" "Chế độ Không làm phiền: BẬT"
    sleep 2
    xfconf-query -c xfce4-notifyd -p /do-not-disturb -n -t bool -s true
fi
