import { useCallback, useMemo, useState } from 'react'
import { melange } from '../data/pins'
import { useSession } from '../state/Session'
import { Masonry, type Element } from '../ui/Masonry'
import { PinCard } from '../ui/PinCard'

/*
 * Le fil d'accueil. Relevé sur la sauvegarde du fil réel : aucune rangée de
 * sujets au-dessus, le masonry commence juste sous l'en-tête. Il se rallonge
 * quand on approche du bas ; chaque nouvelle page reprend les épingles dans
 * un autre ordre, avec une clé neuve.
 */
const PAGES_MAX = 8

export function Fil() {
  const { tousLesPins } = useSession()
  const [pages, setPages] = useState(2)

  const elements = useMemo<Element[]>(
    () => Array.from({ length: pages }, (_, n) => melange(tousLesPins, n * 31 + 7).map((pin) => ({ cle: `${pin.id}-${n}`, pin }))).flat(),
    [tousLesPins, pages],
  )
  const suite = useCallback(() => setPages((p) => (p < PAGES_MAX ? p + 1 : p)), [])

  return (
    <div className="fil">
      <div className="fil-barre-onglets">
        <button type="button" className="onglet-fil actif">
          All
        </button>
      </div>
      <Masonry elements={elements} rendre={(e) => <PinCard pin={e.pin} />} surFin={suite} chargement={pages < PAGES_MAX} />
    </div>
  )
}
