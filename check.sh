#!/bin/sh
# Check the config in this repository before using it:
# i3 syntax (i3 -C), shell scripts, Python files. Exit status 0 = everything passed.
# Limit: i3 -C does not check the command text after 'bindsym' (a wrong command there
# only shows an error when the key is pressed).
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

for f in .config/i3/*.sh .config/i3blocks/scripts/*.sh; do
    case $(head -n 1 "$f") in
        *bash*) shell=bash ;;
        *)      shell=sh ;;
    esac
    if ! "$shell" -n "$f"; then echo "FAIL  $f"; fail=1; fi
done
echo "ok    shell scripts checked"

for f in .config/i3/*.py; do
    if ! python3 -c 'import ast, sys; ast.parse(open(sys.argv[1], encoding="utf-8").read(), sys.argv[1])' "$f"; then
        echo "FAIL  $f"; fail=1
    fi
done
echo "ok    python files checked"

if [ "$fail" -eq 0 ]; then echo "ALL CHECKS PASSED"; else echo "SOME CHECKS FAILED"; fi
exit "$fail"
