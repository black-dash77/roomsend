"""A plain iPhone body drawn around a real screen capture: dark glass, a thin metal rim, side buttons.

Proportions follow an iPhone 17 Pro Max seen from the front: display corner radius about 1/8 of the
display width, a narrow black border, buttons on both edges. Edges are drawn at SUPERSAMPLE times the
final size, then reduced, so curves stay smooth.
"""

from __future__ import annotations

from PIL import Image, ImageDraw

SUPERSAMPLE = 4
SCREEN_RADIUS = 0.125
BORDER = 0.026
RIM = 0.009
BUTTON_DEPTH = 0.006
BUTTON_WIDTH = 0.012
GLASS = (10, 10, 11, 255)
METAL = (58, 60, 64, 255)
METAL_EDGE = (120, 124, 130, 255)
# Buttons as (side, top, length), as fractions of the body height.
BUTTONS = (
    ("left", 0.155, 0.040),
    ("left", 0.225, 0.065),
    ("left", 0.305, 0.065),
    ("right", 0.240, 0.100),
    ("right", 0.560, 0.065),
)


def draw_phone(screen: Image.Image, phone_height: int) -> Image.Image:
    ratio = screen.width / screen.height
    screen_width = phone_height / (1 / ratio + 2 * (BORDER + RIM))
    border, rim = BORDER * screen_width, RIM * screen_width
    body_width = screen_width + 2 * (border + rim)
    margin = BUTTON_DEPTH * screen_width
    size = (round(body_width + 2 * margin), phone_height)
    large = _draw_body(size, margin, rim, screen_width)
    phone = large.resize(size, Image.LANCZOS)
    inset = round(margin + rim + border)
    screen_size = (size[0] - 2 * inset, phone_height - 2 * round(rim + border))
    fitted = screen.convert("RGBA").resize(screen_size, Image.LANCZOS)
    fitted.putalpha(_rounded_mask(screen_size, SCREEN_RADIUS * screen_size[0]))
    phone.alpha_composite(fitted, (inset, round(rim + border)))
    return phone


def _draw_body(size: tuple[int, int], margin: float, rim: float, screen_width: float) -> Image.Image:
    factor = SUPERSAMPLE
    width, height = size[0] * factor, size[1] * factor
    image = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    left, right = margin * factor, width - margin * factor
    outer_radius = (SCREEN_RADIUS * screen_width + (BORDER * screen_width) + rim) * factor
    _draw_buttons(draw, (left, right), height, screen_width * factor)
    draw.rounded_rectangle((left, 0, right, height - 1), radius=outer_radius, fill=METAL_EDGE)
    edge = max(1.0, rim * factor * 0.35)
    draw.rounded_rectangle((left + edge, edge, right - edge, height - 1 - edge),
                           radius=outer_radius - edge, fill=METAL)
    inner = rim * factor
    draw.rounded_rectangle((left + inner, inner, right - inner, height - 1 - inner),
                           radius=outer_radius - inner, fill=GLASS)
    return image


def _draw_buttons(draw: ImageDraw.ImageDraw, edges: tuple[float, float], height: int, screen_width: float) -> None:
    depth, thickness = BUTTON_DEPTH * screen_width, BUTTON_WIDTH * screen_width
    left_edge, right_edge = edges
    for side, top, length in BUTTONS:
        y0, y1 = top * height, (top + length) * height
        if side == "left":
            box = (left_edge - depth, y0, left_edge + thickness, y1)
        else:
            box = (right_edge - thickness, y0, right_edge + depth, y1)
        draw.rounded_rectangle(box, radius=depth, fill=METAL)


def _rounded_mask(size: tuple[int, int], radius: float) -> Image.Image:
    factor = SUPERSAMPLE
    mask = Image.new("L", (size[0] * factor, size[1] * factor), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, mask.width - 1, mask.height - 1), radius=radius * factor, fill=255)
    return mask.resize(size, Image.LANCZOS)
