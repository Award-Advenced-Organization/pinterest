"""Ecrit les ecrans du compte : bienvenue (E01), entree par e-mail ou Google
facon Pinterest (E02), profil a completer (E36), conditions generales (E34)
et aide (E35), dans maquette/ecrans/.

  python outils/ecrans_compte.py
"""

from pathlib import Path

ECRANS = Path(__file__).resolve().parent.parent / 'maquette' / 'ecrans'


def ic(nom, classe=''):
    return f'<svg class="ic{(" " + classe) if classe else ""}"><use href="#i-{nom}"/></svg>'


def mots(texte, k0=0, classe='page-titre', balise='h1'):
    # Typographie francaise : une espace insecable avant ? ! : ;
    texte = texte.replace(' ?', ' ?').replace(' !', ' !')
    morceaux = ' '.join(f'<span class="m"><span style="--k:{k0 + i}">{m}</span></span>' for i, m in enumerate(texte.split(' ')))
    return f'<{balise} class="{classe} mots">{morceaux}</{balise}>'


def ecrire(nom, html):
    (ECRANS / nom).write_text(html, encoding='utf-8')


# ------------------------------------------------------------ E01 bienvenue

def progression(n):
    traits = ''.join(f'<span class="{"fait" if i < n else ("encours" if i == n else "")}"></span>' for i in range(1, 4))
    return f'<div class="progression" aria-label="Étape {n} sur 3">{traits}</div>'


def bienvenue(n, visuel, titre, texte, actions):
    passer = '' if n == 3 else '<button type="button" class="lien-discret">Passer</button>'
    return f'''<div class="app fixe bienvenue">
  <!--barre-etat-->
  {progression(n)}
  <div class="bienvenue-haut">{passer}</div>
  <div class="bienvenue-visuel">
{visuel}
  </div>
  <div class="bienvenue-texte">
    {mots(titre)}
    <p class="page-texte">{texte}</p>
  </div>
  <div class="bienvenue-actions">
{actions}
  </div>
</div>
'''


SUIVANT = f'    <button type="button" class="bouton-verre verre verre-appuyable plein large"><span class="bouton-verre-texte">Suivant{ic("fleche-droite")}</span></button>'

VISUEL_1 = '    <div class="pile pile-grande" style="--d:0s">' + ''.join(
    f'<span class="pile-carte" style="--k:{k}"><span class="photo ph-{p}"></span></span>' for k, p in enumerate(['p76', 'p110', 'p15', 'p108'])
) + '</div>'

VISUEL_2 = f'''    <div class="demo-photo">
      <span class="photo ph-p124"></span>
      <span class="badge verifie">{ic('verifie')}Capture vérifiée</span>
      <div class="puces">
        <span class="puce" style="--k:0">{ic('telephone')}Tecno Camon 50 Pro</span>
        <span class="puce" style="--k:1">{ic('calendrier')}12 août 2026, 17 h 40</span>
        <span class="puce" style="--k:2">{ic('lieu')}Lac Ahémé, Possotomé</span>
      </div>
    </div>'''

VISUEL_3 = f'''    <div class="demo-photo">
      <span class="photo ph-p77"></span>
      <span class="repere-demo">{ic('lieu')}</span>
      <span class="bouton-verre verre plein demo-aller"><span class="bouton-verre-texte">{ic('y-aller')}Y aller · 38 km</span></span>
    </div>'''

ACTIONS_3 = f'''    <button type="button" class="bouton-verre verre verre-appuyable plein large"><span class="bouton-verre-texte">Commencer{ic("fleche-droite")}</span></button>
    <button type="button" class="lien-discret centre">Explorer sans compte</button>'''


# ------------------------------------------------------------ E02 compte

def page(contenu, classe='', titre_haut=''):
    titre = f'<span class="page-haut-titre">{titre_haut}</span>' if titre_haut else ''
    return f'''<div class="app page{(" " + classe) if classe else ""}">
  <!--barre-etat-->
  <div class="page-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Retour">{ic('retour')}</button>{titre}
  </div>
{contenu}
</div>
'''


