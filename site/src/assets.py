"""The files around the pages: styles, scripts, icons, share images, and what hosts and robots read."""
import os
import shutil

from PIL import Image, ImageDraw, ImageFont

from src import config, sources
from src.copy import load as load_copy
from src.render.layout import HEAD_SCRIPT_HASH

ICON_LIGHT = os.path.join(sources.PROJECT, "docs", "icone-clair.png")
ICON_DARK = os.path.join(sources.PROJECT, "docs", "icone-sombre.png")
FONT = "/System/Library/Fonts/HelveticaNeue.ttc"
FONT_BOLD_INDEX = 1
OG_SIZE = (1200, 630)
OG_MARGIN = 72
OG_TITLE_SIZE = 76
OG_NAME_SIZE = 34
OG_ICON = 88
OG_PHONE_WIDTH = 330
OG_PHONE_RADIUS = 52
APPLE_TOUCH = 180
ICON_SIZES = (64, 128, 192, 512)
ICON_TOP, ICON_BOTTOM = (148, 226, 160), (88, 190, 104)

HEADERS = f"""/*
  Content-Security-Policy: default-src 'none'; script-src 'self' '{HEAD_SCRIPT_HASH}'; style-src 'self'; img-src 'self'; manifest-src 'self'; connect-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'; upgrade-insecure-requests
  Strict-Transport-Security: max-age=63072000; includeSubDomains
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: camera=(), microphone=(), geolocation=(), browsing-topics=()
  Cross-Origin-Opener-Policy: same-origin
/assets/shots/*
  Cache-Control: public, max-age=604800
/assets/og/*
  Cache-Control: public, max-age=604800
"""


def write_static(public):
    css_dir = os.path.join(sources.SITE, "src", "css")
    os.makedirs(os.path.join(public, "assets"), exist_ok=True)
    with open(os.path.join(public, "assets", "site.css"), "w", encoding="utf-8") as bundle:
        for name in sorted(os.listdir(css_dir)):
            with open(os.path.join(css_dir, name), encoding="utf-8") as part:
                bundle.write(part.read() + "\n")
    shutil.copytree(os.path.join(sources.SITE, "src", "js"), os.path.join(public, "assets", "js"))
    write_icons(public)
    write_text(public, "_headers", HEADERS)
    write_text(public, "robots.txt", f"User-agent: *\nAllow: /\n\nSitemap: {config.BASE_URL}/sitemap.xml\n")
    write_text(public, "sitemap.xml", sitemap())
    write_text(public, "manifest.webmanifest", manifest())


def write_text(public, name, text):
    with open(os.path.join(public, name), "w", encoding="utf-8") as handle:
        handle.write(text)


def write_icons(public):
    folder = os.path.join(public, "assets", "icons")
    os.makedirs(folder, exist_ok=True)
    light, dark = Image.open(ICON_LIGHT).convert("RGBA"), Image.open(ICON_DARK).convert("RGBA")
    for size in ICON_SIZES:
        light.resize((size, size), Image.LANCZOS).save(os.path.join(folder, f"icon-{size}.png"), optimize=True)
    dark.resize((128, 128), Image.LANCZOS).save(os.path.join(folder, "icon-dark-128.png"), optimize=True)
    light.resize((32, 32), Image.LANCZOS).save(os.path.join(public, "favicon.ico"), sizes=[(32, 32), (16, 16)])
    touch = vertical_gradient((APPLE_TOUCH, APPLE_TOUCH), ICON_TOP, ICON_BOTTOM)
    touch.alpha_composite(light.resize((APPLE_TOUCH, APPLE_TOUCH), Image.LANCZOS))
    touch.convert("RGB").save(os.path.join(folder, "apple-touch-icon.png"), optimize=True)


def vertical_gradient(size, top, bottom):
    image = Image.new("RGBA", size)
    draw = ImageDraw.Draw(image)
    for y in range(size[1]):
        share = y / max(1, size[1] - 1)
        color = tuple(round(a + (b - a) * share) for a, b in zip(top, bottom))
        draw.line([(0, y), (size[0], y)], fill=color + (255,))
    return image


def write_share_images(public, shots_dir):
    """One share image per language: the icon, the name, the headline, the real Room screen."""
    folder = os.path.join(public, "assets", "og")
    os.makedirs(folder, exist_ok=True)
    title_font = ImageFont.truetype(FONT, OG_TITLE_SIZE, index=FONT_BOLD_INDEX)
    name_font = ImageFont.truetype(FONT, OG_NAME_SIZE, index=FONT_BOLD_INDEX)
    icon = Image.open(ICON_DARK).convert("RGBA").resize((OG_ICON, OG_ICON), Image.LANCZOS)
    for language in config.LANGUAGES:
        canvas = Image.new("RGBA", OG_SIZE, (0, 0, 0, 255))
        draw = ImageDraw.Draw(canvas)
        canvas.alpha_composite(icon, (OG_MARGIN, OG_MARGIN))
        draw.text((OG_MARGIN + OG_ICON + 20, OG_MARGIN + 24), "RoomSend", font=name_font, fill="#FAFAFA")
        lines = wrap(load_copy(language)["hero.title"], title_font, OG_SIZE[0] - OG_PHONE_WIDTH - 3 * OG_MARGIN)
        y = OG_MARGIN + OG_ICON + 56
        for line in lines:
            draw.text((OG_MARGIN, y), line, font=title_font, fill="#FAFAFA")
            y += int(OG_TITLE_SIZE * 1.08)
        paste_screen(canvas, os.path.join(shots_dir, language, "dark", f"room-{config.ROOM_STATES - 1}.webp"))
        canvas.convert("RGB").save(os.path.join(folder, f"{language}.png"), optimize=True)


def paste_screen(canvas, path):
    shot = Image.open(path).convert("RGBA")
    height = round(shot.height * OG_PHONE_WIDTH / shot.width)
    shot = shot.resize((OG_PHONE_WIDTH, height), Image.LANCZOS)
    mask = Image.new("L", shot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, shot.width - 1, shot.height - 1], OG_PHONE_RADIUS, fill=255)
    left = OG_SIZE[0] - OG_PHONE_WIDTH - OG_MARGIN
    canvas.paste(shot, (left, OG_MARGIN), mask)


def wrap(text, font, width):
    lines, line = [], ""
    for word in text.split():
        candidate = f"{line} {word}".strip()
        if font.getlength(candidate) <= width or not line:
            line = candidate
        else:
            lines.append(line)
            line = word
    return lines + [line]


def sitemap():
    entries = []
    for page in config.PAGES:
        alternates = "".join(
            f'<xhtml:link rel="alternate" hreflang="{other}" href="{config.BASE_URL}{config.page_path(other, page)}"/>'
            for other in config.LANGUAGES
        )
        for language in config.LANGUAGES:
            entries.append(f"<url><loc>{config.BASE_URL}{config.page_path(language, page)}</loc>{alternates}</url>")
    return ('<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" '
            'xmlns:xhtml="http://www.w3.org/1999/xhtml">' + "".join(entries) + "</urlset>\n")


def manifest():
    icons = ",".join(
        f'{{"src":"/assets/icons/icon-{size}.png","sizes":"{size}x{size}","type":"image/png"}}' for size in (192, 512)
    )
    return ('{"name":"RoomSend","short_name":"RoomSend","start_url":"/","display":"browser",'
            f'"background_color":"#FFFFFF","theme_color":"#FFFFFF","icons":[{icons}]}}\n')
