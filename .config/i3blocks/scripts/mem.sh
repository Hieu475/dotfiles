#!/bin/bash
# Memory in use. Left click: open btop in a floating window (click again to close).
. "$(dirname "$0")/lib.sh"
[ "$BLOCK_BUTTON" = "1" ] && { "$HOME/.config/i3blocks/scripts/open-btop.sh" & }
read -r used total <<< "$(free -m | awk 'NR==2{printf "%.1f %.0f", $3/1024, $2/1024}')"
pct=$(free -m | awk 'NR==2{printf "%d", $3*100/$2}')
if [ "$pct" -ge 88 ]; then pill "$ICON_RAM" "RAM ${used}/${total}G" ram alert; else pill "$ICON_RAM" "RAM ${used}/${total}G" ram; fi
