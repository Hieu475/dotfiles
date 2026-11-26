#!/bin/sh
# (Re)start the autotiling daemon. Called with exec_always, so first stop any old copy.
pkill -f "$HOME/.config/i3/autotiling.py" 2>/dev/null
exec /usr/bin/python3 "$HOME/.config/i3/autotiling.py"
