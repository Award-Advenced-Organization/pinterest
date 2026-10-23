"""Ecrit les feuilles et les dernieres pages, dans maquette/ecrans/ : filtres
du flux (E04), commentaires (E07), telecharger l original (E08), enregistrer
(E09), partager (E10), carte des reels (E11), collection (E19), signaler
(E22), regles communautaires (E23), moderation (E24, E25), confidentialite
(E38).

Une feuille monte du bas, sur la page d ou elle vient ; on la ferme en la
glissant vers le bas. Une seule action principale par feuille.

  python outils/ecrans_feuilles.py
"""

import re

from ecrans_compte import ECRANS, BOUTON, document_vivant, ecrire, ic, mots, page
from ecrans_creer import modele, plan
from ecrans_profil import carte, PUBLICATIONS, bouton


def lire(nom):
    return (ECRANS / nom).read_text(encoding='utf-8')


def sur(base, feuille):
    """Pose une feuille et son fond sur une page existante."""
    html = re.sub(r'\s*<script>.*?</script>', '', lire(base), flags=re.S)
    fin = html.rstrip().rfind('</div>')
    return html[:fin] + '  <div class="feuille-fond"></div>\n' + feuille + '\n</div>\n'


def feuille(contenu, titre, classe='', fermer=True):
    croix = f'<button type="button" class="rond-verre verre verre-appuyable petit-rond" aria-label="Fermer">{ic("fermer")}</button>' if fermer else ''
    return f'''  <div class="feuille verre-plaque{(" " + classe) if classe else ""}" role="dialog" aria-label="{titre}">
    <span class="feuille-poignee"></span>
    <div class="feuille-tete"><h2>{titre}</h2>{croix}</div>
{contenu}
  </div>'''


def pastilles(noms, choisies=()):
    return ''.join(f'<button type="button" class="pastille verre verre-appuyable"{" aria-checked=\"true\"" if n in choisies else ""}>{n}</button>' for n in noms)


def av(initiales, teinte, classe=''):
    return f'<span class="avatar{(" " + classe) if classe else ""}" style="--teinte:{teinte}">{initiales}</span>'


# ------------------------------------------------------------ E04 filtres du flux

FILTRES = sur('e03-accueil.html', feuille(f'''    <section class="filtre-groupe">
      <h3>Pays</h3>
      <div class="champ verre">{ic("globe")}<span class="champ-valeur">Bénin</span>{ic("chevron-bas", "petite")}</div>
    </section>
    <section class="filtre-groupe">
      <h3>Ville</h3>
      <div class="pastilles">{pastilles(["Toutes", "Cotonou", "Ouidah", "Grand-Popo", "Porto-Novo", "Natitingou"], ["Toutes"])}</div>
    </section>
    <section class="filtre-groupe">
      <h3>Type de lieu <span>2 choisis</span></h3>
      <div class="pastilles">{pastilles(["Plages", "Nature", "Cascades", "Villes", "Monuments", "Marchés", "Lacs"], ["Plages", "Nature"])}</div>
    </section>
    <section class="filtre-groupe">
      <h3>Distance <span>À moins de 50 km</span></h3>
      <div class="curseur-rayon" role="slider" aria-valuetext="50 km"><span class="rail"><span class="rail-plein" style="--p:34%"></span></span><span class="bouton-rayon" style="--p:34%"></span></div>
      <div class="rayon-reperes"><span>5 km</span><span>50 km</span><span>Tout le pays</span></div>
    </section>
    <div class="filtre-ligne"><div><strong>Captures vérifiées seulement</strong><span>Lues dans le fichier, pas déclarées</span></div><span class="interrupteur" role="switch" aria-checked="false"></span></div>
    <div class="feuille-pied"><button type="button" class="lien-encre">Tout effacer</button>{bouton("Voir 186 lieux", plein=True)}</div>''',
    'Filtres', 'feuille-filtres'))


# ------------------------------------------------------------ E07 commentaires

def commentaire(initiales, teinte, nom, texte, quand, aimes, aime=False, epingle=False, auteur=False, reponses='', classe=''):
    marque = '<span class="marque-auteur">Auteur</span>' if auteur else ''
    tete = f'<span class="epingle">{ic("drapeau", "mini")}Épinglé par l\'auteur</span>' if epingle else ''
    return f'''      <div class="avis{(" " + classe) if classe else ""}">
        {av(initiales, teinte, "petit")}
        <div class="avis-corps">
          {tete}<p><b>{nom}</b>{marque} {texte}</p>
          <div class="avis-pied"><span>{quand}</span><button type="button">Répondre</button></div>{reponses}
        </div>
        <button type="button" class="avis-aime{" aime" if aime else ""}" aria-label="J'aime">{ic("coeur")}<span>{aimes}</span></button>
      </div>'''


