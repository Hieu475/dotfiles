# shared helpers for the i3blocks scripts: rounded 'pill' look
ICON_KB=""
ICON_WIFI=""
ICON_CPU=""
ICON_RAM=""
ICON_VOL=""
ICON_MUTE=""
ICON_B100=""
ICON_B75=""
ICON_B50=""
ICON_B25=""
ICON_B0=""
ICON_BOLT=""
ICON_CAL=""
ICON_CLOCK=""
ICON_POWER=""
ICON_BELL=""
ICON_BELLOFF=""

# Theme: "color" = a soft accent colour per item, "mono" = grey pills. Change here or run
#   I3BLOCKS_THEME=mono i3blocks ...   (or write mono / color into ~/.config/i3blocks/theme)
THEME="${I3BLOCKS_THEME:-$(cat "$HOME/.config/i3blocks/theme" 2>/dev/null)}"
THEME="${THEME:-color}"

CAP_L=""
CAP_R=""

esc() { sed 's/&/\&amp;/g; s/</\&lt;/g'; }

# colour of an item
item_colour() {
    if [ "$THEME" = "mono" ]; then echo "#2a2a2a"; return; fi
    case "$1" in
        dnd)     echo "#b4befe" ;;   # lavender
        ime)     echo "#89dceb" ;;   # sky
        wifi)    echo "#a6e3a1" ;;   # green
        cpu)     echo "#f9e2af" ;;   # yellow
        ram)     echo "#fab387" ;;   # peach
        volume)  echo "#f5c2e7" ;;   # pink
        battery) echo "#94e2d5" ;;   # teal
        date)    echo "#89b4fa" ;;   # blue
        time)    echo "#74c7ec" ;;   # sapphire
        power)   echo "#cba6f7" ;;   # mauve
        *)       echo "#cdd6f4" ;;
    esac
}

# pill ICON TEXT NAME [alert]
#   rounded block: left cap, body, right cap. "alert" = red body (colour theme) or white (mono).
pill() {
    local icon="$1" text="$2" name="$3" alert="$4" bg fg ifg
    bg=$(item_colour "$name")
    if [ "$THEME" = "mono" ]; then fg="#ffffff"; ifg="#d4d4d4"; else fg="#11111b"; ifg="#11111b"; fi
    if [ "$alert" = "alert" ]; then
        if [ "$THEME" = "mono" ]; then bg="#ffffff"; fg="#000000"; ifg="#000000"; else bg="#f38ba8"; fg="#11111b"; ifg="#11111b"; fi
    fi
    local body
    if [ -n "$text" ]; then body=" <span foreground=\"$ifg\">$icon</span>  $text "; else body=" <span foreground=\"$ifg\">$icon</span> "; fi
    printf '<span foreground="%s">%s</span><span background="%s" foreground="%s">%s</span><span foreground="%s">%s</span>\n' \
        "$bg" "$CAP_L" "$bg" "$fg" "$body" "$bg" "$CAP_R"
}
