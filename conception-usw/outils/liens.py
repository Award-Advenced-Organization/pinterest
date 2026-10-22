"""Les liens du prototype : ou mene chaque bouton, comme les liens d un
prototype Figma. Ils sont ecrits dans maquette/document.json (champ `liens`
de chaque ecran), puis repris tels quels dans le .god2 ; god2-design les suit
en presentation. Voir FORMAT-GOD2.md, « Les liens du prototype ».

Un lien : (selecteur CSS, ecran vise ou "retour", texte facultatif que
l element doit contenir). Le premier qui correspond l emporte : les plus
precis d abord, les liens communs (onglets, retour, fermer) a la fin.

  python outils/liens.py
"""

import json
from pathlib import Path

DOCUMENT = Path(__file__).resolve().parent.parent / 'maquette' / 'document.json'

B = '.bouton-verre'  # un bouton, vise par son libelle


def l(selecteur, vers, texte=None):
    return {'selecteur': selecteur, 'vers': vers, **({'texte': texte} if texte else {})}


# Ce qui revient sur presque tous les ecrans.
COMMUNS = [
    l('.onglet[aria-label="Accueil"]', 'accueil'),
    l('.onglet[aria-label="Reels"]', 'reels'),
    l('.onglet[aria-label="Créer"]', 'creer'),
    l('.onglet[aria-label="Carte"]', 'carte'),
    l('.onglet[aria-label="Profil"]', 'profil'),
    l('[aria-label="Retour"]', 'retour'),
    l('[aria-label="Fermer"]', 'retour'),
    l('.feuille-fond', 'retour'),
]

# La page d une photo, et les feuilles qui s ouvrent dessus.
PHOTO = [
    l('[aria-label="Commentaires"]', 'commentaires'),
    l('.commentaires', 'commentaires'),
    l('[aria-label="Partager"]', 'partager'),
    l('[aria-label="Télécharger l\'original"]', 'telecharger'),
    l('[aria-label="Enregistrer"]', 'enregistrer'),
    l('.photo-grande .badge', 'bulles'),
    l('.createur-nom, .createur .avatar', 'createur'),
    l('.mosaique .carte', 'lieu'),
]

# Un reel, et ses feuilles.
REEL = [
    l('[aria-label="Commentaires"]', 'reel-commentaires'),
    l('[aria-label="Partager"]', 'reel-partager'),
    l('[aria-label="Enregistrer"]', 'reel-enregistrer'),
    l('.bouton-reel.aime', 'reel-reagir'),
    l('.profil-reel, .createur-ligne b', 'createur'),
    l('[aria-label="Rechercher"]', 'recherche'),
]

ACCUEIL = [
    l('.pile-lieu', 'lieu'),
    l('.filtres .pastille', 'filtres', 'Filtres'),
    l('.flux .m', 'position-refusee', 'Près de moi'),
    l('[aria-label="Rechercher"]', 'recherche'),
    l('[aria-label="Notifications"]', 'notifications'),
]

