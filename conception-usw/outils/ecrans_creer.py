"""Ecrit les ecrans du parcours Creer. La photo se prend avec l appareil photo
du telephone ; la lecture du fichier et la verification se font sans rien
demander : un ecran ne vient que s il manque quelque chose (E15)., dans maquette/ecrans/ :
autoriser (E32), creer (E12), tourner un reel (E27), monter le reel (E28),
choisir un son (E29), details (E14), completer (E15), indiquer le lieu (E30), envoi en route (E16),
mes envois (E26).

  python outils/ecrans_creer.py
"""

from ecrans_compte import ecrire, ic, mots, champ, BOUTON
from ecrans_profil import carte, PUBLICATIONS, bouton


def bouton_rond(icone, etiquette, classe=''):
    return f'<button type="button" class="rond-verre givre verre verre-appuyable{(" " + classe) if classe else ""}" aria-label="{etiquette}">{ic(icone)}</button>'


def reglage(icone, titre, texte, actif=True, k=0):
    etat = 'actif' if actif else ''
    return f'''    <div class="reglage-carte verre-plaque" style="--k:{k}">
      <span class="reglage-icone">{ic(icone)}</span>
      <div><strong>{titre}</strong><span>{texte}</span></div>
      <span class="interrupteur {etat}" role="switch" aria-checked="{str(actif).lower()}"></span>
    </div>'''


# ------------------------------------------------------------ E32 autoriser la camera

AUTORISER = f'''<div class="app page">
  <!--barre-etat-->
  <div class="page-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Fermer">{ic("fermer")}</button>
  </div>
  <div class="objectif" aria-hidden="true"><span class="objectif-verre"></span>{ic("camera")}</div>
  {mots("Une seule fois")}
  <p class="page-texte">Les photos se prennent avec l'appareil photo de votre téléphone, avec tous ses modes. USW y ajoute la position et le modèle : elles auront le badge Capture vérifiée.</p>
  <div class="formulaire">
{reglage("cible", "Position", "Inscrite à chaque photo et chaque reel.", k=0)}
{reglage("telephone", "Modèle du téléphone", "Tecno Camon 50 Pro, lu sur l'appareil.", k=1)}
{reglage("micro", "Caméra et micro", "Pour tourner les reels dans USW.", k=2)}
  </div>
  <div class="bas-page">
    {BOUTON.format(k=3, t="Autoriser")}
    <button type="button" class="lien-discret centre">Plus tard</button>
  </div>
</div>
'''


# ------------------------------------------------------------ E12 creer

def option(icone, titre, texte, n):
    return (f'<button type="button" class="option-creer" style="--n:{n}"><span class="option-icone">{ic(icone)}</span>'
            f'<span class="option-texte"><strong>{titre}</strong><span>{texte}</span></span>{ic("chevron-droite", "petite")}</button>')


CREER = f'''<div class="app fixe">
  <!--barre-etat-->
  <main class="mosaique fond-feuille">
{chr(10).join(carte(i, *c) for i, c in enumerate(PUBLICATIONS))}
  </main>
  <div class="feuille-fond"></div>
  <div class="feuille verre-plaque creer-feuille" role="dialog" aria-label="Créer">
    <span class="feuille-poignee"></span>
    <h2 class="feuille-titre">Créer</h2>
    {option("camera", "Prendre une photo", "Avec l'appareil photo du téléphone, tous ses modes", 0)}
    {option("reels", "Tourner un reel", "15, 30 ou 60 secondes, en plusieurs séquences", 1)}
    {option("image", "Importer de la galerie", "Une photo ou une vidéo déjà prise, même ancienne", 2)}
    <p class="note rappel">{ic("bouclier")}<span>USW n'accepte que des photos et des vidéos réelles : les images générées par IA sont refusées. <a class="lien-encre">Les règles</a></span></p>
  </div>
</div>
'''


# ------------------------------------------------------------ la camera USW, pour les reels

def camera(photo, haut, bas, classe=''):
    return f'''<div class="app fixe sombre camera{(" " + classe) if classe else ""}">
  <span class="viseur photo ph-{photo}"></span>
  <!--barre-etat-->
{haut}
{bas}
</div>
'''