def champ(libelle, icone, valeur, aide='', focus=False, fin='', indication=False, k=0):
    if indication:
        # Champ vide : le curseur attend devant l indication.
        texte = ('<span class="curseur"></span>' if focus else '') + f'<span class="champ-place">{valeur}</span>'
    else:
        texte = f'<span class="champ-valeur">{valeur}</span>' + ('<span class="curseur"></span>' if focus else '')
    ligne_aide = f'\n      <p class="champ-aide">{aide}</p>' if aide else ''
    return f'''    <div class="champ-bloc" style="--k:{k}">
      <span class="champ-libelle">{libelle}</span>
      <div class="champ verre{" focus" if focus else ""}">{ic(icone)}{texte}{fin}</div>{ligne_aide}
    </div>'''


OEIL = f'<button type="button" class="champ-bouton" aria-label="Afficher le mot de passe">{ic("oeil")}</button>'
BOUTON = '<button type="button" class="bouton-verre verre verre-appuyable plein large" style="--k:{k}"><span class="bouton-verre-texte">{t}</span></button>'
BOUTON_INACTIF = '<button type="button" class="bouton-verre verre plein large" disabled style="--k:{k}"><span class="bouton-verre-texte">{t}</span></button>'


def critere(ok, texte):
    return f'<li class="{"ok" if ok else ""}">{ic("coche")}{texte}</li>'


LEGAL = "En continuant, vous acceptez les <a class=\"lien\">conditions générales d'utilisation</a> de USW et reconnaissez avoir lu la <a class=\"lien\">politique de confidentialité</a>."

# La mosaique de l entree, comme celle de Pinterest : des colonnes de photos
# qui glissent lentement, en sens contraires. Cinq colonnes, trois au telephone.
COLONNES = [
    ['p110', 'p15', 'p77', 'p124', 'p57'],
    ['p108', 'p62', 'p76', 'p49', 'p12'],
    ['p37', 'p17', 'p58', 'p71', 'p46'],
    ['p92', 'p28', 'p116', 'p54', 'p74'],
    ['p66', 'p78', 'p10', 'p118', 'p101'],
]


def mosaique_entree():
    colonnes = []
    for i, photos in enumerate(COLONNES):
        # Le contenu est double : la colonne glisse d une moitie et reprend sans saut.
        cases = ''.join(f'<span class="photo ph-{p}"></span>' for p in photos * 2)
        colonnes.append(f'<div class="colonne" style="--c:{i}">{cases}</div>')
    return '<div class="entree-mosaique" aria-hidden="true">' + ''.join(colonnes) + '</div>'


ENTREE = f'''<div class="app fixe entree">
  <!--barre-etat-->
  {mosaique_entree()}
  <div class="entree-corps">
    <span class="logo-usw" aria-label="USW"><span>U</span><span>S</span><span class="citron">W</span></span>
    {mots('Bienvenue sur USW')}
    <form class="formulaire">
{champ("E-mail", "enveloppe", "Adresse e-mail", focus=True, indication=True, k=0)}
      {BOUTON.format(k=1, t="Continuer")}
      <div class="separateur" style="--k:2"><span>ou</span></div>
      <button type="button" class="bouton-verre verre verre-appuyable large bouton-google" style="--k:3"><span class="bouton-verre-texte">{ic("google")}Continuer avec Google</span></button>
      <p class="legal" style="--k:4">{LEGAL}</p>
    </form>
  </div>
</div>
'''

# Un compte existe pour cet e-mail : on demande le mot de passe. Ni nom ni
# photo du compte : sinon, taper l e-mail de quelqu un suffirait a savoir
# qu il est sur USW, et sous quel nom.
MOT_DE_PASSE = page(f'''  <div class="retour-compte">
    <span class="email-tape">{ic("enveloppe")}akouavi.k@gmail.com<a class="lien">Changer</a></span>
    {mots('Entrez votre mot de passe')}
  </div>
  <form class="formulaire">
{champ("Mot de passe", "cadenas", "Votre mot de passe", focus=True, fin=OEIL, indication=True, k=0)}
    <a class="lien droite" style="--k:1">Mot de passe oublié ?</a>
    {BOUTON.format(k=2, t="Se connecter")}
  </form>''', classe='authentification')

