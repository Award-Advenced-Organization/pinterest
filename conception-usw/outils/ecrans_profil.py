"""Ecrit les ecrans du profil : mon profil (E18), modifier le profil et
reglages (E21), notifications (E17), profil d un createur (E20), dans
maquette/ecrans/.

  python outils/ecrans_profil.py
"""

from ecrans_compte import ECRANS, champ, ecrire, ic, mots

# Les cartes de la mosaique : photo, auteur ou lieu, telephone, duree d un reel.
PUBLICATIONS = [
    ('p108', 'Plage de Grand-Popo', 'iPhone 14 Pro', None),
    ('p77', 'Ponton de Ouidah', 'iPhone 14 Pro', None),
    ('p124', 'Lac Ahémé, Possotomé', 'Tecno Camon 50 Pro', '0:24'),
    ('p92', 'Plage de Fidjrossè', 'Tecno Camon 50 Pro', None),
    ('p58', 'Phare de Cotonou', 'iPhone 14 Pro', None),
    ('p71', 'Rives du lac Nokoué', 'Tecno Camon 50 Pro', None),
]


def carte(n, photo, lieu, telephone, duree):
    extra = (f'<span class="duree">{duree}</span><span class="son">{ic("muet")}</span>' if duree else '')
    return f'''      <article class="carte" style="--n:{n}">
        <div class="carte-image"><span class="photo ph-{photo}"></span>{extra}<span class="badge verifie">{ic("verifie")}Vérifiée</span></div>
        <div class="carte-pied">
          <div><div class="carte-lieu">{lieu}</div><div class="carte-appareil">{ic("telephone", "mini")}{telephone}</div></div>
          {ic("plus-points", "petite")}
        </div>
      </article>'''


def mosaique(cartes):
    return '  <main class="mosaique">\n' + '\n'.join(carte(i, *c) for i, c in enumerate(cartes)) + '\n  </main>'


def tete_profil(initiales, teinte, nom, pseudo, bio, lieu, chiffres, actions):
    stats = ''.join(f'<div><strong>{v}</strong><span>{l}</span></div>' for v, l in chiffres)
    return f'''  <section class="profil-tete">
    <span class="avatar geant" style="--teinte:{teinte}">{initiales}</span>
    {mots(nom, classe='profil-nom')}
    <p class="profil-pseudo">@{pseudo}</p>
    <p class="profil-bio">{bio}</p>
    <p class="profil-lieu">{ic("lieu")}{lieu}</p>
    <div class="profil-chiffres">{stats}</div>
    <div class="profil-actions">{actions}</div>
  </section>'''


def bouton(texte, plein=False, icone=''):
    return (f'<button type="button" class="bouton-verre verre verre-appuyable{" plein" if plein else ""}">'
            f'<span class="bouton-verre-texte">{ic(icone) if icone else ""}{texte}</span></button>')


# ------------------------------------------------------------ E18 mon profil

MON_PROFIL = f'''<div class="app profil-page">
  <!--barre-etat-->
  <div class="page-haut profil-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Partager le profil">{ic("partager")}</button>
    <span class="espace"></span>
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Mes envois">{ic("telecharger")}</button>
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Réglages">{ic("reglages")}</button>
  </div>
{tete_profil("AK", "hsl(229 97% 55%)", "Akouavi K.", "akouavi.k", "Photos du golfe de Guinée, de Ouidah à Grand-Popo.", "Cotonou, Bénin",
             [("128", "publications"), ("1 284", "abonnés"), ("312", "abonnements")],
             bouton("Modifier le profil", icone="crayon") + bouton("Mes collections", icone="collection"))}
  <nav class="flux mots profil-flux" aria-label="Contenus">
    <span aria-current="true" class="m"><span style="--k:0">Publications</span></span>
    <span class="m"><span style="--k:1">Reels</span></span>
    <span class="m"><span style="--k:2">Enregistrés</span></span>
  </nav>
{mosaique(PUBLICATIONS)}
  <!--onglets:profil-->
</div>
'''


# ------------------------------------------------------------ E20 profil d un createur

