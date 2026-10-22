"""Le pack d icones de USW, dessine pour l application.

Inspire de Google : la geometrie des icones Material de Maps (grille de 24,
formes simples, coins arrondis, trait regulier), une version pleine pour
l onglet actif, et les quatre couleurs de Google pour les icones qui disent
une information sur la photo (le telephone qui l a prise, la date de prise,
le lieu, la boussole), comme le repere de Maps.

Ecrit :
  maquette/symboles.svg      la feuille de symboles des maquettes
  pack-icones/svg/*.svg      chaque icone en fichier (et sa version pleine)
  pack-icones/apercu.html    la planche du pack

  python outils/pack_icones.py
"""

import math
import re
from pathlib import Path

RACINE = Path(__file__).resolve().parent.parent
FEUILLE = RACINE / 'maquette' / 'symboles.svg'
PACK = RACINE / 'pack-icones'

# Les couleurs de Google.
BLEU, ROUGE, JAUNE, VERT = '#4285F4', '#EA4335', '#FBBC04', '#34A853'
BLEU_FONCE, ROUGE_FONCE, GRIS = '#1967D2', '#B31412', '#9AA0A6'

PIN = 'M12 2.25c-3.87 0-7 3.08-7 6.9 0 5.2 7 12.6 7 12.6s7-7.4 7-12.6c0-3.82-3.13-6.9-7-6.9z'
SANS = 'stroke="none"'


def rosette():
    """Le badge de verification : huit festons, comme le « verifie » de Google."""
    points = []
    for i in range(8):
        a = math.radians(i * 45 - 90)
        b = math.radians(i * 45 - 90 + 22.5)
        points.append(((12 + 10.4 * math.cos(a), 12 + 10.4 * math.sin(a)), (12 + 7.9 * math.cos(b), 12 + 7.9 * math.sin(b))))
    depart = points[-1][1]
    d = f'M{depart[0]:.2f} {depart[1]:.2f}'
    for (cx, cy), (x, y) in points:
        d += f'Q{cx:.2f} {cy:.2f} {x:.2f} {y:.2f}'
    return d + 'z'


def engrenage():
    """La roue des reglages : huit dents arrondies autour d un anneau."""
    points = []
    for i in range(8):
        a = i * 45
        for da, r in ((-14, 6.9), (-8, 9.1), (8, 9.1), (14, 6.9)):
            t = math.radians(a + da)
            points.append((12 + r * math.cos(t), 12 + r * math.sin(t)))
    return 'M' + 'L'.join(f'{x:.2f} {y:.2f}' for x, y in points) + 'z'