# Pas de compte pour cet e-mail : on en cree un, avec un mot de passe.
CREER_MDP = page(f'''  {mots('Créez votre mot de passe')}
  <p class="page-texte">Pour le compte <b>akouavi.k@gmail.com</b>.</p>
  <form class="formulaire">
{champ("Mot de passe", "cadenas", "••••••••••", aide='<span class="force"><i></i><i></i><i></i><i></i></span>Solide', focus=True, fin=OEIL, k=0)}
    <ul class="criteres" style="--k:1">{critere(True, "8 caractères au moins")}{critere(True, "Un chiffre")}{critere(True, "Une lettre")}</ul>
    {BOUTON.format(k=2, t="Continuer")}
  </form>
  <p class="pied-page legal">{LEGAL}</p>''', classe='authentification')


# ------------------------------------------------------------ E36 completer le profil
# A la premiere connexion (par e-mail ou par Google), trois etapes.

def etape(n, contenu, passer=False):
    bouton_passer = '<button type="button" class="lien-discret">Passer</button>' if passer else ''
    return f'''<div class="app page completer">
  <!--barre-etat-->
  {progression(n)}
  <div class="page-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Retour">{ic('retour')}</button>
    <span class="etape">Étape {n} sur 3</span>{bouton_passer}
  </div>
{contenu}
</div>
'''


COMPLETER_1 = etape(1, f'''  {mots('Votre profil')}
  <p class="page-texte">Ce que les autres verront à côté de vos photos.</p>
  <div class="photo-profil">
    <span class="avatar geant" style="--teinte:hsl(229 97% 55%)">AK<span class="photo-profil-bouton">{ic("camera")}</span></span>
    <a class="lien">Ajouter une photo</a>
  </div>
  <form class="formulaire">
{champ("Nom affiché", "profil", "Akouavi K.", aide="Repris de votre compte Google : vous pouvez le changer.", k=0)}
{champ("Nom d'utilisateur", "arobase", "akouavi.k", aide=ic("coche", "mini") + "Ce nom est libre", fin=ic("coche", "ok"), focus=True, k=1)}
    <div class="champ-bloc" style="--k:2">
      <span class="champ-libelle">Bio <span class="facultatif">facultatif</span></span>
      <div class="champ verre zone">{ic("crayon")}<span class="champ-place">Ce que vous aimez photographier, en une phrase</span></div>
    </div>
    {BOUTON.format(k=3, t="Continuer")}
  </form>''')

COMPLETER_2 = etape(2, f'''  {mots("D'où êtes-vous ?")}
  <p class="page-texte">Pour vous montrer d'abord les lieux près de chez vous.</p>
  <form class="formulaire">
{champ("Pays", "globe", "Bénin", fin=ic("chevron-bas", "petite"), k=0)}
{champ("Ville", "lieu", "Cotonou", fin=ic("chevron-bas", "petite"), k=1)}
    <div class="reglage-carte verre-plaque" style="--k:2">
      <span class="reglage-icone">{ic("cible")}</span>
      <div><strong>Utiliser ma position</strong><span>Pour le fil « Près de moi ». Modifiable à tout moment dans les réglages.</span></div>
      <span class="interrupteur actif" role="switch" aria-checked="true"></span>
    </div>
    {BOUTON.format(k=3, t="Continuer")}
  </form>''')

INTERETS = [
    ('p108', 'Plages', True), ('p15', 'Cascades', True), ('p110', 'Savane et parcs', False),
    ('p124', 'Lacs et lagunes', True), ('p57', 'Villes et rues', False), ('p62', 'Collines', False),
    ('p28', 'Forêts', True), ('p37', 'Couchers de soleil', False), ('p78', 'Patrimoine', False),
]


