#!/bin/bash
# Wi-Fi. Left click: network settings. Right click: wifi on/off.
. "$(dirname "$0")/lib.sh"
case "$BLOCK_BUTTON" in
    1) nm-connection-editor >/dev/null 2>&1 & ;;
    3) if [ "$(nmcli radio wifi)" = "enabled" ]; then nmcli radio wifi off; else nmcli radio wifi on; fi; sleep 1 ;;
esac
if [ "$(nmcli radio wifi)" != "enabled" ]; then pill "$ICON_WIFI" "off" wifi alert; exit 0; fi
line=$(nmcli -t -f IN-USE,SIGNAL,SSID dev wifi list --rescan no 2>/dev/null | grep '^\*' | head -n 1)
if [ -n "$line" ]; then
    sig=$(echo "$line" | cut -d: -f2)
    ssid=$(echo "$line" | cut -d: -f3- | cut -c1-14 | esc)
    pill "$ICON_WIFI" "$ssid  ${sig}%" wifi
elif nmcli -t -f TYPE,STATE dev 2>/dev/null | grep -q '^ethernet:connected'; then
    pill "LAN" "online" wifi
else
    pill "$ICON_WIFI" "no link" wifi alert
fi
