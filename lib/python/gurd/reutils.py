class MatchRegion:
    def __init__(self, match, end):
        self.match = match
        self.start = match.start()
        self.end = end


def match_regions(regex, string, start=0, end=None):
    if end is None:
        endpos = {}
    else:
        endpos = {"endpos": end}

    regions = []
    last_match = None

    while match := regex.search(string, pos=start, **endpos):
        if last_match is not None:
            regions.append(MatchRegion(last_match, match.start()))
        last_match = match
        start = match.end()

    if last_match is not None:
        regions.append(MatchRegion(last_match, len(string) if end is None else end))

    return regions


def next_line_from(string, start, end=None):
    if end is None:
        end = tuple()
    else:
        end = (end,)
    return string.index("\n", start, *end)
