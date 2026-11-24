"""Builds the App Store screenshots of RoomSend from real captures of the app.

Input: appstore/screenshots/raw/<language>/<name>.png, full-resolution simulator captures
(appstore/tools/sim-setup.sh shot <name>), and the captions of appstore/screenshots/captions.json.
Output: appstore/screenshots/<language>/<size>/<name>.png, opaque RGB PNG, for the two iPhone
sizes App Store Connect asks for today (screenshot specifications, read on 21.11.2026).

    python3 appstore/tools/compose.py [language ...]
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

from frame import draw_phone

ROOT = Path(__file__).resolve().parent.parent / "screenshots"
CAPTIONS = json.loads((ROOT / "captions.json").read_text(encoding="utf-8"))
SIZES = {
    "6.9-inch-1320x2868": (1320, 2868),
    "6.3-inch-1206x2622": (1206, 2622),
}
REFERENCE_WIDTH = 1320
FONT_PATH = "/System/Library/Fonts/SFNS.ttf"
# SF Pro axes: width, optical size, grade, weight. Display optical size, bold.
FONT_AXES = [100, 96, 400, 700]
CAPTION_SIZE = 116
CAPTION_LEADING = 1.08
CAPTION_TOP = 262
CAPTION_SIDE = 96
CAPTION_MAX_LINES = 2
PHONE_TOP = 548
PHONE_BOTTOM_MARGIN = 96
SHADOW_DROP = 36
SHADOW_BLUR = 48
SHADOW_OPACITY = 0.28
SHADOW_TINT = (3, 60, 28, 255)
GREEN_LIGHT = (187, 247, 208)
GREEN_MID = (134, 239, 172)
GREEN = (34, 197, 94)
INK = (5, 46, 22)


def main() -> None:
    languages = sys.argv[1:] or [language for language in CAPTIONS if language != "order"]
    for language in languages:
        for size_name, size in SIZES.items():
            output_dir = ROOT / language / size_name
            output_dir.mkdir(parents=True, exist_ok=True)
            for name in CAPTIONS["order"]:
                capture = ROOT / "raw" / language / f"{name}.png"
                if not capture.exists():
                    print(f"missing {capture.relative_to(ROOT)}")
                    continue
                image = compose(capture, CAPTIONS[language][name], size)
                image.save(output_dir / f"{name}.png", optimize=True)
        print(f"{language}: done")


def compose(capture: Path, caption: str, size: tuple[int, int]) -> Image.Image:
    width, height = size
    scale = width / REFERENCE_WIDTH
    canvas = background(size)
    draw_caption(canvas, caption, scale)
    screen = Image.open(capture).convert("RGB")
    phone_height = height - round((PHONE_TOP + PHONE_BOTTOM_MARGIN) * scale)
    phone = draw_phone(screen, phone_height)
    left = (width - phone.width) // 2
    top = round(PHONE_TOP * scale)
    layer, padding = shadow(phone, scale)
    canvas.alpha_composite(layer, (left - padding, top + round(SHADOW_DROP * scale) - padding))
    canvas.alpha_composite(phone, (left, top))
    return canvas.convert("RGB")


def background(size: tuple[int, int]) -> Image.Image:
    """A vertical wash from the pale greens of the icon down to its full green."""
    width, height = size
    ramp = Image.new("RGB", (1, 3))
    ramp.putpixel((0, 0), GREEN_LIGHT)
    ramp.putpixel((0, 1), GREEN_MID)
    ramp.putpixel((0, 2), GREEN)
    return ramp.resize((width, height), Image.BICUBIC).convert("RGBA")


def draw_caption(canvas: Image.Image, caption: str, scale: float) -> None:
    font = ImageFont.truetype(FONT_PATH, round(CAPTION_SIZE * scale))
    font.set_variation_by_axes(FONT_AXES)
    max_width = canvas.width - 2 * round(CAPTION_SIDE * scale)
    lines = wrap(caption, font, max_width)
    draw = ImageDraw.Draw(canvas)
    line_height = round(font.size * CAPTION_LEADING)
    y = round(CAPTION_TOP * scale) - (len(lines) - 1) * line_height // 2
    for line in lines:
        draw.text((canvas.width // 2, y), line, font=font, fill=INK, anchor="mm")
        y += line_height


def wrap(text: str, font: ImageFont.FreeTypeFont, max_width: int) -> list[str]:
    """Balanced lines: the break that keeps both lines closest in width."""
    if font.getlength(text) <= max_width:
        return [text]
    words = text.split(" ")
    candidates = []
    for cut in range(1, len(words)):
        first, second = " ".join(words[:cut]), " ".join(words[cut:])
        widest = max(font.getlength(first), font.getlength(second))
        if widest <= max_width:
            candidates.append((widest, [first, second]))
    if not candidates:
        raise ValueError(f"caption does not fit on {CAPTION_MAX_LINES} lines: {text}")
    return min(candidates)[1]


def shadow(phone: Image.Image, scale: float) -> tuple[Image.Image, int]:
    """One soft shadow under the device, tinted with the background's green, on a padded layer so
    the blur is never cut at the edges of the phone. Returns the layer and its padding."""
    blur = round(SHADOW_BLUR * scale)
    padding = blur * 3
    alpha = Image.new("L", (phone.width + 2 * padding, phone.height + 2 * padding), 0)
    alpha.paste(phone.getchannel("A").point(lambda value: value * SHADOW_OPACITY), (padding, padding))
    layer = Image.new("RGBA", alpha.size, SHADOW_TINT)
    layer.putalpha(alpha.filter(ImageFilter.GaussianBlur(blur)))
    return layer, padding


if __name__ == "__main__":
    main()
