#!/usr/bin/python3
"""Measure what the desktop layer costs: processes, memory and idle CPU.

Run it inside the i3 session, with the same applications open each time you compare:
    ./bench.py                 # 30 s CPU sample
    ./bench.py 60 > after.txt

Memory is PSS (shared pages split between the processes using them). Processes whose
PSS cannot be read (for example Xorg when it runs as root) are shown with RSS and
marked with '*'; RSS counts shared pages in full, so it reads higher.
Browser, editor and terminal memory is deliberately left out. Short-lived processes
(i3blocks scripts) are not counted in the CPU figure of their parent while running.
"""
import os
import sys
import time

NAMES = ("i3", "i3bar", "i3blocks", "Xorg", "picom", "ibus-daemon", "ibus-engine-bam", "ibus-x11",
         "ibus-ui-gtk3", "ibus-extension-", "copyq", "nm-applet", "pasystray", "xfce4-power-man",
         "xfce4-notifyd", "xss-lock", "polkit-gnome-au")
SCRIPTS = ("autotiling.py",)
TICKS = os.sysconf("SC_CLK_TCK")


def read(path):
    with open(path, "rb") as f:
        return f.read().decode(errors="replace")


def desktop_processes():
    found = {}
    for pid in filter(str.isdigit, os.listdir("/proc")):
        try:
            comm = read(f"/proc/{pid}/comm").strip()
            if comm.startswith("python"):
                args = read(f"/proc/{pid}/cmdline").split("\0")
                comm = next((s for s in SCRIPTS if any(a.endswith(s) for a in args[1:2])), None)
            elif comm not in NAMES:
                comm = None
            if comm:
                found[int(pid)] = comm
        except OSError:
            pass
    return found


def memory_kb(pid):
    """(kilobytes, True if PSS)"""
    try:
        for line in read(f"/proc/{pid}/smaps_rollup").splitlines():
            if line.startswith("Pss:"):
                return int(line.split()[1]), True
    except OSError:
        pass
    try:
        for line in read(f"/proc/{pid}/status").splitlines():
            if line.startswith("VmRSS:"):
                return int(line.split()[1]), False
    except OSError:
        pass
    return 0, False


def cpu_ticks(pid):
    """own CPU time plus that of finished child processes"""
    try:
        fields = read(f"/proc/{pid}/stat").rsplit(")", 1)[1].split()
        return sum(int(fields[i]) for i in (11, 12, 13, 14))
    except (OSError, IndexError, ValueError):
        return None


def main():
    seconds = float(sys.argv[1]) if len(sys.argv) > 1 else 30.0
    procs = desktop_processes()
    start = {pid: cpu_ticks(pid) for pid in procs}
    time.sleep(seconds)

    rows = {}
    for pid, name in procs.items():
        begin, end = start[pid], cpu_ticks(pid)
        if begin is None or end is None:
            continue
        kb, is_pss = memory_kb(pid)
        row = rows.setdefault(name, [0, 0, 0.0, True])
        row[0] += 1
        row[1] += kb
        row[2] += (end - begin) / TICKS / seconds * 100
        row[3] &= is_pss

    session = os.environ.get("XDG_CURRENT_DESKTOP", "?")
    print(f"session: {session} | CPU sample: {seconds:.0f} s | {time.strftime('%Y-%m-%d %H:%M')}")
    if "i3" not in rows:
        print("NOTE: i3 is not running here, so this does not describe the i3 desktop.")
    print(f"{'process':18}{'count':>6}{'MB':>9}{'CPU %':>8}")
    for name, (count, kb, cpu, is_pss) in sorted(rows.items(), key=lambda r: -r[1][1]):
        print(f"{name:18}{count:6}{kb / 1024:8.1f}{' ' if is_pss else '*'}{cpu:8.2f}")
    print(f"{'TOTAL':18}{sum(r[0] for r in rows.values()):6}{sum(r[1] for r in rows.values()) / 1024:8.1f} "
          f"{sum(r[2] for r in rows.values()):8.2f}")
    if any(not r[3] for r in rows.values()):
        print("* RSS (PSS not readable): includes shared memory in full")


if __name__ == "__main__":
    main()
