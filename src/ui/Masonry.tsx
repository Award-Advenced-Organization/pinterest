import { useEffect, useMemo, useRef, type ReactNode } from 'react'
import type { Pin } from '../data/pins'
import { useLargeur } from './outils'

/*
 * La grille du fil. Chaque épingle va dans la colonne la plus courte, dans
 * l'ordre de la liste, comme sur Pinterest : on lit de gauche à droite et les
 * trous se comblent tout seuls. Les hauteurs sont connues d'avance (la photo
 * porte ses dimensions), on n'attend donc aucun chargement pour placer.
 *
 * Colonnes de 236 px et gouttière de 16 px sur grand écran ; sous 720 px, deux
 * colonnes qui prennent toute la largeur.
 */

const COLONNE = 236
const GOUTTIERE = 16

export type Element = { cle: string; pin: Pin }

export function Masonry({
  elements,
  rendre,
  surFin,
  chargement = false,
}: {
  elements: Element[]
  rendre: (e: Element) => ReactNode
  surFin?: () => void
  chargement?: boolean
}) {
  const [ref, largeur] = useLargeur<HTMLDivElement>()
  const etroit = largeur > 0 && largeur < 720
  const nb = etroit ? 2 : Math.max(2, Math.floor((largeur + GOUTTIERE) / (COLONNE + GOUTTIERE)))

  const colonnes = useMemo(() => {
    const cols: Element[][] = Array.from({ length: nb }, () => [])
    const hauteurs = new Array(nb).fill(0)
    for (const e of elements) {
      let i = 0
      for (let k = 1; k < nb; k += 1) if (hauteurs[k] < hauteurs[i]) i = k
      cols[i].push(e)
      /* la ligne du « … » sous chaque photo, plus haute quand un titre l'accompagne */
      hauteurs[i] += (COLONNE * e.pin.h) / e.pin.w + (e.pin.titreVisible ? 58 : 36) + GOUTTIERE
    }
    return cols
  }, [elements, nb])

  const fin = useRef<HTMLDivElement>(null)
  useEffect(() => {
    if (!surFin || !fin.current) return
    const obs = new IntersectionObserver(([e]) => e.isIntersecting && surFin(), { rootMargin: '900px' })
    obs.observe(fin.current)
    return () => obs.disconnect()
  }, [surFin, elements.length])

  return (
    <div ref={ref} className="masonry-cadre">
      {largeur > 0 && (
        <div className={`masonry${etroit ? ' masonry-etroit' : ''}`}>
          {colonnes.map((col, i) => (
            <div className="masonry-col" key={i}>
              {col.map((e) => (
                <div key={e.cle}>{rendre(e)}</div>
              ))}
            </div>
          ))}
        </div>
      )}
      <div ref={fin} aria-hidden="true" />
      {chargement && (
        <div className="points-chargement" role="status" aria-label="Chargement d'autres Épingles">
          <span />
          <span />
          <span />
        </div>
      )}
    </div>
  )
}