CREATEUR = f'''<div class="app profil-page">
  <!--barre-etat-->
  <div class="page-haut profil-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Retour">{ic("retour")}</button>
    <span class="espace"></span>
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Partager le profil">{ic("partager")}</button>
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Plus d'options">{ic("plus-points")}</button>
  </div>
{tete_profil("SV", "hsl(160 55% 34%)", "Sènan Voyage", "senan.voyage", "Les cascades et les sentiers du Nord, à pied.", "Natitingou, Bénin",
             [("342", "publications"), ("12,4 k", "abonnés"), ("188", "abonnements")],
             bouton("S'abonner", plein=True) + bouton("Partager", icone="partager"))}
  <nav class="flux mots profil-flux" aria-label="Contenus">
    <span aria-current="true" class="m"><span style="--k:0">Publications</span></span>
    <span class="m"><span style="--k:1">Reels</span></span>
  </nav>
{mosaique([('p15', 'Cascade de Kota', 'Infinix Note 30', '0:31'), ('p28', 'Forêt de la Pendjari', 'Infinix Note 30', None),
           ('p17', "Sentiers de l'Atacora", 'Infinix Note 30', None), ('p110', 'Parc de la Pendjari', 'Infinix Note 30', None),
           ('p10', 'Monts de Tanguiéta', 'Infinix Note 30', None), ('p66', 'Plaine de Boukoumbé', 'Infinix Note 30', None)])}
  <div class="feuille-fond"></div>
  <div class="feuille verre-plaque" role="dialog" aria-label="Options du profil">
    <span class="feuille-poignee"></span>
    <button type="button" class="feuille-ligne">{ic("partager")}Partager le profil</button>
    <button type="button" class="feuille-ligne">{ic("lien")}Copier le lien</button>
    <button type="button" class="feuille-ligne danger">{ic("bloque")}Bloquer Sènan Voyage</button>
    <button type="button" class="feuille-ligne danger">{ic("drapeau")}Signaler le profil</button>
  </div>
</div>
'''


# ------------------------------------------------------------ E21 modifier le profil

MODIFIER = f'''<div class="app page">
  <!--barre-etat-->
  <div class="page-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Retour">{ic("retour")}</button>
    <span class="page-haut-titre centre">Modifier le profil</span>
    <button type="button" class="bouton-verre verre verre-appuyable plein petit"><span class="bouton-verre-texte">Terminé</span></button>
  </div>
  <p class="page-texte">Ces informations sont visibles par tous, à côté de vos photos.</p>
  <div class="photo-profil">
    <span class="avatar geant" style="--teinte:hsl(229 97% 55%)">AK<span class="photo-profil-bouton">{ic("camera")}</span></span>
    <a class="lien-encre">Changer la photo</a>
  </div>
  <form class="formulaire">
{champ("Nom affiché", "profil", "Akouavi K.", k=0)}
{champ("Nom d'utilisateur", "arobase", "akouavi.k", k=1)}
    <div class="champ-bloc" style="--k:2">
      <span class="champ-libelle">Bio</span>
      <div class="champ verre zone focus">{ic("crayon")}<span class="champ-valeur multi">Photos du golfe de Guinée, de Ouidah à Grand-Popo.</span><span class="curseur"></span></div>
      <p class="champ-aide">52 sur 160 caractères</p>
    </div>
{champ("Ville", "lieu", "Cotonou, Bénin", fin=ic("chevron-bas", "petite"), k=3)}
{champ("Site web", "lien", "akouavi.photo", k=4)}
  </form>
</div>
'''


# ------------------------------------------------------------ E21 reglages

def ligne(icone, texte, valeur='', fin='chevron', classe=''):
    queue = {'chevron': ic('chevron-droite', 'petite'), 'actif': '<span class="interrupteur actif" role="switch" aria-checked="true"></span>',
             'inactif': '<span class="interrupteur" role="switch" aria-checked="false"></span>', '': ''}[fin]
    v = f'<span class="reglage-valeur">{valeur}</span>' if valeur else ''
    return f'<div class="reglage-ligne{(" " + classe) if classe else ""}"><span class="reglage-icone">{ic(icone)}</span><span class="reglage-texte">{texte}</span>{v}{queue}</div>'


def groupe(titre, lignes, n):
    return f'''  <section class="groupe" style="--n:{n}">
    <h2 class="groupe-titre">{titre}</h2>
    <div class="groupe-corps verre-plaque">{''.join(lignes)}</div>
  </section>'''


