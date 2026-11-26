#!/bin/sh
# Put the external monitor on the other side of the laptop (left <-> right) and
# remember that choice for THIS monitor: it is saved as an autorandr profile named
# after the monitor's EDID, so the layout comes back by itself next time it is plugged in.
# Another monitor (e.g. at home) gets its own profile, so each place keeps its own layout.

int=$(xrandr --query | awk '$1 ~ /^eDP/ && $2 == "connected" {print $1; exit}')
ext=$(xrandr --query | awk '$1 !~ /^eDP/ && $2 == "connected" {print $1; exit}')

if [ -z "$int" ] || [ -z "$ext" ]; then
    notify-send "Màn hình" "Không thấy màn hình ngoài đang cắm"
    exit 0
fi

pos_x() {
    xrandr --listmonitors | awk -v o="$1" '$NF == o { split($3, a, "+"); print a[2]; exit }'
}
ext_x=$(pos_x "$ext")
int_x=$(pos_x "$int")

if [ "${ext_x:-0}" -lt "${int_x:-0}" ]; then
    # external is on the left now -> move it to the right
    xrandr --output "$int" --primary --auto --pos 0x0 --output "$ext" --auto --right-of "$int"
    side="bên phải"
else
    xrandr --output "$ext" --auto --pos 0x0 --output "$int" --primary --auto --right-of "$ext"
    side="bên trái"
fi

# profile name = short hash of this monitor's EDID line
sum=$(autorandr --fingerprint 2>/dev/null | grep -F "$ext " | md5sum | cut -c1-8)
name="ext-$sum"
autorandr --save "$name" --force >/dev/null 2>&1

notify-send "Màn hình ngoài: $side" "Đã lưu cho màn hình này (profile $name)"
