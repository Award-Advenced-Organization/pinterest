// Mesure la colonne de chaque carte de mosaique, au telephone et a la tablette,
// pour l entree au defilement (--cp, --ct dans les ecrans). Sert apres un
// changement de cartes :  node outils/colonnes.mjs <dossier temporaire> <id...>
import { readFileSync, writeFileSync } from 'node:fs'
import { execFileSync } from 'node:child_process'
const sortie = process.argv[2], ids = process.argv.slice(3)
const doc = JSON.parse(readFileSync('D:/usw-ihm/maquette-usw.god2', 'utf8'))
const res = {}
for (const id of ids) {
  const e = doc.ecrans.find((x) => x.id === id)
  writeFileSync(`${sortie}/${id}-m.html`, `<!doctype html><html><head><meta charset="utf-8"><style>${doc.styles}</style><style>*{animation:none!important}</style></head><body>${doc.symboles}${e.balisage}</body></html>`)
  const cadres = doc.formats.map((f) => `<iframe data-nom="${f.nom}" src="${id}-m.html" style="width:${f.largeur}px;height:${f.hauteur}px"></iframe>`).join('')
  writeFileSync(`${sortie}/${id}-mesure.html`, `<!doctype html><body>${cadres}<pre id="r"></pre><script>onload=()=>{const o={};for(const f of document.querySelectorAll('iframe')){const d=f.contentDocument;const m=d.querySelector('.mosaique');const ks=[...m.children];const xs=[...new Set(ks.map(k=>Math.round(k.getBoundingClientRect().left)))].sort((a,b)=>a-b);o[f.dataset.nom]=ks.map(k=>xs.indexOf(Math.round(k.getBoundingClientRect().left))+'/'+xs.length)}document.getElementById('r').textContent=JSON.stringify(o)}</script></body>`)
  const out = execFileSync('C:/Program Files/Google/Chrome/Application/chrome.exe', ['--headless=new', '--disable-gpu', '--allow-file-access-from-files', '--virtual-time-budget=3000', '--dump-dom', 'file:///' + `${sortie}/${id}-mesure.html`], { encoding: 'utf8' })
  res[id] = JSON.parse(out.match(/<pre id="r">(.*?)<\/pre>/s)[1])
}
console.log(JSON.stringify(res))
