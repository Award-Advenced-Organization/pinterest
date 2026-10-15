import { useMemo, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { PINS, melange } from '../data/pins'
import { useSession } from '../state/Session'
import { Icone, Marque } from '../ui/Icone'

/*
 * Connexion et inscription, relevées sur la capture du 15 octobre 2026 : un
 * mur d'épingles flouté derrière, une carte blanche en deux colonnes, le
 * formulaire à gauche et le code à scanner à droite.
 *
 * Tout est simulé. Le mot de passe n'est ni gardé ni envoyé : il sert
 * seulement à activer le bouton. La mention sous le formulaire le dit, pour
 * que cette page ne puisse pas passer pour la vraie.
 */
export function Connexion({ mode }: { mode: 'connexion' | 'inscription' }) {
  const { connecter } = useSession()
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [mdp, setMdp] = useState('')
  const [voir, setVoir] = useState(false)
  const [naissance, setNaissance] = useState('')
  const [erreur, setErreur] = useState('')
  const fond = useMemo(() => melange(PINS, 3).slice(0, 28), [])
  const inscription = mode === 'inscription'

  const valide = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) && mdp.length >= 6 && (!inscription || naissance !== '')

  const envoyer = (e: React.FormEvent) => {
    e.preventDefault()
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return setErreur('Cette adresse e-mail ne semble pas valide.')
    if (mdp.length < 6) return setErreur('Le mot de passe doit contenir au moins 6 caractères.')
    connecter(email)
    navigate('/')
  }

  return (
    <div className="connexion">
      <div className="connexion-fond" aria-hidden="true">
        {fond.map((p) => (
          <img key={p.id} src={p.image} alt="" style={{ aspectRatio: `${p.w} / ${p.h}`, background: p.couleur }} />
        ))}
      </div>
      <div className="connexion-carte" role="dialog" aria-labelledby="connexion-titre">
        <Link to="/" className="btn-rond nu connexion-fermer" aria-label="Fermer">
          <Icone nom="croix" taille={20} epaisseur={2.6} />
        </Link>
        <div className="connexion-formulaire">
          <span className="connexion-marque">
            <Marque taille={40} />
          </span>
          <h1 id="connexion-titre">Bienvenue sur Pinterest</h1>
          <p className="connexion-sous-titre">{inscription ? 'Trouvez de nouvelles idées à essayer' : 'Connectez-vous pour retrouver vos idées'}</p>
          <form onSubmit={envoyer} noValidate>
            <label className="champ">
              <span className="invisible">E-mail</span>
              <input type="email" value={email} onChange={(e) => (setEmail(e.target.value), setErreur(''))} placeholder="E-mail" autoComplete="off" />
            </label>
            <label className="champ champ-mdp">
              <span className="invisible">Mot de passe</span>
              <input
                type={voir ? 'text' : 'password'}
                value={mdp}
                onChange={(e) => (setMdp(e.target.value), setErreur(''))}
                placeholder={inscription ? 'Créez un mot de passe' : 'Mot de passe'}
                autoComplete="off"
              />
              <button type="button" className="btn-rond nu petit" aria-label={voir ? 'Masquer le mot de passe' : 'Afficher le mot de passe'} onClick={() => setVoir((v) => !v)}>
                <Icone nom={voir ? 'masquer' : 'oeil'} taille={18} />
              </button>
            </label>
            {inscription && (
              <label className="champ">
                <span className="etiquette">Date de naissance</span>
                <input type="date" value={naissance} onChange={(e) => setNaissance(e.target.value)} max="2013-12-31" />
              </label>
            )}
            {!inscription && (
              <button type="button" className="lien-bleu" onClick={() => setErreur('La réinitialisation n\'existe pas dans cette reproduction.')}>
                Mot de passe oublié ?
              </button>
            )}
            {erreur && (
              <p className="erreur" role="alert">
                {erreur}
              </p>
            )}
            <button type="submit" className="btn btn-rouge btn-plein" disabled={!valide}>
              {inscription ? 'Continuer' : 'Se connecter'}
            </button>
          </form>
          <p className="ou">OU</p>
          <button type="button" className="btn btn-contour btn-plein" onClick={() => setErreur('La connexion par un service tiers n\'existe pas dans cette reproduction.')}>
            <span className="g-neutre" aria-hidden="true">
              G
            </span>
            Continuer avec un compte externe
          </button>
          <p className="connexion-bascule">
            {inscription ? (
              <>
                Vous avez déjà un compte ? <Link to="/login">Connectez-vous</Link>
              </>
            ) : (
              <>
                Vous débutez sur Pinterest ? <Link to="/signup">Inscrivez-vous gratuitement</Link>
              </>
            )}
          </p>
          <p className="connexion-mention">
            Reproduction d'étude : la connexion est simulée dans votre navigateur. Aucun mot de passe n'est conservé ni envoyé, n'y saisissez pas celui d'un vrai compte.
          </p>
        </div>
        <div className="connexion-qr">
          <div className="qr" aria-hidden="true">
            <Motif />
            <span className="qr-centre">
              <Marque taille={44} />
            </span>
          </div>
          <p>
            Ou <strong>connectez-vous en un instant</strong> en scannant le code avec votre téléphone
          </p>
        </div>
      </div>
    </div>
  )
}

/* Un motif de points dans l'esprit d'un code à scanner. Il ne contient rien. */
function Motif() {
  const cases = useMemo(() => {
    const l: [number, number][] = []
    let s = 11
    for (let y = 0; y < 25; y += 1)
      for (let x = 0; x < 25; x += 1) {
        const coin = (x < 8 && y < 8) || (x > 16 && y < 8) || (x < 8 && y > 16)
        if (coin) continue
        s = (s * 1103515245 + 12345) % 2147483648
        if (s % 7 < 3) l.push([x, y])
      }
    return l
  }, [])
  const repere = (x: number, y: number) => (
    <g key={`${x}-${y}`}>
      <rect x={x + 0.5} y={y + 0.5} width="6" height="6" rx="1.4" fill="none" stroke="currentColor" strokeWidth="1" />
      <rect x={x + 2} y={y + 2} width="3" height="3" rx=".6" fill="currentColor" />
    </g>
  )
  return (
    <svg viewBox="0 0 25 25" width="160" height="160">
      {cases.map(([x, y]) => (
        <rect key={`${x}-${y}`} x={x + 0.1} y={y + 0.1} width=".8" height=".8" rx=".2" fill="currentColor" />
      ))}
      {repere(0, 0)}
      {repere(18, 0)}
      {repere(0, 18)}
    </svg>
  )
}