REPONSES = f'''
          <div class="reponses">
{commentaire("SV", "hsl(160 55% 34%)", "Sènan Voyage", "<a class=\"mention\">@mawuli.s</a> merci ! On repasse en décembre pour les tortues.", "1 h", "12")}
            <button type="button" class="voir-reponses"><span></span>Voir 1 autre réponse</button>
          </div>'''

COMMENTAIRES = sur('e05-photo.html', feuille(f'''    <div class="avis-liste">
{commentaire("AK", "hsl(18 70% 52%)", "Akouavi K.", "Le chemin se prend à pied depuis le parking de l'hôtel, comptez dix minutes.", "2 j", "86", epingle=True, auteur=True)}
{commentaire("MS", "hsl(229 97% 55%)", "Mawuli S.", "On y était dimanche avec <a class=\"mention\">@senan.voyage</a>, c'est exactement ça.", "3 h", "24", aime=True, reponses=REPONSES)}
{commentaire("EA", "hsl(280 40% 50%)", "Edem A.", "Il y a des moustiques le soir ? On pense y dormir en septembre.", "5 h", "3")}
{commentaire("FH", "hsl(40 80% 45%)", "Fifamè H.", "La lumière à cette heure-là, rien à dire.", "8 h", "9")}
    </div>
    <div class="saisie-bloc">
      <div class="mentions verre-plaque" role="listbox" aria-label="Mentionner">
        <div class="mention-ligne choisie">{av("SV", "hsl(160 55% 34%)", "petit")}<div><strong>senan.voyage</strong><span>Sènan Voyage · vous suit</span></div></div>
        <div class="mention-ligne">{av("SA", "hsl(330 50% 50%)", "petit")}<div><strong>sena.adjovi</strong><span>Séna Adjovi</span></div></div>
      </div>
      <div class="repondre-a">Réponse à <b>Edem A.</b><button type="button" aria-label="Annuler la réponse">{ic("fermer", "mini")}</button></div>
      <div class="saisie">{av("JD", "hsl(200 60% 40%)", "petit")}<div class="champ verre focus"><span class="champ-valeur">Oui, prenez un répulsif <span class="mention">@sen</span></span><span class="curseur"></span></div>
        <button type="button" class="rond-verre verre verre-appuyable envoyer" aria-label="Envoyer">{ic("envoyer")}</button></div>
    </div>''', '48 commentaires', 'haute feuille-avis'))


# ------------------------------------------------------------ E08 telecharger l original

TELECHARGER = sur('e05-photo.html', feuille(f'''    <div class="fichier-ligne"><span class="photo ph-p108"></span><div><strong>IMG_20260314_175212.jpg</strong><span>JPEG · 4 032 × 3 024 · 12,2 Mpx</span><span>iPhone 14 Pro · 14 mars 2026</span></div></div>
    <div class="modeles verre-plaque choix-taille">
      {modele("Original · 4,8 Mo", "Tel que pris, avec ses informations de capture", True)}
      {modele("Taille écran · 420 Ko", "2 160 px, léger, sans les informations du fichier")}
    </div>
    <div class="avertissement">{ic("alerte")}<p><strong>Vous êtes en 3G</strong>Environ 1 min 20 pour l'original. S'il coupe, le téléchargement reprend seul.</p></div>
    <div class="filtre-ligne"><div><strong>Attendre le Wi-Fi</strong><span>Il partira dès que vous serez connecté</span></div><span class="interrupteur" role="switch" aria-checked="false"></span></div>
    <p class="feuille-note">Pour un usage personnel. Pour toute autre utilisation, demandez l'accord d'Akouavi K.</p>
    {bouton("Télécharger · 4,8 Mo", plein=True, icone="telecharger")}''',
    "Télécharger l'original", 'feuille-large'))


# ------------------------------------------------------------ E09 enregistrer

def collection(n, photos, nom, detail, choisie=False, secrete=False):
    vignettes = ''.join(f'<span class="photo ph-{p}"></span>' for p in photos)
    cadenas = ic("cadenas", "mini") if secrete else ''
    fin = f'<span class="coche-ronde">{ic("coche")}</span>' if choisie else ''
    return (f'      <div class="collection-ligne{" choisie" if choisie else ""}" style="--n:{n}"><span class="collection-vignettes">{vignettes}</span>'
            f'<div><strong>{nom}</strong><span>{cadenas}{detail}</span></div>{fin}</div>')


