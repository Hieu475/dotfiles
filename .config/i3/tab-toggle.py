#!/usr/bin/python3
"""Toggle the current workspace between tiles and one row of tabs.

Tiles -> tabs: every tiled window of the workspace becomes a tab in a single
tabbed container (title bars on top show what is open). The window you were on
stays focused.
Tabs -> tiles: the workspace goes back to side-by-side tiling; autotiling takes
over again for new windows.

Floating windows are not touched.

Implementation notes
- Windows are gathered with 'move container to mark', not by moving them through
  another workspace: with workspace_auto_back_and_forth a move to the *current*
  workspace is turned into "go back to the previous one".
- autotiling.py is paused (flag file) while windows are rearranged, otherwise it
  keeps splitting them.
"""
import os

import i3ipc

MARK = "_tabroot"
PAUSE_FILE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "i3-autotiling-pause")


def workspace_depth(con):
    """Number of 'focus parent' steps from a window up to its workspace."""
    depth = 0
    node = con
    while node.parent is not None and node.type != "workspace":
        node = node.parent
        depth += 1
    return depth


def main():
    i3 = i3ipc.Connection()
    focused = i3.get_tree().find_focused()
    if focused is None:
        return
    ws = focused.workspace()
    if ws is None:
        return

    leaves = [c for c in ws.leaves() if c.window and c.floating not in ("auto_on", "user_on")]
    if len(leaves) < 2:
        return

    # Already one row of tabs? (all windows share one tabbed parent)
    parent = focused.parent
    already_tabs = (
        parent is not None
        and parent.layout == "tabbed"
        and all(c.parent.id == parent.id for c in leaves)
    )

    open(PAUSE_FILE, "w").close()
    try:
        if already_tabs:
            # tabs -> tiles: switch the shared tabbed parent back to side-by-side
            i3.command(f"[con_id={focused.id}] focus")
            i3.command("layout splith")
            return

        # tiles -> tabs: first make every window a direct child of the workspace ...
        for _ in range(workspace_depth(focused)):
            i3.command("focus parent")
        i3.command(f"mark --add {MARK}")
        for leaf in leaves:
            i3.command(f"[con_id={leaf.id}] move container to mark {MARK}")
        i3.command(f"unmark {MARK}")
        # ... then switch their parent (the workspace) to tabbed
        i3.command(f"[con_id={focused.id}] focus")
        i3.command("layout tabbed")
    finally:
        try:
            os.remove(PAUSE_FILE)
        except OSError:
            pass


if __name__ == "__main__":
    main()