def completer_3():
    tuiles = ''.join(
        f'<button type="button" class="interet{" choisi" if choisi else ""}" aria-pressed="{str(choisi).lower()}" style="--n:{i}">'
        f'<span class="photo ph-{p}"></span><span class="interet-nom">{nom}</span>'
        f'{"<span class=" + chr(34) + "interet-coche" + chr(34) + ">" + ic("coche") + "</span>" if choisi else ""}</button>'
        for i, (p, nom, choisi) in enumerate(INTERETS)
    )
    choisis = sum(1 for *_, c in INTERETS if c)
    return etape(3, f'''  {mots('Ce que vous aimez voir')}
  <p class="page-texte">Choisissez au moins 3 types de lieux : votre fil commencera par eux.</p>
  <div class="interets">{tuiles}</div>
  <div class="completer-bas">
    {BOUTON.format(k=0, t=f"Terminer · {choisis} choisis")}
  </div>''', passer=True)


CODE = page(f'''  {mots('Vérifiez votre e-mail')}
  <p class="page-texte">Nous avons envoyé un code à 6 chiffres à <b>akouavi.k@gmail.com</b>.</p>
  <div class="code" aria-label="Code à 6 chiffres">
    <span class="verre" style="--k:0">4</span><span class="verre" style="--k:1">8</span><span class="verre" style="--k:2">1</span><span class="verre" style="--k:3">9</span><span class="verre actif" style="--k:4"><span class="curseur"></span></span><span class="verre" style="--k:5"></span>
  </div>
  <p class="champ-aide renvoi">{ic("horloge", "mini")}Renvoyer le code dans 0:42</p>
  {BOUTON_INACTIF.format(k=0, t="Vérifier")}
  <p class="pied-page">Mauvaise adresse ? <a class="lien">La corriger</a></p>''', classe='authentification')

OUBLI = page(f'''  {mots('Mot de passe oublié')}
  <p class="page-texte">Indiquez l'e-mail du compte : nous y enverrons un code pour choisir un nouveau mot de passe.</p>
  <form class="formulaire">
{champ("E-mail", "enveloppe", "akouavi.k@gm", focus=True, k=0)}
    {BOUTON.format(k=1, t="Envoyer le code")}
  </form>
  <p class="pied-page">Vous vous en souvenez ? <a class="lien">Se connecter</a></p>''', classe='authentification')

NOUVEAU = page(f'''  {mots('Nouveau mot de passe')}
  <p class="page-texte">Choisissez-en un que vous n'utilisez pas ailleurs.</p>
  <form class="formulaire">
{champ("Nouveau mot de passe", "cadenas", "••••••••", fin=OEIL, k=0)}
{champ("Confirmer", "cadenas", "••••••", focus=True, fin=OEIL, k=1)}
    <ul class="criteres" style="--k:2">{critere(True, "8 caractères au moins")}{critere(True, "Un chiffre")}{critere(False, "Les deux mots de passe sont identiques")}</ul>
    {BOUTON_INACTIF.format(k=3, t="Enregistrer")}
  </form>''', classe='authentification')


# ------------------------------------------------------------ E34 conditions generales

ARTICLES = [
    ('objet', 'Objet', "Les présentes conditions encadrent l'utilisation de USW (United State of World), application de partage de photos et de reels de lieux, prises sur place par leurs auteurs. En créant un compte, vous les acceptez."),
    ('compte', 'Votre compte', "Vous fournissez un e-mail valide et gardez votre mot de passe secret. Un compte est personnel. Vous pouvez le supprimer à tout moment depuis les réglages : vos contenus sont alors retirés."),
    ('contenus', 'Ce que vous publiez', "Vous ne publiez que des photos et des vidéos que vous avez prises vous-même, sur le lieu indiqué. Les images générées ou retouchées par une intelligence artificielle sont refusées. Une photo ancienne est acceptée."),
    ('capture', 'Les informations de capture', "USW lit dans le fichier le téléphone, la date et la position de la prise. Ce que le fichier ne dit pas, vous l'indiquez vous-même : l'information est alors marquée « déclarée ». Indiquer une information fausse peut entraîner le retrait du contenu."),
    ('droits', 'Vos droits sur vos contenus', "Vous restez propriétaire de vos photos et de vos reels. Vous accordez à USW le droit de les afficher, de les redimensionner et de les convertir pour l'application, le temps de leur publication."),
    ('original', "Le téléchargement de l'original", "Les autres membres peuvent télécharger l'original d'une photo pour un usage personnel. Toute autre utilisation demande votre accord."),
    ('moderation', 'Modération et signalement', "Chaque contenu peut être signalé. L'équipe de modération vérifie les signalements et peut retirer un contenu ou suspendre un compte qui ne respecte pas les règles communautaires."),
    ('donnees', 'Données personnelles', "USW ne collecte que ce dont l'application a besoin. Le détail figure dans la politique de confidentialité."),
    ('contact', 'Nous écrire', "Pour toute question sur ces conditions : support@usw.app."),
]