ENREGISTRER = sur('e05-photo.html', feuille(f'''    <div class="collections">
{collection(0, ["p108", "p92", "p12"], "Plages", "25 publications · à l'instant", choisie=True)}
{collection(1, ["p15", "p28", "p10"], "Nord du Bénin", "31 publications")}
{collection(2, ["p77", "p58", "p62"], "À visiter en décembre", "12 publications · secrète", secrete=True)}
{collection(3, ["p124", "p71", "p76"], "Lacs et lagunes", "8 publications")}
    </div>
    <button type="button" class="nouvelle-collection">{ic("plus")}Créer une collection</button>''',
    'Enregistrer dans'))


# ------------------------------------------------------------ E10 partager

def appli(icone, nom, classe=''):
    return f'<button type="button" class="appli"><span class="appli-icone{(" " + classe) if classe else ""}">{ic(icone)}</span>{nom}</button>'


def membre(initiales, teinte, nom, choisi=False):
    coche = f'<span class="membre-coche">{ic("coche")}</span>' if choisi else ''
    return (f'<button type="button" class="membre{" choisi" if choisi else ""}" aria-pressed="{"true" if choisi else "false"}">'
            f'<span class="membre-avatar">{av(initiales, teinte)}{coche}</span><span>{nom}</span></button>')


# Le premier rond : chercher un membre qui n est pas dans les recents.
CHERCHER_MEMBRE = f'<button type="button" class="membre chercher"><span class="membre-avatar">{ic("loupe")}</span><span>Rechercher</span></button>'


PARTAGER = sur('e05-photo.html', feuille(f'''    <div class="partage-apercu"><span class="photo ph-p108"></span><div><strong>Les cocotiers de Grand-Popo</strong><span>Akouavi K. · Capture vérifiée</span><span class="lien-court">usw.app/p/k3x9</span></div></div>
    <h3 class="feuille-sous-titre">Envoyer à un membre</h3>
    <div class="membres">{CHERCHER_MEMBRE}{membre("MS", "hsl(229 97% 55%)", "Mawuli")}{membre("SV", "hsl(160 55% 34%)", "Sènan")}{membre("FH", "hsl(40 80% 45%)", "Fifamè")}{membre("EA", "hsl(280 40% 50%)", "Edem")}</div>
    <h3 class="feuille-sous-titre">Partager avec</h3>
    <div class="applis">{appli("whatsapp", "WhatsApp", "marque")}{appli("lien", "Copier le lien")}{appli("envoyer", "Message")}{appli("enveloppe", "E-mail")}{appli("plus-points", "Autres")}</div>
    <p class="feuille-note">Le lien ouvre la photo, même sans l'application.</p>''',
    'Partager'))


# ------------------------------------------------------------ E22 signaler

MOTIFS = [
    ("Image générée ou retouchée par IA", ""),
    ("Pas pris à cet endroit", "Le lieu indiqué est faux"),
    ("Ce n'est pas son auteur", "Le contenu appartient à quelqu'un d'autre"),
    ("Contenu choquant ou violent", ""),
    ("Harcèlement ou propos haineux", ""),
    ("Spam ou arnaque", ""),
]

SIGNALER = sur('e06-reels.html', feuille(f'''    <p class="feuille-texte">Votre signalement reste anonyme. L'équipe le vérifie sous 24 h et vous tient au courant.</p>
    <div class="modeles verre-plaque motifs">
      {"".join(modele(m, d, i == 1) for i, (m, d) in enumerate(MOTIFS))}
    </div>
    <div class="champ verre zone">{ic("crayon")}<span class="champ-valeur multi">La vidéo montre la cascade de Tanougou, pas celle de Kota.</span></div>
    <p class="feuille-note">Voir les <a class="lien-encre">règles communautaires</a>.</p>
    <button type="button" class="bouton-verre verre verre-appuyable plein large rouge"><span class="bouton-verre-texte">Envoyer le signalement</span></button>''',
    'Signaler ce reel', 'feuille-signaler feuille-large'))


# ------------------------------------------------------------ E11 carte des reels

# Les contenus poses sur la carte : x, y en %, photo, reel ou non.
REPERES = [
    (22, 30, 'p15', True), (64, 22, 'p110', False), (78, 44, 'p28', True),
    (30, 52, 'p92', False), (52, 63, 'p108', True), (14, 70, 'p124', False),
]


