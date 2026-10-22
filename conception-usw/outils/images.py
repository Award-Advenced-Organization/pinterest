# Prepare les photos de la maquette : les images du fil du projet Pinterest
# (pinterest_api/storage/app/media/pins), reduites et converties en WebP,
# comme le fera la plateforme. Ce sont des photos d'illustration, a remplacer
# par de vraies captures USW.
import sys, os
from PIL import Image
SRC = sys.argv[1]; OUT = sys.argv[2]
CHOIX = [10, 11, 12, 15, 17, 28, 29, 37, 46, 49, 54, 57, 58, 62, 66, 71, 74, 76, 77, 78, 92, 101, 108, 110, 116, 118, 124, 127, 128, 132]
os.makedirs(OUT, exist_ok=True)
total = 0
tailles = {}
for n in CHOIX:
    im = Image.open(os.path.join(SRC, f"{n}.jpg")).convert("RGB")
    im.thumbnail((440, 780))
    p = os.path.join(OUT, f"p{n}.webp")
    im.save(p, "WEBP", quality=62, method=6)
    total += os.path.getsize(p)
    tailles[f"p{n}"] = im.size
    print(f"p{n}", im.size, os.path.getsize(p) // 1024, "Ko")
print("total", total // 1024, "Ko")
import json
json.dump(tailles, open(os.path.join(OUT, "images.json"), "w"), indent=1)