REGLAGES = f'''<div class="app page reglages">
  <!--barre-etat-->
  <div class="page-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Retour">{ic("retour")}</button>
  </div>
  {mots("Réglages")}
  <div class="compte-carte verre-plaque">
    <span class="avatar grand" style="--teinte:hsl(229 97% 55%)">AK</span>
    <div><strong>Akouavi K.</strong><span>akouavi.k@gmail.com · Google</span></div>
    {ic("chevron-droite", "petite")}
  </div>
{groupe("Compte", [ligne("crayon", "Modifier le profil"), ligne("cadenas", "E-mail et mot de passe"), ligne("bloque", "Comptes bloqués", "2")], 0)}
{groupe("Données mobiles", [ligne("image", "Photos en qualité réduite en 3G", fin="actif"), ligne("reels", "Lire les reels en Wi-Fi seulement", fin="actif"), ligne("telecharger", "Envois en Wi-Fi seulement", fin="inactif")], 1)}
{groupe("Autorisations", [ligne("cible", "Position", "Autorisée"), ligne("camera", "Caméra USW", "Autorisée"), ligne("cloche", "Notifications", "Activées")], 2)}
{groupe("Aide et informations", [ligne("aide", "Aide"), ligne("bouclier", "Règles communautaires"), ligne("document", "Conditions générales"), ligne("cadenas", "Confidentialité")], 3)}
  <section class="groupe" style="--n:4">
    <div class="groupe-corps verre-plaque">{ligne("sortie", "Se déconnecter", fin="", classe="danger")}</div>
  </section>
  <button type="button" class="supprimer">Supprimer mon compte</button>
  <p class="version">USW 1.0 · Groupe 4, IFRI</p>
</div>
'''


# ------------------------------------------------------------ E17 notifications

def notif(n, visuel, texte, quand, fin='', nouvelle=False):
    return (f'<div class="notif{" nouvelle" if nouvelle else ""}" style="--n:{n}">{visuel}'
            f'<p>{texte}<span class="quand">{quand}</span></p>{fin}</div>')


def av(initiales, teinte):
    return f'<span class="avatar" style="--teinte:{teinte}">{initiales}</span>'


def vignette(photo):
    return f'<span class="vignette photo ph-{photo}"></span>'


def pastille(icone, classe):
    return f'<span class="notif-icone {classe}">{ic(icone)}</span>'


NOTIFICATIONS = f'''<div class="app page notifications">
  <!--barre-etat-->
  <div class="page-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Retour">{ic("retour")}</button>
    <span class="espace"></span>
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Réglages des notifications">{ic("reglages")}</button>
  </div>
  {mots("Notifications")}
  <h2 class="groupe-titre">Aujourd'hui</h2>
  <div class="notifs">
    {notif(0, av("MS", "hsl(160 55% 34%)"), "<b>Mawuli S.</b> a aimé votre photo.", "2 min", vignette("p108"), True)}
    {notif(1, av("KD", "hsl(25 85% 50%)"), "<b>Kofi D.</b> a commenté : « Quelle lumière, à quelle heure ? »", "1 h", vignette("p77"), True)}
    {notif(2, pastille("verifie", "ok"), "Votre photo <b>Ponton de Ouidah</b> est en ligne, avec le badge Capture vérifiée.", "3 h", vignette("p77"))}
    {notif(3, pastille("telecharger", ""), "Votre envoi de <b>3 photos</b> est terminé.", "5 h")}
  </div>
  <h2 class="groupe-titre">Cette semaine</h2>
  <div class="notifs">
    {notif(4, av("AÏ", "hsl(280 50% 50%)"), "<b>Aïcha K.</b> s'est abonnée à vous.", "2 j", bouton("S'abonner", plein=True))}
    {notif(5, av("HO", "hsl(200 70% 40%)"), "<b>@hounkpe</b> vous a mentionnée : « @akouavi.k regarde ce coucher de soleil »", "3 j", vignette("p71"))}
    {notif(6, pastille("drapeau", "danger"), "Votre reel <b>Cascade de Kota</b> a été retiré : il contient des images générées par IA.", "4 j", '<a class="lien-encre">Voir le motif</a>')}
    {notif(7, av("SV", "hsl(160 55% 34%)"), "<b>Sènan Voyage</b> a publié 4 photos à <b>Ganvié</b>.", "6 j", vignette("p76"))}
  </div>
</div>
'''


def main():
    ecrire('e18-profil.html', MON_PROFIL)
    ecrire('e20-createur.html', CREATEUR)
    ecrire('e21-modifier.html', MODIFIER)
    ecrire('e21-reglages.html', REGLAGES)
    ecrire('e17-notifications.html', NOTIFICATIONS)
    print('ecrans du profil ecrits.')


if __name__ == '__main__':
    main()
