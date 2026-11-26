#!/bin/sh
# Show the keyboard cheatsheet in rofi. Type to filter (e.g. "workspace"), Esc or Enter to close.
exec rofi -dmenu -i -no-custom -p "keys" \
    -theme-str 'window { width: 780px; } listview { lines: 24; }' \
    < "$HOME/.config/i3/cheatsheet.txt" > /dev/null
