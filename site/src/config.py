"""Everything the build decides once: languages, routes, the public address, image sizes."""
import os

# The public address. The Netlify one until a domain is bought; override with ROOMSEND_SITE_URL.
BASE_URL = os.environ.get("ROOMSEND_SITE_URL", "https://roomsend.netlify.app").rstrip("/")
# Filled once the app is live; until then the site says « coming soon » and links nowhere.
APP_STORE_URL = os.environ.get("ROOMSEND_APP_STORE_URL") or None
LOCALSEND_URL = "https://localsend.org"
COPYRIGHT_YEAR = 2026

LANGUAGES = ("en", "fr", "de", "es", "it", "pt")
DEFAULT_LANGUAGE = "en"
THEMES = ("light", "dark")
PAGES = ("home", "privacy", "terms", "support")
PATHS = {"home": "", "privacy": "privacy/", "terms": "terms/", "support": "support/"}

# Captures are taken on an iPhone 17 Pro (1206 x 2622) and published at this width.
SHOT_WIDTH = 720
SHOT_HEIGHT = 1565
SHOT_QUALITY = 80
ROOM_STATES = 5


def page_path(language, page):
    """The path of a page, English at the root and the other languages under their code."""
    prefix = "" if language == DEFAULT_LANGUAGE else f"{language}/"
    return f"/{prefix}{PATHS[page]}"


def shot_path(language, theme, name):
    return f"/assets/shots/{language}/{theme}/{name}.webp"
