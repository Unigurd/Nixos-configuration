import re
from gurd.reutils import match_regions, next_line_from

import pyedid

attribute_regex = re.compile(r"^\t([^:\s][^:]*):", flags=re.M)


def parse_edid(string, start=0):
    end = start
    for _ in range(8):
        end = string.index("\n", end + 1)

    edid0 = string[start:end]
    edid1 = "".join(edid0.split())
    edid = pyedid.parse_edid(edid1)
    return edid


def parse_attributes(string, start=0, end=None):
    regions = match_regions(
        attribute_regex,
        string,
        next_line_from(string, start, end),
        end,
    )

    attributes = {
        region.match[1]: string[region.start : region.end] for region in regions
    }

    return attributes


class Resolution:
    def __init__(self, width, height, raw_string=None):
        self.width = width
        self.height = height
        self.raw_string = raw_string

    def __repr__(self):
        return f"<Resolution {self.width}x{self.height}>"

    def __eq__(self, other, check_raw_string=False):
        return (
            (self.width == other.width)
            and (self.height == other.height)
            and (self.raw_string == other.raw_string if check_raw_string else True)
        )


resolution_regex = re.compile(r"^  ([0-9]+)x([0-9]+)", flags=re.M)


def parse_resolution(string, start=0, end=None):
    endpos = {"endpos": end} if end else {}

    match = resolution_regex.search(string, pos=start, **endpos)
    resolution = Resolution(
        width=int(match[1]),
        height=int(match[2]),
        raw_string=string[start:end],
    )

    return resolution


def parse_resolutions(string, start=0, end=None):
    regions = match_regions(
        resolution_regex,
        string,
        start,
        end,
    )

    resolutions = [
        parse_resolution(string, region.start, region.end) for region in regions
    ]

    return resolutions


class Display:
    def __init__(
        self,
        name,
        connected,
        active,
        primary,
        width,
        height,
        posx,
        posy,
        resolutions,
        attributes=None,
        edid=None,
        brightness=None,
    ):
        self.name = name
        self.connected = connected
        self.active = active
        self.primary = primary
        self.width = width
        self.height = height
        self.posx = posx
        self.posy = posy
        self.attributes = attributes if attributes is not None else {}
        self.resolutions = resolutions
        self.edid = edid
        self.brightness = brightness

    def __repr__(self):
        got_edid = ", EDID" if self.attributes.get("EDID") else ""
        is_connected = " connected" if self.connected else ""
        return f"<Display {self.name}{is_connected}{got_edid}>"

    def __eq__(self, other, check_attributes=False):
        return (
            (self.name == other.name)
            and (self.connected == other.connected)
            and (self.resolutions == other.resolutions)
            and (self.width == other.width)
            and (self.height == other.height)
            and (self.posx == other.posx)
            and (self.posy == other.posy)
            and (self.edid == other.edid)
            and (self.brightness == other.brightness)
            and (not check_attributes or (self.attributes == other.attributes))
        )


display_regex = re.compile(
    r"^(?P<name>[a-zA-Z0-9-]+) (?P<connected>dis)?connected",
    flags=re.M,
)

display_regex2 = re.compile(
    r"^(?P<name>[a-zA-Z0-9-]+) (?P<connected>dis)?connected (?P<primary>primary )?(?P<width>[0-9]+)x(?P<height>[0-9]+)\+(?P<posx>[0-9]+)\+(?P<posy>[0-9]+)",
    flags=re.M,
)


def _get_int_or_none(x, key):
    if x is None or x[key] is None:
        return None
    return int(x[key])


brightness_regex = "\tBrightness: ([0-9.]+)"


def parse_brightness(string):
    return float(re.match(brightness_regex, string)[1])


def parse_display(string, start=0, end=None):
    endpos = {"endpos": end} if end else {}

    match = display_regex.match(string, pos=start, **endpos)
    if match is None:
        return None
    match2 = display_regex2.match(
        string, pos=match.start(), endpos=next_line_from(string, match.start())
    )

    resolution_start = resolution_regex.search(string, pos=start, **endpos)
    if resolution_start is not None:
        resolution_start_pos = resolution_start.start()
    else:
        resolution_start_pos = end

    attributes = parse_attributes(string, start, resolution_start_pos)
    resolutions = parse_resolutions(string, resolution_start_pos, end)

    if attributes.get("EDID") is not None:
        edid_str_with_header = attributes["EDID"]
        edid_str = edid_str_with_header[next_line_from(attributes["EDID"], 0) :]
        edid = parse_edid(edid_str) if attributes.get("EDID") is not None else None
    else:
        edid = None

    if attributes.get("Brightness") is not None:
        brightness = parse_brightness(attributes["Brightness"])
    else:
        brightness = None

    return Display(
        name=match["name"],
        connected=not bool(match["connected"]),
        active=match2 is None,
        primary=bool(match2["primary"] if match2 is not None else None),
        width=_get_int_or_none(match2, "width"),
        height=_get_int_or_none(match2, "height"),
        posx=_get_int_or_none(match2, "posx"),
        posy=_get_int_or_none(match2, "posy"),
        attributes=attributes,
        resolutions=resolutions,
        edid=edid,
        brightness=brightness,
    )


def parse_displays(string, start=0, end=None):
    regions = match_regions(
        display_regex,
        string,
        next_line_from(string, start, end),
        end,
    )

    displays = {}
    for region in regions:
        display = parse_display(string, region.start, region.end)
        displays[display.name] = display

    return displays


class Screen:
    def __init__(self, number, displays):
        self.number = number
        self.displays = displays

    def __repr__(self):
        display_string = ", ".join(
            [repr(display) for display in self.displays.values()]
        )
        return f"<Screen {self.number}: {display_string}>"


screen_regex = re.compile(r"^Screen ([0-9]+):", flags=re.M)


def parse_screen(string, start=0, end=None):
    if end is None:
        endpos = {}
    else:
        endpos = {"endpos": end}

    return Screen(
        number=int(screen_regex.match(string, pos=start, **endpos)[1]),
        displays=parse_displays(string, start, end),
    )


def parse_xrandr(string, start=0, end=None):
    regions = match_regions(screen_regex, string)

    screens = {}
    for region in regions:
        screen = parse_screen(string, region.start, region.end)
        screens[screen.number] = screen

    return screens