# Le document vivant de SafeVault, tel quel : une feuille ou le texte s ecrit,
# un titre a l encre ocean puis quatre lignes, tracees l une apres l autre.
LIGNES_DOCUMENT = [
    'M9 18.5c1.5-1.5 3 1.5 4.5 0s3 1.5 4.5 0 3 1.5 4.5 0',
    'M9 24.5c1.75-1.4 3.5 1.4 5.25 0s3.5 1.4 5.25 0 3.5 1.4 5.25 0 3.5 1.4 5.25 0',
    'M9 29.5c1.6-1.4 3.2 1.4 4.8 0s3.2 1.4 4.8 0 3.2 1.4 4.8 0 3.2 1.4 3.6 0',
    'M9 34.5c1.75-1.4 3.5 1.4 5.25 0s3.5 1.4 5.25 0 3.5 1.4 5.25 0 3.5 1.4 5.25 0',
    'M9 39.5c1.5-1.4 3 1.4 4.5 0s3 1.4 4.5 0',
]


def document_vivant():
    lignes = ''.join(f'<path class="ligne ligne-{i + 1}" d="{d}" pathLength="1"/>' for i, d in enumerate(LIGNES_DOCUMENT))
    return ('<svg class="document-vivant" viewBox="0 0 40 48" aria-hidden="true"><defs>'
            '<linearGradient id="papier" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#ffffff"/><stop offset="1" stop-color="#eef0f8"/></linearGradient>'
            '<linearGradient id="pli" x1="0" y1="1" x2="1" y2="0"><stop offset="0" stop-color="#f6f7fc"/><stop offset="1" stop-color="#cfd4e6"/></linearGradient></defs>'
            '<path class="papier" d="M8 2.5h17.5l10 10V41a4.5 4.5 0 0 1-4.5 4.5H8A4.5 4.5 0 0 1 3.5 41V7A4.5 4.5 0 0 1 8 2.5z" fill="url(#papier)"/>'
            '<path d="M25.5 2.5 35.5 12.5V16l-10-6z" fill="#1b2350" opacity="0.07"/>'
            '<path class="papier-pli" d="M25.5 2.5V9a3.5 3.5 0 0 0 3.5 3.5h6.5z" fill="url(#pli)"/>'
            + lignes + '</svg>')


def cgu():
    sommaire = ''.join(f'<span class="pastille verre" style="--k:{i}">{t}</span>' for i, (_, t, _) in enumerate(ARTICLES))
    articles = '\n'.join(
        f'''    <section class="article" id="{a}" style="--n:{i}">
      <h2><span class="numero">{i + 1}</span>{t}</h2>
      <p>{texte}</p>
    </section>''' for i, (a, t, texte) in enumerate(ARTICLES)
    )
    return page(f'''  <div class="document-tete">
    {document_vivant()}
    {mots("Conditions générales d'utilisation")}
    <p class="page-texte">En vigueur le 22 octobre 2026 · 4 min de lecture</p>
  </div>
  <nav class="sommaire" aria-label="Sommaire">{sommaire}</nav>
  <main class="document">
{articles}
  </main>
  <p class="pied-page">Voir aussi les <a class="lien">règles communautaires</a> et la <a class="lien">politique de confidentialité</a>.</p>''', classe='lecture')


# ------------------------------------------------------------ E35 aide

