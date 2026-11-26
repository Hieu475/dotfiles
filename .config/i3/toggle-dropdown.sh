#!/bin/sh
# Dropdown terminal: start it on first use, then just show/hide it.
# The window is matched by its class (dev.dropdown); see the for_window rule in the i3 config.
if ! command -v ghostty >/dev/null 2>&1; then
    notify-send "Dropdown terminal" "ghostty not found in PATH"
    exit 1
fi

if i3-msg -t get_tree | grep -q '"class":"dev.dropdown"'; then
    i3-msg '[class="dev.dropdown"] scratchpad show' >/dev/null
else
    ghostty --class=dev.dropdown >/dev/null 2>&1 &
fi