def repere(n, x, y, photo, reel, choisi=False):
    lecture = f'<span class="repere-reel">{ic("lecture")}</span>' if reel else ''
    return (f'  <button type="button" class="repere-contenu{" choisi" if choisi else ""}" style="--x:{x}%;--y:{y}%;--n:{n}" aria-label="Voir le contenu">'
            f'<span class="photo ph-{photo}"></span>{lecture}</button>')


CARTE = f'''<div class="app fixe carte-reels">
  {plan()}
  <!--barre-etat-->
  <div class="carte-haut">
    <div class="lieu-haut-ligne">
      <div class="champ verre givre-champ">{ic("loupe")}<span class="champ-place">Rechercher un lieu</span></div>
      <button type="button" class="rond-verre verre verre-appuyable givre" aria-label="Filtres">{ic("filtres")}</button>
    </div>
    <div class="filtres">{pastilles(["Tout", "Reels", "Photos", "Captures vérifiées"], ["Reels"])}</div>
  </div>
{chr(10).join(repere(i, *r, choisi=(i == 4)) for i, r in enumerate(REPERES))}
  <span class="groupe-reperes" style="--x:86%;--y:72%">14</span>
  <span class="ma-position-point" style="--x:46%;--y:80%"></span>
  <button type="button" class="rond-verre verre verre-appuyable givre ma-position" aria-label="Ma position">{ic("cible")}</button>
  <div class="carte-apercu verre-plaque">
    <span class="photo ph-p108"><span class="duree">0:24</span></span>
    <div class="apercu-texte">
      <strong>Plage de Grand-Popo</strong>
      <span>{ic("telephone", "mini")}Tecno Camon 50 Pro · senan.voyage</span>
      <span class="badge verifie">{ic("verifie")}Capture vérifiée</span>
      <div class="apercu-actions">{bouton("Voir le reel")}{bouton("Y aller · 38 km", plein=True, icone="y-aller")}</div>
    </div>
  </div>
  <!--onglets:carte-->
</div>
'''


# ------------------------------------------------------------ E19 une collection

COLLECTION = f'''<div class="app profil-page">
  <!--barre-etat-->
  <div class="page-haut profil-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Retour">{ic("retour")}</button>
    <span class="espace"></span>
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Partager la collection">{ic("partager")}</button>
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Plus d'options">{ic("plus-points")}</button>
  </div>
  <section class="collection-tete">
    <div class="collection-couverture"><span class="photo ph-p108"></span><span class="photo ph-p92"></span><span class="photo ph-p12"></span></div>
    {mots("Plages", classe="profil-nom")}
    <p class="profil-pseudo">{ic("cadenas", "mini")}Secrète · 25 publications</p>
    <div class="profil-actions">{bouton("Renommer", icone="crayon")}{bouton("Rendre publique", icone="globe")}</div>
  </section>
  <nav class="flux mots profil-flux" aria-label="Contenus">
    <span aria-current="true" class="m"><span style="--k:0">Tout</span></span>
    <span class="m"><span style="--k:1">Photos</span></span>
    <span class="m"><span style="--k:2">Reels</span></span>
  </nav>
  <main class="mosaique">
{chr(10).join(carte(i, *c) for i, c in enumerate(PUBLICATIONS))}
  </main>
  <!--onglets:profil-->
</div>
'''


# ------------------------------------------------------------ E23 regles communautaires

REGLES = [
    ('camera', 'Pris sur place, par vous', "Publiez ce que vous avez photographié ou filmé vous-même, à l'endroit indiqué. Une photo ancienne est bienvenue.",
     "Votre photo de la plage de Fidjrossè, prise dimanche.", "Une image trouvée sur Internet ou envoyée par un ami."),
    ('etincelle', 'Pas d\'image générée', "USW montre des lieux tels qu'ils sont. Les images créées ou transformées par une IA sont refusées.",
     "Recadrer, redresser, régler la lumière.", "Remplacer le ciel, ajouter ou effacer des éléments."),
    ('lieu', 'Des informations vraies', "Le lieu, la date et le téléphone aident les autres à y aller. Indiquez-les tels qu'ils sont.",
     "« Cascade de Tanougou » pour une vidéo de Tanougou.", "Un lieu célèbre pour attirer plus de vues."),
    ('profil', 'Le respect des personnes', "Demandez avant de photographier quelqu'un de près. Pas d'insulte, de moquerie ni de harcèlement.", "", ""),
    ('bouclier', 'Les lieux sacrés et privés', "Respectez les lieux où la photo est interdite, comme certaines forêts sacrées. Ne montrez pas l'adresse d'une maison.", "", ""),
    ('drapeau', 'Pas de spam', "Pas de publicité déguisée, de faux comptes ni de liens trompeurs.", "", ""),
]

