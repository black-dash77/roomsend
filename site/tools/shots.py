"""Turns the raw simulator captures into the site's images.

    python3 tools/shots.py

Reads `tools/capture/raw/<lang>/<theme>/<name>.png` (1206 x 2622, iPhone 17 Pro) and writes
`src/shots/<lang>/<theme>/<name>.webp` at the published width. Nothing is retouched: the
capture is only resized.
"""
import os
import sys

from PIL import Image

SITE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, SITE)

from src import config  # noqa: E402

RAW = os.path.join(SITE, "tools", "capture", "raw")
OUT = os.path.join(SITE, "src", "shots")


def main():
    count = 0
    for folder, _, files in os.walk(RAW):
        for name in sorted(files):
            if not name.endswith(".png"):
                continue
            relative = os.path.relpath(os.path.join(folder, name), RAW)
            target = os.path.join(OUT, relative[: -len(".png")] + ".webp")
            os.makedirs(os.path.dirname(target), exist_ok=True)
            image = Image.open(os.path.join(folder, name)).convert("RGB")
            image = image.resize((config.SHOT_WIDTH, config.SHOT_HEIGHT), Image.LANCZOS)
            image.save(target, "WEBP", quality=config.SHOT_QUALITY, method=6)
            count += 1
    print(f"shots: {count} images in {OUT}")


if __name__ == "__main__":
    main()