LIENS = {
    'ouverture': [l('.app', 'bienvenue-1')],
    'bienvenue-1': [l(B, 'bienvenue-2', 'Suivant'), l('.lien-discret', 'entree', 'Passer')],
    'bienvenue-2': [l(B, 'bienvenue-3', 'Suivant'), l('.lien-discret', 'entree', 'Passer')],
    'bienvenue-3': [l(B, 'entree', 'Commencer'), l('.lien-discret', 'accueil', 'Explorer sans compte')],
    'entree': [l(B, 'completer-1', 'Google'), l(B, 'creer-mdp', 'Continuer'),
               l('.lien', 'cgu', 'conditions'), l('.lien', 'confidentialite', 'confidentialité')],
    'mot-de-passe': [l(B, 'accueil', 'Se connecter'), l('.lien', 'oubli', 'oublié'), l('.lien', 'entree', 'Changer')],
    'creer-mdp': [l(B, 'code', 'Continuer'), l('.lien', 'cgu', 'conditions'), l('.lien', 'confidentialite', 'confidentialité')],
    'code': [l(B, 'completer-1', 'Vérifier'), l('.lien', 'retour', 'corriger')],
    'oubli': [l(B, 'nouveau-mdp', 'Envoyer le code'), l('.lien', 'mot-de-passe', 'Se connecter')],
    'nouveau-mdp': [l(B, 'accueil', 'Enregistrer')],
    'completer-1': [l(B, 'completer-2', 'Continuer')],
    'completer-2': [l(B, 'completer-3', 'Continuer')],
    'completer-3': [l(B, 'accueil', 'Terminer'), l('.lien-discret', 'accueil', 'Passer')],

    'accueil': ACCUEIL,
    'filtres': [l(B, 'retour', 'Voir')],
    'lieu': [l('.mosaique .carte', 'photo'), l('[aria-label="Partager"]', 'partager')],
    'photo': PHOTO,
    'commentaires': [],
    'telecharger': [l(B, 'retour', 'Télécharger')],
    'enregistrer': [l('.collection-ligne', 'bulles')],
    'partager': [l('.appli, .membre', 'retour')],
    'bulles': [l('.message-action', 'enregistrer'), l('.bulle-aide', 'retour')] + PHOTO,

    'reels': REEL,
    'reel-reagir': [l('.bouton-reel.aime .rond-verre', 'reel-reactions'), l('.reaction', 'retour'), l('.voile-reagir', 'retour')],
    'reel-reactions': [],
    'reel-commentaires': [],
    'reel-partager': [l('.appli', 'reel-telecharger', 'Télécharger'), l('.appli', 'reel-enregistrer', 'Enregistrer'),
                      l('.appli', 'signaler', 'Signaler'), l('.appli, .membre', 'retour')],
    'reel-enregistrer': [l('.collection-ligne', 'retour')],
    'reel-telecharger': [l(B, 'retour', 'Télécharger')],
    'signaler': [l('.lien-encre', 'regles'), l(B, 'retour', 'Envoyer')],
    'carte': [l('.repere-contenu', 'reels'), l(B, 'reels', 'Voir le reel'), l('[aria-label="Filtres"]', 'filtres')],
    'recherche': [l('.idee', 'lieu'), l('.recentes', 'recherche-vide')],

    'creer': [l('.option-creer', 'details', 'Prendre une photo'), l('.option-creer', 'autoriser', 'Tourner un reel'),
              l('.option-creer', 'completer-capture', 'Importer'), l('.lien-encre', 'regles')],
    'autoriser': [l(B, 'reel-camera', 'Autoriser'), l('.lien-discret', 'retour', 'Plus tard')],
    'reel-camera': [l(B, 'montage', 'Suivant')],
    'montage': [l(B, 'details', 'Suivant'), l('.outil', 'son', 'Son')],
    'son': [l(B, 'retour', 'Suivant')],
    'completer-capture': [l(B, 'details', 'Continuer'), l('.lien-encre', 'indiquer-lieu', 'Indiquer'), l('.resultat, .lu, .manque', 'indiquer-lieu', 'Lieu')],
    'indiquer-lieu': [l(B, 'retour', 'Choisir ce lieu')],
    'details': [l(B, 'en-route', 'Publier')],
    'en-route': [l('.envoi-pastille', 'envois')],
    'envois': [l('.lien-encre', 'refusee', 'Motif')],

    'notifications': [l('.lien-encre', 'refusee', 'motif'), l('.notif', 'photo')],
    'profil': [l(B, 'modifier', 'Modifier le profil'), l(B, 'collection', 'Mes collections'),
               l('[aria-label="Réglages"]', 'reglages'), l('[aria-label="Mes envois"]', 'envois'), l('.mosaique .carte', 'photo')],
    'collection': [l('.mosaique .carte', 'photo')],
    'createur': [l('.feuille-ligne', 'signaler', 'Signaler'), l('.feuille-ligne', 'retour'), l('.mosaique .carte', 'photo')],
    'modifier': [l(B, 'retour', 'Terminé')],
    'reglages': [l('.reglage-ligne', 'dialogue', 'Se déconnecter'), l('.reglage-ligne', 'modifier', 'Modifier le profil'),
                 l('.reglage-ligne', 'aide', 'Aide'), l('.reglage-ligne', 'regles', 'Règles'),
                 l('.reglage-ligne', 'cgu', 'Conditions'), l('.reglage-ligne', 'confidentialite', 'Confidentialité'),
                 l('.compte-carte', 'profil')],
    'dialogue': [l(B, 'retour', 'Annuler'), l(B, 'entree', 'Se déconnecter')],
    'aide': [l('.liens-legaux a', 'regles', 'Règles'), l('.liens-legaux a', 'cgu', 'Conditions'),
             l('.liens-legaux a', 'confidentialite', 'Confidentialité'), l('.sujet', 'regles', 'Signaler')],
    'cgu': [l('.lien', 'regles', 'règles'), l('.lien', 'confidentialite', 'confidentialité')],
    'regles': [l('.lien', 'cgu', 'conditions'), l('.lien', 'confidentialite', 'confidentialité')],
    'confidentialite': [],
    'moderation': [l('.dossier', 'decision')],
    'decision': [l(B, 'retour', 'Refuser'), l(B, 'retour', 'Publier')],

    'mdp-erreur': [l(B, 'accueil', 'Se connecter'), l('.lien', 'oubli', 'oublié'), l('.lien', 'entree', 'Changer')],
    'hors-ligne': [l(B, 'profil', 'Voir les photos'), l(B, 'accueil', 'Réessayer')],
    'introuvable': [l(B, 'accueil', "Retour à l'accueil")],
    'refusee': [l(B, 'regles', 'Lire les règles'), l(B, 'retour', 'Demander')],
    'position-refusee': [l(B, 'filtres', 'Choisir une ville'), l(B, 'accueil', 'Autoriser'), l('.flux .m', 'accueil', 'Découverte')] + ACCUEIL,
    'recherche-vide': [l('.lien-encre', 'lieu'), l('.idee', 'lieu')],
}

def main():
    doc = json.loads(DOCUMENT.read_text(encoding='utf-8'))
    ids = {e['id'] for e in doc['ecrans']}
    for e in doc['ecrans']:
        e['liens'] = LIENS.get(e['id'], []) + COMMUNS
        for x in e['liens']:
            if x['vers'] not in ids and x['vers'] != 'retour':
                raise SystemExit(f'{e["id"]} : ecran inconnu « {x["vers"]} »')
    DOCUMENT.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(sum(len(e['liens']) for e in doc['ecrans']), 'liens sur', len(doc['ecrans']), 'ecrans.')


if __name__ == '__main__':
    main()