SANCTIONS = [
    ('1', 'Le contenu est retiré', "Vous recevez le motif et pouvez demander une vérification."),
    ('2', 'Le compte est suspendu 7 jours', "Après plusieurs retraits dans l'année."),
    ('3', 'Le compte est supprimé', "En cas de manquement grave ou répété."),
]


def regles():
    blocs = []
    for i, (icone, titre, texte, oui, non) in enumerate(REGLES):
        exemples = ''
        if oui:
            exemples = (f'<div class="exemples"><p class="oui">{ic("coche", "mini")}{oui}</p>'
                        f'<p class="non">{ic("fermer", "mini")}{non}</p></div>')
        blocs.append(f'''    <section class="regle" style="--n:{i}">
      <span class="regle-icone">{ic(icone)}</span>
      <div><h2>{titre}</h2><p>{texte}</p>{exemples}</div>
    </section>''')
    etapes = ''.join(f'<li><span class="numero">{n}</span><div><strong>{t}</strong><span>{d}</span></div></li>' for n, t, d in SANCTIONS)
    return page(f'''  <div class="document-tete">
    {document_vivant()}
    {mots("Règles communautaires")}
    <p class="page-texte">Six règles pour que chaque photo dise vrai · 3 min de lecture</p>
  </div>
  <main class="regles">
{chr(10).join(blocs)}
  </main>
  <h2 class="section-titre">Si une règle n'est pas respectée</h2>
  <ol class="sanctions verre-plaque">{etapes}</ol>
  <p class="pied-page">Voir aussi les <a class="lien">conditions générales</a> et la <a class="lien">politique de confidentialité</a>.</p>''', classe='lecture')


# ------------------------------------------------------------ E38 confidentialite

EN_BREF = [
    "Nous ne vendons pas vos données et ne montrons pas de publicité ciblée.",
    "La position n'est lue qu'au moment de publier, dans le fichier de la photo.",
    "Vous pouvez tout télécharger ou tout supprimer, à tout moment.",
]
DONNEES = [
    ('enveloppe', 'E-mail et mot de passe', 'Vous connecter', 'Tant que le compte existe'),
    ('lieu', 'Position de la prise', 'Afficher le lieu, Y aller', 'Avec la publication'),
    ('telephone', 'Modèle du téléphone, date', 'Les informations de capture', 'Avec la publication'),
    ('image', 'Fichiers originaux', "Le téléchargement de l'original", 'Avec la publication'),
    ('drapeau', 'Signalements', 'La modération', '1 an'),
]


def confidentialite():
    bref = ''.join(f'<li>{ic("coche", "mini")}{t}</li>' for t in EN_BREF)
    lignes = ''.join(f'<div class="donnee">{ic(i)}<div><strong>{d}</strong><span>{p}</span></div><span class="duree-garde">{g}</span></div>' for i, d, p, g in DONNEES)
    return page(f'''  <div class="document-tete">
    {document_vivant()}
    {mots("Politique de confidentialité")}
    <p class="page-texte">En vigueur le 22 octobre 2026 · 3 min de lecture</p>
  </div>
  <section class="en-bref verre-plaque"><h2>En bref</h2><ul>{bref}</ul></section>
  <h2 class="section-titre">Ce que nous gardons, et pourquoi</h2>
  <div class="donnees verre-plaque">{lignes}</div>
  <main class="document">
    <section class="article" style="--n:0">
      <h2><span class="numero">1</span>Ce que les autres voient</h2>
      <p>Votre nom, votre photo de profil, vos publications et leurs informations de capture. Une collection secrète n'est visible que par vous.</p>
    </section>
    <section class="article" style="--n:1">
      <h2><span class="numero">2</span>Les copies pour l'écran</h2>
      <p>Les versions légères affichées dans l'application ne contiennent aucune information du fichier. Seul l'original les garde.</p>
    </section>
    <section class="article" style="--n:2">
      <h2><span class="numero">3</span>Vos droits</h2>
      <p>Vous pouvez consulter, corriger, télécharger ou supprimer vos données. Vous pouvez aussi saisir l'Autorité de protection des données personnelles (APDP).</p>
    </section>
  </main>
  <div class="droits">
    {bouton("Télécharger mes données", icone="telecharger")}
    <button type="button" class="supprimer">Supprimer mon compte</button>
  </div>
  <p class="pied-page">Une question : <span class="lien">vie-privee@usw.app</span></p>''', classe='lecture')


