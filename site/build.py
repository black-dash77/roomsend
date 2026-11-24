"""Builds the RoomSend site into `site/public`, static files only.

    python3 build.py

Reads the words in `src/copy`, the legal texts in `tools/legal` (the ones the app shows), the
avatars computed by the app's own code, and the captures in `src/shots`. Fails on a missing
translation, a missing capture or a link to a file that does not exist.
"""
import json
import os
import re
import shutil
import sys

SITE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, SITE)

from src import assets, config, sources  # noqa: E402
from src.copy import check, load  # noqa: E402
from src.render import home, layout, pages  # noqa: E402

# Overridable only to try the layout elsewhere; a deploy always builds from the defaults.
PUBLIC = os.environ.get("ROOMSEND_PUBLIC_DIR", os.path.join(SITE, "public"))
SHOTS = os.environ.get("ROOMSEND_SHOTS_DIR", os.path.join(SITE, "src", "shots"))
LOCAL_REFERENCE = re.compile(r'(?:src|href)="(/[^"#?]*)"')


def main():
    check(config.LANGUAGES)
    with open(os.path.join(SHOTS, "manifest.json"), encoding="utf-8") as handle:
        shots = json.load(handle)
    peers = sources.devices(shots)
    if os.path.exists(PUBLIC):
        shutil.rmtree(PUBLIC)
    assets.write_static(PUBLIC)
    shutil.copytree(SHOTS, os.path.join(PUBLIC, "assets", "shots"), ignore=shutil.ignore_patterns("*.json"))
    assets.write_share_images(PUBLIC, SHOTS)
    for language in config.LANGUAGES:
        build_language(language, load(language), sources.legal.load(language), peers, shots)
    english = load(config.DEFAULT_LANGUAGE)
    write("404.html", layout.page(config.DEFAULT_LANGUAGE, "home", english, english["notfound.title"],
                                  english["meta.home.description"], pages.not_found(english), indexable=False))
    verify_references()
    print(f"site: {len(config.LANGUAGES) * len(config.PAGES)} pages in {PUBLIC}")


def build_language(language, copy, legal, peers, shots):
    write_page(language, "home", copy["meta.home.title"], copy["meta.home.description"],
               home.body(language, copy, peers, shots), copy)
    for name in ("privacy", "terms"):
        document = legal[name]
        write_page(language, name, f"{document['title']} · RoomSend", copy[f"meta.{name}.description"],
                   pages.legal(language, copy, document, name), copy)
    write_page(language, "support", copy["meta.support.title"], copy["meta.support.description"],
               pages.support(language, copy), copy)


def write_page(language, key, title, description, body, copy):
    path = config.page_path(language, key).strip("/")
    write(os.path.join(path, "index.html"), layout.page(language, key, copy, title, description, body))


def write(relative, text):
    target = os.path.join(PUBLIC, relative)
    os.makedirs(os.path.dirname(target), exist_ok=True)
    with open(target, "w", encoding="utf-8") as handle:
        handle.write(text)


def verify_references():
    """Every local `src` and `href` of every page must lead to a file of the build."""
    broken = set()
    for folder, _, files in os.walk(PUBLIC):
        for name in files:
            if not name.endswith(".html"):
                continue
            with open(os.path.join(folder, name), encoding="utf-8") as handle:
                text = handle.read()
            references = LOCAL_REFERENCE.findall(text) + re.findall(r'(/assets/shots/[^"&]+\.webp)', text)
            for reference in references:
                target = os.path.join(PUBLIC, reference.lstrip("/"))
                if reference.endswith("/"):
                    target = os.path.join(target, "index.html")
                if not os.path.exists(target):
                    broken.add(reference)
    assert not broken, f"missing files: {sorted(broken)}"


if __name__ == "__main__":
    main()
