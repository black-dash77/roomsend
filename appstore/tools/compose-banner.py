"""Builds the two RoomSend banners outside App Store Connect: a 16:9 card (also the minimum size of an
In-App Event card, 1920 x 1080) and the 1200 x 630 image for links shared on the web. The icon, the name
and the line sit in the middle; two real screens frame them. The App Store creative assets themselves
(header, search results, universal) come from compose-creative.py.

    python3 appstore/tools/compose-banner.py
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from frame import draw_phone
from icon import draw_icon

APPSTORE = Path(__file__).resolve().parent.parent
RAW = APPSTORE / "screenshots" / "raw"
OUTPUT = APPSTORE / "banner"
FONT_PATH = "/System/Library/Fonts/SFNS.ttf"
TITLE_AXES = [100, 96, 400, 800]
LINE_AXES = [100, 28, 400, 600]
INK = (5, 46, 22)
INK_SOFT = (20, 83, 45)
GREEN_LIGHT = (187, 247, 208)
GREEN_MID = (134, 239, 172)
GREEN = (34, 197, 94)
LINES = {
    "en": "Photos and files to every device on your Wi-Fi",
    "fr": "Photos et fichiers vers chaque appareil de ton Wi-Fi",
}
SCREENS = ("01-room", "05-history")
# name: (size, safe area as x, y, width, height)
FORMATS = {
    "card-16x9-1920x1080": ((1920, 1080), (420, 300, 1080, 480)),
    "link-1200x630": ((1200, 630), (250, 165, 700, 300)),
}
ICON_SHARE = 0.46
TITLE_SHARE = 0.25
LINE_SHARE = 0.075
PHONE_HEIGHT_SHARE = 1.12
PHONE_GAP_SHARE = 0.03
PHONE_TOP_SHARE = 0.18


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for language, line in LINES.items():
        screens = [Image.open(RAW / language / f"{name}.png").convert("RGB") for name in SCREENS]
        for name, (size, safe) in FORMATS.items():
            banner = compose(size, safe, line, screens)
            banner.save(OUTPUT / f"{name}-{language}.png", optimize=True)
        print(f"{language}: {len(FORMATS)} banners")


def compose(size: tuple[int, int], safe: tuple[int, int, int, int], line: str,
            screens: list[Image.Image]) -> Image.Image:
    canvas = background(size)
    place_phones(canvas, safe, screens)
    place_mark(canvas, safe, line)
    return canvas.convert("RGB")


def background(size: tuple[int, int]) -> Image.Image:
    ramp = Image.new("RGB", (1, 3))
    for index, color in enumerate((GREEN_LIGHT, GREEN_MID, GREEN)):
        ramp.putpixel((0, index), color)
    return ramp.resize(size, Image.BICUBIC).convert("RGBA")


def place_phones(canvas: Image.Image, safe: tuple[int, int, int, int], screens: list[Image.Image]) -> None:
    """One real screen on each side of the safe area, as large as the side margin allows."""
    x, _, width, _ = safe
    gap = round(canvas.width * PHONE_GAP_SHARE)
    aspect = screens[0].width / screens[0].height
    target = round(canvas.height * PHONE_HEIGHT_SHARE)
    phone_height = min(target, round((x - 2 * gap) / aspect))
    top = min(round(canvas.height * PHONE_TOP_SHARE), (canvas.height - phone_height) // 2 + round(canvas.height * 0.06))
    left_phone, right_phone = (draw_phone(screen, phone_height) for screen in screens)
    canvas.alpha_composite(left_phone, (x - gap - left_phone.width, top))
    canvas.alpha_composite(right_phone, (x + width + gap, top))


def place_mark(canvas: Image.Image, safe: tuple[int, int, int, int], line: str) -> None:
    x, y, width, height = safe
    icon_size = round(height * ICON_SHARE)
    title_font = font(TITLE_AXES, round(height * TITLE_SHARE))
    line_font = fit_font(line, LINE_AXES, round(height * LINE_SHARE), width)
    draw = ImageDraw.Draw(canvas)
    title_gap, line_gap = round(height * 0.05), round(height * 0.06)
    block = icon_size + title_gap + title_font.size + line_gap + line_font.size
    top = y + (height - block) // 2
    center = x + width // 2
    canvas.alpha_composite(draw_icon(icon_size), (center - icon_size // 2, top))
    title_y = top + icon_size + title_gap + title_font.size // 2
    draw.text((center, title_y), "RoomSend", font=title_font, fill=INK, anchor="mm")
    line_y = title_y + title_font.size // 2 + line_gap + line_font.size // 2
    draw.text((center, line_y), line, font=line_font, fill=INK_SOFT, anchor="mm")


def font(axes: list[int], size: int) -> ImageFont.FreeTypeFont:
    face = ImageFont.truetype(FONT_PATH, size)
    face.set_variation_by_axes(axes)
    return face


def fit_font(text: str, axes: list[int], size: int, max_width: int) -> ImageFont.FreeTypeFont:
    face = font(axes, size)
    while face.getlength(text) > max_width:
        size -= 1
        face = font(axes, size)
    return face


if __name__ == "__main__":
    main()
