// Exporte la maquette pour Figma, a partir de maquette-usw.god2 :
//   maquette/figma/telephone/NN-id.jpg   chaque ecran a 412 px de large, en x2
//   maquette/figma/tablette/NN-id.jpg    chaque ecran a 800 px de large, en x1
//   maquette/figma/html/NN-id.html       chaque ecran en page autonome, pour
//                                        le module html.to.design (calques modifiables)
// Les animations sont figees a leur etat final, comme sur la toile de l atelier.
//
//   node outils/figma.mjs

import { mkdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs'
import { execFileSync } from 'node:child_process'
import { join } from 'node:path'
import { fileURLToPath } from 'node:url'

const racine = fileURLToPath(new URL('..', import.meta.url))
const doc = JSON.parse(readFileSync(join(racine, 'maquette-usw.god2'), 'utf8'))
const CHROME = 'C:/Program Files/Google/Chrome/Application/chrome.exe'
const FIGE = '*,*::before,*::after{animation:none!important;transition:none!important}html,body{overflow:hidden!important}'
const sortie = join(racine, 'maquette', 'figma')
const brouillon = join(sortie, '.captures')
const FORMATS = [
  { dossier: 'telephone', format: 'Téléphone', echelle: 2 },
  { dossier: 'tablette', format: 'Tablette', echelle: 1 },
]

rmSync(sortie, { recursive: true, force: true })
for (const d of ['html', '.captures', ...FORMATS.map((f) => f.dossier)]) mkdirSync(join(sortie, d), { recursive: true })
writeFileSync(join(sortie, 'html', 'styles.css'), `${doc.styles}\n${FIGE}\n`)

const recadrages = []
doc.ecrans.forEach((ecran, i) => {
  const nom = `${String(i + 1).padStart(2, '0')}-${ecran.id}`
  writeFileSync(join(sortie, 'html', `${nom}.html`),
    `<!doctype html><html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>${ecran.nom}</title><link rel="stylesheet" href="styles.css"></head><body>${doc.symboles}${ecran.balisage}</body></html>`)
  for (const f of FORMATS) {
    const { largeur, hauteur: h } = doc.formats.find((x) => x.nom === f.format)
    const hauteur = ecran.fenetre ? h : h * 2
    const planche = join(brouillon, `${nom}-${f.dossier}.html`)
    writeFileSync(planche, `<!doctype html><html><body style="margin:0"><iframe src="../html/${nom}.html" style="display:block;width:${largeur}px;height:${hauteur}px;border:0;background:#fff"></iframe></body></html>`)
    const png = join(brouillon, `${nom}-${f.dossier}.png`)
    execFileSync(CHROME, ['--headless=new', '--disable-gpu', '--hide-scrollbars', `--force-device-scale-factor=${f.echelle}`, '--allow-file-access-from-files',
      `--window-size=${Math.max(largeur, 800)},${hauteur}`, `--screenshot=${png}`, '--virtual-time-budget=4000',
      'file:///' + planche.replace(/\\/g, '/')], { stdio: 'ignore' })
    recadrages.push([png, join(sortie, f.dossier, `${nom}.jpg`), largeur * f.echelle, hauteur * f.echelle])
  }
  console.log(nom)
})

// Chrome photographie toute la fenetre : on garde le cadre seul, en JPEG.
execFileSync('python', ['-c', `
import json, sys
from PIL import Image
for png, jpg, l, h in json.load(sys.stdin):
    Image.open(png).convert('RGB').crop((0, 0, l, h)).save(jpg, quality=88, optimize=True)
`], { input: JSON.stringify(recadrages), stdio: ['pipe', 'inherit', 'inherit'] })
rmSync(brouillon, { recursive: true, force: true })
console.log(`${doc.ecrans.length} écrans exportés dans maquette/figma.`)
