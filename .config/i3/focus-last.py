#!/usr/bin/python3
"""Jump back to the previously focused window (like Alt+Tab on other systems).

Reads the focus history written by autotiling.py. Pressing it repeatedly toggles
between the last two windows, even across workspaces and monitors.
"""
import json
import os

import i3ipc

HISTORY_FILE = os.environ.get("I3_FOCUS_HISTORY") or os.path.join(
    os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "i3-focus-history.json"
)


def main():
    try:
        with open(HISTORY_FILE) as f:
            history = json.load(f)
    except (OSError, ValueError):
        return

    i3 = i3ipc.Connection()
    tree = i3.get_tree()
    current = tree.find_focused()
    current_id = current.id if current else None
    alive = {c.id for c in tree.leaves() if c.window}

    for cid in history:
        if cid != current_id and cid in alive:
            i3.command(f"[con_id={cid}] focus")
            return


if __name__ == "__main__":
    main()
