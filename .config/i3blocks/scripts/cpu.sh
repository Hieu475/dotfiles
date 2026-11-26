#!/bin/bash
# CPU load. Left click: open btop in a floating window (click again to close).
. "$(dirname "$0")/lib.sh"
[ "$BLOCK_BUTTON" = "1" ] && { "$HOME/.config/i3blocks/scripts/open-btop.sh" & }
a=($(head -n 1 /proc/stat)); sleep 0.4; b=($(head -n 1 /proc/stat))
ta=0; tb=0
for v in "${a[@]:1:8}"; do ta=$((ta + v)); done
for v in "${b[@]:1:8}"; do tb=$((tb + v)); done
ia=$((a[4] + a[5])); ib=$((b[4] + b[5]))
dt=$((tb - ta)); [ "$dt" -le 0 ] && dt=1
pct=$(( 100 * (dt - (ib - ia)) / dt ))
if [ "$pct" -ge 90 ]; then pill "$ICON_CPU" "CPU ${pct}%" cpu alert; else pill "$ICON_CPU" "CPU ${pct}%" cpu; fi
