#!/bin/sh
# Lay out displays left to right: every external output (HDMI, DP, USB-C...) first,
# then the laptop panel (eDP*) as the rightmost, primary screen.
#   [ external ][ laptop ]
# Outputs that are unplugged but still configured get switched off.
# To put the external screen on the right instead, see the "RIGHT" note below.

internal=$(xrandr --query | awk '$1 ~ /^eDP/ && $2 == "connected" {print $1; exit}')
[ -n "$internal" ] || exit 0

# 1) A known external monitor (saved with flip-monitor.sh or `autorandr --save NAME`):
#    autorandr recognises it by its EDID and restores the layout you chose for it.
profile=$(autorandr --detect 2>/dev/null | head -n 1)
if [ -n "$profile" ] && [ "$profile" != "laptop" ]; then
    autorandr --load "$profile" >/dev/null 2>&1 && exit 0
fi

# 2) Unknown monitor (or none): default layout, external screens on the left.

args=""
prev=""
for out in $(xrandr --query | awk -v i="$internal" '$2 == "connected" && $1 != i {print $1}'); do
    if [ -z "$prev" ]; then
        args="$args --output $out --auto --pos 0x0"
    else
        args="$args --output $out --auto --right-of $prev"
    fi
    prev=$out
done

if [ -n "$prev" ]; then
    args="$args --output $internal --primary --auto --right-of $prev"
else
    args="--output $internal --primary --auto --pos 0x0"
fi

for out in $(xrandr --query | awk '$2 == "disconnected" && $3 ~ /^[0-9]+x[0-9]+\+/ {print $1}'); do
    args="$args --output $out --off"
done

# RIGHT: to put external screens on the right of the laptop, replace the whole block above
# with: --output $internal --primary --auto --pos 0x0, then each external --right-of the previous one.

# shellcheck disable=SC2086
xrandr $args
