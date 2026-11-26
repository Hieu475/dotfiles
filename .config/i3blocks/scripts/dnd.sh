#!/bin/bash
# Do Not Disturb for notifications. Left click: toggle.
. "$(dirname "$0")/lib.sh"
if [ "$BLOCK_BUTTON" = "1" ]; then "$HOME/.config/i3/notify-dnd.sh"; sleep 2.5; fi
if [ "$(xfconf-query -c xfce4-notifyd -p /do-not-disturb 2>/dev/null)" = "true" ]; then
    pill "$ICON_BELLOFF" "off" dnd alert
else
    pill "$ICON_BELL" "on" dnd
fi
