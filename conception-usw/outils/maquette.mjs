// Assemble la maquette de USW, comme celle de SafeVault, sous deux formes :
//
//   maquette-usw.god2   le document seul, au format .god2 (FORMAT-GOD2.md
//                       de god2-design), copie aussi dans
//                       D:\god2-design\public\maquettes\usw.god2 ;
//   maquette-usw.html   le meme document dans l atelier god2-design, a
//                       ouvrir au double-clic, sans serveur ni reseau.
//
//   node outils/maquette.mjs
//
// Sources, dans maquette/ :
//   document.json   le nom, les formats (tablette, telephone), les ecrans,
//                   les noms des calques ;
//   ecrans/*.html   le balisage de chaque ecran. Deux reperes y sont
//                   remplaces : <!--barre-etat--> et <!--onglets:NOM-->
//                   (NOM : accueil, reels, creer, carte, profil) ;
//   styles/         tokens, verre, boutons de SafeVault tels quels, puis
//                   base.css, usw.css, compte.css, profil.css, creer.css et messages.css ;
//   symboles.svg    les icones ;
//   images/         les photos en WebP (outils/images.py) et leurs tailles ;
//   polices/        Wura mi by GemmaS ;
//   atelier/        gabarit.html, atelier.css, atelier.js de god2-design.
// Aucune dependance : Node suffit.

import { copyFileSync, existsSync, readFileSync, writeFileSync } from 'node:fs'

const racine = new URL('../', import.meta.url)
const source = new URL('maquette/', racine)
const lire = (chemin) => readFileSync(new URL(chemin, source), 'utf8')
const base64 = (chemin) => readFileSync(new URL(chemin, source)).toString('base64')

// ---------------------------------------------------------------- polices
const GRAISSES = [
  ['WuraMiByGemmaS-Light.woff2', 300],
  ['WuraMiByGemmaS.woff2', 400],
  ['WuraMiByGemmaS-SemiBold.woff2', 600],
  ['WuraMiByGemmaS-Bold.woff2', 700],
]
const police = ([fichier, graisse]) => `@font-face {
  font-family: 'WuraMi';
  src: url(data:font/woff2;base64,${base64(`polices/${fichier}`)}) format('woff2');
  font-weight: ${graisse};
  font-style: normal;
  font-display: block;
}`
const polices = GRAISSES.map(police).join('\n\n')
const policesAtelier = GRAISSES.filter(([, g]) => g !== 300).map(police).join('\n\n')

// ---------------------------------------------------------------- photos
// Une classe par photo : son fond et ses proportions, poses une seule fois.
const tailles = JSON.parse(lire('images/images.json'))
const photos = Object.entries(tailles)
  .map(([nom, [l, h]]) => `.ph-${nom} { background-image: url(data:image/webp;base64,${base64(`images/${nom}.webp`)}); aspect-ratio: ${l} / ${h}; }`)
  .join('\n')

// ---------------------------------------------------------------- styles
const FEUILLES = ['tokens.css', 'verre.css', 'boutons.css', 'bouton-verre.css', 'base.css', 'usw.css', 'compte.css', 'profil.css', 'creer.css', 'messages.css', 'feuilles.css']
const styles = [
  polices,
  ...FEUILLES.map((f) => `/* ---- styles/${f} ---- */\n${lire(`styles/${f}`).trim()}`),
  `/* ---- photos ---- */\n${photos}`,
].join('\n\n')

// ---------------------------------------------------------------- reperes
const icone = (nom) => `<svg class="ic"><use href="#i-${nom}"/></svg>`
const BARRE_ETAT = `<div class="barre-etat"><span>9:41</span><span class="etat-icones">${icone('signal')}${icone('wifi')}${icone('batterie')}</span></div>`
const ONGLETS = [
  ['accueil', 'Accueil', 'accueil'],
  ['reels', 'Reels', 'reels'],
  ['creer', 'Créer', 'plus'],
  ['carte', 'Carte', 'carte'],
  ['profil', 'Profil', 'profil'],
]
function onglets(actif) {
  const boutons = ONGLETS.map(([id, nom, ic]) => {
    if (id === 'creer') return `<button type="button" class="onglet creer verre verre-appuyable plein" aria-label="${nom}">${icone(ic)}</button>`
    const courant = id === actif ? ' aria-current="page"' : ''
    return `<button type="button" class="onglet"${courant} aria-label="${nom}">${icone(ic)}</button>`
  })
  return `<nav class="onglets verre" aria-label="Navigation principale">${boutons.join('')}</nav>`
}
function balisage(fichier) {
  return lire(`ecrans/${fichier}`)
    .replace(/<!--barre-etat-->/g, BARRE_ETAT)
    .replace(/<!--onglets:(\w+)-->/g, (_, actif) => onglets(actif))
    .trim()
}

// ---------------------------------------------------------------- document
const doc = JSON.parse(lire('document.json'))
const god2 = JSON.stringify({
  format: 'god2',
  version: 1,
  nom: doc.nom,
  auteurs: doc.auteurs,
  formats: doc.formats,
  ecrans: doc.ecrans.map(({ source: fichier, ...ecran }) => ({ ...ecran, balisage: balisage(fichier) })),
  symboles: lire('symboles.svg').trim(),
  styles,
  jetons: doc.jetons,
  stylesTexte: doc.stylesTexte,
  calques: doc.calques,
})
writeFileSync(new URL('maquette-usw.god2', racine), god2)

const studio = new URL('file:///D:/god2-design/public/maquettes/')
if (existsSync(studio)) copyFileSync(new URL('maquette-usw.god2', racine), new URL('usw.god2', studio))

// ---------------------------------------------------------------- atelier autonome
const atelier = lire('atelier/atelier.js').trim()
if (/<\/script/i.test(atelier)) throw new Error('"</script" dans atelier.js : le fichier assemble serait coupe a cet endroit.')
const pieces = {
  '/*{{STYLES_ATELIER}}*/': lire('atelier/atelier.css').replace('/*{{POLICES}}*/', () => policesAtelier).trim(),
  '/*{{DOCUMENT_GOD2}}*/': god2.replace(/</g, () => String.fromCharCode(92) + 'u003c'),
  '/*{{SCRIPT_ATELIER}}*/': atelier,
}
let page = lire('atelier/gabarit.html')
for (const [repere, contenu] of Object.entries(pieces)) {
  if (!page.includes(repere)) throw new Error(`Le gabarit a perdu son repere ${repere}.`)
  page = page.replace(repere, () => contenu)
}
writeFileSync(new URL('maquette-usw.html', racine), page)

const ko = (t) => `${Math.round(t.length / 1024)} Ko`
console.log(`maquette-usw.god2 : ${ko(god2)}, ${doc.ecrans.length} écrans x ${doc.formats.length} formats. maquette-usw.html : ${ko(page)}.`)
console.log(existsSync(studio) ? 'Copiée dans god2-design : public/maquettes/usw.god2' : 'god2-design introuvable : copie non faite.')
