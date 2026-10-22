"""Ecrit les messages et les erreurs, dans maquette/ecrans/ (E37).

La securite travaille sans rien demander : la lecture du fichier, la
recherche des signes d IA, la reprise d un envoi se font en silence. On ne
montre quelque chose que lorsqu il y a un probleme, et on dit alors quoi
faire, en une phrase, avec une seule action principale.

  python outils/ecrans_messages.py
"""

import re

from ecrans_compte import ECRANS, OEIL, BOUTON, ecrire, ic, mots, page
from ecrans_profil import REGLAGES


def lire(nom):
    return (ECRANS / nom).read_text(encoding='utf-8')


def etat(icone, titre, texte, actions, classe=''):
    """Un ecran d etat : une icone, un titre, une phrase, l action a faire."""
    return f'''<div class="app fixe etat{(" " + classe) if classe else ""}">
  <!--barre-etat-->
  <div class="page-haut etat-haut">
    <button type="button" class="rond-verre verre verre-appuyable" aria-label="Retour">{ic("retour")}</button>
  </div>
  <div class="etat-corps">
    <span class="etat-icone">{ic(icone)}</span>
    {mots(titre, classe="etat-titre", balise="h1")}
    <p class="etat-texte">{texte}</p>
    <div class="etat-actions">{actions}</div>
  </div>
</div>
'''


def bouton(texte, plein=False, classe=''):
    return (f'<button type="button" class="bouton-verre verre verre-appuyable large{" plein" if plein else ""}{(" " + classe) if classe else ""}">'
            f'<span class="bouton-verre-texte">{texte}</span></button>')


# ------------------------------------------------------------ un champ en erreur

MDP_ERREUR = page(f'''  <div class="retour-compte">
    <span class="email-tape">{ic("enveloppe")}akouavi.k@gmail.com<a class="lien">Changer</a></span>
    {mots('Entrez votre mot de passe')}
  </div>
  <form class="formulaire">
    <div class="champ-bloc erreur" style="--k:0">
      <span class="champ-libelle">Mot de passe</span>
      <div class="champ verre">{ic("cadenas")}<span class="champ-valeur">••••••••</span>{OEIL}</div>
      <p class="champ-aide">{ic("alerte", "mini")}Mot de passe incorrect. Encore 4 essais avant une pause de 15 min.</p>
    </div>
    <a class="lien droite" style="--k:1">Mot de passe oublié ?</a>
    {BOUTON.format(k=2, t="Se connecter")}
  </form>''', classe='authentification')


# ------------------------------------------------------------ les etats

HORS_LIGNE = etat(
    "hors-ligne", "Pas de connexion",
    "Les photos que vous avez déjà vues restent là. Tout ce que vous publiez partira dès que le réseau revient.",
    bouton("Voir les photos enregistrées", plein=True) + bouton("Réessayer"),
)

INTROUVABLE = etat(
    "image-barre", "Cette photo n'est plus là",
    "Son auteur l'a retirée, ou le lien est incomplet.",
    bouton("Retour à l'accueil", plein=True),
)

REFUSEE = etat(
    "drapeau", "Publication refusée",
    "« Rues de Porto-Novo » contient des signes d'image générée par IA. Si c'est une vraie photo, demandez une vérification par l'équipe : la réponse arrive sous 48 h.",
    bouton("Demander une vérification", plein=True) + bouton("Lire les règles"),
    classe="danger-etat",
)


# ------------------------------------------------------------ une fenetre de confirmation

def dialogue():
    # La page des reglages, et la fenetre posee dessus.
    fin = REGLAGES.rstrip().rfind('</div>')
    return REGLAGES[:fin] + f'''  <div class="feuille-fond"></div>
  <div class="dialogue verre-plaque" role="alertdialog" aria-labelledby="dialogue-titre">
    <span class="dialogue-icone">{ic("sortie")}</span>
    <h2 id="dialogue-titre">Se déconnecter ?</h2>
    <p>Vos envois en cours seront mis en pause et reprendront à la prochaine connexion.</p>
    <div class="dialogue-actions">
      <button type="button" class="bouton-verre verre verre-appuyable"><span class="bouton-verre-texte">Annuler</span></button>
      <button type="button" class="bouton-verre verre verre-appuyable rouge"><span class="bouton-verre-texte">Se déconnecter</span></button>
    </div>
  </div>
</div>
'''


