#!/bin/bash
# Volume. Left click: mute. Right click: mixer. Scroll: +/- 5%.
. "$(dirname "$0")/lib.sh"
case "$BLOCK_BUTTON" in
    1) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
    3) pavucontrol >/dev/null 2>&1 & ;;
    4) pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
    5) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
esac
vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -o '[0-9]*%' | head -n 1 | tr -d '%')
[ -z "$vol" ] && vol=0
[ "$vol" -gt 100 ] && { pactl set-sink-volume @DEFAULT_SINK@ 100%; vol=100; }
if [ "$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')" = "yes" ]; then
    pill "$ICON_MUTE" "muted" volume alert
else
    pill "$ICON_VOL" "${vol}%" volume
fi
