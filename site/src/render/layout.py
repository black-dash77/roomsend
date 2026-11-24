"""The shell of every page: head, header with language and appearance, footer."""
import base64
import hashlib

from src import config, sources
from src.copy import load as load_copy
from src.render.parts import esc, icon

# Runs before the first paint: sets the appearance, and sends a visitor who never picked a
# language from an English page to the same page in their browser's language.
HEAD_SCRIPT = (
    "(function(){var d=document.documentElement,g=function(k){try{return localStorage.getItem(k)}catch(e){"
    "return null}};d.dataset.theme=g('theme')||(matchMedia('(prefers-color-scheme: dark)').matches?'dark':"
    "'light');if(!('autoLang' in d.dataset)||g('lang'))return;var o=['fr','de','es','it','pt'],"
    "n=navigator.languages||[navigator.language];for(var i=0;i<n.length;i++){var k=String(n[i]).slice(0,2)"
    ".toLowerCase();if(k==='en')return;if(o.indexOf(k)>-1){location.replace('/'+k+location.pathname+"
    "location.hash);return}}})();"
)
HEAD_SCRIPT_HASH = "sha256-" + base64.b64encode(hashlib.sha256(HEAD_SCRIPT.encode()).digest()).decode()


def page(language, key, copy, title, description, body, indexable=True):
    """A complete HTML page for `key` in `language`. A page that is not indexable (the missing
    page) gets no canonical address, no alternates and no language redirect."""
    canonical = config.BASE_URL + config.page_path(language, key)
    default = f'{config.BASE_URL}{config.page_path(config.DEFAULT_LANGUAGE, key)}'
    links = "".join(
        f'<link rel="alternate" hreflang="{other}" href="{config.BASE_URL}{config.page_path(other, key)}">\n'
        for other in config.LANGUAGES
    ) + f'<link rel="alternate" hreflang="x-default" href="{default}">'
    index = f'<link rel="canonical" href="{canonical}">\n{links}' if indexable else '<meta name="robots" content="noindex">'
    auto = " data-auto-lang" if indexable and language == config.DEFAULT_LANGUAGE else ""
    return f"""<!doctype html>
<html lang="{language}"{auto}>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>{esc(title)}</title>
<meta name="description" content="{esc(description)}">
<meta name="color-scheme" content="light dark">
<meta name="theme-color" content="#FFFFFF" media="(prefers-color-scheme: light)">
<meta name="theme-color" content="#000000" media="(prefers-color-scheme: dark)">
{index}
<meta property="og:type" content="website">
<meta property="og:site_name" content="RoomSend">
<meta property="og:title" content="{esc(title)}">
<meta property="og:description" content="{esc(description)}">
<meta property="og:url" content="{canonical}">
<meta property="og:image" content="{config.BASE_URL}/assets/og/{language}.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:locale" content="{language}">
<meta name="twitter:card" content="summary_large_image">
<link rel="icon" href="/favicon.ico" sizes="32x32">
<link rel="icon" href="/assets/icons/icon-192.png" type="image/png" sizes="192x192">
<link rel="apple-touch-icon" href="/assets/icons/apple-touch-icon.png">
<link rel="manifest" href="/manifest.webmanifest">
<script>{HEAD_SCRIPT}</script>
<link rel="stylesheet" href="/assets/site.css">
<script type="module" src="/assets/js/main.js"></script>
</head>
<body data-page="{key}">
<a class="skip" href="#content">{esc(copy["nav.skip"])}</a>
{header(language, key, copy)}
<main id="content">
{body}
</main>
{footer(language, key, copy)}
</body>
</html>
"""


def header(language, key, copy):
    support_current = ' aria-current="page"' if key == "support" else ""
    return f"""<header class="bar">
<div class="bar__inner">
<a class="brand" href="{config.page_path(language, 'home')}" aria-label="{esc(copy['nav.home'])}">
<img class="brand__icon" src="/assets/icons/icon-64.png" alt="" width="28" height="28">
<span class="brand__name">RoomSend</span></a>
<nav class="bar__nav">
<a class="bar__link" href="{config.page_path(language, 'support')}"{support_current}>{esc(copy['nav.support'])}</a>
{language_menu(language, key, copy)}
{theme_toggle(copy)}
</nav>
</div>
</header>"""


def language_menu(language, key, copy, extra=""):
    current = {other: ' aria-current="true"' if other == language else "" for other in config.LANGUAGES}
    items = "".join(
        f'<li><a href="{config.page_path(other, key)}" hreflang="{other}" lang="{other}" data-lang="{other}"'
        f'{current[other]}>{esc(load_copy(other)["lang.name"])}</a></li>'
        for other in config.LANGUAGES
    )
    return f"""<details class="lang {extra}">
<summary class="lang__button" aria-label="{esc(copy['nav.language'])}">{icon('globe')}<span>{esc(copy['lang.name'])}</span></summary>
<ul class="lang__menu" role="list">{items}</ul>
</details>"""


def theme_toggle(copy):
    return (
        f'<button class="theme" type="button" aria-label="{esc(copy["nav.theme.dark"])}" '
        f'data-label-dark="{esc(copy["nav.theme.dark"])}" data-label-light="{esc(copy["nav.theme.light"])}">'
        f'{icon("moon", "theme__moon")}{icon("sun", "theme__sun")}</button>'
    )


def store_badge(copy, extra=""):
    """The App Store link once the app is live; until then, a plain line that says so."""
    if config.APP_STORE_URL:
        return f'<a class="pill pill--primary {extra}" href="{esc(config.APP_STORE_URL)}">{esc(copy["store.get"])}</a>'
    return f'<p class="soon {extra}"><span class="soon__dot" aria-hidden="true"></span>{esc(copy["store.soon"])}</p>'


def footer(language, key, copy):
    links = "".join(
        f'<a href="{config.page_path(language, page)}">{esc(copy["nav." + page])}</a>'
        for page in ("privacy", "terms", "support")
    )
    return f"""<footer class="foot">
<div class="foot__inner">
<div class="foot__top">
<a class="brand" href="{config.page_path(language, 'home')}" aria-label="{esc(copy['nav.home'])}">
<img class="brand__icon" src="/assets/icons/icon-64.png" alt="" width="28" height="28" loading="lazy">
<span class="brand__name">RoomSend</span></a>
<nav class="foot__links">{links}</nav>
</div>
<div class="foot__bottom">
<p>© {config.COPYRIGHT_YEAR} {esc(sources.PUBLISHER['name'])}. {esc(copy['footer.notice'])}</p>
<div class="foot__controls">{language_menu(language, key, copy, 'lang--up')}{theme_toggle(copy)}</div>
</div>
</div>
</footer>"""