# ------------------------------------------------------------ les bulles et les messages

def bulles():
    """La page d une photo : une bulle d aide sur le badge, un message apres « Enregistrer »."""
    html = lire('e05-photo.html')
    bulle = (f'<span class="bulle-aide" role="tooltip"><strong>Capture vérifiée</strong>'
             f'Le téléphone, la date et le lieu viennent du fichier lui-même.<a class="lien-encre">En savoir plus</a></span>')
    html = re.sub(r'(<span class="badge verifie">.*?Capture vérifiée</span>)', r'\1' + bulle.replace('\\', '\\\\'), html, count=1)
    message = (f'  <div class="message" role="status"><span class="photo ph-p108"></span>'
               f'<span>Enregistrée dans <b>Plages</b></span><a class="message-action">Changer</a></div>\n')
    fin = html.rstrip().rfind('</div>')
    return html[:fin] + message + '</div>\n'


# ------------------------------------------------------------ une autorisation refusee, une recherche vide

def pres_de_moi():
    html = lire('e03-accueil.html')
    html = html.replace('<span aria-current="true" class="m"><span style="--k:0">Découverte</span></span>', '<span class="m"><span style="--k:0">Découverte</span></span>')
    html = html.replace('<span class="m"><span style="--k:2">Près de moi</span></span>', '<span aria-current="true" class="m"><span style="--k:2">Près de moi</span></span>')
    vide = f'''<main class="vide">
    <span class="etat-icone">{ic("cible")}</span>
    <h2>La position est désactivée</h2>
    <p>Pour voir les lieux autour de vous, autorisez la position. Vous pouvez aussi choisir une ville.</p>
    <div class="etat-actions">{bouton("Autoriser la position", plein=True)}{bouton("Choisir une ville")}</div>
  </main>'''
    html = re.sub(r'<main class="mosaique piles".*?</main>', vide, html, count=1, flags=re.S)
    html = re.sub(r'\s*<script>.*?</script>', '', html, flags=re.S)
    return html


RECHERCHE_VIDE = f'''<div class="app">
  <!--barre-etat-->
  <main class="recherche">
    <div class="champ-recherche verre">{ic("loupe")}<span>Ganvi plage</span><span class="curseur"></span></div>
    <div class="vide vide-recherche">
      <span class="etat-icone">{ic("loupe")}</span>
      <h2>Aucun résultat pour « Ganvi plage »</h2>
      <p>Vouliez-vous dire <a class="lien-encre">Ganvié</a> ? Essayez aussi un mot plus court.</p>
    </div>
    <h2 class="section-titre">Lieux proches de votre recherche</h2>
    <div class="idees">
      <div class="idee" style="--n:0"><span class="photo ph-p76"></span><span>Ganvié</span></div>
      <div class="idee" style="--n:1"><span class="photo ph-p71"></span><span>Lac Nokoué</span></div>
      <div class="idee" style="--n:2"><span class="photo ph-p124"></span><span>Lac Ahémé</span></div>
      <div class="idee" style="--n:3"><span class="photo ph-p108"></span><span>Grand-Popo</span></div>
    </div>
  </main>
  <!--onglets:accueil-->
</div>
'''


def main():
    ecrire('e37-mdp-erreur.html', MDP_ERREUR)
    ecrire('e37-hors-ligne.html', HORS_LIGNE)
    ecrire('e37-introuvable.html', INTROUVABLE)
    ecrire('e37-refusee.html', REFUSEE)
    ecrire('e37-dialogue.html', dialogue())
    ecrire('e37-bulles.html', bulles())
    ecrire('e37-position.html', pres_de_moi())
    ecrire('e37-recherche-vide.html', RECHERCHE_VIDE)
    print('messages et erreurs ecrits.')


if __name__ == '__main__':
    main()
