#!/bin/bash
# Battery. Left click: power settings.
. "$(dirname "$0")/lib.sh"
[ "$BLOCK_BUTTON" = "1" ] && { xfce4-power-manager-settings >/dev/null 2>&1 & }
bat=$(ls /sys/class/power_supply | grep '^BAT' | head -n 1)
[ -z "$bat" ] && exit 0
cap=$(cat /sys/class/power_supply/$bat/capacity)
st=$(cat /sys/class/power_supply/$bat/status)
if   [ "$cap" -ge 88 ]; then ic="$ICON_B100"
elif [ "$cap" -ge 63 ]; then ic="$ICON_B75"
elif [ "$cap" -ge 38 ]; then ic="$ICON_B50"
elif [ "$cap" -ge 13 ]; then ic="$ICON_B25"
else ic="$ICON_B0"; fi
[ "$st" = "Charging" ] && ic="$ICON_BOLT"
if [ "$st" = "Discharging" ] && [ "$cap" -le 20 ]; then pill "$ic" "${cap}%" battery alert; else pill "$ic" "${cap}%" battery; fi
