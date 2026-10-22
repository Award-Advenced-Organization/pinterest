# Assemble les apercus de pages en une planche contact.
import sys, glob
from PIL import Image
files = sorted(glob.glob(sys.argv[1] + "/page-*.png"))
cols = int(sys.argv[3]) if len(sys.argv) > 3 else 6
ims = [Image.open(f) for f in files]
w = max(i.width for i in ims); h = max(i.height for i in ims)
rows = (len(ims) + cols - 1) // cols
sheet = Image.new("RGB", (cols * (w + 10), rows * (h + 10)), "#888")
for k, im in enumerate(ims):
    sheet.paste(im, ((k % cols) * (w + 10), (k // cols) * (h + 10)))
sheet.save(sys.argv[2])
print(sheet.size)