# ------------------------------------------------------------ E24 moderation, la file

def dossier(n, photo, titre, auteur, raison, icone, quand, classe=''):
    return f'''    <div class="dossier" style="--n:{n}">
      <span class="photo ph-{photo}"></span>
      <div class="dossier-texte"><strong>{titre}</strong><span>{auteur}</span><span class="raison {classe}">{ic(icone, "mini")}{raison}</span></div>
      <span class="quand">{quand}</span>
    </div>'''


MODERATION = f'''<div class="app page moderation">
  <!--barre-etat-->
  <div class="page-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Retour">{ic("retour")}</button>
    <span class="espace"></span>
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Filtres">{ic("filtres")}</button>
  </div>
  {mots("Modération")}
  <nav class="flux mots" aria-label="Files">
    <span aria-current="true" class="m"><span style="--k:0">À vérifier <b>12</b></span></span>
    <span class="m"><span style="--k:1">Signalements <b>5</b></span></span>
    <span class="m"><span style="--k:2">Demandes <b>2</b></span></span>
  </nav>
  <p class="file-note">Les plus urgents d'abord. Le reste est publié sans attendre.</p>
  <div class="dossiers">
{dossier(0, "p37", "Côte de Sèmè au matin", "@koffi.photo · photo", "Signes d'IA · 72 %", "etincelle", "12 min", "forte")}
{dossier(1, "p15", "Cascade de Kota", "@senan.voyage · reel", "Signalé 3 fois · pas pris à cet endroit", "drapeau", "40 min", "forte")}
{dossier(2, "p62", "Collines de Dassa", "@aminata.d · photo", "Téléphone déclaré, pas lu dans le fichier", "telephone", "1 h")}
{dossier(3, "p46", "Marché Dantokpa", "@yao.b · photo", "Visages en gros plan", "profil", "2 h")}
{dossier(4, "p116", "Ganvié au lever", "@lagune.229 · reel", "Signes d'IA · 41 %", "etincelle", "3 h")}
  </div>
  <!--onglets:profil-->
</div>
'''


# ------------------------------------------------------------ E25 moderation, la decision

def comparaison(icone, libelle, fichier, declare, ok=True):
    etat = f'<span class="accord ok">{ic("coche", "mini")}Concorde</span>' if ok else f'<span class="accord">{ic("alerte", "mini")}Diffère</span>'
    return f'<div class="compare-ligne">{ic(icone)}<div><dt>{libelle}</dt><dd>{fichier}<span>Déclaré : {declare}</span></dd></div>{etat}</div>'


DECISION = f'''<div class="app page moderation decision">
  <!--barre-etat-->
  <div class="page-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Retour">{ic("retour")}</button>
    <span class="page-haut-titre">Dossier 1 sur 12</span>
  </div>
  <div class="decision-image"><span class="photo ph-p37"></span></div>
  <div class="decision-auteur">{av("KP", "hsl(18 70% 52%)", "petit")}<div><strong>Côte de Sèmè au matin</strong><span>@koffi.photo · 214 publications, aucun retrait</span></div></div>
  <section class="analyse verre-plaque">
    <div class="analyse-tete">{ic("etincelle")}<strong>Signes d'image générée</strong><span>72 %</span></div>
    <span class="jauge" style="--p:72%"></span>
    <p>Textures répétées dans le ciel et la végétation, pas de bruit de capteur, contours trop nets sur les rochers.</p>
  </section>
  <section class="fiche verre-plaque">
    <div class="fiche-tete"><h3>Fichier et déclaration</h3></div>
    <dl>
      {comparaison("telephone", "Téléphone", "Aucun dans le fichier", "Samsung Galaxy A54", ok=False)}
      {comparaison("calendrier", "Prise le", "3 septembre 2026, 10 h 12", "3 septembre 2026")}
      {comparaison("lieu", "Lieu", "6,3712° N, 2,6203° E · Sèmè-Kpodji", "Sèmè-Kpodji")}
    </dl>
  </section>
  <h2 class="section-titre">Motif du refus</h2>
  <div class="modeles verre-plaque motifs">
    {modele("Image générée ou retouchée par IA", "", True)}
    {modele("Informations fausses", "")}
    {modele("Autre motif", "")}
  </div>
  <p class="feuille-note">L'auteur reçoit le motif et peut demander une seconde vérification.</p>
  <div class="decision-actions">
    <button type="button" class="bouton-verre verre verre-appuyable large rouge"><span class="bouton-verre-texte">{ic("fermer")}Refuser</span></button>
    <button type="button" class="bouton-verre verre verre-appuyable large valider"><span class="bouton-verre-texte">{ic("coche")}Publier</span></button>
  </div>
</div>
'''


