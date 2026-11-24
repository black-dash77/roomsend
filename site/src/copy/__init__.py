"""The site's words, one module per language, all with the same keys."""
from functools import lru_cache
from importlib import import_module


@lru_cache(maxsize=None)
def load(language):
    return import_module(f"{__name__}.{language}").COPY


def check(languages):
    """Fails the build when a language misses a key the English text has, or has one too many."""
    reference = set(load("en"))
    for language in languages:
        keys = set(load(language))
        missing, extra = reference - keys, keys - reference
        assert not missing and not extra, f"copy/{language}: missing {sorted(missing)}, extra {sorted(extra)}"
        for key, value in load(language).items():
            assert "—" not in value, f"copy/{language}: em dash in {key}"
