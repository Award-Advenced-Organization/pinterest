# Ecrit le balisage des cartes de la mosaique (photos d'illustration,
# lieux du Benin, telephones courants), pour ne pas le recopier a la main.
import sys
CARTES = [
  ("p110", "Parc de la Pendjari", "Tecno Camon 20 Pro", "0:24", True),
  ("p108", "Plage de Grand-Popo", "iPhone 14 Pro", None, True),
  ("p124", "Lac Ahémé, Possotomè", "Samsung Galaxy A54", None, True),
  ("p15",  "Cascade de Kota", "Infinix Note 30", "0:41", True),
  ("p77",  "Ponton de Ouidah", "itel S23", None, False),
  ("p62",  "Collines de Dassa-Zoumè", "Tecno Spark 20", None, True),
  ("p92",  "Plage de Fidjrossè", "Samsung Galaxy A15", "0:17", True),
  ("p58",  "Phare de Cotonou", "iPhone 12", None, False),
  ("p116", "Route des pêches", "Tecno Camon 20", None, True),
  ("p37",  "Côte de Sèmè-Podji", "Infinix Hot 40", None, True),
  ("p71",  "Rives du lac Nokoué", "Redmi Note 13", "0:33", True),
  ("p54",  "Mont Sokbaro", "Tecno Pova 6", None, True),
]
def carte(i, ph, lieu, tel, duree, verifie):
    haut = ""
    if duree:
        haut = (f'<span class="duree">{duree}</span>'
                '<span class="son"><svg class="ic"><use href="#i-muet"/></svg></span>')
    badge = ('<span class="badge verifie"><svg class="ic"><use href="#i-verifie"/></svg>Vérifiée</span>'
             if verifie else "")
    return f'''      <article class="carte" style="--n:{i}">
        <div class="carte-image"><span class="photo ph-{ph}"></span>{haut}{badge}</div>
        <div class="carte-pied">
          <div><div class="carte-lieu">{lieu}</div><div class="carte-appareil"><svg class="ic mini"><use href="#i-telephone"/></svg>{tel}</div></div>
          <svg class="ic petite"><use href="#i-plus-points"/></svg>
        </div>
      </article>'''
debut, fin = int(sys.argv[1]), int(sys.argv[2])
print("\n".join(carte(i, *c) for i, c in enumerate(CARTES[debut:fin])))
