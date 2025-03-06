from pathlib import Path
import re
import sys
import subprocess
import os

capacity_percentage_threshold = int(
    os.environ.get("GURD_BATTERY_WARNING_CAPACITY_PERCENTAGE", 5)
)


def battery_capacity(battery):
    # `battery/"energy_full_design"` is the max energy of the battery
    # when it was new, and `battery/"energy_full"` is the max energy
    # of the batter as it is now. `battery/"capacity"` is equivalent
    # to `100*energy_now/energy_full`, bu I want
    # `100*energy_now/energy_full_design`.
    energy_full_design_path = battery / "energy_full_design"
    if not energy_full_design_path.exists:
        return

    with open(energy_full_design_path) as fd:
        energy_full_design = int(fd.read())

    energy_now_path = battery / "energy_now"
    if not energy_now_path.exists:
        return

    with open(energy_now_path) as fd:
        energy_now = int(fd.read())

        # No real reason that I chose to work with ints
        return (energy_now * 100) // energy_full_design


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
