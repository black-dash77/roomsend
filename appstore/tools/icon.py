"""The RoomSend icon (light variant, track G2 of docs/icone-source.py) redrawn at any size.

Same geometry as the source on its 1024 grid: the open room, the trail of three dots, the disc
leaving through the corner, on a green squircle. The Liquid Glass lighting of the real icon is not
reproduced; this flat version is for banners only.
"""

from __future__ import annotations

from PIL import Image, ImageDraw

GRID = 1024
SUPERSAMPLE = 2
CORNER = 0.225
TOP_GREEN = (74, 222, 128)
BOTTOM_GREEN = (22, 163, 74)
WHITE = (255, 255, 255, 255)
PALE = (187, 247, 208, 255)
OUTER = (172, 172, 852, 852, 170)
INNER = (282, 282, 742, 742, 62)
EXIT = (800, 224)
EXIT_GAP = 196
EXIT_RADIUS = 132
TRAIL = ((636, 388, 50), (536, 488, 38), (448, 576, 28))


def draw_icon(size: int) -> Image.Image:
    scale = size * SUPERSAMPLE / GRID
    full = size * SUPERSAMPLE
    image = Image.new("RGBA", (full, full), (0, 0, 0, 0))
    ramp = Image.new("RGB", (1, 2))
    ramp.putpixel((0, 0), TOP_GREEN)
    ramp.putpixel((0, 1), BOTTOM_GREEN)
    squircle = Image.new("L", (full, full), 0)
    ImageDraw.Draw(squircle).rounded_rectangle((0, 0, full - 1, full - 1), radius=full * CORNER, fill=255)
    image.paste(ramp.resize((full, full), Image.BICUBIC), (0, 0), squircle)
    image.alpha_composite(_room(full, scale))
    draw = ImageDraw.Draw(image)
    for x, y, radius in TRAIL:
        draw.ellipse(_circle(x, y, radius, scale), fill=PALE)
    draw.ellipse(_circle(*EXIT, EXIT_RADIUS, scale), fill=WHITE)
    return image.resize((size, size), Image.LANCZOS)


def _room(full: int, scale: float) -> Image.Image:
    """The frame: outer rounded square minus the inner one, cut where the disc leaves."""
    mask = Image.new("L", (full, full), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([value * scale for value in OUTER[:4]], radius=OUTER[4] * scale, fill=255)
    draw.rounded_rectangle([value * scale for value in INNER[:4]], radius=INNER[4] * scale, fill=0)
    draw.ellipse(_circle(*EXIT, EXIT_GAP, scale), fill=0)
    layer = Image.new("RGBA", (full, full), WHITE)
    layer.putalpha(mask)
    return layer


def _circle(x: float, y: float, radius: float, scale: float) -> tuple[float, float, float, float]:
    return ((x - radius) * scale, (y - radius) * scale, (x + radius) * scale, (y + radius) * scale)
