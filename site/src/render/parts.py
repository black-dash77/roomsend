"""Small pieces every page uses: escaping, inline links, the phone, the avatars, the icons."""
import html
import json
import re

from src import config

LINK = re.compile(r"\[([^\]]+)\]\(([^)\s]+)\)")
EXTERNAL = ("http://", "https://")


def esc(text):
    return html.escape(text, quote=True)


def inline(text):
    """Escapes text and turns its `[label](url)` links into anchors."""
    parts, last = [], 0
    for match in LINK.finditer(text):
        parts.append(esc(text[last:match.start()]))
        label, url = match.group(1), match.group(2)
        rel = ' rel="noopener"' if url.startswith(EXTERNAL) else ""
        parts.append(f'<a href="{esc(url)}"{rel}>{esc(label)}</a>')
        last = match.end()
    parts.append(esc(text[last:]))
    return "".join(parts)


def data(value):
    """A value for a `data-` attribute, as JSON."""
    return esc(json.dumps(value, ensure_ascii=False, separators=(",", ":")))


def shot_pair(language, name):
    return [config.shot_path(language, theme, name) for theme in config.THEMES]


def phone(language, states, initial, label, extra="", eager=False):
    """An iPhone with a real capture on screen. `states` maps a state to its capture name; the
    page scripts switch between them, and each state has its light and its dark capture."""
    urls = {state: shot_pair(language, name) for state, name in states.items()}
    return phone_from_urls(urls, initial, label, extra, eager)


def phone_from_urls(urls, initial, label, extra="", eager=False):
    """The same phone from `{state: [light url, dark url]}`, for states taken in several languages."""
    loading = 'fetchpriority="high"' if eager else 'loading="lazy"'
    images = "".join(
        f'<img class="shot shot--{theme} is-current" src="{esc(url)}" alt="" width="{config.SHOT_WIDTH}" '
        f'height="{config.SHOT_HEIGHT}" decoding="async" {loading} data-state="{esc(initial)}">'
        for theme, url in zip(config.THEMES, urls[initial])
    )
    return (
        f'<figure class="phone {extra}" role="img" aria-label="{esc(label)}" data-states="{data(urls)}" '
        f'data-state="{esc(initial)}"><div class="phone__frame"><div class="phone__screen">{images}</div>'
        '<span class="phone__island" aria-hidden="true"></span></div></figure>'
    )


def avatar(pattern, extra=""):
    """A device avatar drawn from the pattern the app computes for its fingerprint."""
    side = 100
    half = side / 2
    length = pattern["scale"] * side
    squares = "".join(
        f'<rect x="{-length / 2:.2f}" y="{-length / 2:.2f}" width="{length:.2f}" height="{length:.2f}" '
        f'fill="{square["color"]}" transform="translate({half + square["x"] * side:.2f} '
        f'{half + square["y"] * side:.2f}) rotate({square["rotation"]:.2f})"/>'
        for square in pattern["squares"]
    )
    return (
        f'<span class="avatar {extra}" aria-hidden="true"><svg viewBox="0 0 {side} {side}" focusable="false">'
        f'<rect width="{side}" height="{side}" fill="{pattern["base"]}"/>{squares}</svg></span>'
    )


ICONS = {
    "globe": '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c2.6 2.6 3.9 5.6 3.9 9s-1.3 6.4-3.9 9'
    'M12 3c-2.6 2.6-3.9 5.6-3.9 9s1.3 6.4 3.9 9"/>',
    "sun": '<circle cx="12" cy="12" r="4"/><path d="M12 2.5v2.2M12 19.3v2.2M2.5 12h2.2M19.3 12h2.2'
    'M5.3 5.3l1.6 1.6M17.1 17.1l1.6 1.6M5.3 18.7l1.6-1.6M17.1 6.9l1.6-1.6"/>',
    "moon": '<path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z"/>',
    "chevron": '<path d="M9 6l6 6-6 6"/>',
    "arrow": '<path d="M5 12h14M13 6l6 6-6 6"/>',
}


def icon(name, extra=""):
    return (
        f'<svg class="icon {extra}" viewBox="0 0 24 24" aria-hidden="true" focusable="false" fill="none" '
        f'stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">'
        f"{ICONS[name]}</svg>"
    )
