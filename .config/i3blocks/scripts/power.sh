#!/bin/bash
# Power menu. Left click: menu (lock / logout / sleep / reboot / shutdown). Right click: lock.
. "$(dirname "$0")/lib.sh"
case "$BLOCK_BUTTON" in
    1) "$HOME/.config/i3/powermenu.sh" >/dev/null 2>&1 & ;;
    3) "$HOME/.config/i3/lock.sh" >/dev/null 2>&1 & ;;
esac
pill "$ICON_POWER" "" power
