#!/bin/bash
# Open btop in a small floating window; run it again to close it.
# --confirm-close-surface=false: Ghostty would otherwise ask before closing a window that is
# running a program, and that made Super+Shift+q appear to do nothing.
if i3-msg -t get_tree | grep -q '"class":"dev.btop"'; then
    i3-msg '[class="dev.btop"] kill' >/dev/null
else
    ghostty --class=dev.btop --confirm-close-surface=false -e btop >/dev/null 2>&1 &
fi