SUJETS = [
    ('camera', 'Publier une photo'),
    ('verifie', 'Capture vérifiée'),
    ('lieu', 'Y aller et Maps'),
    ('profil', 'Mon compte'),
    ('telecharger', 'Envoi en 3G'),
    ('bouclier', 'Signaler un contenu'),
]
QUESTIONS = [
    ("Pourquoi ma photo n'a pas le badge « Capture vérifiée » ?", "Le badge vient quand le téléphone, la date et le lieu sont lus dans le fichier lui-même, ou quand la photo est prise avec la caméra USW. Si vous les avez indiqués à la main, la photo porte « Informations déclarées » : elle est publiée de la même façon."),
    ("Puis-je publier une photo prise il y a longtemps ?", ''),
    ("Pourquoi USW refuse les images générées par IA ?", ''),
    ("Mon envoi s'est arrêté en 3G, que faire ?", ''),
    ("Comment télécharger l'original d'une photo ?", ''),
]


def aide():
    sujets = ''.join(f'<button type="button" class="sujet verre verre-appuyable" style="--n:{i}">{ic(n)}<span>{t}</span></button>' for i, (n, t) in enumerate(SUJETS))
    questions = []
    for i, (q, r) in enumerate(QUESTIONS):
        ouverte = bool(r)
        reponse = f'<p>{r}</p>' if r else ''
        questions.append(f'      <div class="question{" ouverte" if ouverte else ""}" style="--n:{i}"><button type="button" aria-expanded="{str(ouverte).lower()}"><span>{q}</span>{ic("chevron-bas", "petite")}</button>{reponse}</div>')
    return page(f'''  {mots("Comment pouvons-nous vous aider ?")}
  <div class="champ verre recherche-aide">{ic("loupe")}<span class="champ-place">Rechercher dans l'aide</span></div>
  <h2 class="section-titre">Les sujets</h2>
  <div class="sujets">{sujets}</div>
  <h2 class="section-titre">Questions fréquentes</h2>
  <div class="questions">
{chr(10).join(questions)}
  </div>
  <div class="contact verre-plaque">
    <span class="contact-icone">{ic("enveloppe")}</span>
    <div><strong>Pas trouvé la réponse ?</strong><span>L'équipe répond sous 48 h.</span></div>
    <button type="button" class="bouton-verre verre verre-appuyable"><span class="bouton-verre-texte">Écrire</span></button>
  </div>
  <nav class="liens-legaux">
    <a>{ic("bouclier")}Règles communautaires{ic("chevron-droite", "petite")}</a>
    <a>{ic("document")}Conditions générales{ic("chevron-droite", "petite")}</a>
    <a>{ic("cadenas")}Confidentialité{ic("chevron-droite", "petite")}</a>
  </nav>''', classe='lecture')


def main():
    ecrire('e01-bienvenue-1.html', bienvenue(1, VISUEL_1, 'Des lieux, en vraies photos', "Chaque photo et chaque reel de USW a été pris sur place, par quelqu'un qui y était.", SUIVANT))
    ecrire('e01-bienvenue-2.html', bienvenue(2, VISUEL_2, "Chaque photo dit d'où elle vient", "Le téléphone, la date et le lieu de la prise sont lus dans le fichier, ou indiqués par l'auteur.", SUIVANT))
    ecrire('e01-bienvenue-3.html', bienvenue(3, VISUEL_3, "Envie d'y aller ?", "Touchez « Y aller » : Maps ouvre l'itinéraire jusqu'au lieu de la photo.", ACTIONS_3))
    ecrire('e02-entree.html', ENTREE)
    ecrire('e02-mot-de-passe.html', MOT_DE_PASSE)
    ecrire('e02-creer-mdp.html', CREER_MDP)
    ecrire('e36-completer-1.html', COMPLETER_1)
    ecrire('e36-completer-2.html', COMPLETER_2)
    ecrire('e36-completer-3.html', completer_3())
    ecrire('e02-code.html', CODE)
    ecrire('e02-oubli.html', OUBLI)
    ecrire('e02-nouveau.html', NOUVEAU)
    ecrire('e34-cgu.html', cgu())
    ecrire('e35-aide.html', aide())
    print('ecrans du compte ecrits.')


if __name__ == '__main__':
    main()
