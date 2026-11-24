"""The privacy policy and the terms of use of RoomSend, in its six languages.

One source for the two places that show them: `tools/strings.py` writes them into the app's
catalog, `site/build.py` renders them as pages. Each language module defines `PRIVACY` and
`TERMS`. A document is a title, a date, an introduction and sections; a section is a heading
and blocks; a block is a paragraph (`str`) or a list (`list` of `str`). Text may hold inline
links written `[label](url)` and the fields `{name}`, `{address}` and `{email}`.
"""
import re
from importlib import import_module

from .publisher import PUBLISHER

LANGUAGES = ("en", "fr", "de", "es", "it", "pt")
DOCUMENTS = ("privacy", "terms")
EM_DASH = "—"
NON_BREAKING_HYPHEN = "\u2011"
EMAIL_LABEL = re.compile(r"\[([^\]]*@[^\]]*)\]")


def load(language):
    """Both documents of one language, filled with the publisher's identity."""
    empty = [field for field, value in PUBLISHER.items() if not value]
    if empty or not PUBLISHER["address"].get(language):
        raise SystemExit(f"legal: fill {empty or ['address']} in tools/legal/publisher.py")
    values = {"name": PUBLISHER["name"], "email": PUBLISHER["email"], "address": PUBLISHER["address"][language]}
    module = import_module(f"{__name__}.{language}")
    return {document: _fill(getattr(module, document.upper()), values) for document in DOCUMENTS}


def to_markdown(document):
    """The plain format the app reads: `## ` opens a section, `- ` a list item. The title and
    the date have keys of their own."""
    parts = [document["intro"]]
    for heading, blocks in document["sections"]:
        parts.append(f"## {heading}")
        for block in blocks:
            parts.append("\n".join(f"- {item}" for item in block) if isinstance(block, list) else block)
    return EMAIL_LABEL.sub(keep_together, "\n\n".join(parts))


def keep_together(match):
    """An address shown as a link never breaks at its hyphen on a narrow screen."""
    return "[" + match.group(1).replace("-", NON_BREAKING_HYPHEN) + "]"


def _fill(document, values):
    def text(value):
        filled = value.format_map(values)
        assert EM_DASH not in filled, f"em dash in: {filled[:60]}"
        return filled

    def block(value):
        return [text(item) for item in value] if isinstance(value, list) else text(value)

    return {
        "title": text(document["title"]),
        "updated": text(document["updated"]),
        "intro": text(document["intro"]),
        "sections": [(text(heading), [block(item) for item in blocks]) for heading, blocks in document["sections"]],
    }
