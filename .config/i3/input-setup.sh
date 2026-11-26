#!/bin/sh
# Tap-to-click and natural scrolling on every touchpad, whatever its device name is.
xinput list --name-only | grep -i touchpad | while IFS= read -r name; do
    xinput set-prop "$name" "libinput Tapping Enabled" 1
    xinput set-prop "$name" "libinput Natural Scrolling Enabled" 1
done
