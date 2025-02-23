import argparse
import re
import subprocess
import sys

from gurd.xrandr import parse_xrandr

arg_regex = r"([+-]?)([0-9]+(?:\.[0-9]+)?)$"


def parse_brightness_modifier(string):
    match = re.match(arg_regex, string)
    mod = match[1]
    num = float(match[2])
    if mod == "":
        return lambda b: num
    elif mod == "+":
        return lambda b: b + num
    elif mod == "-":
        return lambda b: b - num
    else:
        raise Exception("Failed to parse input.")


min_brightness = 0.2

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("brightness", type=parse_brightness_modifier)
    brightness_modifier = args = parser.parse_args().brightness

    raw_xrandr = subprocess.run(
        ["xrandr", "--verbose"], capture_output=True
    ).stdout.decode("utf-8")
    xrandr = parse_xrandr(raw_xrandr)

    displays = []
    for screen in xrandr.values():
        displays += screen.displays.values()

    laptop_monitor = None
    for display in displays:
        if display.name == "eDP-1":
            laptop_monitor = display

    if laptop_monitor is None:
        print("Built-in laptop display eDP-1 not found.", file=sys.stderr)
        sys.exit(1)

    brightness = laptop_monitor.brightness

    if brightness is None:
        print(
            "Could not find brightness information about default display eDP-1",
            file=sys.stderr,
        )
        sys.exit(2)

    new_brightness = max(min_brightness, brightness_modifier(brightness))

    arguments = [
        string
        for display in displays
        if display.active
        for string in [
            "--output",
            display.name,
            "--brightness",
            str(new_brightness),
        ]
    ]

    if not arguments:
        print(
            "Error in building call to xrandr to change brightness.",
            file=sys.stderr,
        )
        sys.exit(2)

    call = ["xrandr"] + arguments

    print(call)
    subprocess.run(call)
