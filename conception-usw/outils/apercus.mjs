// Photographie chaque ecran de maquette-usw.god2, ses formats cote a cote,
// fige comme sur la toile de l atelier (animations a leur etat final), avec
// Chrome sans fenetre. Chaque format est un cadre a sa vraie largeur : Chrome
// impose une largeur minimale a sa fenetre, pas a un cadre. Sert au controle
// visuel.
//
//   node outils/apercus.mjs <dossier de sortie> [id d ecran...]

import { mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { execFileSync } from 'node:child_process'
import { join } from 'node:path'

const sortie = process.argv[2]
const seuls = process.argv.slice(3)
const doc = JSON.parse(readFileSync(new URL('../maquette-usw.god2', import.meta.url), 'utf8'))
const CHROME = 'C:/Program Files/Google/Chrome/Application/chrome.exe'
const FIGE = '*,*::before,*::after{animation:none!important;transition:none!important}html,body{overflow:hidden!important}'
const ECART = 24
mkdirSync(sortie, { recursive: true })

for (const ecran of doc.ecrans) {
  if (seuls.length && !seuls.includes(ecran.id)) continue
  const page = `<!doctype html><html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><style>${doc.styles}</style><style>${FIGE}</style></head><body>${doc.symboles}${ecran.balisage}</body></html>`
  const fichier = join(sortie, `${ecran.id}.html`)
  writeFileSync(fichier, page)
  const cadres = doc.formats.map((f) => ({ l: f.largeur, h: ecran.fenetre ? f.hauteur : Math.round(f.hauteur * 2) }))
  const largeur = cadres.reduce((s, c) => s + c.l + ECART, ECART)
  const hauteur = Math.max(...cadres.map((c) => c.h)) + 2 * ECART
  const planche = `<!doctype html><html><body style="margin:0;background:#9aa0b4;display:flex;gap:${ECART}px;padding:${ECART}px;align-items:flex-start">${cadres
    .map((c) => `<iframe src="${ecran.id}.html" style="width:${c.l}px;height:${c.h}px;border:0;background:#fff"></iframe>`)
    .join('')}</body></html>`
  const fichierPlanche = join(sortie, `${ecran.id}-planche.html`)
  writeFileSync(fichierPlanche, planche)
  const png = join(sortie, `${ecran.id}.png`)
  execFileSync(CHROME, ['--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=1', '--allow-file-access-from-files',
    `--window-size=${largeur},${hauteur}`, `--screenshot=${png}`, '--virtual-time-budget=4000',
    'file:///' + fichierPlanche.replace(/\\/g, '/')], { stdio: 'ignore' })
  console.log(png)
}