INFOS_PRISE = f'''  <div class="infos-prise">
    <span class="info-prise">{ic("telephone")}Tecno Camon 50 Pro</span>
    <span class="info-prise">{ic("lieu")}Ouidah, Bénin</span>
  </div>'''

CAMERA_REEL = camera('p15', f'''  <div class="sequences" aria-label="Séquences filmées"><span style="--p:100%"></span><span style="--p:100%"></span><span class="encours" style="--p:46%"></span><span></span></div>
  <div class="camera-haut">
    {bouton_rond("fermer", "Fermer")}
    <span class="chrono">{'<span class="rec"></span>'}0:18 / 0:30</span>
    {bouton_rond("minuteur", "Minuteur")}
  </div>
{INFOS_PRISE.replace("Ouidah, Bénin", "Cascade de Kota")}''', f'''  <div class="camera-bas">
    <div class="durees"><span>15 s</span><span aria-current="true">30 s</span><span>60 s</span></div>
    <div class="commandes-camera">
      {bouton_rond("poubelle", "Effacer la dernière séquence")}
      <button type="button" class="declencheur enregistre" aria-label="Arrêter la séquence"><span></span></button>
      <button type="button" class="bouton-verre verre verre-appuyable plein suivant-reel"><span class="bouton-verre-texte">Suivant</span></button>
    </div>
    <div class="modes"><span>Photo</span><span aria-current="true">Reel</span></div>
  </div>''', 'reel-camera')


# ------------------------------------------------------------ E28 monter le reel

def segment(photo, duree, choisi=False, n=0):
    return (f'<div class="segment{" choisi" if choisi else ""}" style="--n:{n};--l:{duree}">'
            f'<span class="photo ph-{photo}"></span><span class="segment-duree">{duree} s</span></div>')


def outil(icone, nom, classe=''):
    return f'<button type="button" class="outil{(" " + classe) if classe else ""}"><span class="outil-icone">{ic(icone)}</span>{nom}</button>'


MONTAGE_CORPS = f'''  <div class="page-haut montage-haut">
    <button type="button" class="rond-verre givre verre verre-appuyable" aria-label="Retour">{ic("retour")}</button>
    <span class="page-haut-titre centre">Monter le reel</span>
    <button type="button" class="bouton-verre verre verre-appuyable plein petit"><span class="bouton-verre-texte">Suivant</span></button>
  </div>
  <div class="apercu-reel">
    <span class="photo ph-p15"></span>
    <span class="texte-reel">Avant 9 h, personne</span>
    <button type="button" class="lecture-reel" aria-label="Lire">{ic("lecture")}</button>
    <span class="temps-reel">0:07 / 0:28</span>
  </div>
  <div class="outils">
    {outil("ciseaux", "Couper")}
    {outil("texte", "Texte")}
    {outil("musique", "Son")}
    {outil("retourner", "Réordonner")}
    {outil("poubelle", "Supprimer", "danger")}
  </div>
  <div class="frise">
    <span class="tete-lecture"></span>
    {segment("p15", 11, False, 0)}{segment("p28", 9, True, 1)}{segment("p10", 8, False, 2)}
  </div>'''

MONTAGE = f'''<div class="app fixe sombre montage">
  <!--barre-etat-->
{MONTAGE_CORPS}
</div>
'''


# ------------------------------------------------------------ E29 choisir un son

def piste(n, titre, auteur, duree, choisie=False, lecture=False):
    return (f'<div class="piste{" choisie" if choisie else ""}" style="--n:{n}"><span class="piste-icone">{ic("pause" if lecture else "lecture")}</span>'
            f'<div><strong>{titre}</strong><span>{auteur} · {duree}</span></div>'
            f'{"<span class=" + chr(34) + "piste-coche" + chr(34) + ">" + ic("coche") + "</span>" if choisie else ""}</div>')


