#!/bin/bash
# Typing language. Left click: switch Vietnamese <-> English.
. "$(dirname "$0")/lib.sh"
if [ "$BLOCK_BUTTON" = "1" ]; then "$HOME/.config/i3/toggle-ime.sh"; sleep 0.4; fi
case "$(ibus engine 2>/dev/null)" in Bamboo*) t="VI" ;; *) t="EN" ;; esac
pill "$ICON_KB" "$t" ime
