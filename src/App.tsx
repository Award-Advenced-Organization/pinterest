import { useEffect, type ReactNode } from 'react'
import { BrowserRouter, Navigate, Route, Routes, useLocation, useParams } from 'react-router-dom'
import { SessionProvider, useSession } from './state/Session'
import { AppShell } from './shell/AppShell'
import { PiedPublic, PublicShell } from './shell/PublicShell'
import { Accueil } from './pages/Accueil'
import { Connexion } from './pages/Connexion'
import { Creer } from './pages/Creer'
import { Explorer } from './pages/Explorer'
import { Fil } from './pages/Fil'
import { Idees } from './pages/Idees'
import { Info, Introuvable } from './pages/Introuvable'
import { Parametres } from './pages/Parametres'
import { PinPage } from './pages/PinPage'
import { Profil } from './pages/Profil'
import { Resultats } from './pages/Resultats'
import { TableauPage } from './pages/TableauPage'

/*
 * Les adresses suivent celles du vrai site : /pin/:id, /search/pins?q=,
 * /today, /pin-creation-tool, /settings, /:pseudo et /:pseudo/:tableau.
 * La racine montre l'accueil déconnecté ou le fil, selon la session.
 */

function HautDePage() {
  const { pathname, search } = useLocation()
  useEffect(() => {
    window.scrollTo(0, 0)
  }, [pathname, search])
  return null
}

/** Les pages qui existent des deux côtés : dans le cadre connecté, ou dans l'en-tête public. */
function Cadre({ children }: { children: ReactNode }) {
  const { utilisateur } = useSession()
  if (utilisateur) return <AppShell>{children}</AppShell>
  return (
    <PublicShell>
      <div className="contenu-public">{children}</div>
      <PiedPublic />
    </PublicShell>
  )
}

function Prive({ children }: { children: ReactNode }) {
  const { utilisateur } = useSession()
  return utilisateur ? <AppShell>{children}</AppShell> : <Navigate to="/login" replace />
}

function Racine() {
  const { utilisateur } = useSession()
  return utilisateur ? (
    <AppShell>
      <Fil />
    </AppShell>
  ) : (
    <Accueil />
  )
}

function SansCompte({ children }: { children: ReactNode }) {
  const { utilisateur } = useSession()
  return utilisateur ? <Navigate to="/" replace /> : <>{children}</>
}

function VersMesTableaux() {
  const { utilisateur } = useSession()
  return <Navigate to={utilisateur ? `/${utilisateur.pseudo}/_saved` : '/login'} replace />
}

function ProfilOuTableau() {
  const { pseudo, tableau } = useParams()
  if (tableau === '_saved') return <Profil key={`${pseudo}-e`} onglet="enregistres" />
  if (tableau === '_created') return <Profil key={`${pseudo}-c`} onglet="crees" />
  return <TableauPage />
}

function ProfilParPseudo() {
  const { pseudo } = useParams()
  return <Profil key={pseudo} />
}

function Routes_() {
  return (
    <>
      <HautDePage />
      <Routes>
        <Route path="/" element={<Racine />} />
        <Route path="/ideas" element={<Idees />} />
        <Route path="/info/:sujet" element={<Info />} />
        <Route
          path="/login"
          element={
            <SansCompte>
              <Connexion mode="connexion" />
            </SansCompte>
          }
        />
        <Route
          path="/signup"
          element={
            <SansCompte>
              <Connexion mode="inscription" />
            </SansCompte>
          }
        />
        <Route path="/pin/:id" element={<Cadre><PinPage /></Cadre>} />
        <Route path="/search/pins" element={<Cadre><Resultats /></Cadre>} />
        <Route path="/today" element={<Cadre><Explorer /></Cadre>} />
        <Route path="/tableaux" element={<VersMesTableaux />} />
        <Route path="/pin-creation-tool" element={<Prive><Creer /></Prive>} />
        <Route path="/settings" element={<Prive><Parametres /></Prive>} />
        <Route path="/settings/:rubrique" element={<Prive><Parametres /></Prive>} />
        <Route path="/:pseudo" element={<Cadre><ProfilParPseudo /></Cadre>} />
        <Route path="/:pseudo/:tableau" element={<Cadre><ProfilOuTableau /></Cadre>} />
        <Route path="*" element={<Cadre><Introuvable /></Cadre>} />
      </Routes>
    </>
  )
}

export function App() {
  return (
    <SessionProvider>
      <BrowserRouter>
        <Routes_ />
      </BrowserRouter>
    </SessionProvider>
  )
}
