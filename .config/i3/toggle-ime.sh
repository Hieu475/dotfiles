#!/bin/sh
# Toggle between English (US) and Vietnamese (Bamboo) with ibus.
# Starts the ibus daemon first if it is not running.
if ! pgrep -x ibus-daemon >/dev/null; then
    ibus-daemon -drx
    sleep 1
fi

if [ "$(ibus engine 2>/dev/null)" = "Bamboo" ]; then
    ibus engine xkb:us::eng
else
    ibus engine Bamboo
fi

# refresh the VI/EN item on the bar right away
pkill -RTMIN+12 -x i3blocks 2>/dev/null || true
