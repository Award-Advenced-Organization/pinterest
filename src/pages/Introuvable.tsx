import { Link, useParams } from 'react-router-dom'
import { PiedPublic, PublicShell } from '../shell/PublicShell'

export function Introuvable() {
  return (
    <div className="vide grand-vide">
      <h1>Cette page n'existe pas</h1>
      <p>Le lien est peut-être cassé, ou l'Épingle a été supprimée.</p>
      <Link to="/" className="btn btn-rouge">
        Revenir à l'accueil
      </Link>
    </div>
  )
}

const INFOS: Record<string, { titre: string; texte: string }> = {
  'a-propos': {
    titre: 'À propos',
    texte: "Pinterest est un moteur de découverte visuelle : on y cherche des idées, on les range dans des tableaux et on y revient au moment de passer à l'action. Cette page appartient à une reproduction d'étude de son interface.",
  },
  professionnels: {
    titre: 'Professionnels',
    texte: "Les entreprises publient leurs produits sous forme d'Épingles et touchent des personnes qui préparent un projet. Cette reproduction n'en contient aucune.",
  },
  creer: {
    titre: 'Créer',
    texte: "Une Épingle se crée en quelques secondes : une image, un titre, un lien. Connectez-vous pour essayer le créateur d'Épingle de cette reproduction.",
  },
  actualites: {
    titre: 'Actualités',
    texte: 'Les nouveautés du produit sont annoncées ici sur le vrai site. Cette reproduction est figée au 15 octobre 2026.',
  },
  confidentialite: {
    titre: 'Confidentialité',
    texte: "Cette reproduction ne dépose aucun traceur et n'envoie rien sur le réseau. Vos tableaux et vos choix restent dans le stockage de votre navigateur.",
  },
}

export function Info() {
  const { sujet = '' } = useParams()
  const info = INFOS[sujet]
  return (
    <PublicShell>
      {info ? (
        <article className="page-info">
          <h1>{info.titre}</h1>
          <p>{info.texte}</p>
          <Link to="/ideas" className="btn btn-gris">
            Explorer les idées
          </Link>
        </article>
      ) : (
        <Introuvable />
      )}
      <PiedPublic />
    </PublicShell>
  )
}
