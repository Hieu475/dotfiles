#!/usr/bin/python3
"""Force-close the focused window (for a window that ignores a normal close).

Super+Shift+q asks the window to close politely; a program can refuse or show a
confirmation dialog. This cuts the window's connection to the X server instead,
which makes almost every program exit.
"""
import subprocess

import i3ipc


def main():
    focused = i3ipc.Connection().get_tree().find_focused()
    if focused is None or not focused.window:
        return
    subprocess.run(["xkill", "-id", str(focused.window)], check=False)


if __name__ == "__main__":
    main()