SON = f'''<div class="app fixe sombre montage">
  <!--barre-etat-->
{MONTAGE_CORPS}
  <div class="feuille-fond"></div>
  <div class="feuille verre-plaque son-feuille" role="dialog" aria-label="Choisir un son">
    <span class="feuille-poignee"></span>
    <h2 class="feuille-titre">Le son</h2>
    <nav class="flux" aria-label="Sources"><span aria-current="true">Musiques libres</span><span>Son d'origine</span><span>Voix off</span></nav>
    <div class="champ verre">{ic("loupe")}<span class="champ-place">Chercher une musique</span></div>
    <div class="pistes">
      {piste(0, "Lagune au matin", "Kossi Studio", "1:42", True, True)}
      {piste(1, "Marée haute", "Atelier Ouidah", "2:10")}
      {piste(2, "Chemins rouges", "Nord Sonore", "1:58")}
      {piste(3, "Pluie sur Ganvié", "Kossi Studio", "2:31")}
    </div>
    <div class="melange">
      <span>{ic("micro")}Son d'origine</span><span class="curseur-volume" style="--v:30%"></span>
    </div>
    <p class="note">{ic("bouclier")}Musiques libres de droits, utilisables dans vos reels.</p>
  </div>
</div>
'''


# ------------------------------------------------------------ E14 details

DETAILS = f'''<div class="app page">
  <!--barre-etat-->
  <div class="page-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Retour">{ic("retour")}</button>
    <span class="page-haut-titre centre">Nouvelle publication</span>
    <span class="place-bouton"></span>
  </div>
  <div class="details-apercu">
    <div class="carte-image"><span class="photo ph-p124"></span><span class="badge verifie">{ic("verifie")}Capture vérifiée</span></div>
    <div class="details-infos">
      <span>{ic("telephone")}Tecno Camon 50 Pro</span>
      <span>{ic("calendrier")}12 août 2026</span>
      <span>{ic("lieu")}Lac Ahémé</span>
    </div>
  </div>
  <form class="formulaire">
    <div class="champ-bloc" style="--k:0">
      <span class="champ-libelle">Légende</span>
      <div class="champ verre zone focus"><span class="champ-valeur multi">Les pirogues rentrent au coucher du soleil, côté Possotomé.</span><span class="curseur"></span></div>
    </div>
    <div class="champ-bloc" style="--k:1">
      <span class="champ-libelle">Lieu trouvé</span>
      <div class="champ verre">{ic("lieu")}<span class="champ-valeur">Lac Ahémé, Possotomé, Mono</span>{ic("chevron-droite", "petite")}</div>
      <div class="types"><span class="pastille verre" aria-checked="true">Lac et lagune</span><span class="pastille verre">Plage</span><span class="pastille verre">Village</span></div>
    </div>
    {BOUTON.format(k=2, t=ic("envoyer") + "Publier")}
  </form>
</div>
'''


# ------------------------------------------------------------ E15 completer

def modele(nom, detail, choisi=False):
    return (f'<div class="modele{" choisi" if choisi else ""}"><span class="radio"></span>'
            f'<div><strong>{nom}</strong>{"<span>" + detail + "</span>" if detail else ""}</div></div>')


