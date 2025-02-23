from gurd.brightness import parse_brightness_modifier
import pytest


@pytest.mark.parametrize("mod", ["", "-", "+"])
@pytest.mark.parametrize("input", ["1", "0", "2.3", "0.1"])
def test_parse_brightness_modifier(mod, input):
    value = float(input)
    if mod == "":
        result = value
    elif mod == "-":
        result = 1 - value
    else:
        result = 1 + value
    bm = parse_brightness_modifier(mod + input)
    assert result == bm(1)
