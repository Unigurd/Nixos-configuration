from pathlib import Path
import re
import sys
import subprocess
import os

capacity_percentage_threshold = int(
    os.environ.get("GURD_BATTERY_WARNING_CAPACITY_PERCENTAGE", 5)
)


def battery_capacity(battery):
    capacity = battery / "capacity"
    if not capacity.exists:
        return

    with open(capacity) as fd:
        return int(fd.read())


def battery_is_discharging(battery):
    status = battery / "status"
    if not status.exists:
        return

    with open(status) as fd:
        return fd.read() == "Discharging\n"


power_supply = Path("/sys/class/power_supply")

if __name__ == "__main__":
    if not power_supply.exists():
        sys.exit(1)

    batteries = [
        supply
        for supply in power_supply.iterdir()
        if re.match("BAT[0-9]+", supply.name)
    ]

    for battery in batteries:
        capacity = battery_capacity(battery)
        print(f"{capacity} < {capacity_percentage_threshold}")
        if (capacity < capacity_percentage_threshold) and battery_is_discharging(
            battery
        ):
            notification = subprocess.run(
                [
                    "notify-send",
                    "PLUG IN YOUR LAPTOP DUMMY",
                    f"{capacity}% power left on {battery.name}!",
                ],
                capture_output=True,
            ).stdout.decode("utf-8")
