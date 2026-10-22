# Extrait les images du cahier des charges d'origine (logos UAC et IFRI)
# et releve les polices utilisees.
import sys, fitz
src, out = sys.argv[1], sys.argv[2]
doc = fitz.open(src)
fonts = set()
for p in doc:
    for f in p.get_fonts():
        fonts.add(f[3])
print("polices:", sorted(fonts))
page = doc[0]
for i, img in enumerate(page.get_images(full=True)):
    xref = img[0]
    pix = doc.extract_image(xref)
    rect = page.get_image_rects(xref)
    name = f"{out}/logo-{i}.{pix['ext']}"
    open(name, "wb").write(pix["image"])
    print(name, pix["width"], pix["height"], rect)
