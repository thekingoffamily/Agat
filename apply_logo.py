from pathlib import Path

from PIL import Image

SRC = Path(r"c:\Users\palapalaru\Desktop\CursorRemote\ИИАгат.png")
APP = Path(r"c:\Users\palapalaru\Desktop\CursorRemote\RuStoreApps\04-agat")
BG = (255, 255, 255)


def flatten(im: Image.Image) -> Image.Image:
    im = im.convert("RGBA")
    out = Image.new("RGB", im.size, BG)
    out.paste(im, mask=im.split()[-1])
    return out


def crop_square(rgb: Image.Image, pad_ratio: float = 0.12) -> Image.Image:
    mask = rgb.convert("L").point(lambda p: 255 if p < 248 else 0)
    box = mask.getbbox()
    if not box:
        return rgb
    l, t, r, b = box
    w, h = r - l, b - t
    pad = int(max(w, h) * pad_ratio)
    side = max(w, h) + pad * 2
    cx, cy = (l + r) // 2, (t + b) // 2
    half = side // 2
    sq = (cx - half, cy - half, cx - half + side, cy - half + side)
    canvas = Image.new("RGB", (side, side), BG)
    src = rgb.crop(
        (
            max(0, sq[0]),
            max(0, sq[1]),
            min(rgb.width, sq[2]),
            min(rgb.height, sq[3]),
        )
    )
    canvas.paste(src, (max(0, -sq[0]), max(0, -sq[1])))
    return canvas


def main() -> None:
    rgb = crop_square(flatten(Image.open(SRC)))
    icon = rgb.resize((512, 512), Image.Resampling.LANCZOS)
    branding = APP / "branding"
    branding.mkdir(parents=True, exist_ok=True)
    assets = APP / "app" / "assets"
    assets.mkdir(parents=True, exist_ok=True)
    icon.save(branding / "logo-512.png", optimize=True)
    icon.save(assets / "icon.png", optimize=True)
    print("ok", (branding / "logo-512.png").stat().st_size)


if __name__ == "__main__":
    main()
