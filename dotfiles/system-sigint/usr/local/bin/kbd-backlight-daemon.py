#!/usr/bin/env python3
"""Keyboard backlight auto-dim daemon (sigint / Asahi MacBook Air).

Brightens the keyboard backlight on keypress, dims it gradually after an
idle timeout. Runs as root: writes sysfs directly, reads evdev directly,
no external deps.
"""
import os
import select
import struct
import sys
import time

BRIGHTNESS = "/sys/class/leds/kbd_backlight/brightness"
IDLE_LEVEL = 5
ACTIVE_LEVEL = 26
TIMEOUT = 10.0
DIM_STEPS = 8
DIM_DURATION = 0.8

EV_KEY = 1
EVENT_FMT = "@llHHi"
EVENT_SIZE = struct.calcsize(EVENT_FMT)


def find_keyboard():
    for n in os.listdir("/sys/class/input"):
        if not n.startswith("event"):
            continue
        try:
            with open(f"/sys/class/input/{n}/device/name") as f:
                if "keyboard" in f.read().lower():
                    return f"/dev/input/{n}"
        except OSError:
            pass
    return None


def set_brightness(value):
    try:
        with open(BRIGHTNESS, "w") as f:
            f.write(str(value))
    except OSError as e:
        print(f"kbd-backlight: {e}", file=sys.stderr, flush=True)


def key_pressed(fd):
    """Return True if any key-press event is pending on fd."""
    while True:
        try:
            data = os.read(fd, 4096)
        except BlockingIOError:
            break
        if not data:
            break
        for off in range(0, len(data), EVENT_SIZE):
            _t1, _t2, etype, _code, value = struct.unpack_from(EVENT_FMT, data, off)
            if etype == EV_KEY and value:
                return True
    return False


def dim(fd, from_level, to_level):
    """Gradually dim from from_level to to_level. Return True if interrupted."""
    step_delay = DIM_DURATION / DIM_STEPS
    for i in range(1, DIM_STEPS + 1):
        level = from_level + int((to_level - from_level) * i / DIM_STEPS)
        set_brightness(level)
        ready, _, _ = select.select([fd], [], [], step_delay)
        if ready and key_pressed(fd):
            return True
    set_brightness(to_level)
    return False


def main():
    dev = find_keyboard()
    if not dev:
        print("kbd-backlight: no keyboard input device found", file=sys.stderr)
        return 1

    fd = os.open(dev, os.O_RDONLY | os.O_NONBLOCK)
    set_brightness(IDLE_LEVEL)
    lit = False
    last_key = time.monotonic()

    while True:
        now = time.monotonic()
        timeout = (TIMEOUT - (now - last_key)) if lit else None

        ready, _, _ = select.select([fd], [], [], timeout)
        if not ready:
            if dim(fd, ACTIVE_LEVEL, IDLE_LEVEL):
                last_key = time.monotonic()
                set_brightness(ACTIVE_LEVEL)
                lit = True
            else:
                lit = False
            continue

        if key_pressed(fd):
            last_key = time.monotonic()
            if not lit:
                set_brightness(ACTIVE_LEVEL)
                lit = True


if __name__ == "__main__":
    sys.exit(main())
