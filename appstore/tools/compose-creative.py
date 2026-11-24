"""Builds the App Store « creative assets » of RoomSend: the product page header and the search results
image, as dark cards that each carry a two-part line and a real screen of the app, on the green of the icon.

Formats, App Store Connect Help « Creative assets specifications », read on 21.11.2026:
  search results 3:2, 1920 x 1280 to 3840 x 2560;  product page header 21:9, 3840 x 1646;
  universal 16:9, 5244 x 2950, PNG.
Reads appstore/screenshots/raw/<language>/<screen>.png. Writes appstore/banner/<format>-<language>.png.

    python3 appstore/tools/compose-creative.py [language ...]
"""

from __future__ import annotations

import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

APPSTORE = Path(__file__).resolve().parent.parent
RAW = APPSTORE / "screenshots" / "raw"
OUTPUT = APPSTORE / "banner"
FONT_PATH = "/System/Library/Fonts/SFNS.ttf"
LINE_AXES = [100, 96, 400, 700]
GREEN_LIGHT, GREEN_MID, GREEN = (187, 247, 208), (134, 239, 172), (34, 197, 94)
CARD = (0, 0, 0)
LEAD = (250, 250, 250)
FOLLOW = (161, 161, 170)
MARGIN = 0.025
CARD_RADIUS = 0.03
CAPTION_SIZE = 0.085
CAPTION_TOP = 0.075
CONTENT_TOP = 0.27
CONTENT_SIDE = 0.05
# Where the useful part of each raw screen starts, in pixels of the 1320-wide capture.
CROP_TOP = {"01-room": 150, "02-send": 210, "03-incoming": 150}
FORMATS = {
    "app-store-search-3840x2560": ((3840, 2560), ("01-room", "02-send")),
    "app-store-header-3840x1646": ((3840, 1646), ("01-room", "02-send", "03-incoming")),
    "app-store-universal-5244x2950": ((5244, 2950), ("01-room", "02-send", "03-incoming")),
}
LINES = {
    "en": {"01-room": ("See who's", "on your Wi-Fi."), "02-send": ("Send to one,", "or the whole room."),
           "03-incoming": ("See who's sending,", "then accept.")},
    "fr": {"01-room": ("Vois qui est", "sur ton Wi-Fi."), "02-send": ("Envoie à un seul,", "ou à toute la pièce."),
           "03-incoming": ("Vois qui envoie,", "puis accepte.")},
    "de": {"01-room": ("Sieh, wer in", "deinem WLAN ist."), "02-send": ("An ein Gerät", "oder den ganzen Raum."),
           "03-incoming": ("Wer sendet was?", "Du entscheidest.")},
    "es": {"01-room": ("Mira quién está", "en tu Wi-Fi."), "02-send": ("Envía a uno", "o a toda la sala."),
           "03-incoming": ("Mira quién envía", "y acepta.")},
    "it": {"01-room": ("Guarda chi c'è", "sulla tua Wi-Fi."), "02-send": ("A una persona", "o a tutta la stanza."),
           "03-incoming": ("Vedi chi invia,", "poi accetta.")},
    "pt": {"01-room": ("Vê quem está", "na tua Wi-Fi."), "02-send": ("Envia para um", "ou para a sala toda."),
           "03-incoming": ("Vê quem envia", "e aceita.")},
}


def main() -> None:
    languages = sys.argv[1:] or [language for language in LINES if (RAW / language / "01-room.png").exists()]
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for language in languages:
        for name, (size, screens) in FORMATS.items():
            image = compose(size, [(screen, LINES[language][screen]) for screen in screens], language)
            image.save(OUTPUT / f"{name}-{language}.png", optimize=True)
        print(f"{language}: {len(FORMATS)} creative assets")


def compose(size: tuple[int, int], cards: list[tuple[str, tuple[str, str]]], language: str) -> Image.Image:
    width, height = size
    canvas = background(size)
    margin = round(width * MARGIN)
    card_width = (width - margin * (len(cards) + 1)) // len(cards)
    card_height = height - 2 * margin
    for index, (screen, line) in enumerate(cards):
        card = draw_card((card_width, card_height), RAW / language / f"{screen}.png", CROP_TOP[screen], line)
        canvas.paste(card, (margin + index * (card_width + margin), margin), card)
    return canvas.convert("RGB")


def background(size: tuple[int, int]) -> Image.Image:
    ramp = Image.new("RGB", (1, 3))
    for index, color in enumerate((GREEN_LIGHT, GREEN_MID, GREEN)):
        ramp.putpixel((0, index), color)
    return ramp.resize(size, Image.BICUBIC).convert("RGBA")


def draw_card(size: tuple[int, int], capture: Path, crop_top: int, line: tuple[str, str]) -> Image.Image:
    width, height = size
    card = Image.new("RGBA", size, CARD + (255,))
    inner = width - 2 * round(width * CONTENT_SIDE)
    screen = Image.open(capture).convert("RGB")
    scale = inner / screen.width
    content_top = round(height * CONTENT_TOP)
    visible = round((height - content_top) / scale)
    piece = screen.crop((0, crop_top, screen.width, min(screen.height, crop_top + visible)))
    piece = piece.resize((inner, round(piece.height * scale)), Image.LANCZOS)
    card.paste(piece, ((width - inner) // 2, content_top))
    draw_line(card, line)
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, width - 1, height - 1), radius=round(width * CARD_RADIUS), fill=255)
    card.putalpha(mask)
    return card


def draw_line(card: Image.Image, line: tuple[str, str]) -> None:
    """The lead in white, the rest in grey, centred, shrunk until both fit the card."""
    size = round(card.width * CAPTION_SIZE)
    face = font(size)
    while max(face.getlength(part) for part in line) > card.width * 0.86:
        size -= 2
        face = font(size)
    draw = ImageDraw.Draw(card)
    top = round(card.height * CAPTION_TOP)
    leading = round(size * 1.12)
    draw.text((card.width // 2, top), line[0], font=face, fill=LEAD, anchor="mt")
    draw.text((card.width // 2, top + leading), line[1], font=face, fill=FOLLOW, anchor="mt")


def font(size: int) -> ImageFont.FreeTypeFont:
    face = ImageFont.truetype(FONT_PATH, size)
    face.set_variation_by_axes(LINE_AXES)
    return face


if __name__ == "__main__":
    main()
