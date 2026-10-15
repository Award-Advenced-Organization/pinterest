import { useCallback, useState, type ReactNode } from 'react'
import { Link, NavLink } from 'react-router-dom'
import { Icone, Marque } from '../ui/Icone'
import { useHorsDe } from '../ui/outils'
import { Recherche } from './Recherche'
import { Cookies } from './Cookies'
import { Toasts } from './Toasts'

/*
 * L'en-tête du site déconnecté. Deux variantes, relevées sur le vrai site :
 * l'accueil montre les liens d'information et met « Se connecter » en rouge ;
 * les autres pages raccourcissent tout, passent « S'inscrire » en rouge et
 * rangent les liens dans un chevron.
 */
export function PublicShell({ children, accueil = false }: { children: ReactNode; accueil?: boolean }) {
  return (
    <div className="public">
      <header className={`entete-public${accueil ? ' accueil' : ''}`}>
        <Link to="/" className="entete-marque" aria-label="Accueil Pinterest">
          <Marque taille={24} avecNom />
        </Link>
        <NavLink to="/ideas" className="entete-lien">
          Explorer
        </NavLink>
        <Recherche placeholder="Recherchez des idées pour des dîners faciles, sur la mode, etc." />
        {accueil && (
          <nav className="entete-infos" aria-label="Informations">
            <Link to="/info/a-propos">À propos</Link>
            <Link to="/info/professionnels">Professionnels</Link>
            <Link to="/info/creer">Créer</Link>
            <Link to="/info/actualites">Actualités</Link>
          </nav>
        )}
        <div className="entete-actions">
          <Link to="/login" className={`btn ${accueil ? 'btn-rouge' : 'btn-gris'}`}>
            Se connecter
          </Link>
          <Link to="/signup" className={`btn ${accueil ? 'btn-gris' : 'btn-rouge'}`}>
            S'inscrire
          </Link>
          {!accueil && <MenuInfos />}
        </div>
      </header>
      <main>{children}</main>
      <Cookies />
      <Toasts />
    </div>
  )
}

function MenuInfos() {
  const [ouvert, setOuvert] = useState(false)
  const fermer = useCallback(() => setOuvert(false), [])
  const ref = useHorsDe<HTMLDivElement>(ouvert, fermer)
  return (
    <div className="menu-infos" ref={ref}>
      <button type="button" className="btn-rond nu" aria-label="Plus d'options" aria-expanded={ouvert} onClick={() => setOuvert((o) => !o)}>
        <Icone nom="chevron" taille={20} epaisseur={2.4} />
      </button>
      {ouvert && (
        <div className="menu menu-droite" role="menu">
          <Link role="menuitem" to="/info/a-propos" onClick={fermer}>
            À propos
          </Link>
          <Link role="menuitem" to="/info/professionnels" onClick={fermer}>
            Professionnels
          </Link>
          <Link role="menuitem" to="/info/creer" onClick={fermer}>
            Créer
          </Link>
          <Link role="menuitem" to="/info/actualites" onClick={fermer}>
            Actualités
          </Link>
        </div>
      )}
    </div>
  )
}

export function PiedPublic() {
  return (
    <footer className="pied-public">
      <nav aria-label="Liens de bas de page">
        <Link to="/info/a-propos">À propos</Link>
        <Link to="/info/professionnels">Professionnels</Link>
        <Link to="/info/creer">Créer</Link>
        <Link to="/info/actualites">Actualités</Link>
        <Link to="/ideas">Explorer</Link>
        <Link to="/info/confidentialite">Confidentialité</Link>
      </nav>
      <p>Reproduction d'étude de l'interface Pinterest. Code écrit à la main, photos libres de droits, connexion simulée en local.</p>
    </footer>
  )
}
