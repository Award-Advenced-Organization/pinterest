import { useEffect, useRef, useState, type RefObject } from 'react'

/**
 * Ferme un menu quand on clique ailleurs ou qu'on appuie sur Échap. Un clic
 * sur un élément marqué data-garde ne compte pas : c'est le bouton qui ouvre
 * et ferme lui-même le panneau, sinon il le refermerait puis le rouvrirait.
 */
export function useHorsDe<T extends HTMLElement>(ouvert: boolean, fermer: () => void): RefObject<T> {
  const ref = useRef<T>(null)
  useEffect(() => {
    if (!ouvert) return
    const clic = (e: MouseEvent) => {
      const cible = e.target as Element
      if (cible.closest?.('[data-garde]')) return
      if (ref.current && !ref.current.contains(cible)) fermer()
    }
    const touche = (e: KeyboardEvent) => {
      if (e.key === 'Escape') fermer()
    }
    const id = window.setTimeout(() => document.addEventListener('mousedown', clic), 0)
    document.addEventListener('keydown', touche)
    return () => {
      window.clearTimeout(id)
      document.removeEventListener('mousedown', clic)
      document.removeEventListener('keydown', touche)
    }
  }, [ouvert, fermer])
  return ref
}

/** La largeur d'un élément, suivie quand la fenêtre change. */
export function useLargeur<T extends HTMLElement>(): [RefObject<T>, number] {
  const ref = useRef<T>(null)
  const [largeur, setLargeur] = useState(0)
  useEffect(() => {
    const el = ref.current
    if (!el) return
    const obs = new ResizeObserver(([e]) => setLargeur(e.contentRect.width))
    obs.observe(el)
    setLargeur(el.getBoundingClientRect().width)
    return () => obs.disconnect()
  }, [])
  return [ref, largeur]
}

export function abrege(n: number) {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1).replace('.', ',').replace(',0', '')} M`
  if (n >= 1000) return `${(n / 1000).toFixed(1).replace('.', ',').replace(',0', '')} k`
  return String(n)
}
