import { useMemo, useState } from 'react'
import { Link, Navigate, useParams } from 'react-router-dom'
import { melange } from '../data/pins'
import { useSession } from '../state/Session'
import { Avatar, Icone } from '../ui/Icone'
import { Masonry } from '../ui/Masonry'
import { PinCard } from '../ui/PinCard'

/*
 * Un tableau. Le titre, le propriétaire, le compte d'épingles, trois outils
 * ronds sous le titre, puis le masonry. « Plus d'idées » ouvre une rangée de
 * suggestions prises dans les catégories déjà présentes.
 */
export function TableauPage() {
  const { pseudo = '', tableau: id = '' } = useParams()
  const { utilisateur, tableaux, tousLesPins } = useSession()
  const [idees, setIdees] = useState(false)
  const tout = id === 'tout'
  const t = tableaux.find((x) => x.id === id)

  const pins = useMemo(() => {
    const ids = tout ? [...new Set(tableaux.flatMap((x) => x.pins))] : (t?.pins ?? [])
    return ids.flatMap((pid) => tousLesPins.filter((p) => p.id === pid))
  }, [tout, t, tableaux, tousLesPins])

  const suggestions = useMemo(() => {
    const cats = new Set(pins.map((p) => p.categorie))
    return melange(
      tousLesPins.filter((p) => cats.has(p.categorie) && !pins.includes(p)),
      pins.length + 1,
    ).slice(0, 12)
  }, [pins, tousLesPins])

  if (!utilisateur || utilisateur.pseudo !== pseudo) return <Navigate to={`/${pseudo}`} replace />
  if (!tout && !t) return <Navigate to={`/${pseudo}`} replace />

  return (
    <div className="page-tableau">
      <header className="tableau-entete">
        <h1>
          {tout ? 'Toutes les Épingles' : t!.nom}
          {t?.secret && <Icone nom="cadenas" taille={24} epaisseur={2.4} />}
        </h1>
        <Link to={`/${pseudo}`} className="tableau-proprio">
          <Avatar nom={utilisateur.nom} couleur={utilisateur.couleur} taille={48} />
        </Link>
        {!tout && (
          <div className="tableau-outils">
            <button type="button" className={`outil${idees ? ' actif' : ''}`} aria-pressed={idees} onClick={() => setIdees((v) => !v)}>
              <span className="rond-gris grand">
                <Icone nom="etincelle" plein={idees} />
              </span>
              Plus d'idées
            </button>
            <Link to="/pin-creation-tool" className="outil">
              <span className="rond-gris grand">
                <Icone nom="plus" epaisseur={2.6} />
              </span>
              Ajouter
            </Link>
          </div>
        )}
      </header>
      <p className="tableau-compte">
        {pins.length} Épingle{pins.length > 1 ? 's' : ''}
      </p>
      {idees && (
        <section className="tableau-idees">
          <h2>Idées pour ce tableau</h2>
          <div className="rangee-pins">
            {suggestions.slice(0, 6).map((p) => (
              <PinCard key={p.id} pin={p} />
            ))}
          </div>
        </section>
      )}
      {pins.length ? (
        <Masonry elements={pins.map((p) => ({ cle: p.id, pin: p }))} rendre={(e) => <PinCard pin={e.pin} />} />
      ) : (
        <div className="vide">
          <p>Ce tableau est vide. Enregistrez des Épingles depuis le fil pour le remplir.</p>
          <Link to="/" className="btn btn-gris">
            Parcourir le fil
          </Link>
        </div>
      )}
    </div>
  )
}