COMPLETER = f'''<div class="app page">
  <!--barre-etat-->
  <div class="page-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Retour">{ic("retour")}</button>
  </div>
  {mots("Ce que le fichier ne dit pas")}
  <p class="page-texte">Cette photo ancienne n'a ni téléphone ni date. Indiquez-les : elle sera publiée avec le badge « Informations déclarées ».</p>
  <section class="manque" style="--n:0">
    <h2 class="champ-libelle">{ic("telephone")}Le téléphone qui l'a prise</h2>
    <div class="champ verre focus">{ic("loupe")}<span class="champ-valeur">Tecno Spark 30C</span><span class="curseur"></span></div>
    <p class="champ-aide">Tapez le modèle : choisissez-le s'il est dans la liste, sinon ajoutez-le.</p>
    <div class="modeles verre-plaque">
      <div class="modele-ajout">{ic("plus")}<div><strong>Ajouter « Tecno Spark 30C »</strong><span>Il rejoindra la liste pour les suivants</span></div></div>
      {modele("Tecno Spark 30 Pro", "Déjà utilisé sur USW")}
      {modele("Tecno Spark 20C", "Déjà utilisé sur USW")}
    </div>
    <button type="button" class="ce-telephone">{ic("telephone")}C'est ce téléphone : Tecno Camon 50 Pro</button>
  </section>
  <section class="manque" style="--n:1">
    <h2 class="champ-libelle">{ic("calendrier")}La date de la prise</h2>
    <div class="champ verre focus">{ic("calendrier")}<span class="champ-valeur">Mars 2019</span><span class="curseur"></span></div>
    <p class="champ-aide">Le mois et l'année suffisent.</p>
  </section>
  <section class="manque" style="--n:2">
    <h2 class="champ-libelle">{ic("lieu")}Le lieu</h2>
    <div class="champ verre"><span class="champ-place">Pas de GPS dans le fichier</span><a class="lien-encre fin">Indiquer</a></div>
  </section>
  <div class="resultat"><span>Badge de la publication</span><span class="badge declare">{ic("crayon")}Informations déclarées</span></div>
  <div class="bas-page">{BOUTON.format(k=0, t="Continuer")}</div>
</div>
'''


# ------------------------------------------------------------ E30 indiquer le lieu

def plan(classe='plan'):
    """Un plan dessine pour la maquette : la cote de Grand-Popo, la lagune, des routes."""
    return f'''<svg class="{classe}" viewBox="0 0 400 800" preserveAspectRatio="xMidYMid slice" aria-hidden="true">
    <rect width="400" height="800" fill="#eceef4"/>
    <path d="M0 610 C80 590 140 640 220 620 S340 600 400 615 V800 H0z" fill="#b9d7f2"/>
    <path d="M0 520 C60 505 120 540 190 525 S320 500 400 520 V548 C330 530 260 556 190 552 S60 535 0 548z" fill="#b9d7f2"/>
    <path d="M30 140 C70 120 130 150 150 200 S120 280 70 270 S10 190 30 140z" fill="#cfe6cf"/>
    <path d="M250 260 C300 240 360 270 365 320 S320 390 280 375 S220 290 250 260z" fill="#cfe6cf"/>
    <g fill="none" stroke="#fff" stroke-linecap="round">
      <path d="M-10 470 C90 450 200 480 410 455" stroke-width="12"/>
      <path d="M200 -10 C190 120 230 260 205 470" stroke-width="9"/>
      <path d="M-10 300 C100 320 260 290 410 330" stroke-width="7"/>
      <path d="M90 470 C100 400 70 350 95 300" stroke-width="5"/>
      <path d="M310 460 C300 400 330 360 320 320" stroke-width="5"/>
    </g>
    <g fill="none" stroke="#f3d27a" stroke-linecap="round"><path d="M-10 470 C90 450 200 480 410 455" stroke-width="5"/></g>
  </svg>'''


LIEU_CARTE = f'''<div class="app fixe choisir-lieu">
  {plan()}
  <!--barre-etat-->
  <div class="lieu-haut">
    <button type="button" class="rond-verre verre verre-appuyable givre" aria-label="Retour">{ic("retour")}</button>
    <div class="champ verre givre-champ">{ic("loupe")}<span class="champ-valeur">Grand-Popo</span></div>
  </div>
  <div class="epingle-carte">{ic("lieu")}<span class="epingle-ombre"></span></div>
  <button type="button" class="rond-verre verre verre-appuyable givre ma-position" aria-label="Ma position">{ic("cible")}</button>
  <div class="lieu-choisi verre-plaque">
    <p class="lieu-indice">Déplacez la carte pour poser l'épingle.</p>
    <div class="lieu-ligne-choix"><span class="lieu-pastille">{ic("lieu")}</span><div><strong>Plage de Grand-Popo</strong><span>Grand-Popo, Mono, Bénin · 6,2795° N, 1,8226° E</span></div></div>
    {BOUTON.format(k=0, t="Choisir ce lieu")}
  </div>
</div>
'''


