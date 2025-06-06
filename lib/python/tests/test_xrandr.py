from importlib.resources import files
from gurd.xrandr import (
    parse_brightness,
    parse_display,
    parse_resolutions,
    parse_xrandr,
    Display,
    Resolution,
)

import tests.resources
import pytest

xrandr_text = files(tests.resources).joinpath("xrandr-verbose.txt").read_text()

resolutions_text = """
  1920x1080 (0x4a) 173.000MHz -HSync +VSync
        h: width  1920 start 2048 end 2248 total 2576 skew    0 clock  67.16KHz
        v: height 1080 start 1083 end 1088 total 1120           clock  59.96Hz
  1920x1080 (0x4b) 138.500MHz +HSync -VSync
        h: width  1920 start 1968 end 2000 total 2080 skew    0 clock  66.59KHz
        v: height 1080 start 1083 end 1088 total 1111           clock  59.93Hz
  1680x1050 (0x4c) 146.250MHz -HSync +VSync
        h: width  1680 start 1784 end 1960 total 2240 skew    0 clock  65.29KHz
        v: height 1050 start 1053 end 1059 total 1089           clock  59.95Hz
  1680x1050 (0x4d) 119.000MHz +HSync -VSync
        h: width  1680 start 1728 end 1760 total 1840 skew    0 clock  64.67KHz
        v: height 1050 start 1053 end 1059 total 1080           clock  59.88Hz
  1400x1050 (0x4e) 122.000MHz +HSync +VSync
        h: width  1400 start 1488 end 1640 total 1880 skew    0 clock  64.89KHz
        v: height 1050 start 1052 end 1064 total 1082           clock  59.98Hz
  1600x900 (0x4f) 246.000MHz -HSync +VSync DoubleScan
        h: width  1600 start 1728 end 1900 total 2200 skew    0 clock 111.82KHz
        v: height  900 start  901 end  904 total  932           clock  59.99Hz
"""


def test_parse_resolutions():
    resolutions = parse_resolutions(
        resolutions_text, start=2, end=len(resolutions_text) - 300
    )
    assert resolutions == [
        Resolution(1920, 1080),
        Resolution(1680, 1050),
        Resolution(1680, 1050),
        Resolution(1400, 1050),
    ]


@pytest.mark.parametrize("connected", [True, False])
@pytest.mark.parametrize("primary", [True, False])
def test_parse_display(connected, primary):
    display_text = """
MyDisplay {prefix}connected {primary}111x222+333+444
	Attribute1: blabla
  123x456
  456x789
""".format(prefix="" if connected else "dis", primary="primary " if primary else "")
    display = parse_display(display_text, 1, end=len(display_text) - 10)
    assert display == Display(
        name="MyDisplay",
        connected=connected,
        active=True,
        primary=primary,
        width=111,
        height=222,
        posx=333,
        posy=444,
        resolutions=[Resolution(123, 456)],
    )


def test_parse_all_displays():
    xrandr = parse_xrandr(xrandr_text)
    assert list(xrandr[0].displays.keys()) == [
        "eDP-1",
        "DP-1",
        "HDMI-1",
        "DP-2",
        "HDMI-2",
    ]


def test_parse_brightness():
    string = "	Brightness: 0.90"
    assert 0.9 == parse_brightness(string)


def test_parse_brightness_in_context():
    xrandr = parse_xrandr(xrandr_text)
    assert 0.7 == xrandr[0].displays["eDP-1"].brightness


def test_parse_active_in_context():
    text = (
        files(tests.resources)
        .joinpath("xrandr-verbose-connected-but-not-active.txt")
        .read_text()
    )
    xrandr = parse_xrandr(text)

    for display in xrandr[0].displays.values():
        if display.name == "eDP-1":
            assert display.connected
            assert display.active
        elif display.name == "DP-1":
            assert display.connected
            assert not display.active
        else:
            assert not display.connected
            assert not display.active
