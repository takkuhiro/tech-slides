#!/usr/bin/env python3
"""contact_sheet.py — PDF の全ページを一覧画像（コンタクトシート）にする。目視 QA 用。

    python3 scripts/contact_sheet.py deck.pdf [out_dir] [--cols 3] [--per 6] [--width 560]

出力: out_dir/sheet-01.png, sheet-02.png, ...（既定 3列×2行 = 6枚/シート、1枚 560px 幅）
      各シートにはページ番号を焼き込む。個別ページを大きく見たいときは
      `pdftoppm -png -r 96 -f N -l N deck.pdf out_dir/page` を使う。

依存: PyMuPDF（pip install pymupdf）。無ければ pdftoppm + Pillow にフォールバックする。
"""
import sys, os, math, argparse, subprocess, shutil


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("pdf")
    ap.add_argument("out_dir", nargs="?", default=None)
    ap.add_argument("--cols", type=int, default=3)
    ap.add_argument("--per", type=int, default=6)
    ap.add_argument("--width", type=int, default=560)
    a = ap.parse_args()

    out = a.out_dir or (os.path.splitext(a.pdf)[0] + "-preview")
    os.makedirs(out, exist_ok=True)
    for f in os.listdir(out):
        if f.startswith("sheet-") and f.endswith(".png"):
            os.remove(os.path.join(out, f))

    try:
        import fitz  # PyMuPDF
    except ImportError:
        fitz = None

    W = a.width
    H = round(W * 9 / 16)
    pad = 12
    label_h = 30

    if fitz is not None:
        doc = fitz.open(a.pdf)
        n = len(doc)
        sheets = []
        for k in range(0, n, a.per):
            idx = list(range(k, min(k + a.per, n)))
            rows = math.ceil(len(idx) / a.cols)
            sheet = fitz.open()
            page = sheet.new_page(width=a.cols * (W + pad) + pad, height=rows * (H + pad + label_h) + pad)
            for j, i in enumerate(idx):
                x = pad + (j % a.cols) * (W + pad)
                y = pad + (j // a.cols) * (H + pad + label_h)
                rect = fitz.Rect(x, y + label_h, x + W, y + label_h + H)
                page.draw_rect(rect, color=(0.8, 0.8, 0.8), width=0.8)
                page.show_pdf_page(rect, doc, i)
                page.insert_text((x, y + label_h - 8), f"p{i + 1}", fontsize=16, color=(0.2, 0.2, 0.2))
            path = os.path.join(out, f"sheet-{k // a.per + 1:02d}.png")
            page.get_pixmap(dpi=96).save(path)
            sheets.append(path)
        print(f"[sheet] {n} pages → {len(sheets)} sheet(s)")
        for s in sheets:
            print("  " + s)
        return

    # フォールバック: pdftoppm + Pillow
    if shutil.which("pdftoppm") is None:
        sys.exit("PyMuPDF も pdftoppm も無いためコンタクトシートを作れません（pip install pymupdf）")
    from PIL import Image, ImageDraw
    tmp = os.path.join(out, "_pages")
    os.makedirs(tmp, exist_ok=True)
    subprocess.run(["pdftoppm", "-png", "-r", "60", a.pdf, os.path.join(tmp, "p")], check=True)
    files = sorted(f for f in os.listdir(tmp) if f.endswith(".png"))
    for k in range(0, len(files), a.per):
        idx = files[k:k + a.per]
        rows = math.ceil(len(idx) / a.cols)
        img = Image.new("RGB", (a.cols * (W + pad) + pad, rows * (H + pad + label_h) + pad), "white")
        d = ImageDraw.Draw(img)
        for j, f in enumerate(idx):
            x = pad + (j % a.cols) * (W + pad)
            y = pad + (j // a.cols) * (H + pad + label_h)
            im = Image.open(os.path.join(tmp, f)).resize((W, H))
            img.paste(im, (x, y + label_h))
            d.rectangle([x, y + label_h, x + W, y + label_h + H], outline=(200, 200, 200))
            d.text((x, y + 6), f"p{k + j + 1}", fill=(40, 40, 40))
        img.save(os.path.join(out, f"sheet-{k // a.per + 1:02d}.png"))
    shutil.rmtree(tmp)
    print(f"[sheet] {len(files)} pages → {math.ceil(len(files) / a.per)} sheet(s) in {out}")


if __name__ == "__main__":
    main()