# ------------------------------------------------------------ E16 envoi en route

def envoi_pastille():
    return f'''  <div class="envoi-pastille verre-plaque" role="status">
    <span class="photo ph-p124"></span>
    <div><strong>Envoi en cours · 64 %</strong><span>2 sur 3 · réseau 3G, reprise automatique</span><span class="barre-envoi" style="--p:64%"></span></div>
    <button type="button" class="rond-verre verre verre-appuyable petit-rond" aria-label="Mettre en pause">{ic("pause")}</button>
  </div>'''


EN_ROUTE = f'''<div class="app fixe">
  <!--barre-etat-->
  <main class="mosaique">
{chr(10).join(carte(i, *c) for i, c in enumerate(PUBLICATIONS))}
  </main>
  <div class="toast">{ic("coche")}Publication lancée : vous pouvez continuer à naviguer.</div>
{envoi_pastille()}
  <!--onglets:accueil-->
</div>
'''


# ------------------------------------------------------------ E26 mes envois

def envoi(n, photo, titre, etat, detail, progres=None, actions=''):
    barre = f'<span class="barre-envoi" style="--p:{progres}"></span>' if progres else ''
    return (f'<div class="envoi {etat}" style="--n:{n}"><span class="photo ph-{photo}"></span>'
            f'<div><strong>{titre}</strong><span class="envoi-detail">{detail}</span>{barre}</div>'
            f'<div class="envoi-actions">{actions}</div></div>')


ROND_PAUSE = f'<button type="button" class="rond-verre verre verre-appuyable petit-rond" aria-label="Pause">{ic("pause")}</button>'
ROND_REPRENDRE = f'<button type="button" class="rond-verre verre verre-appuyable petit-rond" aria-label="Reprendre">{ic("lecture")}</button>'
ROND_ANNULER = f'<button type="button" class="rond-verre verre verre-appuyable petit-rond danger" aria-label="Annuler">{ic("fermer")}</button>'

MES_ENVOIS = f'''<div class="app page">
  <!--barre-etat-->
  <div class="page-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Retour">{ic("retour")}</button>
  </div>
  {mots("Mes envois")}
  <p class="page-texte">Un envoi coupé reprend où il s'était arrêté, dès que le réseau revient.</p>
  <h2 class="groupe-titre">En cours</h2>
  <div class="envois">
    {envoi(0, "p124", "Lac Ahémé, 3 photos", "encours", "64 % · 4,1 Mo sur 6,4 Mo · 3G", "64%", ROND_PAUSE + ROND_ANNULER)}
    {envoi(1, "p15", "Cascade de Kota, reel 0:28", "pause", "En pause · 22 % · reprendra en Wi-Fi", "22%", ROND_REPRENDRE + ROND_ANNULER)}
  </div>
  <h2 class="groupe-titre">En vérification</h2>
  <div class="envois">
    {envoi(2, "p77", "Ponton de Ouidah", "verification", "Recherche des signes d'IA · environ 1 min")}
  </div>
  <h2 class="groupe-titre">Terminés</h2>
  <div class="envois">
    {envoi(3, "p108", "Plage de Grand-Popo", "publie", f'{ic("verifie")}Publiée hier, Capture vérifiée')}
    {envoi(4, "p57", "Rues de Porto-Novo", "refuse", f'{ic("drapeau")}Refusée : image générée par IA', actions='<a class="lien-encre">Motif</a>')}
  </div>
</div>
'''


def main():
    ecrire('e32-autoriser.html', AUTORISER)
    ecrire('e12-creer.html', CREER)
    ecrire('e27-reel.html', CAMERA_REEL)
    ecrire('e28-montage.html', MONTAGE)
    ecrire('e29-son.html', SON)
    ecrire('e14-details.html', DETAILS)
    ecrire('e15-completer.html', COMPLETER)
    ecrire('e30-lieu.html', LIEU_CARTE)
    ecrire('e16-en-route.html', EN_ROUTE)
    ecrire('e26-envois.html', MES_ENVOIS)
    print('ecrans de creation ecrits.')


if __name__ == '__main__':
    main()
