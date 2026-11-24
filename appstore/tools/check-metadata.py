"""Checks the App Store texts of appstore/metadata/<language>.md against Apple's limits.

Limits from App Store Connect Help (Platform version information, App information), read on
21.11.2026: name 2 to 30 characters, subtitle 30, promotional text 170, description 4000,
keywords 100 bytes with each keyword longer than two characters, What's New 4000.

    python3 appstore/tools/check-metadata.py
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass
from pathlib import Path

METADATA_DIR = Path(__file__).resolve().parent.parent / "metadata"
LANGUAGES = ("en", "fr", "de", "es", "it", "pt")
FIELDS = ("name", "subtitle", "promo", "description", "keywords", "whats_new")
CHARACTER_LIMITS = {"subtitle": 30, "promo": 170, "description": 4000, "whats_new": 4000}
NAME_RANGE = (2, 30)
KEYWORD_BYTE_LIMIT = 100
KEYWORD_MIN_LENGTH = 3
EM_DASH = "—"
FORBIDDEN_IN_KEYWORDS = ("roomsend", "localsend", "airdrop", "android", "nearby share")
FORBIDDEN_IN_NAME_AND_SUBTITLE = ("localsend",)
BLOCK_PATTERN = re.compile(r"```text\n(.*?)\n```", re.DOTALL)
WORD_PATTERN = re.compile(r"[^\W\d_]+", re.UNICODE)


@dataclass(frozen=True)
class Measure:
    field: str
    size: int
    limit: int
    unit: str

    @property
    def is_within(self) -> bool:
        return self.size <= self.limit


def main() -> int:
    problems: list[str] = []
    for language in LANGUAGES:
        fields = read_fields(language)
        measures = measure(fields)
        print(f"\n{language}")
        for item in measures:
            mark = "ok " if item.is_within else "TOO LONG"
            print(f"  {mark:8} {item.field:12} {item.size:5} / {item.limit} {item.unit}")
            if not item.is_within:
                problems.append(f"{language}: {item.field} is {item.size} {item.unit} (limit {item.limit})")
        problems += [f"{language}: {problem}" for problem in content_problems(fields)]
    print()
    for problem in problems:
        print(f"PROBLEM {problem}")
    print("all limits respected" if not problems else f"{len(problems)} problem(s)")
    return 1 if problems else 0


def read_fields(language: str) -> dict[str, str]:
    blocks = BLOCK_PATTERN.findall((METADATA_DIR / f"{language}.md").read_text(encoding="utf-8"))
    if len(blocks) != len(FIELDS):
        raise SystemExit(f"{language}.md has {len(blocks)} text blocks, {len(FIELDS)} expected")
    return dict(zip(FIELDS, blocks))


def measure(fields: dict[str, str]) -> list[Measure]:
    measures = [Measure("name", len(fields["name"]), NAME_RANGE[1], "chars")]
    measures += [Measure(field, len(fields[field]), limit, "chars") for field, limit in CHARACTER_LIMITS.items()]
    measures.append(Measure("keywords", len(fields["keywords"].encode("utf-8")), KEYWORD_BYTE_LIMIT, "bytes"))
    return measures


def content_problems(fields: dict[str, str]) -> list[str]:
    problems = []
    if len(fields["name"]) < NAME_RANGE[0]:
        problems.append("name is shorter than two characters")
    keywords = fields["keywords"].split(",")
    title_words = set(WORD_PATTERN.findall(f"{fields['name']} {fields['subtitle']}".lower()))
    for keyword in keywords:
        if keyword != keyword.strip():
            problems.append(f"keyword '{keyword}' has spaces around it")
        if len(keyword.strip()) < KEYWORD_MIN_LENGTH:
            problems.append(f"keyword '{keyword}' has two characters or fewer")
        if keyword.strip().lower() in title_words:
            problems.append(f"keyword '{keyword}' repeats a word of the name or subtitle")
        if any(term in keyword.lower() for term in FORBIDDEN_IN_KEYWORDS):
            problems.append(f"keyword '{keyword}' names another app, brand or platform")
    if len(set(keywords)) != len(keywords):
        problems.append("a keyword appears twice")
    head = f"{fields['name']} {fields['subtitle']}".lower()
    problems += [f"name or subtitle mentions '{term}'" for term in FORBIDDEN_IN_NAME_AND_SUBTITLE if term in head]
    problems += [f"{field} contains an em dash" for field, text in fields.items() if EM_DASH in text]
    return problems


if __name__ == "__main__":
    sys.exit(main())
