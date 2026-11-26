#!/bin/sh
# Lock the screen (black) and switch the displays off right away.
# Any key press or mouse move wakes the screen, which then asks for your password.
# (i3lock alone only paints the screen black; it does not turn the backlight off.)
if ! pgrep -x i3lock >/dev/null; then
    "$HOME/.config/i3/locker.sh" &
fi
sleep 1
xset dpms force off
