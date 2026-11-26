#!/bin/bash
# Date and time. Left click: calendar.
. "$(dirname "$0")/lib.sh"
[ "$BLOCK_BUTTON" = "1" ] && { zenity --calendar --title="Lịch" >/dev/null 2>&1 & }
d=$(date '+%a %d/%m')
t=$(date '+%H:%M')
printf '%s %s\n' "$(pill "$ICON_CAL" "$d" date)" "$(pill "$ICON_CLOCK" "$t" time)"