# ------------------------------------------------------------ E06 les reels : reagir, commenter, partager...

# Les quatre reactions rapides de l analyse : J aime, Waou, Envie d y aller, Merci.
REACTIONS = [('❤️', "J'aime"), ('🤩', 'Waou'), ('🧳', "Envie d'y aller"), ('🙏', 'Merci')]


def reagir():
    """Un appui long sur le coeur : les quatre reactions s ouvrent a cote."""
    html = lire('e06-reels.html')
    choix = ''.join(f'<button type="button" class="reaction{" choisie" if i == 2 else ""}" style="--k:{i}"><span class="emoji">{e}</span><span class="reaction-nom">{n}</span></button>'
                    for i, (e, n) in enumerate(REACTIONS))
    barre = f'<div class="reactions-choix" role="menu" aria-label="Réagir">{choix}</div>'
    html = html.replace('<div class="bouton-reel aime" style="--k:1">', '<div class="bouton-reel aime appui" style="--k:1">' + barre, 1)
    html = html.replace('<div class="reels-progres"', '<div class="voile-reagir"></div>\n  <div class="reels-progres"', 1)
    return html


def reacteur(n, initiales, teinte, nom, detail, emoji, suivi=False):
    action = bouton("Abonné") if suivi else bouton("S'abonner", plein=True)
    return (f'      <div class="reacteur" style="--n:{n}"><span class="avatar-reaction">{av(initiales, teinte)}<span class="emoji">{emoji}</span></span>'
            f'<div><strong>{nom}</strong><span>{detail}</span></div>{action}</div>')


REACTIONS_LISTE = sur('e06-reels.html', feuille(f'''    <nav class="flux reactions-flux" aria-label="Réactions">
      <span aria-current="true">Toutes 12,4 k</span><span>❤️ 8,9 k</span><span>🤩 2,1 k</span><span>🧳 1,2 k</span><span>🙏 214</span>
    </nav>
    <div class="reacteurs">
{reacteur(0, "MS", "hsl(229 97% 55%)", "Mawuli S.", "mawuli.s · vous suit", "🧳")}
{reacteur(1, "FH", "hsl(40 80% 45%)", "Fifamè H.", "fifame.h", "🤩", suivi=True)}
{reacteur(2, "EA", "hsl(280 40% 50%)", "Edem A.", "edem.a", "❤️")}
{reacteur(3, "SA", "hsl(330 50% 50%)", "Séna Adjovi", "sena.adjovi", "🙏")}
{reacteur(4, "KB", "hsl(18 70% 52%)", "Koffi B.", "koffi.photo", "❤️", suivi=True)}
    </div>''', '12,4 k réactions', 'haute'))


REEL_COMMENTAIRES = sur('e06-reels.html', feuille(f'''    <div class="avis-liste">
{commentaire("SV", "hsl(160 55% 34%)", "Sènan Voyage", "Le sentier part derrière le campement, 20 min de marche. Prenez des sandales qui tiennent.", "1 j", "412", epingle=True, auteur=True)}
{commentaire("AK", "hsl(18 70% 52%)", "Akouavi K.", "Le passage à <a class=\"moment\">0:12</a> 😍 On y va en janvier avec <a class=\"mention\">@mawuli.s</a>.", "6 h", "57", aime=True, reponses=f'''
          <div class="reponses">
{commentaire("SV", "hsl(160 55% 34%)", "Sènan Voyage", "En janvier il reste de l'eau, mais moins de débit. Partez tôt !", "5 h", "18")}
          </div>''')}
{commentaire("YB", "hsl(200 60% 40%)", "Yao B.", "On peut s'y baigner ?", "3 h", "6")}
    </div>
    <div class="saisie-bloc">
      <div class="saisie">{av("JD", "hsl(200 60% 40%)", "petit")}<div class="champ verre"><span class="champ-place">Ajouter un commentaire, @mentionner…</span></div>
        <button type="button" class="rond-verre verre verre-appuyable envoyer" aria-label="Envoyer">{ic("envoyer")}</button></div>
    </div>''', '326 commentaires', 'haute feuille-avis'))


