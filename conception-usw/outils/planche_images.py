# Planche des rendus PNG, reduits, pour un controle d'un coup d'oeil.
import sys, glob
from PIL import Image
files = [f for f in sorted(glob.glob(sys.argv[1] + "/cas-*.png"))]
ims = []
for f in files:
    im = Image.open(f); im.thumbnail((900, 900)); ims.append(im)
W = sum(i.width for i in ims[:3]) + 40; 
rows = [ims[:3], ims[3:]]
H = sum(max(i.height for i in r) for r in rows if r) + 30
sheet = Image.new("RGB", (W, H), "white")
y = 0
for r in rows:
    x = 0
    for im in r:
        sheet.paste(im, (x, y)); x += im.width + 20
    y += max(i.height for i in r) + 30
sheet.save(sys.argv[2]); print(sheet.size)
