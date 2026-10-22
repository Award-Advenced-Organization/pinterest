# Rend chaque page d'un PDF en PNG (controle visuel) et compte les pages.
import sys, fitz
doc = fitz.open(sys.argv[1])
out = sys.argv[2]
print("pages:", doc.page_count)
pages = [int(p) for p in sys.argv[3].split(",")] if len(sys.argv) > 3 else range(doc.page_count)
for i in pages:
    doc[i].get_pixmap(dpi=60).save(f"{out}/page-{i+1:02d}.png")
