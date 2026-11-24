"""Makes the three photos sent during the App Store captures.

They only exist to give the transfer a real size: RoomSend shows a symbol and the file names, never
the pictures themselves. Plain gradients with grain, drawn here, so no third-party image is used.
The grain is random: sizes vary by a few kilobytes from one run to the next.

    python3 appstore/tools/make-media.py
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageFilter

OUTPUT_DIR = Path(__file__).resolve().parent / "media"
PHOTO_SIZE = (4032, 3024)
FIRST_NUMBER = 4211
GRAIN_SIGMA = 40
GRAIN_WEIGHT = 0.12
BLUR_RADIUS = 1
JPEG_QUALITY = 92
ROTATION_STEP = 30
PAIRS = (
    ((34, 197, 94), (187, 247, 208)),
    ((250, 204, 21), (251, 146, 60)),
    ((56, 189, 248), (129, 140, 248)),
)


def make_photo(index: int, start: tuple[int, int, int], end: tuple[int, int, int]) -> Image.Image:
    ramp = Image.linear_gradient("L").rotate(ROTATION_STEP * index).resize(PHOTO_SIZE)
    base = Image.composite(Image.new("RGB", PHOTO_SIZE, start), Image.new("RGB", PHOTO_SIZE, end), ramp)
    grain = Image.effect_noise(PHOTO_SIZE, GRAIN_SIGMA).convert("RGB")
    return Image.blend(base, grain, GRAIN_WEIGHT).filter(ImageFilter.GaussianBlur(BLUR_RADIUS))


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for index, (start, end) in enumerate(PAIRS, start=1):
        photo = make_photo(index, start, end)
        photo.save(OUTPUT_DIR / f"IMG_{FIRST_NUMBER + index - 1}.jpg", quality=JPEG_QUALITY)


if __name__ == "__main__":
    main()
