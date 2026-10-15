import { Link } from 'react-router-dom'
import { useSession } from '../state/Session'

/** Les annonces en bas de l'écran : « Enregistrée dans … », « Lien copié ». */
export function Toasts() {
  const { toasts } = useSession()
  return (
    <div className="toasts" role="status" aria-live="polite">
      {toasts.map((t) => (
        <div className="toast" key={t.id}>
          {t.image && <img src={t.image} alt="" />}
          <span>{t.texte}</span>
          {t.lien && (
            <Link to={t.lien} className="btn btn-gris btn-petit">
              Voir
            </Link>
          )}
        </div>
      ))}
    </div>
  )
}
