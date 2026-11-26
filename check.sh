#!/bin/sh
# Check the config in this repository before using it. Exit status 0 = everything passed.
#   - i3 syntax (i3 -C), shell and Python syntax
#   - every script that the i3 / i3blocks config refers to exists and is executable
#   - warns (does not fail) about programs the config needs that are not installed
# Limits: it does not press keys or talk to a running i3, and i3 -C does not check
# the command text after 'bindsym'.
cd "$(dirname "$0")" || exit 1
repo=$(pwd)
fail=0

# The i3 config includes files through ~, so point HOME at the repository to check
# the repository's files, not the ones already installed.
out=$(HOME="$repo" i3 -C -c "$repo/.config/i3/config" 2>&1)
status=$?
if [ "$status" -ne 0 ] || printf '%s\n' "$out" | grep -q 'ERROR'; then
    echo "FAIL  i3 config"
    printf '%s\n' "$out" | grep 'ERROR' | head -n 10
    fail=1
else
    echo "ok    i3 config"
fi

bad=0
for f in .config/i3/*.sh .config/i3blocks/scripts/*.sh ./*.sh; do
    case $(head -n 1 "$f") in
        *bash*) shell=bash ;;
        *)      shell=sh ;;
    esac
    if ! "$shell" -n "$f"; then echo "FAIL  $f"; bad=1; fi
done
if [ "$bad" -eq 0 ]; then echo "ok    shell syntax"; else fail=1; fi

bad=0
for f in .config/i3/*.py ./*.py; do
    if ! python3 -c 'import ast, sys; ast.parse(open(sys.argv[1], encoding="utf-8").read(), sys.argv[1])' "$f"; then
        echo "FAIL  $f"; bad=1
    fi
done
if [ "$bad" -eq 0 ]; then echo "ok    python syntax"; else fail=1; fi

# Scripts referenced as ~/.config/... or $HOME/.config/... (comment lines ignored)
bad=0
refs=$(cat .config/i3/autostart .config/i3/keybindings .config/i3/rules .config/i3/appearance \
           .config/i3blocks/config .config/i3/*.sh .config/i3blocks/scripts/*.sh \
       | grep -v '^[[:space:]]*#' \
       | grep -oE '(~|\$HOME)/\.config/[A-Za-z0-9_./-]+\.(sh|py)' \
       | sed -E 's#^(~|\$HOME)/##' | sort -u)
for r in $refs; do
    if [ ! -f "$r" ]; then echo "FAIL  referenced script is missing: $r"; bad=1
    # lib.sh is sourced, not executed
    elif [ ! -x "$r" ] && [ "${r##*/}" != "lib.sh" ]; then echo "FAIL  not executable: $r"; bad=1
    fi
done
if [ "$bad" -eq 0 ]; then echo "ok    referenced scripts ($(printf '%s\n' "$refs" | grep -c .))"; else fail=1; fi

missing=""
for c in i3 i3blocks i3lock xss-lock dex rofi picom autorandr xrandr xset xsetroot xinput xkill pactl nmcli \
         notify-send zenity brightnessctl xfconf-query xfce4-power-manager nm-applet ibus flameshot copyq \
         thunar ghostty btop; do
    command -v "$c" >/dev/null 2>&1 || missing="$missing $c"
done
if [ -n "$missing" ]; then echo "warn  not installed:$missing"; else echo "ok    programs installed"; fi

if [ "$fail" -eq 0 ]; then echo "ALL CHECKS PASSED"; else echo "SOME CHECKS FAILED"; fi
exit "$fail"