REEL_PARTAGER = sur('e06-reels.html', feuille(f'''    <div class="partage-apercu"><span class="photo ph-p15"></span><div><strong>Cascade de Kota</strong><span>senan.voyage · reel de 0:31</span><span class="lien-court">usw.app/r/7tq2</span></div></div>
    <h3 class="feuille-sous-titre">Envoyer à un membre</h3>
    <div class="membres">{CHERCHER_MEMBRE}{membre("MS", "hsl(229 97% 55%)", "Mawuli", choisi=True)}{membre("AK", "hsl(18 70% 52%)", "Akouavi")}{membre("FH", "hsl(40 80% 45%)", "Fifamè", choisi=True)}{membre("EA", "hsl(280 40% 50%)", "Edem")}</div>
    <div class="envoi-membres">
      <div class="champ verre">{ic("commentaire")}<span class="champ-place">Ajouter un message (facultatif)</span></div>
      <button type="button" class="bouton-verre verre verre-appuyable large plein"><span class="bouton-verre-texte">{ic("envoyer")}Envoyer à 2 membres</span></button>
    </div>''',
    'Partager le reel'))


REEL_ENREGISTRER = sur('e06-reels.html', feuille(f'''    <div class="collections">
{collection(0, ["p15", "p28", "p10"], "Nord du Bénin", "32 publications · à l'instant", choisie=True)}
{collection(1, ["p108", "p92", "p12"], "Plages", "25 publications")}
{collection(2, ["p77", "p58", "p62"], "À visiter en décembre", "12 publications · secrète", secrete=True)}
{collection(3, ["p124", "p71", "p76"], "Lacs et lagunes", "8 publications")}
    </div>
    <button type="button" class="nouvelle-collection">{ic("plus")}Créer une collection</button>''',
    'Enregistrer dans'))


REEL_TELECHARGER = sur('e06-reels.html', feuille(f'''    <div class="fichier-ligne"><span class="photo ph-p15 vertical"></span><div><strong>Cascade de Kota</strong><span>Vidéo MP4 · 1 080 × 1 920 · 0:31</span><span>Infinix Note 30 · son d'origine compris</span></div></div>
    <div class="modeles verre-plaque choix-taille">
      {modele("Original · 38 Mo", "Tel que filmé, avec ses informations de capture", True)}
      {modele("Taille écran · 7 Mo", "720 p, léger, sans les informations du fichier")}
    </div>
    <div class="avertissement">{ic("alerte")}<p><strong>Vous êtes en 3G</strong>Environ 9 min pour l'original. Il partira tout seul dès que vous serez en Wi-Fi.</p></div>
    <div class="filtre-ligne"><div><strong>Attendre le Wi-Fi</strong><span>Proposé pour les vidéos de plus de 20 Mo</span></div><span class="interrupteur actif" role="switch" aria-checked="true"></span></div>
    <p class="feuille-note">Pour un usage personnel. La musique de la bibliothèque n'est pas incluse.</p>
    {bouton("Télécharger en Wi-Fi · 38 Mo", plein=True, icone="telecharger")}''',
    'Télécharger le reel', 'feuille-large'))


def main():
    ecrire('e04-filtres.html', FILTRES)
    ecrire('e07-commentaires.html', COMMENTAIRES)
    ecrire('e08-telecharger.html', TELECHARGER)
    ecrire('e09-enregistrer.html', ENREGISTRER)
    ecrire('e10-partager.html', PARTAGER)
    ecrire('e11-carte.html', CARTE)
    ecrire('e19-collection.html', COLLECTION)
    ecrire('e22-signaler.html', SIGNALER)
    ecrire('e23-regles.html', regles())
    ecrire('e24-moderation.html', MODERATION)
    ecrire('e25-decision.html', DECISION)
    ecrire('e38-confidentialite.html', confidentialite())
    ecrire('e06-reel-reagir.html', reagir())
    ecrire('e06-reel-reactions.html', REACTIONS_LISTE)
    ecrire('e06-reel-commentaires.html', REEL_COMMENTAIRES)
    ecrire('e06-reel-partager.html', REEL_PARTAGER)
    ecrire('e06-reel-enregistrer.html', REEL_ENREGISTRER)
    ecrire('e06-reel-telecharger.html', REEL_TELECHARGER)
    print('feuilles et dernieres pages ecrites.')


if __name__ == '__main__':
    main()
