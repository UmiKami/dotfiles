import json
import os
import colorsys

def adjust_hue_lightness(hex_color, hue_shift=0.05, lightness_shift=0.2):
    r, g, b = int(hex_color[1:3], 16) / 255.0, int(hex_color[3:5], 16) / 255.0, int(hex_color[5:7], 16) / 255.0
    h, l, s = colorsys.rgb_to_hls(r, g, b)

    h = (h + hue_shift) % 1.0
    l = min(1.0, max(0.0, l + lightness_shift))

    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return "#{:02x}{:02x}{:02x}".format(int(r * 255), int(g * 255), int(b * 255))

with open('/home/umikami/.cache/wal/colors.json', 'r') as f:
    data = json.load(f)

bg = data["special"]["background"]
fg = data["special"]["foreground"]

bg_hovered = adjust_hue_lightness(bg)
fg_hovered = adjust_hue_lightness(fg)

css_content = f"""
@define-color textColor {fg};
@define-color textColorHover {fg_hovered};
@define-color backgroundColor {bg};
@define-color backgroundColorHover {bg_hovered};
"""

with open(os.path.expanduser("~/.config/gtk-3.0/gtk.css"), "w") as f:
    f.write(css_content)

