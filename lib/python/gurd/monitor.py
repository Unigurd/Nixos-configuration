import subprocess

from gurd.xrandr import parse_xrandr

raw_xrandr = subprocess.run(["xrandr", "--verbose"], capture_output=True).stdout.decode(
    "utf-8"
)
xrandr = parse_xrandr(raw_xrandr)


displays = []

for screen in xrandr.values():
    displays += screen.displays.values()


home_monitor = None
laptop_monitor = None

for display in displays:
    if display.name == "eDP-1":
        laptop_monitor = display

    if (
        display.connected
        and display.name != "eDP-1"
        and display.edid is not None
        and display.edid.product_id == 36361
    ):
        home_monitor = display


def same_as_default_display(monitor):
    return ["--output", monitor.name, "--auto", "--same-as", "eDP-1"]


def monitor_configuration_is_active(laptop_monitor, home_monitor):
    return (
        (laptop_monitor.width == 1920)
        and (laptop_monitor.height == 1080)
        and (laptop_monitor.posx == 1600)
        and (laptop_monitor.posy == 1440)
        and (home_monitor.width == 5120)
        and (home_monitor.height == 1440)
        and (home_monitor.posx == 0)
        and (home_monitor.posy == 0)
    )


if home_monitor is None:
    call = [
        "xrandr",
        "--output",
        "eDP-1",
        "--auto",
    ] + [
        x
        for display in displays
        for x in same_as_default_display(display)
        if display.name != "eDP-1"
    ]

else:
    call = (
        "xrandr",
        "--fb",
        "5120x2520",
        "--output",
        home_monitor.name,
        "--mode",
        "5120x1440",
        "--pos",
        "0x0",
        "--output",
        "eDP-1",
        "--auto",
        "--pos",
        "1600x1440",
    )

print(call)
subprocess.run(call)
