import { useMemo, useState } from 'react'
import { Link, useNavigate, useParams } from 'react-router-dom'
import { CREATEURS, PINS } from '../data/pins'
import { useSession, type Tableau } from '../state/Session'
import { Avatar, Icone } from '../ui/Icone'
import { CreerTableau } from '../ui/Enregistrer'
import { Masonry } from '../ui/Masonry'
import { PinCard } from '../ui/PinCard'
import { abrege } from '../ui/outils'
import { Introuvable } from './Introuvable'

/*
 * Le profil. Centré : l'avatar, le nom, le pseudo, les abonnés, deux boutons,
 * puis deux onglets soulignés. Le sien s'ouvre sur « Enregistrés » et montre
 * les tableaux ; celui d'un créateur s'ouvre sur « Créés » et montre son fil.
 */
export function Profil({ onglet: ongletDepart }: { onglet?: 'crees' | 'enregistres' }) {
  const { pseudo = '' } = useParams()
  const { utilisateur, tableaux, crees, abonnements, suivre, annoncer, creerTableau } = useSession()
  const navigate = useNavigate()
  const moi = utilisateur && utilisateur.pseudo === pseudo
  const createur = CREATEURS.find((c) => c.pseudo === pseudo)
  const [onglet, setOnglet] = useState<'crees' | 'enregistres'>(ongletDepart ?? (moi ? 'enregistres' : 'crees'))
  const [creation, setCreation] = useState(false)
  const [tri, setTri] = useState<'recent' | 'alpha'>('recent')

  const pinsCreateur = useMemo(() => (createur ? PINS.filter((p) => p.createur.id === createur.id) : []), [createur])
  const tableauxTries = useMemo(
    () => [...tableaux].sort((a, b) => (tri === 'alpha' ? a.nom.localeCompare(b.nom, 'fr') : b.cree - a.cree)),
    [tableaux, tri],
  )

  if (!moi && !createur) return <Introuvable />

  const nom = moi ? utilisateur!.nom : createur!.nom
  const couleur = moi ? utilisateur!.couleur : createur!.couleur
  const abonne = createur ? abonnements.includes(createur.id) : false
  const tousEnregistres = [...new Set(tableaux.flatMap((t) => t.pins))]

  const partager = async () => {
    try {
      await navigator.clipboard.writeText(window.location.href)
      annoncer({ texte: 'Lien du profil copié' })
    } catch {
      annoncer({ texte: 'Copie impossible dans ce navigateur' })
    }
  }

  return (
    <div className="profil">
      <header className="profil-entete">
        <Avatar nom={nom} couleur={couleur} taille={120} />
        <h1>{nom}</h1>
        <p className="profil-pseudo">
          <Icone nom="etincelle" taille={16} plein />@{pseudo}
        </p>
        {moi && utilisateur!.apropos && <p className="profil-apropos">{utilisateur!.apropos}</p>}
        {createur?.site && <p className="profil-site">{createur.site}</p>}
        <p className="profil-chiffres">
          {moi ? `${abonnements.length} abonnement${abonnements.length > 1 ? 's' : ''}` : `${abrege(createur!.abonnes + (abonne ? 1 : 0))} abonnés · ${12 + pinsCreateur.length} abonnements`}
        </p>
        <div className="profil-actions">
          <button type="button" className="btn btn-gris" onClick={partager}>
            Partager
          </button>
          {moi ? (
            <Link to="/settings" className="btn btn-gris">
              Modifier le profil
            </Link>
          ) : (
            <button type="button" className={`btn ${abonne ? 'btn-noir' : 'btn-rouge'}`} onClick={() => (utilisateur ? suivre(createur!.id) : navigate('/signup'))}>
              {abonne ? 'Abonné(e)' : "S'abonner"}
            </button>
          )}
        </div>
        <div className="onglets" role="tablist">
          <button type="button" role="tab" aria-selected={onglet === 'crees'} className={onglet === 'crees' ? 'actif' : ''} onClick={() => setOnglet('crees')}>
            Créés
          </button>
          <button type="button" role="tab" aria-selected={onglet === 'enregistres'} className={onglet === 'enregistres' ? 'actif' : ''} onClick={() => setOnglet('enregistres')}>
            Enregistrés
          </button>
        </div>
      </header>

      {onglet === 'crees' &&
        (moi ? (
          crees.length ? (
            <Masonry elements={crees.map((p) => ({ cle: p.id, pin: p }))} rendre={(e) => <PinCard pin={e.pin} />} />
          ) : (
            <div className="vide">
              <p>Rien à afficher… pour l'instant ! Les Épingles que vous créez apparaîtront ici.</p>
              <Link to="/pin-creation-tool" className="btn btn-rouge">
                Créer une Épingle
              </Link>
            </div>
          )
        ) : (
          <Masonry elements={pinsCreateur.map((p) => ({ cle: p.id, pin: p }))} rendre={(e) => <PinCard pin={e.pin} />} />
        ))}

      {onglet === 'enregistres' &&
        (moi ? (
          <>
            <div className="outils-tableaux">
              <button type="button" className="btn-rond nu" aria-label={tri === 'recent' ? 'Trier par ordre alphabétique' : 'Trier par date'} onClick={() => setTri((t) => (t === 'recent' ? 'alpha' : 'recent'))}>
                <Icone nom="filtre" />
              </button>
              <span className="outils-tri">{tri === 'recent' ? 'Les plus récents' : 'De A à Z'}</span>
              <button type="button" className="btn-rond gris" aria-label="Créer un tableau" onClick={() => setCreation(true)}>
                <Icone nom="plus" epaisseur={2.6} />
              </button>
            </div>
            <div className="grille-tableaux">
              <CarteTableau
                lien={`/${pseudo}/tout`}
                nom="Toutes les Épingles"
                pins={tousEnregistres}
              />
              {tableauxTries.map((t) => (
                <CarteTableau key={t.id} lien={`/${pseudo}/${t.id}`} nom={t.nom} pins={t.pins} tableau={t} />
              ))}
            </div>
          </>
        ) : (
          <div className="vide">
            <p>{nom} n'a pas encore enregistré d'Épingles publiques.</p>
          </div>
        ))}

      {creation && (
        <CreerTableau
          fermer={() => setCreation(false)}
          creer={(n, s) => {
            const t = creerTableau(n, s)
            setCreation(false)
            navigate(`/${pseudo}/${t.id}`)
          }}
        />
      )}
    </div>
  )
}

export function CarteTableau({ lien, nom, pins, tableau }: { lien: string; nom: string; pins: string[]; tableau?: Tableau }) {
  const images = [0, 1, 2].map((k) => pins[k])
  return (
    <Link to={lien} className="carte-tableau">
      <span className="carte-tableau-images">
        {images.map((id, k) => (id ? <img key={k} src={`/pins/${id}.jpg`} alt="" /> : <span key={k} className="case-vide" />))}
        {tableau?.secret && (
          <span className="badge-secret" aria-label="Tableau secret">
            <Icone nom="cadenas" taille={14} epaisseur={2.6} />
          </span>
        )}
      </span>
      <strong>{nom}</strong>
      <small>
        {pins.length} Épingle{pins.length > 1 ? 's' : ''}
        {tableau ? ` · ${tableau.cree > 1000 ? "à l'instant" : `${tableau.cree + 1} sem.`}` : ''}
      </small>
    </Link>
  )
}