# Chaque icone : (contour, plein ou None). Les dessins sont au trait
# (currentColor, epaisseur donnee par la page) ; les couleurs fixes sont
# ecrites sur la forme. Une version pleine troue ses details par un masque.
ICONES = {
    # --- la barre d onglets, avec leur version pleine
    'accueil': (
        '<path d="M4 10.2 12 4l8 6.2V19a1.5 1.5 0 0 1-1.5 1.5H15V15a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v5.5H5.5A1.5 1.5 0 0 1 4 19z"/>',
        '<path d="M4 10.2 12 4l8 6.2V19a1.5 1.5 0 0 1-1.5 1.5H15V15a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v5.5H5.5A1.5 1.5 0 0 1 4 19z" fill="currentColor"/>',
    ),
    'reels': (
        '<rect x="3.5" y="3.5" width="17" height="17" rx="4.5"/><path d="M3.5 8.5h17M8.75 3.5l2.25 5M14.25 3.5l2.25 5"/><path d="M10.25 12.1v5l4.25-2.5z" fill="currentColor"/>',
        ('<rect x="3.5" y="3.5" width="17" height="17" rx="4.5" fill="currentColor"/>',
         '<path d="M3.5 8.5h17M8.75 3.5l2.25 5M14.25 3.5l2.25 5" stroke="#000" stroke-width="1.5"/><path d="M10.25 12.1v5l4.25-2.5z" fill="#000" stroke="#000" stroke-width="0.6"/>'),
    ),
    'carte': (
        '<path d="M9 4.5 3.75 6.5v13L9 17.5l6 2 5.25-2v-13L15 6.5z"/><path d="M9 4.5v13M15 6.5v13"/>',
        ('<path d="M9 4.5 3.75 6.5v13L9 17.5l6 2 5.25-2v-13L15 6.5z" fill="currentColor"/>',
         '<path d="M9 4.5v13M15 6.5v13" stroke="#000" stroke-width="1.5"/>'),
    ),
    'profil': (
        '<circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="10" r="3"/><path d="M6.6 18.2a6.5 6.5 0 0 1 10.8 0"/>',
        ('<circle cx="12" cy="12" r="9" fill="currentColor" stroke="none"/>',
         '<circle cx="12" cy="10" r="3.1" fill="#000" stroke="none"/><path d="M6.4 18.4a6.7 6.7 0 0 1 11.2 0" fill="none" stroke="#000" stroke-width="1.7"/>'),
    ),
    'plus': ('<path d="M12 5v14M5 12h14"/>', None),
    # --- les actions, au trait
    'loupe': ('<circle cx="10.5" cy="10.5" r="6"/><path d="m15 15 5 5"/>', None),
    'cloche': ('<path d="M5.5 17.5h13M6.75 17.5V11a5.25 5.25 0 0 1 10.5 0v6.5M10 20.5h4M12 4.5v1.25"/>', None),
    'coeur': ('<path d="M12 20.2s-7.5-4.6-7.5-10.1A4.3 4.3 0 0 1 12 7.4a4.3 4.3 0 0 1 7.5 2.7c0 5.5-7.5 10.1-7.5 10.1z"/>', None),
    'commentaire': ('<path d="M7 4.5h10.5a2 2 0 0 1 2 2V15a2 2 0 0 1-2 2H9.25L5 20.25V6.5a2 2 0 0 1 2-2z"/>', None),
    'partager': ('<circle cx="17.5" cy="5.5" r="2.25"/><circle cx="6.5" cy="12" r="2.25"/><circle cx="17.5" cy="18.5" r="2.25"/><path d="m8.45 10.85 7.1-4.2M8.45 13.15l7.1 4.2"/>', None),
    'enregistrer': ('<path d="M7 3.75h10a1.5 1.5 0 0 1 1.5 1.5v15l-6.5-4-6.5 4v-15A1.5 1.5 0 0 1 7 3.75z"/>', None),
    'telecharger': ('<path d="M12 4v11M7.5 10.5 12 15l4.5-4.5M5 19.5h14"/>', None),
    'filtres': ('<path d="M4 7h9M17 7h3M4 17h3M11 17h9"/><circle cx="15" cy="7" r="2"/><circle cx="9" cy="17" r="2"/>', None),
    'muet': ('<path d="M4.5 9.5h3L12 5.75v12.5L7.5 14.5h-3z"/><path d="m16 9.5 4 4M20 9.5l-4 4"/>', None),
    'plus-points': (f'<circle cx="6" cy="12" r="1.5" fill="currentColor" {SANS}/><circle cx="12" cy="12" r="1.5" fill="currentColor" {SANS}/><circle cx="18" cy="12" r="1.5" fill="currentColor" {SANS}/>', None),
    'retour': ('<path d="M19.5 12H5M11 6l-6 6 6 6"/>', None),
    'fermer': ('<path d="m6 6 12 12M18 6 6 18"/>', None),
    'camera': ('<path d="M4 8.5a2 2 0 0 1 2-2h2.2l1.5-2h4.6l1.5 2H18a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z"/><circle cx="12" cy="13" r="3.5"/>', None),
    'musique': ('<path d="M10 17.5V6.75L18 5v9.5"/><circle cx="7.75" cy="17.5" r="2.25"/><circle cx="15.75" cy="14.5" r="2.25"/>', None),
    'chevron-bas': ('<path d="m6.5 9.5 5.5 5.5 5.5-5.5"/>', None),
    'chevron-droite': ('<path d="m9.5 6.5 5.5 5.5-5.5 5.5"/>', None),
    'horloge': ('<path d="M4.6 12a7.4 7.4 0 1 0 2.2-5.25M4.5 5v3.75h3.75M12 8v4.25l2.75 1.75"/>', None),
    'verifie': (f'<path d="{rosette()}"/><path d="m8.6 12.2 2.3 2.3 4.5-4.7"/>', None),
    # --- le compte, l aide, les documents
    'oeil': ('<path d="M2.75 12S6.15 5.75 12 5.75 21.25 12 21.25 12 17.85 18.25 12 18.25 2.75 12 2.75 12z"/><circle cx="12" cy="12" r="3"/>', None),
    'oeil-barre': ('<path d="M6.3 7.4C3.95 9.15 2.75 12 2.75 12S6.15 18.25 12 18.25c1.75 0 3.25-.55 4.5-1.35M9.9 5.95c.66-.13 1.36-.2 2.1-.2 5.85 0 9.25 6.25 9.25 6.25s-.75 1.4-2.2 2.95"/><path d="M9.9 9.9a3 3 0 0 0 4.2 4.2M4 4l16 16"/>', None),
    'enveloppe': ('<rect x="3.5" y="5.5" width="17" height="13" rx="2.5"/><path d="m4 7.5 8 5.75 8-5.75"/>', None),
    'cadenas': ('<rect x="5" y="10.5" width="14" height="10" rx="2.5"/><path d="M8 10.5V8a4 4 0 0 1 8 0v2.5M12 14.5V17"/>', None),
    'arobase': ('<circle cx="12" cy="12" r="3.25"/><path d="M15.25 12v1.5a2.5 2.5 0 0 0 5 0V12a8.25 8.25 0 1 0-3.3 6.6"/>', None),
    'globe': ('<circle cx="12" cy="12" r="8.5"/><path d="M3.5 12h17M12 3.5c2.4 2.4 3.5 5.3 3.5 8.5s-1.1 6.1-3.5 8.5c-2.4-2.4-3.5-5.3-3.5-8.5S9.6 5.9 12 3.5z"/>', None),
    'coche': ('<path d="m5 12.5 4.5 4.5L19 7.5"/>', None),
    'aide': (f'<circle cx="12" cy="12" r="8.5"/><path d="M9.6 9.6a2.5 2.5 0 1 1 3.6 2.25c-.75.35-1.2.95-1.2 1.75v.4"/><circle cx="12" cy="16.9" r="0.95" fill="currentColor" {SANS}/>', None),
    'document': ('<path d="M7 3.5h7l4.5 4.5v11a1.5 1.5 0 0 1-1.5 1.5H7a1.5 1.5 0 0 1-1.5-1.5V5A1.5 1.5 0 0 1 7 3.5z"/><path d="M14 3.5V8h4.5M8.75 12.5h6.5M8.75 16h4.5"/>', None),
    'bouclier': ('<path d="M12 3.5 19 6.25v5.25c0 4.4-2.9 7.6-7 9-4.1-1.4-7-4.6-7-9V6.25z"/><path d="m9 12 2 2 4-4"/>', None),
    'fleche-droite': ('<path d="M4.5 12H19M13 6l6 6-6 6"/>', None),
    'sortie': ('<path d="M14 4.5H7A1.5 1.5 0 0 0 5.5 6v12A1.5 1.5 0 0 0 7 19.5h7M10.5 12h10M17 8.5l3.5 3.5-3.5 3.5"/>', None),
    # --- le profil et les reglages
    'reglages': (f'<path d="{engrenage()}"/><circle cx="12" cy="12" r="3"/>', None),
    'crayon': ('<path d="M4.5 19.5v-3.25L15.6 5.15a1.9 1.9 0 0 1 2.7 0l.55.55a1.9 1.9 0 0 1 0 2.7L7.75 19.5zM13.75 7l3.25 3.25"/>', None),
    'lien': ('<path d="M10.25 13.75a3.9 3.9 0 0 0 5.5 0l2.9-2.9a3.9 3.9 0 0 0-5.5-5.5l-.95.95M13.75 10.25a3.9 3.9 0 0 0-5.5 0l-2.9 2.9a3.9 3.9 0 0 0 5.5 5.5l.95-.95"/>', None),
    'cible': ('<circle cx="12" cy="12" r="6.75"/><circle cx="12" cy="12" r="2.5" fill="currentColor"/><path d="M12 2.75v2.5M12 18.75v2.5M2.75 12h2.5M18.75 12h2.5"/>', None),
    'drapeau': ('<path d="M5.5 20.5V4.5M5.5 5h11.25l-2.25 4 2.25 4H5.5"/>', None),
    'bloque': ('<circle cx="12" cy="12" r="8.5"/><path d="m6 6 12 12"/>', None),
    'grille': ('<rect x="4" y="4" width="7" height="7" rx="1.75"/><rect x="13" y="4" width="7" height="7" rx="1.75"/><rect x="4" y="13" width="7" height="7" rx="1.75"/><rect x="13" y="13" width="7" height="7" rx="1.75"/>', None),
    'collection': ('<rect x="7" y="7" width="13" height="13" rx="2.5"/><path d="M4 16.5V6.25A2.25 2.25 0 0 1 6.25 4H16.5"/>', None),
    'image': ('<rect x="3.5" y="4.5" width="17" height="15" rx="2.5"/><circle cx="9" cy="9.5" r="1.6"/><path d="m3.75 17 5-5 4 4 2.5-2.5 5 5"/>', None),
    # --- la camera et le montage
    'eclair': ('<path d="M13 3 5.5 13.5h6L10.5 21l8-10.5h-6z"/>', None),
    'retourner': ('<path d="M5.5 10.5a6.75 6.75 0 0 1 12-3.75M18.5 3.5v3.75h-3.75M18.5 13.5a6.75 6.75 0 0 1-12 3.75M5.5 20.5v-3.75h3.75"/>', None),
    'minuteur': ('<circle cx="12" cy="13.5" r="7.25"/><path d="M12 13.5V9.75M9.5 2.75h5M18.25 6.75l1.25-1.25"/>', None),
    'ciseaux': ('<circle cx="6.5" cy="6.5" r="2.5"/><circle cx="6.5" cy="17.5" r="2.5"/><path d="M8.6 8 19.5 17.5M8.6 16 19.5 6.5"/>', None),
    'texte': ('<path d="M5 7V5h14v2M12 5v14M9 19h6"/>', None),
    'micro': ('<rect x="9" y="3.5" width="6" height="11" rx="3"/><path d="M5.5 11.5a6.5 6.5 0 0 0 13 0M12 18v2.5"/>', None),
    'lecture': ('<path d="M7.5 5.25v13.5l11-6.75z" fill="currentColor"/>', None),
    'pause': ('<rect x="6.5" y="5" width="3.5" height="14" rx="1" fill="currentColor"/><rect x="14" y="5" width="3.5" height="14" rx="1" fill="currentColor"/>', None),
    'poubelle': ('<path d="M4.5 6.5h15M9.5 6.5v-2h5v2M6.5 6.5l.9 12.6a1.5 1.5 0 0 0 1.5 1.4h6.2a1.5 1.5 0 0 0 1.5-1.4l.9-12.6M10.25 10.5v6M13.75 10.5v6"/>', None),
    'envoyer': ('<path d="M12 15V4M7.5 8.5 12 4l4.5 4.5M5 19.5h14"/>', None),
    # --- les messages et les erreurs
    'alerte': (f'<circle cx="12" cy="12" r="8.5"/><path d="M12 7.75v5"/><circle cx="12" cy="16.25" r="0.95" fill="currentColor" {SANS}/>', None),
    'hors-ligne': (f'<path d="M3.5 9.25a12.6 12.6 0 0 1 4.4-2.85M12 5.75c3.2 0 6.15 1.2 8.5 3.5M6.6 12.6a7.6 7.6 0 0 1 3.1-1.75M17.4 12.6a7.6 7.6 0 0 0-2-1.35M10 15.9a3 3 0 0 1 4 0M4 4l16 16"/><circle cx="12" cy="19" r="1" fill="currentColor" {SANS}/>', None),
    'image-barre': ('<path d="M20.5 16.5V7A2.5 2.5 0 0 0 18 4.5H8.5M3.5 6.75V17A2.5 2.5 0 0 0 6 19.5h11.25M3.75 17l5-5 4 4M4 4l16 16"/>', None),
    # La marque de Google, telle que Google la fournit pour « Continuer avec
    # Google » (sa charte l impose sur ce bouton) : la seule icone qui n est pas a nous.
    'google': (
        '<g transform="translate(3 3)">'
        f'<path d="M17.64 9.2c0-.64-.06-1.25-.16-1.84H9v3.48h4.84a4.14 4.14 0 0 1-1.8 2.72v2.26h2.91c1.7-1.57 2.69-3.87 2.69-6.62z" fill="{BLEU}" {SANS}/>'
        f'<path d="M9 18c2.43 0 4.47-.8 5.96-2.18l-2.91-2.26c-.8.54-1.84.86-3.05.86-2.34 0-4.33-1.58-5.04-3.71H.96v2.33A9 9 0 0 0 9 18z" fill="{VERT}" {SANS}/>'
        f'<path d="M3.96 10.71A5.41 5.41 0 0 1 3.68 9c0-.59.1-1.17.28-1.71V4.96H.96A9 9 0 0 0 0 9c0 1.45.35 2.83.96 4.04z" fill="{JAUNE}" {SANS}/>'
        f'<path d="M9 3.58c1.32 0 2.51.45 3.44 1.35l2.58-2.58A9 9 0 0 0 .96 4.96L3.96 7.3C4.67 5.16 6.66 3.58 9 3.58z" fill="{ROUGE}" {SANS}/>'
        '</g>',
        None,
    ),
    # La marque WhatsApp, pour la seule feuille « Partager » : la bulle verte, le combine blanc.
    'whatsapp': (
        f'<path d="M12 2.6a9.4 9.4 0 0 0-8.1 14.15L2.6 21.4l4.78-1.25A9.4 9.4 0 1 0 12 2.6z" fill="#25D366" {SANS}/>'
        f'<path d="M8.6 7.3c.25-.3.7-.32.9 0l1.05 1.75c.15.25.1.57-.1.78l-.62.62a6.2 6.2 0 0 0 3.72 3.72l.62-.62c.21-.2.53-.25.78-.1l1.75 1.05c.32.2.3.65 0 .9-.8.75-1.95 1-2.95.6a8.6 8.6 0 0 1-5.75-5.75c-.4-1 -.15-2.15.6-2.95z" fill="#fff" {SANS}/>',
        None,
    ),
    # Les signes d une image generee : une etincelle, pour la moderation.
    'etincelle': ('<path d="M10.5 3.5c.6 3.9 2.1 5.4 6 6-3.9.6-5.4 2.1-6 6-.6-3.9-2.1-5.4-6-6 3.9-.6 5.4-2.1 6-6zM18 14.5c.3 1.9 1 2.6 2.9 2.9-1.9.3-2.6 1-2.9 2.9-.3-1.9-1-2.6-2.9-2.9 1.9-.3 2.6-1 2.9-2.9z" stroke-linejoin="round"/>', None),
    # --- l information, aux couleurs de Google
    'lieu': (f'<path d="{PIN}" fill="{ROUGE}" {SANS}/><circle cx="12" cy="9.15" r="2.6" fill="{ROUGE_FONCE}" {SANS}/>', None),
    'y-aller': (f'<path d="{PIN}" fill="#fff" stroke="#fff" stroke-width="3" stroke-linejoin="round"/><path d="{PIN}" fill="{ROUGE}" {SANS}/><circle cx="12" cy="9.15" r="2.6" fill="{ROUGE_FONCE}" {SANS}/>', None),
    'telephone': (
        f'<rect x="6" y="2.25" width="12" height="19.5" rx="3" fill="{BLEU}" {SANS}/>'
        f'<rect x="7.6" y="4.6" width="8.8" height="13.6" rx="1.2" fill="#fff" {SANS}/>'
        f'<path d="M7.6 17.2 10.6 14l2.1 2.1 1.6-1.6 2.1 2.1v.4a1.2 1.2 0 0 1-1.2 1.2H8.8a1.2 1.2 0 0 1-1.2-1.2z" fill="{VERT}" {SANS}/>'
        f'<circle cx="13.9" cy="8.4" r="1.35" fill="{JAUNE}" {SANS}/>'
        f'<path d="M10.75 20h2.5" stroke="#fff" stroke-width="1.1"/>',
        None,
    ),
    'calendrier': (
        f'<rect x="3.75" y="4.75" width="16.5" height="15.5" rx="2.5" fill="#fff" stroke="{BLEU}" stroke-width="1.5"/>'
        f'<path d="M3.75 9.5V7.25a2.5 2.5 0 0 1 2.5-2.5h11.5a2.5 2.5 0 0 1 2.5 2.5V9.5z" fill="{BLEU}" stroke="{BLEU}" stroke-width="1.5" stroke-linejoin="round"/>'
        f'<path d="M8 3v3M16 3v3" stroke="{BLEU_FONCE}" stroke-width="1.6"/>'
        + ''.join(f'<circle cx="{x}" cy="{y}" r="0.95" fill="{GRIS}" {SANS}/>' for x, y in [(8, 13), (12, 13), (16, 13), (8, 16.6), (12, 16.6)])
        + f'<circle cx="16" cy="16.6" r="1.45" fill="{ROUGE}" {SANS}/>',
        None,
    ),
    'boussole': (
        f'<circle cx="12" cy="12" r="8.5"/><path d="M12 5.9 14.3 12H9.7z" fill="{ROUGE}" {SANS}/><path d="M12 18.1 9.7 12h4.6z" fill="{GRIS}" {SANS}/>',
        None,
    ),
}

