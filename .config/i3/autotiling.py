#!/usr/bin/python3
"""i3 helper daemon: automatic split direction + focus history.

1. Autotiling (dwindle style): whenever focus changes or a window opens, the
   focused tiled window is split the way that suits its shape: wider than tall ->
   split horizontally (new window goes right), taller than wide -> split vertically
   (new window goes below). Floating, fullscreen, tabbed and stacked containers
   are left alone.
2. Focus history: the most recently focused windows are written to a small JSON
   file so focus-last.py (Alt+Tab) can jump back to the previous window.

Needs python3-i3ipc (apt). Started from ~/.config/i3/autostart.
"""
import json
import os
import tempfile

import i3ipc

HISTORY_FILE = os.environ.get("I3_FOCUS_HISTORY") or os.path.join(
    os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "i3-focus-history.json"
)
MAX_HISTORY = 40
# set by the manual split keys (Super+v, Super+Ctrl+h)
MANUAL_MARK = "_manual"
history = []


def save_history():
    try:
        fd, tmp = tempfile.mkstemp(dir=os.path.dirname(HISTORY_FILE))
        with os.fdopen(fd, "w") as f:
            json.dump(history, f)
        os.replace(tmp, HISTORY_FILE)
    except OSError:
        pass


def on_focus(i3, event):
    cid = event.container.id
    if cid in history:
        history.remove(cid)
    history.insert(0, cid)
    del history[MAX_HISTORY:]
    save_history()
    adjust(i3)


def on_new(i3, event):
    """A window that opens inside the manually split container uses up the manual choice."""
    try:
        # i3 reports 'focus' before 'new', so the new window may already be wrapped in a
        # container of its own: look anywhere below the marked window's parent.
        for marked in i3.get_tree().find_marked(f"^{MANUAL_MARK}$"):
            new_id = event.container.id
            if marked.id != new_id and marked.parent is not None:
                if any(c.id == new_id for c in marked.parent.descendants()):
                    i3.command(f"unmark {MANUAL_MARK}")
    except Exception:
        pass
    adjust(i3)


def on_close(i3, event):
    cid = event.container.id
    if cid in history:
        history.remove(cid)
        save_history()


PAUSE_FILE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "i3-autotiling-pause")


def paused():
    """tab-toggle.py creates this file while it rearranges windows."""
    try:
        import time
        return time.time() - os.path.getmtime(PAUSE_FILE) < 10
    except OSError:
        return False


def adjust(i3, _event=None):
    if paused():
        return
    try:
        con = i3.get_tree().find_focused()
        if con is not None and MANUAL_MARK in con.marks:
            return  # the user chose the split direction for this window; keep it
        if con is None or con.floating in ("auto_on", "user_on"):
            return
        if con.fullscreen_mode:
            return
        parent = con.parent
        if parent is None or parent.layout in ("stacked", "tabbed"):
            return

        want = "vertical" if con.rect.height > con.rect.width else "horizontal"
        if parent.orientation != want:
            i3.command("split v" if want == "vertical" else "split h")
    except Exception:
        # never let a transient error (window closed mid-query) kill the daemon
        pass


def main():
    i3 = i3ipc.Connection()
    i3.on("window::focus", on_focus)
    i3.on("window::close", on_close)
    i3.on("window::new", on_new)
    i3.on("window::move", adjust)
    i3.main()


if __name__ == "__main__":
    main()
