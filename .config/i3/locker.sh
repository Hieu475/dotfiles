#!/bin/sh
# Foreground locker (used by lock.sh and xss-lock).
# Black i3lock; when it is unlocked, wake the displays and re-detect the monitors,
# because an HDMI screen can come back without a picture after being switched off.
i3lock -c 000000 -e -f --nofork
xset dpms force on
"$HOME/.config/i3/monitor-setup.sh"