ENTETE = '<!-- Le pack d icones de USW (outils/pack_icones.py) : grille de 24, inspire des icones Material de Google Maps, versions pleines pour l onglet actif, couleurs de Google pour l information. -->'


def corps(nom, contour, plein):
    """Le contenu d un symbole : le contour, et la version pleine que montre --ic-plein."""
    if plein is None:
        return contour
    if isinstance(plein, tuple):
        forme, trous = plein
        masque = (f'<mask id="m-{nom}" maskUnits="userSpaceOnUse" x="0" y="0" width="24" height="24">'
                  f'<rect width="24" height="24" fill="#fff" stroke="none"/>{trous}</mask>')
        plein_svg = f'{masque}<g mask="url(#m-{nom})">{forme}</g>'
    else:
        plein_svg = plein
    return (f'<g style="display:var(--ic-contour,inline)">{contour}</g>'
            f'<g style="display:var(--ic-plein,none)">{plein_svg}</g>')


def main():
    ancienne = FEUILLE.read_text(encoding='utf-8')
    # La barre d etat reste celle du telephone.
    systeme = re.findall(r'<symbol id="i-(?:signal|wifi|batterie)"[\s\S]*?</symbol>', ancienne)
    symboles = [f'  <symbol id="i-{nom}" viewBox="0 0 24 24">{corps(nom, c, p)}</symbol>' for nom, (c, p) in ICONES.items()]
    FEUILLE.write_text(
        '<svg xmlns="http://www.w3.org/2000/svg" width="0" height="0" style="position:absolute" aria-hidden="true">\n'
        f'  {ENTETE}\n' + '\n'.join(symboles) + '\n' + '\n'.join('  ' + s for s in systeme) + '\n</svg>\n',
        encoding='utf-8',
    )

    # Chaque icone en fichier, au trait de 1,6.
    dossier = PACK / 'svg'
    dossier.mkdir(parents=True, exist_ok=True)
    style = 'fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"'
    for nom, (c, p) in ICONES.items():
        (dossier / f'{nom}.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" {style}>{c}</svg>\n', encoding='utf-8')
        if p is not None:
            interieur = corps(nom, c, p).replace('display:var(--ic-contour,inline)', 'display:none').replace('display:var(--ic-plein,none)', 'display:inline')
            (dossier / f'{nom}-plein.svg').write_text(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" {style}>{interieur}</svg>\n', encoding='utf-8')

    # La planche.
    cases = []
    for nom, (c, p) in ICONES.items():
        variantes = [('', c)] + ([('plein', corps(nom, c, p).replace('display:var(--ic-contour,inline)', 'display:none').replace('display:var(--ic-plein,none)', 'display:inline'))] if p else [])
        for suffixe, contenu in variantes:
            etiquette = nom + (' · plein' if suffixe else '')
            cases.append(f'<figure><svg viewBox="0 0 24 24" {style}>{contenu}</svg><svg class="petit" viewBox="0 0 24 24" {style}>{contenu}</svg><figcaption>{etiquette}</figcaption></figure>')
    (PACK / 'apercu.html').write_text(
        '<!doctype html><html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">'
        '<title>USW · pack d icônes</title><style>'
        'body{margin:0;padding:40px clamp(16px,4vw,48px);background:hsl(229 36% 92%);color:hsl(229 30% 14%);font:15px/1.4 system-ui,sans-serif}'
        'h1{margin:0 0 4px;font-size:28px;letter-spacing:-.02em}p{margin:0 0 28px;color:hsl(229 14% 42%)}'
        'main{display:grid;grid-template-columns:repeat(auto-fill,minmax(132px,1fr));gap:12px}'
        'figure{margin:0;display:grid;grid-template-columns:auto auto;align-items:end;justify-content:center;gap:14px;padding:22px 10px 14px;border-radius:18px;background:hsl(0 0% 100% / .6)}'
        'figure svg{width:48px;height:48px}figure svg.petit{width:24px;height:24px}'
        'figcaption{grid-column:1/-1;text-align:center;font-size:12.5px;color:hsl(229 14% 42%)}'
        '</style></head><body><h1>USW · pack d’icônes</h1>'
        '<p>Grille de 24, inspiré des icônes Material de Google Maps. Versions pleines pour l’onglet actif ; couleurs de Google pour l’information (téléphone, date de prise, lieu, boussole).</p>'
        '<main>' + ''.join(cases) + '</main></body></html>\n',
        encoding='utf-8',
    )
    print(f'{len(ICONES)} icones, feuille et pack ecrits.')


if __name__ == '__main__':
    main()
