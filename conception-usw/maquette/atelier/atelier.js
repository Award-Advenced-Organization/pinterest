// god2-design : l atelier des maquettes .god2.
//
// Une maquette est un document .god2 (voir FORMAT-GOD2.md) : des ecrans en
// HTML, leurs styles, et de quoi nommer leurs calques. L atelier pose chaque
// ecran sur une toile, une fois par format (bureau, telephone). Chaque cadre
// est une page a part entiere, une iframe a sa largeur, si bien que les
// styles s y appliquent comme dans une vraie fenetre. Par-dessus, un capteur
// recoit le pointeur : il sert a se deplacer, a zoomer, a designer le calque
// sous la main, a le deplacer, a le dimensionner et a dessiner. Les calques et
// leurs proprietes sont lus dans la page de chaque cadre, et les retouches y
// sont faites avant d etre inscrites dans le document (voir "l edition").
//
// Un .god2 ouvert depuis le disque n est pas forcement le notre : son contenu
// est pose dans des iframes bridees (sandbox). Sur la toile, aucun script du
// document ne s execute ; en presentation, les scripts tournent, mais coupes
// de l atelier.
function atelierGod2(depart, hote) {
  'use strict'

  // Ce que l atelier ecoute hors de sa coque (la fenetre, le document) se
  // retire d un coup a l arret.
  var fin = new AbortController()
  var hors = { signal: fin.signal }

  function id(nom) { return document.getElementById(nom) }
  var racine = id('gd')
  var toile = id('gd-toile')
  var monde = id('gd-monde')
  var capteur = id('gd-capteur')
  var dessus = id('gd-dessus')
  var arbre = id('gd-arbre')
  var fiche = id('gd-fiche')
  var contourSurvol = id('gd-survol')
  var contourChoix = id('gd-choix')
  var mesure = id('gd-mesure')
  var zoomValeur = id('gd-zoom-valeur')
  var presentation = id('gd-presentation')
  var presentationEcran = id('gd-presentation-ecran')
  var presentationTitre = id('gd-presentation-titre')
  var presentationFormats = id('gd-presentation-formats')
  var presentationScene = id('gd-presentation-scene')
  var voletDroit = id('gd-volet-droit')
  var large = window.matchMedia('(min-width: 900px)')

  // Sur la toile, les ecrans sont des images fixes : rien ne bouge, rien ne
  // defile, et le calcul reste leger meme avec plusieurs cadres. Les
  // animations sont coupees net, pas seulement accelerees : un element lu au
  // milieu de son entree en scene serait encore invisible.
  var FIGE =
    '*,*::before,*::after{animation:none!important;transition:none!important}' +
    '.document-vivant .ligne{stroke-dashoffset:0!important}' +
    'html,body{overflow:hidden!important}.apercu-cadre{overflow:hidden!important}'

  // En presentation, la lumiere du verre suit la main, comme dans l application.
  var LUMIERE =
    '(function(){if(matchMedia("(prefers-reduced-motion: reduce)").matches)return;var a=false,d=null;' +
    'function p(){a=false;var e=d;if(!e||!e.target||!e.target.closest)return;var c=e.target.closest(".verre");if(!c)return;' +
    'var b=c.getBoundingClientRect(),x=e.clientX-b.left,y=e.clientY-b.top;c.style.setProperty("--lx",x+"px");c.style.setProperty("--ly",y+"px");' +
    'c.style.setProperty("--angle",Math.atan2(y-b.height/2,x-b.width/2)*180/Math.PI+90+"deg")}' +
    'addEventListener("pointermove",function(e){d=e;if(a)return;a=true;requestAnimationFrame(p)},{passive:true})})()'

  var ECART = 200

  // ---------------------------------------------------------------- le document

  var doc = null

  // Un document .god2 doit au moins dire ce qu il est et porter des ecrans.
  function valider(d) {
    if (!d || d.format !== 'god2') throw new Error('Ce fichier n\'est pas un document .god2.')
    if (!Array.isArray(d.ecrans) || !d.ecrans.length) throw new Error('Ce document .god2 ne contient aucun écran.')
    d.ecrans.forEach(function (e) {
      if (typeof e.balisage !== 'string') throw new Error('Un écran de ce document n\'a pas de contenu.')
      // Les liens du prototype : un selecteur, au besoin un texte que l element
      // doit contenir, et l ecran vise (ou "retour").
      e.liens = Array.isArray(e.liens) ? e.liens.filter(function (l) {
        return l && typeof l.selecteur === 'string' && typeof l.vers === 'string' && (l.texte === undefined || typeof l.texte === 'string')
      }) : []
    })
    if (!Array.isArray(d.formats) || !d.formats.length) d.formats = [{ nom: 'Bureau', largeur: 1440 }]
    d.calques = d.calques || {}
    d.calques.noms = d.calques.noms || {}
    d.calques.composants = d.calques.composants || []
    d.calques.images = d.calques.images || []
    return d
  }

  function pageDe(ecran, extra, script) {
    return (
      '<!doctype html><html lang="fr"><head><meta charset="utf-8">' +
      '<meta name="viewport" content="width=device-width, initial-scale=1">' +
      '<title>' + echapper(ecran.nom) + '</title><style>' + (doc.styles || '') + '</style>' +
      (extra ? '<style>' + extra + '</style>' : '') +
      '</head><body>' + (doc.symboles || '') + '<!--god2-->' + ecran.balisage +
      (script ? '<script>' + script + '<\/script>' : '') +
      '</body></html>'
    )
  }

  // ---------------------------------------------------------------- les calques

  var DESSINS = {
    ecran: '<rect x="2.5" y="3" width="11" height="8" rx="1.25"/><path d="M6 13.5h4"/>',
    cadre: '<path d="M5.5 2.5v11M10.5 2.5v11M2.5 5.5h11M2.5 10.5h11"/>',
    texte: '<path d="M4 5V3.75h8V5M8 3.75v8.5M6.5 12.25h3"/>',
    vecteur: '<path d="M3 12.5c1.5-6 4-9 6.5-9S13 6 10 8s-5 1.5-7 4.5z"/>',
    image: '<rect x="2.5" y="3" width="11" height="10" rx="1.5"/><path d="m3 11 3-3 2.5 2 1.75-1.5L13 11"/>',
    instance: '<path d="m8 2.5 5.5 5.5L8 13.5 2.5 8z"/>',
  }
  function dessin(type) {
    return '<svg class="gd-type" viewBox="0 0 16 16" aria-hidden="true">' + DESSINS[type] + '</svg>'
  }

  var noeudDe = new WeakMap()
  var index = {}

  function classes(el) {
    var c = el.getAttribute('class')
    return c ? c.split(/\s+/).filter(Boolean) : []
  }
  function court(texte) {
    var t = String(texte).replace(/\s+/g, ' ').trim()
    return t.length > 42 ? t.slice(0, 41) + '…' : t
  }
  function aDuTexte(el) {
    for (var n = el.firstChild; n; n = n.nextSibling) if (n.nodeType === 3 && n.nodeValue.trim()) return true
    return false
  }
  function parmi(liste, ensemble) {
    for (var i = 0; i < liste.length; i++) if (ensemble.indexOf(liste[i]) >= 0) return liste[i]
    return null
  }

  // Un element de la page devient un calque : son type dit s il contient
  // d autres calques ou s il s arrete la (un texte, une icone, une image).
  // `cle` l identifie : son cadre, puis son chemin dans la page. Elle reste la
  // meme d une relecture a l autre.
  function lire(el, cadre, parent, cle) {
    var style = cadre.iframe.contentWindow.getComputedStyle(el)
    // Un calque masque depuis l atelier reste dans l arbre, pour qu on puisse le remontrer.
    var masque = el.hasAttribute('data-masque')
    if (parent && !masque) {
      var boite = el.getBoundingClientRect()
      if (boite.width <= 1 && boite.height <= 1) return null
      if (style.visibility === 'hidden' || style.opacity === '0') return null
    }
    var balise = el.tagName.toLowerCase()
    var liste = classes(el)
    var type = 'cadre'
    var feuille = masque
    var composant = parmi(liste, doc.calques.composants)

    if (balise === 'svg') { type = 'vecteur'; feuille = true }
    else if (balise === 'img' || parmi(liste, doc.calques.images)) { type = 'image'; feuille = true }
    else if (balise === 'input') { type = 'texte'; feuille = true }
    else if (aDuTexte(el) && !el.querySelector('svg')) { type = 'texte'; feuille = true }
    else if (composant) type = 'instance'

    var nom = null
    for (var i = 0; i < liste.length && !nom; i++) nom = doc.calques.noms[liste[i]] || null
    if (type === 'texte') nom = balise === 'input' ? el.getAttribute('placeholder') || 'Saisie' : el.textContent
    else if (!nom) nom = el.getAttribute('aria-label') || (type === 'vecteur' ? 'Vecteur' : 'Groupe')
    if (type === 'instance' && aDuTexte(el)) nom += ' · ' + court(el.textContent)
    // Un nom donne dans l atelier l emporte sur celui qu on deduit.
    nom = el.getAttribute('data-nom') || nom

    var noeud = {
      id: cle, el: el, cadre: cadre, parent: parent, nom: court(nom), type: type, masque: masque,
      composant: type === 'instance' ? composant : null, enfants: [],
    }
    noeudDe.set(el, noeud)
    index[noeud.id] = noeud
    if (!feuille) {
      var rang = 0
      for (var e = el.firstElementChild; e; e = e.nextElementSibling, rang++) {
        var enfant = lire(e, cadre, noeud, cle + '.' + rang)
        if (enfant) noeud.enfants.push(enfant)
      }
    }
    return noeud
  }

  // Dans la page d un cadre, le balisage de l ecran suit un repere ; avant lui
  // viennent les symboles du document.
  function repereDe(page) {
    for (var n = page.body.firstChild; n; n = n.nextSibling) if (n.nodeType === 8 && n.nodeValue === 'god2') return n
    return null
  }
  function racineDe(page) {
    for (var n = repereDe(page); n; n = n.nextSibling) if (n.nodeType === 1) return n
    return page.body
  }
  // Lit, ou relit, les calques d un cadre.
  function relire(cadre) {
    var noeud = lire(racineDe(cadre.iframe.contentDocument), cadre, null, 'k' + cadres.indexOf(cadre))
    noeud.type = 'ecran'
    noeud.nom = cadre.nom
    cadre.racine = noeud
  }
  function reindexer() {
    index = {}
    cadres.forEach(function (c) { if (c.racine) parcourir(c.racine, function (n) { index[n.id] = n }) })
  }

  function parcourir(noeud, faire) {
    faire(noeud)
    noeud.enfants.forEach(function (e) { parcourir(e, faire) })
  }

  // ---------------------------------------------------------------- les cadres

  var cadres = []

  function creerCadres() {
    doc.formats.forEach(function (format, rangee) {
      doc.ecrans.forEach(function (ecran) {
        var iframe = document.createElement('iframe')
        iframe.className = 'gd-cadre'
        iframe.setAttribute('tabindex', '-1')
        iframe.setAttribute('aria-hidden', 'true')
        // Meme origine pour lire les calques, mais aucun script du document.
        iframe.setAttribute('sandbox', 'allow-same-origin')
        // Un ecran "fenetre" (une fenetre modale, par exemple) se montre a la
        // hauteur de la fenetre du format ; les autres, a celle de leur contenu.
        var fixe = (ecran.fenetre && format.hauteur) || 0
        iframe.style.width = format.largeur + 'px'
        iframe.style.height = (fixe || 900) + 'px'
        var etiquette = document.createElement('button')
        etiquette.type = 'button'
        etiquette.className = 'gd-etiquette'
        etiquette.textContent = nomDeCadre(ecran, format)
        dessus.appendChild(etiquette)
        var cadre = {
          ecran: ecran, format: format, rangee: rangee, iframe: iframe, etiquette: etiquette,
          nom: etiquette.textContent, x: 0, y: 0, largeur: format.largeur, hauteur: fixe || 900, fixe: fixe, racine: null,
        }
        etiquette.addEventListener('click', function () { if (cadre.racine) choisir(cadre.racine) })
        cadres.push(cadre)
        monde.appendChild(iframe)
        iframe.srcdoc = pageDe(ecran, FIGE)
      })
    })
  }

  // La hauteur d un cadre est celle de son contenu. Certaines mesures de la
  // page dependent de la hauteur de la fenetre : on ajuste en quelques passes.
  function ajusterHauteur(cadre) {
    if (cadre.fixe) return
    var page = cadre.iframe.contentDocument
    for (var passe = 0; passe < 4; passe++) {
      var h = Math.ceil(page.documentElement.scrollHeight)
      var contenu = Math.ceil(page.body.getBoundingClientRect().height)
      var cible = Math.max(Math.min(h, contenu || h), 200)
      if (Math.abs(cible - cadre.hauteur) < 1) break
      cadre.hauteur = cible
      cadre.iframe.style.height = cible + 'px'
    }
  }

  function disposer() {
    var y = 0
    doc.formats.forEach(function (format, rangee) {
      var x = 0
      var haut = 0
      cadres.filter(function (c) { return c.rangee === rangee }).forEach(function (c) {
        c.x = x
        c.y = y
        c.iframe.style.left = x + 'px'
        c.iframe.style.top = y + 'px'
        x += c.largeur + ECART
        haut = Math.max(haut, c.hauteur)
      })
      y += haut + ECART + 60
    })
  }

  function preparer() {
    var attendus = cadres.map(function (cadre) {
      return new Promise(function (pret) {
        cadre.iframe.addEventListener('load', function () {
          var page = cadre.iframe.contentDocument
          var apres = page.fonts && page.fonts.ready ? page.fonts.ready : Promise.resolve()
          apres.then(function () {
            ajusterHauteur(cadre)
            pret()
          })
        }, { once: true })
      })
    })
    return Promise.all(attendus).then(function () {
      disposer()
      cadres.forEach(relire)
    })
  }

  // Ouvre un document : l historique repart de lui, et des retouches gardees
  // dans le navigateur pour cette maquette sont proposees.
  function ouvrir(nouveau) {
    doc = valider(nouveau)
    historique = []
    refaits = []
    noterModifie(false)
    proposerReprise()
    return monter()
  }

  // Pose le document sur la toile : tout ce qui tenait au montage precedent
  // est remis a zero.
  function monter() {
    if (ecriture) { ecriture.champ.remove(); ecriture = null }
    plume = null
    dessinerEsquisse(null)
    cadres.forEach(function (c) { c.iframe.remove(); c.etiquette.remove() })
    cadres = []
    index = {}
    ouverts = {}
    survol = null
    choix = null
    filtre = ''
    id('gd-recherche').value = ''
    contourSurvol.hidden = true
    contourChoix.hidden = true
    id('gd-attente').hidden = false
    document.title = doc.nom + ' · god2-design'
    id('gd-nom-fichier').textContent = doc.nom + '.god2'
    id('gd-equipe').innerHTML = (doc.auteurs || []).map(function (a) {
      return '<span class="gd-pastille" title="' + echapper(a) + '">' + echapper(String(a).charAt(0).toUpperCase()) + '</span>'
    }).join('')
    creerCadres()
    // Les cadres prennent leur place tout de suite : on les voit arriver un a
    // un, avant que leurs hauteurs et leurs calques soient lus.
    disposer()
    toutVoir()
    return preparer().then(function () {
      id('gd-attente').hidden = true
      ouverts[cadres[0].racine.id] = true
      dessinerArbre()
      dessinerComposants()
      dessinerStyles()
      dessinerFiche()
      toutVoir()
    })
  }

  // ---------------------------------------------------------------- la vue

  var vue = { x: 0, y: 0, z: 1 }
  var rafraichir = false

  function borner(z) { return Math.min(4, Math.max(0.04, z)) }

  function appliquer() {
    if (rafraichir) return
    rafraichir = true
    requestAnimationFrame(function () {
      rafraichir = false
      monde.style.transform = 'translate(' + vue.x + 'px,' + vue.y + 'px) scale(' + vue.z + ')'
      zoomValeur.textContent = Math.round(vue.z * 100) + ' %'
      cadres.forEach(function (c) {
        c.etiquette.style.left = vue.x + c.x * vue.z + 'px'
        c.etiquette.style.top = vue.y + c.y * vue.z - 4 + 'px'
        c.etiquette.style.maxWidth = Math.max(40, c.largeur * vue.z) + 'px'
      })
      poserContour(contourSurvol, survol === choix ? null : survol)
      poserContour(contourChoix, choix)
      if (ecriture) placerEcriture()
      if (plume) esquisserPlume()
      if (ecartsVus) montrerEcarts(ecartsVus)
    })
  }

  // La part de la toile que rien ne recouvre : sur grand ecran, les outils
  // flottent a gauche et les proprietes a droite.
  function champLibre() {
    var boite = toile.getBoundingClientRect()
    var gauche = large.matches ? 56 : 0
    var droite = large.matches ? voletDroit.getBoundingClientRect().width + 12 : 0
    return { gauche: gauche, largeur: Math.max(120, boite.width - gauche - droite), hauteur: boite.height }
  }

  function zoomer(z, cx, cy) {
    if (cx === undefined) {
      var champ = champLibre()
      cx = champ.gauche + champ.largeur / 2
      cy = champ.hauteur / 2
    }
    z = borner(z)
    vue.x = cx - ((cx - vue.x) / vue.z) * z
    vue.y = cy - ((cy - vue.y) / vue.z) * z
    vue.z = z
    appliquer()
  }

  function cadrer(x, y, largeur, hauteur, marge) {
    var champ = champLibre()
    var z = borner(Math.min((champ.largeur - marge * 2) / largeur, (champ.hauteur - marge * 2 - 30) / hauteur))
    vue.z = z
    vue.x = champ.gauche + (champ.largeur - largeur * z) / 2 - x * z
    vue.y = (champ.hauteur - hauteur * z) / 2 - y * z + 10
    appliquer()
  }

  function toutVoir() {
    var droite = 0
    var bas = 0
    cadres.forEach(function (c) {
      droite = Math.max(droite, c.x + c.largeur)
      bas = Math.max(bas, c.y + c.hauteur)
    })
    if (droite) cadrer(0, 0, droite, bas, 40)
  }

  // La boite d un calque dans la page de son cadre. Un ecran prend celle du
  // cadre : sa page peut depasser (un ecran "fenetre" s arrete a la fenetre).
  function boiteDe(noeud) {
    if (noeud.type === 'ecran') return { left: 0, top: 0, width: noeud.cadre.largeur, height: noeud.cadre.hauteur }
    return noeud.el.getBoundingClientRect()
  }

  // La boite d un calque, dans le repere du monde.
  function boiteMonde(noeud) {
    var b = boiteDe(noeud)
    return { x: noeud.cadre.x + b.left, y: noeud.cadre.y + b.top, largeur: b.width, hauteur: b.height }
  }

  function voirChoix() {
    if (!choix) return toutVoir()
    var b = boiteMonde(choix)
    cadrer(b.x, b.y, Math.max(b.largeur, 40), Math.max(b.hauteur, 40), 90)
  }

  // ---------------------------------------------------------------- survol et choix

  var survol = null
  var choix = null
  var ouverts = {}

  // La boite d un calque sur la toile, en pixels d ecran.
  function boiteEcran(noeud) {
    var b = boiteMonde(noeud)
    return { x: vue.x + b.x * vue.z, y: vue.y + b.y * vue.z, l: b.largeur * vue.z, h: b.hauteur * vue.z }
  }

  function poserContour(contour, noeud) {
    var b = noeud ? boiteMonde(noeud) : null
    // Un calque masque n a plus de boite : pas de contour.
    contour.hidden = !b || (!b.largeur && !b.hauteur)
    if (!contour.hidden) {
      contour.style.transform = 'translate(' + (vue.x + b.x * vue.z) + 'px,' + (vue.y + b.y * vue.z) + 'px)'
      contour.style.width = b.largeur * vue.z + 'px'
      contour.style.height = b.hauteur * vue.z + 'px'
    }
    if (contour !== contourChoix) return
    if (b) mesure.textContent = arrondi(b.largeur) + ' × ' + arrondi(b.hauteur)
    poserRayons()
  }

  function marquer(noeud, oui) {
    var rang = id('rang-' + noeud.id)
    if (rang) rang.dataset.survol = String(oui)
  }

  function survoler(noeud) {
    if (noeud === survol) return
    if (survol) marquer(survol, false)
    survol = noeud
    if (survol) marquer(survol, true)
    poserContour(contourSurvol, survol === choix ? null : survol)
  }

  function choisir(noeud) {
    choix = noeud || null
    montrerEcarts(null)
    if (choix) for (var p = choix.parent; p; p = p.parent) ouverts[p.id] = true
    cadres.forEach(function (c) { c.etiquette.dataset.choisie = String(Boolean(choix) && choix === c.racine) })
    dessinerArbre()
    dessinerFiche()
    poserContour(contourChoix, choix)
    poserContour(contourSurvol, survol === choix ? null : survol)
    id('gd-export-quoi').textContent = choix
      ? 'L\'export porte sur « ' + choix.nom + ' ».'
      : 'Rien de choisi : l\'export porte sur tous les cadres.'
    if (choix) {
      var rang = id('rang-' + choix.id)
      if (rang) rang.scrollIntoView({ block: 'nearest' })
    }
  }

  // Le calque sous un point de la fenetre.
  function calqueSous(clientX, clientY) {
    var boite = toile.getBoundingClientRect()
    var mx = (clientX - boite.left - vue.x) / vue.z
    var my = (clientY - boite.top - vue.y) / vue.z
    for (var i = cadres.length - 1; i >= 0; i--) {
      var c = cadres[i]
      if (!c.racine || mx < c.x || my < c.y || mx > c.x + c.largeur || my > c.y + c.hauteur) continue
      var el = c.iframe.contentDocument.elementFromPoint(mx - c.x, my - c.y)
      while (el && !noeudDe.has(el)) el = el.parentElement
      return el ? noeudDe.get(el) : c.racine
    }
    return null
  }

  // ---------------------------------------------------------------- le volet gauche

  var filtre = ''

  var OEIL = '<svg viewBox="0 0 16 16" aria-hidden="true"><path d="M1.75 8c1.4-2.7 3.6-4.25 6.25-4.25S12.85 5.3 14.25 8c-1.4 2.7-3.6 4.25-6.25 4.25S3.15 10.7 1.75 8z"/><circle cx="8" cy="8" r="1.9"/></svg>'
  var OEIL_FERME = OEIL.replace('</svg>', '<path d="m3 13 10-10"/></svg>')

  function rangDe(noeud, niveau, plie, ouvert) {
    var oeil = noeud.masque ? 'Montrer' : 'Masquer'
    return (
      '<div class="gd-rang" role="treeitem" id="rang-' + noeud.id + '" data-id="' + noeud.id + '" data-type="' + noeud.type + '"' +
      ' data-masque="' + noeud.masque + '" aria-level="' + (niveau + 1) + '" aria-selected="' + (noeud === choix) + '"' +
      (plie ? ' aria-expanded="' + ouvert + '"' : '') + ' style="--niveau:' + niveau + '">' +
      '<span class="gd-rang-pli"' + (plie ? ' data-pli="' + noeud.id + '"' : '') + '>' +
      (plie ? '<svg viewBox="0 0 12 12" aria-hidden="true"><path d="m4.5 2.5 3.5 3.5-3.5 3.5"/></svg>' : '') + '</span>' +
      dessin(noeud.type) + '<span class="gd-rang-nom">' + echapper(noeud.nom) + '</span>' +
      (noeud.type === 'ecran' ? '' : '<button type="button" class="gd-rang-oeil" data-oeil="' + noeud.id + '" aria-label="' + oeil + ' le calque" title="' + oeil + '">' +
        (noeud.masque ? OEIL_FERME : OEIL) + '</button>') + '</div>'
    )
  }

  function dessinerArbre() {
    var html = []
    if (filtre) {
      // En recherche, l arbre s aplatit : les calques dont le nom contient le texte.
      var cherche = sansAccent(filtre)
      cadres.forEach(function (c) {
        if (c.racine) parcourir(c.racine, function (n) {
          if (html.length < 200 && sansAccent(n.nom).indexOf(cherche) >= 0) html.push(rangDe(n, 0, false, false))
        })
      })
      if (!html.length) html.push('<p class="gd-vide">Aucun calque ne porte ce nom.</p>')
    } else {
      var rang = function (noeud, niveau) {
        var plie = noeud.enfants.length > 0
        var ouvert = Boolean(ouverts[noeud.id])
        html.push(rangDe(noeud, niveau, plie, ouvert))
        if (plie && ouvert) noeud.enfants.forEach(function (e) { rang(e, niveau + 1) })
      }
      cadres.forEach(function (c) { if (c.racine) rang(c.racine, 0) })
    }
    arbre.innerHTML = html.join('')
  }

  function sansAccent(t) { return String(t).normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase() }

  arbre.addEventListener('click', function (e) {
    if (e.target.closest('.gd-rang-champ')) return
    var oeil = e.target.closest('[data-oeil]')
    if (oeil) return basculerMasque(index[oeil.dataset.oeil])
    var pli = e.target.closest('[data-pli]')
    if (pli) {
      ouverts[pli.dataset.pli] = !ouverts[pli.dataset.pli]
      dessinerArbre()
      return
    }
    var rang = e.target.closest('.gd-rang')
    if (rang) choisir(index[rang.dataset.id])
  })
  // Un double-clic sur un calque permet de le renommer.
  arbre.addEventListener('dblclick', function (e) {
    if (e.target.closest('[data-pli], [data-oeil], .gd-rang-champ')) return
    var rang = e.target.closest('.gd-rang')
    if (rang) saisirNom(index[rang.dataset.id])
  })
  arbre.addEventListener('pointerover', function (e) {
    var rang = e.target.closest('.gd-rang')
    survoler(rang ? index[rang.dataset.id] : null)
  })
  arbre.addEventListener('pointerleave', function () { survoler(null) })
  id('gd-recherche').addEventListener('input', function (e) {
    filtre = e.target.value.trim()
    dessinerArbre()
  })

  // Les composants : les pieces reprises d un ecran a l autre, et combien de fois.
  var instances = {}
  function dessinerComposants() {
    instances = {}
    cadres.forEach(function (c) {
      parcourir(c.racine, function (n) {
        if (n.composant) (instances[n.composant] = instances[n.composant] || []).push(n)
      })
    })
    var cles = Object.keys(instances)
    id('gd-composants').innerHTML = cles.length
      ? '<ul class="gd-composants">' + cles.map(function (cle) {
          return '<li><button type="button" class="gd-composant" data-composant="' + echapper(cle) + '">' + dessin('instance') +
            '<span class="gd-composant-nom">' + echapper(doc.calques.noms[cle] || cle) + '</span>' +
            '<span class="gd-composant-compte">' + instances[cle].length + '</span></button></li>'
        }).join('') + '</ul><p class="gd-vide">Un clic montre une occurrence sur la toile, un autre clic la suivante.</p>'
      : '<p class="gd-vide">Ce document ne déclare aucun composant.</p>'
  }
  id('gd-composants').addEventListener('click', function (e) {
    var bouton = e.target.closest('[data-composant]')
    if (!bouton) return
    var liste = instances[bouton.dataset.composant]
    var suivant = liste[(liste.indexOf(choix) + 1) % liste.length]
    choisir(suivant)
    voirChoix()
  })

  // Les styles : les couleurs et les textes que la maquette declare.
  var GRAISSES = { 300: 'Light', 400: 'Regular', 500: 'Medium', 600: 'SemiBold', 700: 'Bold' }
  function dessinerStyles() {
    var premier = cadres[0]
    var page = premier.iframe.contentDocument
    var fenetre = premier.iframe.contentWindow
    var couleurs = ''
    ;(doc.jetons || []).forEach(function (j) {
      // Une sonde neuve par couleur : une valeur lue en cours de transition serait fausse.
      var sonde = page.createElement('span')
      sonde.style.cssText = 'transition:none!important;color:var(' + j[0] + ')'
      page.body.appendChild(sonde)
      var c = couleur(fenetre.getComputedStyle(sonde).color)
      sonde.remove()
      if (c) couleurs += ligneCouleur(j[1], c)
    })
    var textes = ''
    ;(doc.stylesTexte || []).forEach(function (t) {
      // Dans le premier cadre qui le montre : tous les ecrans n ont pas tout.
      var el = null
      for (var i = 0; i < cadres.length && !el; i++) el = cadres[i].iframe.contentDocument.querySelector(t[0])
      if (!el) return
      var s = el.ownerDocument.defaultView.getComputedStyle(el)
      textes += caseDe(t[1], (GRAISSES[s.fontWeight] || s.fontWeight) + ' · ' + arrondi(parseFloat(s.fontSize)), true)
    })
    id('gd-styles').innerHTML =
      (couleurs ? bloc('Couleurs', '<ul class="gd-couleurs">' + couleurs + '</ul>') : '') +
      (textes ? bloc('Textes', '<dl class="gd-grille">' + textes + '</dl>') : '') +
      (couleurs || textes ? '' : '<p class="gd-vide">Ce document ne déclare aucun style.</p>')
  }

  function montrerSection(nom) {
    racine.dataset.section = nom
    document.querySelectorAll('[data-section]').forEach(function (b) {
      if (b === racine) return
      b.setAttribute(b.getAttribute('role') === 'tab' ? 'aria-selected' : 'aria-pressed', String(b.dataset.section === nom))
    })
    document.querySelectorAll('.gd-pan').forEach(function (p) { p.hidden = p.dataset.pan !== nom })
  }

  // ---------------------------------------------------------------- la fiche

  function arrondi(v) { return Math.round(v * 100) / 100 }
  function echapper(t) {
    return String(t).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c] })
  }

  // Une couleur calculee par le navigateur, en hexadecimal et en opacite.
  function couleur(valeur) {
    var m = /rgba?\(([^)]+)\)/.exec(valeur)
    var r, v, b, a = 1
    if (m) {
      var p = m[1].split(/[\s,\/]+/).filter(Boolean).map(parseFloat)
      r = p[0]; v = p[1]; b = p[2]
      if (p.length > 3) a = p[3]
    } else {
      m = /color\(srgb ([\d.]+) ([\d.]+) ([\d.]+)(?: \/ ([\d.]+))?\)/.exec(valeur)
      if (!m) return null
      r = m[1] * 255; v = m[2] * 255; b = m[3] * 255
      if (m[4] !== undefined) a = parseFloat(m[4])
    }
    if (!(a > 0)) return null
    function hex(n) { return ('0' + Math.round(n).toString(16)).slice(-2) }
    return { hex: ('#' + hex(r) + hex(v) + hex(b)).toUpperCase(), alpha: a, opacite: Math.round(a * 100), css: valeur }
  }

  function caseDe(nom, valeur, grande) {
    return '<div class="gd-case"' + (grande ? ' data-large="true"' : '') + '><dt>' + echapper(nom) + '</dt><dd title="' + echapper(valeur) + '">' + echapper(valeur) + '</dd></div>'
  }
  function bloc(titre, contenu) {
    return '<section class="gd-bloc"><h3 class="gd-bloc-titre">' + titre + '</h3>' + contenu + '</section>'
  }
  function ligneCouleur(nom, c) {
    return '<li class="gd-couleur"><span class="gd-pave" style="background:' + echapper(c.css) + '"></span>' +
      '<span class="gd-couleur-nom">' + echapper(nom) + '</span><span class="gd-couleur-valeur">' + c.hex + (c.opacite < 100 ? ' · ' + c.opacite + ' %' : '') + '</span></li>'
  }

  var TYPES = { ecran: 'Écran', cadre: 'Cadre', texte: 'Texte', vecteur: 'Vecteur', image: 'Image', instance: 'Composant' }

  function ficheCalque(noeud) {
    var el = noeud.el
    var fenetre = noeud.cadre.iframe.contentWindow
    var s = fenetre.getComputedStyle(el)
    var b = boiteDe(noeud)
    var html = '<div class="gd-fiche-tete">' + dessin(noeud.type) + '<span class="gd-fiche-nom">' + echapper(noeud.nom) + '</span></div>' +
      '<p class="gd-fiche-ou">' + TYPES[noeud.type] + (noeud.type === 'ecran' ? '' : ' · ' + echapper(noeud.cadre.nom)) + '</p>'

    if (noeud.type === 'ecran') {
      var ecran = noeud.cadre.ecran
      html += bloc('Écran', '<dl class="gd-grille">' + champ('Nom', 'ecran-nom', ecran.nom, true) + champ('Adresse', 'ecran-adresse', ecran.adresse || '', true) + '</dl>')
      html += bloc('Dimensions', '<dl class="gd-grille">' + caseDe('L', arrondi(b.width)) + caseDe('H', arrondi(b.height)) + '</dl>')
      var fond = couleur(fenetre.getComputedStyle(el.ownerDocument.body).backgroundColor)
      if (fond) html += bloc('Remplissage', '<ul class="gd-couleurs">' + ligneCouleur('Fond', fond) + '</ul>')
      html += bloc('Appareil', '<dl class="gd-grille">' + caseDe('Format', noeud.cadre.format.nom + ' ' + noeud.cadre.format.largeur, true) + '</dl>')
      return html + bloc('Gérer', boutons([['ecran-dupliquer', 'Dupliquer l\'écran'], ['ecran-supprimer', 'Supprimer l\'écran']]))
    }
    if (noeud.masque) {
      return html + bloc('Calque', '<p class="gd-note">Ce calque est masqué : il reste dans la maquette, sans se voir.</p>' + boutons([['masquer', 'Montrer'], ['supprimer', 'Supprimer']]))
    }

    html += bloc('Position', '<dl class="gd-grille">' + champ('X', 'x', arrondi(b.left)) + champ('Y', 'y', arrondi(b.top)) + '</dl>')
    html += bloc('Dimensions', '<dl class="gd-grille">' + champ('L', 'l', arrondi(b.width)) + champ('H', 'h', arrondi(b.height)) +
      champ('Rayon', 'rayon', rayonEcrit(s, b)) + champ('Opacité', 'opacite', Math.round(s.opacity * 100)) + '</dl>')

    if (noeud.type === 'vecteur') {
      html += bloc('Trait', '<ul class="gd-couleurs">' + champCouleur('Couleur', 'couleur', couleur(s.color)) + '</ul>' +
        (el.getAttribute('stroke') ? '<dl class="gd-grille">' + champ('Épaisseur', 'trait', el.getAttribute('stroke-width') || '1') + '</dl>' : ''))
    } else {
      var remplissages = champCouleur('Fond', 'fond', couleur(s.backgroundColor))
      if (s.backgroundImage && s.backgroundImage !== 'none') {
        var genre = s.backgroundImage.indexOf('gradient') >= 0 ? 'Dégradé' : 'Image'
        remplissages += '<li class="gd-couleur"><span class="gd-pave" style="background:' + echapper(s.backgroundImage) + ' center / cover"></span><span class="gd-couleur-nom">' + genre + '</span></li>'
      }
      html += bloc('Remplissage', '<ul class="gd-couleurs">' + remplissages + '</ul>')

      var bord = s.borderTopStyle !== 'none' ? parseFloat(s.borderTopWidth) : 0
      var contours = champCouleur('Bordure', 'bord-couleur', bord > 0 ? couleur(s.borderTopColor) : null)
      var filet = parseFloat(s.outlineWidth)
      if (filet > 0 && s.outlineStyle !== 'none') {
        var co = couleur(s.outlineColor)
        if (co) contours += ligneCouleur((s.outlineStyle === 'dashed' ? 'Pointillé ' : 'Filet ') + arrondi(filet), co)
      }
      html += bloc('Contour', '<ul class="gd-couleurs">' + contours + '</ul><dl class="gd-grille">' + champ('Épaisseur', 'bord', arrondi(bord)) + '</dl>')
    }

    if (noeud.type === 'texte' || aDuTexte(el)) {
      var taille = parseFloat(s.fontSize)
      var interligne = s.lineHeight === 'normal' ? 'Auto' : arrondi(parseFloat(s.lineHeight))
      var espace = s.letterSpacing === 'normal' ? '0 %' : arrondi((parseFloat(s.letterSpacing) / taille) * 100) + ' %'
      var police = s.fontFamily.split(',')[0].replace(/["']/g, '')
      var cote = { start: 'left', end: 'right', justify: 'left' }[s.textAlign] || s.textAlign
      html += bloc('Texte', '<dl class="gd-grille">' +
        caseDe('Police', police === 'WuraMi' ? 'Wura mi by GemmaS' : police, true) +
        choixDe('Graisse', 'graisse', s.fontWeight, GRAISSES_CHOIX) + champ('Corps', 'corps', arrondi(taille)) +
        caseDe('Interligne', interligne) + caseDe('Approche', espace) + choixDe('Aligné', 'aligne', cote, ALIGNEMENTS) + '</dl>' +
        '<ul class="gd-couleurs">' + champCouleur('Couleur', 'couleur', couleur(s.color)) + '</ul>' +
        boutons([['ecrire', 'Modifier le texte']]))
    }

    var effets = ''
    if (s.boxShadow && s.boxShadow !== 'none') {
      var ombres = s.boxShadow.split(/,(?![^(]*\))/)
      var internes = ombres.filter(function (o) { return o.indexOf('inset') >= 0 }).length
      if (ombres.length - internes) effets += caseDe('Ombre portée', '× ' + (ombres.length - internes), true)
      if (internes) effets += caseDe('Ombre interne', '× ' + internes, true)
    }
    if (s.filter && s.filter !== 'none') effets += caseDe('Filtre', s.filter.indexOf('drop-shadow') >= 0 ? 'Ombre portée' : s.filter, true)
    var flou = s.backdropFilter || s.webkitBackdropFilter
    if (flou && flou !== 'none') effets += caseDe('Arrière-plan', 'Flou', true)
    if (effets) html += bloc('Effets', '<dl class="gd-grille">' + effets + '</dl>')

    return html + bloc('Calque', boutons([['dupliquer', 'Dupliquer'], ['masquer', 'Masquer'], ['supprimer', 'Supprimer']]) +
      boutons([['avancer', 'Avancer'], ['reculer', 'Reculer'], ['renommer', 'Renommer']]))
  }

  function fichePage() {
    var fond = couleur(getComputedStyle(toile).backgroundColor)
    return '<div class="gd-fiche-tete"><span class="gd-fiche-nom">' + echapper(doc.nom) + '</span></div>' +
      '<p class="gd-fiche-ou">Page · ' + cadres.length + ' cadres · ' + doc.ecrans.length + ' écrans</p>' +
      (fond ? bloc('Toile', '<ul class="gd-couleurs">' + ligneCouleur('Fond', fond) + '</ul>') : '') +
      bloc('Édition', '<p class="gd-note">Glissez un calque pour le déplacer, tirez un bord ou un coin pour le dimensionner, ' +
        'un point rond dans un coin pour l\'arrondir. Alt montre les écarts avec le calque survolé. ' +
        'Un double-clic sur un texte permet de le réécrire. Les outils dessinent cadres, formes, traits, textes et images. ' +
        'Une retouche vaut pour tous les formats d\'un écran.</p>' + boutons([['ecran-nouveau', 'Nouvel écran']]))
  }

  function dessinerFiche() {
    fiche.innerHTML = choix ? ficheCalque(choix) : fichePage()
  }

  function rayonDe(s, b) {
    var brut = s.borderTopLeftRadius
    var r = parseFloat(brut) || 0
    if (brut.indexOf('%') > 0) r = (r / 100) * Math.min(b.width, b.height)
    return Math.min(r, b.width / 2, b.height / 2)
  }

  // Les quatre coins, dans l ordre de border-radius : leur nom en CSS, et
  // le sens qui mene vers le centre du calque.
  var COINS = [['TopLeft', 1, 1], ['TopRight', -1, 1], ['BottomRight', -1, -1], ['BottomLeft', 1, -1]]

  function rayonsDe(s, b) {
    return COINS.map(function (c) {
      var brut = s['border' + c[0] + 'Radius']
      var r = parseFloat(brut) || 0
      if (brut.indexOf('%') > 0) r = (r / 100) * Math.min(b.width, b.height)
      return Math.min(r, b.width / 2, b.height / 2)
    })
  }
  // Un seul nombre si les quatre coins ont le meme rayon, sinon les quatre.
  function rayonEcrit(s, b) {
    var r = rayonsDe(s, b).map(arrondi)
    return r.every(function (v) { return v === r[0] }) ? r[0] : r.join(' ')
  }

  // ---------------------------------------------------------------- l export en SVG
  //
  // Un cadre, ou un calque, devient un dessin vectoriel que les editeurs de
  // design savent ouvrir : un groupe par calque (son nom en identifiant), un
  // rectangle pour chaque fond ou bordure, les textes ligne par ligne, les
  // icones telles quelles. Ce qui ne se traduit pas proprement (ombres,
  // reflets du verre) est laisse de cote.

  var POLICE_EXPORT = 'Outfit, \'Wura mi by GemmaS\', sans-serif'

  function nombre(v) { return String(Math.round(v * 100) / 100) }
  function xml(t) {
    return String(t).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c] })
  }
  // Chaque forme exportee ne porte qu une peinture (un fond, ou un trait) : sa
  // transparence s ecrit en "opacity", que tous les editeurs lisent, plutot
  // qu en fill-opacity ou stroke-opacity, que certains ignorent a l import.
  function peinture(attribut, c) {
    return ' ' + attribut + '="' + c.hex + '"' + (c.alpha < 1 ? ' opacity="' + nombre(c.alpha) + '"' : '')
  }

  // Les arguments d une fonction CSS, coupes aux virgules de premier niveau.
  function arguments_(texte) {
    var morceaux = []
    var niveau = 0
    var debut = 0
    for (var i = 0; i < texte.length; i++) {
      var c = texte.charAt(i)
      if (c === '(') niveau++
      else if (c === ')') niveau--
      else if (c === ',' && !niveau) { morceaux.push(texte.slice(debut, i).trim()); debut = i + 1 }
    }
    morceaux.push(texte.slice(debut).trim())
    return morceaux
  }

  // Le premier degrade lineaire d un fond, traduit en <linearGradient>.
  function degrade(fond, b, identifiant) {
    var depart = fond.indexOf('linear-gradient(')
    if (depart < 0) return null
    var niveau = 0
    var fin = -1
    for (var i = depart + 15; i < fond.length; i++) {
      if (fond.charAt(i) === '(') niveau++
      else if (fond.charAt(i) === ')' && --niveau === 0) { fin = i; break }
    }
    if (fin < 0) return null
    var morceaux = arguments_(fond.slice(depart + 16, fin))
    var angle = 180
    var cotes = { 'to top': 0, 'to right': 90, 'to bottom': 180, 'to left': 270 }
    if (/deg$/.test(morceaux[0])) angle = parseFloat(morceaux.shift())
    else if (cotes[morceaux[0]] !== undefined) angle = cotes[morceaux.shift()]
    else if (/^to /.test(morceaux[0])) { morceaux.shift(); angle = 135 }
    var arrets = morceaux.map(function (m) {
      var position = /([\d.]+)%\s*$/.exec(m)
      return { couleur: couleur(m) || { hex: '#FFFFFF', alpha: 0 }, position: position ? parseFloat(position[1]) : null }
    })
    if (arrets.length < 2) return null
    if (arrets[0].position === null) arrets[0].position = 0
    if (arrets[arrets.length - 1].position === null) arrets[arrets.length - 1].position = 100
    // Les arrets sans position se repartissent entre leurs voisins.
    for (var k = 1; k < arrets.length - 1; k++) {
      if (arrets[k].position !== null) continue
      var suivant = k
      while (arrets[suivant].position === null) suivant++
      var pas = (arrets[suivant].position - arrets[k - 1].position) / (suivant - k + 1)
      for (var j = k; j < suivant; j++) arrets[j].position = arrets[k - 1].position + pas * (j - k + 1)
    }
    var radians = (angle * Math.PI) / 180
    var dx = Math.sin(radians)
    var dy = -Math.cos(radians)
    var longueur = Math.abs(b.width * dx) + Math.abs(b.height * dy)
    var cx = b.left + b.width / 2
    var cy = b.top + b.height / 2
    return '<linearGradient id="' + identifiant + '" gradientUnits="userSpaceOnUse"' +
      ' x1="' + nombre(cx - (dx * longueur) / 2) + '" y1="' + nombre(cy - (dy * longueur) / 2) + '"' +
      ' x2="' + nombre(cx + (dx * longueur) / 2) + '" y2="' + nombre(cy + (dy * longueur) / 2) + '">' +
      arrets.map(function (a) {
        return '<stop offset="' + nombre(a.position) + '%" stop-color="' + a.couleur.hex + '"' + (a.couleur.alpha < 1 ? ' stop-opacity="' + nombre(a.couleur.alpha) + '"' : '') + '/>'
      }).join('') + '</linearGradient>'
  }

  function exporteur() {
    var definitions = []
    var noms = {}
    var suite = 0

    function identifiant(nom) {
      var base = String(nom).replace(/\s+/g, '_').replace(/[^\wÀ-ɏ.·-]/g, '') || 'calque'
      if (/^[\d.-]/.test(base)) base = '_' + base
      noms[base] = (noms[base] || 0) + 1
      return noms[base] > 1 ? base + '_' + noms[base] : base
    }

    function boite(el, s, b) {
      var sortie = ''
      var rayon = rayonDe(s, b)
      var forme = function (retrait, extra) {
        return '<rect x="' + nombre(b.left + retrait) + '" y="' + nombre(b.top + retrait) + '" width="' + nombre(Math.max(0, b.width - retrait * 2)) +
          '" height="' + nombre(Math.max(0, b.height - retrait * 2)) + '"' + (rayon > 0 ? ' rx="' + nombre(Math.max(0, rayon - retrait)) + '"' : '') + extra + '/>'
      }
      var uni = couleur(s.backgroundColor)
      if (uni) sortie += forme(0, peinture('fill', uni))
      var image = s.backgroundImage
      if (image && image !== 'none') {
        var photo = /url\("?(data:image\/[^")]+)"?\)/.exec(image)
        if (photo) {
          sortie += '<image x="' + nombre(b.left) + '" y="' + nombre(b.top) + '" width="' + nombre(b.width) + '" height="' + nombre(b.height) +
            '" preserveAspectRatio="xMidYMid meet" href="' + photo[1] + '"/>'
        } else {
          var cle = 'degrade' + ++suite
          var definition = degrade(image, b, cle)
          if (definition) {
            definitions.push(definition)
            sortie += forme(0, ' fill="url(#' + cle + ')"')
          }
        }
      }
      var bord = parseFloat(s.borderTopWidth)
      var teinte = bord > 0 && s.borderTopStyle !== 'none' ? couleur(s.borderTopColor) : null
      if (teinte) sortie += forme(bord / 2, ' fill="none"' + peinture('stroke', teinte) + ' stroke-width="' + nombre(bord) + '"')
      var filet = parseFloat(s.outlineWidth)
      var encre = filet > 0 && s.outlineStyle !== 'none' ? couleur(s.outlineColor) : null
      if (encre) {
        var recul = -(parseFloat(s.outlineOffset) || 0) + filet / 2
        sortie += forme(recul, ' fill="none"' + peinture('stroke', encre) + ' stroke-width="' + nombre(filet) + '"' +
          (s.outlineStyle === 'dashed' ? ' stroke-dasharray="' + nombre(filet * 3) + ' ' + nombre(filet * 2) + '"' : ''))
      }
      // Une ombre ne se traduit pas : un filet tres leger garde le bord du calque visible.
      if (!teinte && !encre && s.boxShadow && s.boxShadow !== 'none') {
        sortie += forme(0.25, ' fill="none" stroke="#1B2340" opacity="0.12" stroke-width="0.5"')
      }
      return sortie
    }

    // La hauteur de l oeil au-dessus de la ligne de base, pour poser un texte.
    function metriques(fenetre, s) {
      var toileMesure = fenetre.document.createElement('canvas').getContext('2d')
      toileMesure.font = s.fontStyle + ' ' + s.fontWeight + ' ' + s.fontSize + ' ' + s.fontFamily
      var m = toileMesure.measureText('Hg')
      var monte = m.fontBoundingBoxAscent || parseFloat(s.fontSize) * 0.9
      var descend = m.fontBoundingBoxDescent || parseFloat(s.fontSize) * 0.25
      return { monte: monte, descend: descend }
    }

    function attributsTexte(s) {
      var c = couleur(s.color) || { hex: '#000000', alpha: 1 }
      var approche = parseFloat(s.letterSpacing)
      return ' font-family="' + POLICE_EXPORT + '" font-size="' + nombre(parseFloat(s.fontSize)) + '" font-weight="' + s.fontWeight + '"' +
        (approche ? ' letter-spacing="' + nombre(approche) + '"' : '') + peinture('fill', c)
    }

    // Les textes d un element, ligne par ligne. Pour un calque de texte, tous
    // ses fragments (un mot en gras garde sa graisse) ; pour un cadre, seulement
    // le texte pose directement dedans, ses enfants etant des calques a part.
    function textes(el, fenetre, profond) {
      var page = el.ownerDocument
      var sortie = ''
      var fragments = []
      if (profond) {
        var marcheur = page.createTreeWalker(el, 4)
        while (marcheur.nextNode()) fragments.push(marcheur.currentNode)
      } else {
        for (var f = el.firstChild; f; f = f.nextSibling) if (f.nodeType === 3) fragments.push(f)
      }
      fragments.forEach(function (n) {
        if (!n.nodeValue.trim()) return
        var s = fenetre.getComputedStyle(n.parentElement)
        if (s.visibility === 'hidden' || s.opacity === '0') return
        // Un texte reserve aux lecteurs d ecran tient dans un point : il ne se dessine pas.
        var place = n.parentElement.getBoundingClientRect()
        if (place.width <= 1 && place.height <= 1) return
        var m = metriques(fenetre, s)
        var plage = page.createRange()
        var lignes = []
        var ligne = null
        for (var i = 0; i < n.nodeValue.length; i++) {
          plage.setStart(n, i)
          plage.setEnd(n, i + 1)
          var r = plage.getClientRects()[0]
          if (!r || !r.width) continue
          if (!ligne || Math.abs(r.top - ligne.haut) > r.height * 0.5) {
            ligne = { haut: r.top, gauche: r.left, hauteur: r.height, texte: '' }
            lignes.push(ligne)
          }
          ligne.texte += n.nodeValue.charAt(i)
        }
        lignes.forEach(function (l) {
          var texte = l.texte.replace(/\s+$/, '')
          if (!texte) return
          var base = l.haut + (l.hauteur * m.monte) / (m.monte + m.descend)
          sortie += '<text x="' + nombre(l.gauche) + '" y="' + nombre(base) + '"' + attributsTexte(s) + ' xml:space="preserve">' + xml(texte) + '</text>'
        })
      })
      return sortie
    }

    function saisie(el, s, b, fenetre) {
      var texte = el.value || el.getAttribute('placeholder') || ''
      if (!texte) return ''
      var m = metriques(fenetre, s)
      var encre = el.value ? s : fenetre.getComputedStyle(el, '::placeholder')
      var c = couleur(encre.color) || { hex: '#64748B', alpha: 1 }
      return '<text x="' + nombre(b.left + parseFloat(s.paddingLeft)) + '" y="' + nombre(b.top + (b.height + m.monte - m.descend) / 2) + '"' +
        ' font-family="' + POLICE_EXPORT + '" font-size="' + nombre(parseFloat(s.fontSize)) + '" font-weight="' + s.fontWeight + '"' + peinture('fill', c) + '>' + xml(texte) + '</text>'
    }

    // Une icone ou un dessin : on en fait une copie dont chaque trait porte
    // ses couleurs en clair, puisque les styles de la page ne suivront pas.
    var FORMES = 'path, rect, circle, ellipse, line, polyline, polygon, text'
    function habiller(originaux, copies, fenetre) {
      for (var i = 0; i < originaux.length; i++) {
        var o = originaux[i]
        var c = copies[i]
        c.removeAttribute('class')
        if (!o.matches(FORMES)) continue
        var s = fenetre.getComputedStyle(o)
        if (s.fill.indexOf('url(') !== 0) {
          var plein = s.fill === 'none' ? null : couleur(s.fill)
          c.setAttribute('fill', plein ? plein.hex : 'none')
          if (plein && plein.alpha < 1) c.setAttribute('fill-opacity', nombre(plein.alpha))
        }
        var trait = s.stroke === 'none' ? null : couleur(s.stroke)
        if (trait) {
          c.setAttribute('stroke', trait.hex)
          if (trait.alpha < 1) c.setAttribute('stroke-opacity', nombre(trait.alpha))
          c.setAttribute('stroke-width', nombre(parseFloat(s.strokeWidth)))
          c.setAttribute('stroke-linecap', s.strokeLinecap)
          c.setAttribute('stroke-linejoin', s.strokeLinejoin)
        } else c.setAttribute('stroke', 'none')
        if (s.opacity !== '1') c.setAttribute('opacity', s.opacity)
        // Le pointille ne servait qu a animer le trace.
        c.removeAttribute('pathLength')
        if (o.tagName.toLowerCase() === 'text') {
          c.setAttribute('font-family', POLICE_EXPORT)
          c.setAttribute('font-size', nombre(parseFloat(s.fontSize)))
          c.setAttribute('font-weight', s.fontWeight)
          if (parseFloat(s.letterSpacing)) c.setAttribute('letter-spacing', nombre(parseFloat(s.letterSpacing)))
        }
      }
    }

    function vecteur(el, b, fenetre) {
      var page = el.ownerDocument
      var copie = el.cloneNode(true)
      habiller(el.querySelectorAll('*'), copie.querySelectorAll('*'), fenetre)
      // Un <use> pointe vers un dessin range ailleurs dans la page : on le recopie ici.
      Array.prototype.forEach.call(copie.querySelectorAll('use'), function (appel) {
        var cible = page.querySelector(appel.getAttribute('href') || appel.getAttribute('xlink:href') || 'none')
        if (!cible) { appel.remove(); return }
        var contenu = cible.cloneNode(true)
        habiller(cible.querySelectorAll('*'), contenu.querySelectorAll('*'), fenetre)
        var groupe = page.createElementNS('http://www.w3.org/2000/svg', 'g')
        while (contenu.firstChild) groupe.appendChild(contenu.firstChild)
        appel.replaceWith(groupe)
      })
      var s = fenetre.getComputedStyle(el)
      var encre = (couleur(s.color) || { hex: '#000000' }).hex
      // Un <svg> imbrique est mal lu par plusieurs editeurs : le dessin devient
      // un groupe, deplace et mis a l echelle de sa boite.
      var vue = (el.getAttribute('viewBox') || '0 0 ' + b.width + ' ' + b.height).split(/[\s,]+/).map(parseFloat)
      var echelle = Math.min(b.width / vue[2], b.height / vue[3])
      var dx = b.left + (b.width - vue[2] * echelle) / 2 - vue[0] * echelle
      var dy = b.top + (b.height - vue[3] * echelle) / 2 - vue[1] * echelle
      var herites = ''
      ;['fill', 'stroke', 'stroke-width', 'stroke-linecap', 'stroke-linejoin'].forEach(function (a) {
        var v = el.getAttribute(a)
        if (v) herites += ' ' + a + '="' + (v === 'currentColor' ? encre : xml(v)) + '"'
      })
      var dedans = ''
      var serie = new XMLSerializer()
      for (var e = copie.firstChild; e; e = e.nextSibling) dedans += serie.serializeToString(e)
      return '<g transform="translate(' + nombre(dx) + ' ' + nombre(dy) + ') scale(' + (Math.round(echelle * 10000) / 10000) + ')"' + herites + '>' +
        dedans.replace(/ xmlns="http:\/\/www\.w3\.org\/2000\/svg"/g, '') + '</g>'
    }

    function calque(noeud) {
      var el = noeud.el
      var fenetre = noeud.cadre.iframe.contentWindow
      var s = fenetre.getComputedStyle(el)
      var b = el.getBoundingClientRect()
      if (noeud.masque) return ''
      var sortie = '<g id="' + xml(identifiant(noeud.nom)) + '"' + (s.opacity !== '1' ? ' opacity="' + s.opacity + '"' : '') + '>'
      if (noeud.type === 'vecteur') sortie += vecteur(el, b, fenetre)
      else {
        sortie += boite(el, s, b)
        if (el.tagName === 'IMG' && el.getAttribute('src')) {
          sortie += '<image x="' + nombre(b.left) + '" y="' + nombre(b.top) + '" width="' + nombre(b.width) + '" height="' + nombre(b.height) +
            '" preserveAspectRatio="xMidYMid slice" href="' + xml(el.src) + '"/>'
        }
        if (el.tagName.toLowerCase() === 'input') sortie += saisie(el, s, b, fenetre)
        else sortie += textes(el, fenetre, noeud.type === 'texte')
        var dedans = ''
        noeud.enfants.forEach(function (e) { dedans += calque(e) })
        // Un element qui coupe ce qui deborde (une zone qui defile) le coupe aussi ici.
        if (dedans && s.overflowY !== 'visible' && noeud.type !== 'ecran') {
          var cle = 'coupe' + ++suite
          var rayon = rayonDe(s, b)
          definitions.push('<clipPath id="' + cle + '"><rect x="' + nombre(b.left) + '" y="' + nombre(b.top) + '" width="' + nombre(b.width) +
            '" height="' + nombre(b.height) + '"' + (rayon > 0 ? ' rx="' + nombre(rayon) + '"' : '') + '/></clipPath>')
          dedans = '<g clip-path="url(#' + cle + ')">' + dedans + '</g>'
        }
        sortie += dedans
      }
      return sortie + '</g>'
    }

    return {
      // Le dessin d un calque et de tout ce qu il contient.
      svg: function (noeud) {
        var b = noeud.el.getBoundingClientRect()
        var fenetre = noeud.cadre.iframe.contentWindow
        var corps = ''
        if (noeud.type === 'ecran') {
          var fond = couleur(fenetre.getComputedStyle(noeud.el.ownerDocument.body).backgroundColor)
          if (fond) corps += '<rect id="Fond" x="0" y="0" width="' + nombre(noeud.cadre.largeur) + '" height="' + nombre(noeud.cadre.hauteur) + '"' + peinture('fill', fond) + '/>'
        }
        corps += calque(noeud)
        var x = noeud.type === 'ecran' ? 0 : b.left
        var y = noeud.type === 'ecran' ? 0 : b.top
        var l = noeud.type === 'ecran' ? noeud.cadre.largeur : b.width
        var h = noeud.type === 'ecran' ? noeud.cadre.hauteur : b.height
        return '<?xml version="1.0" encoding="UTF-8"?>\n' +
          '<svg xmlns="http://www.w3.org/2000/svg" width="' + nombre(l) + '" height="' + nombre(h) + '" viewBox="' + nombre(x) + ' ' + nombre(y) + ' ' + nombre(l) + ' ' + nombre(h) + '">' +
          '<title>' + xml(doc.nom + ' · ' + noeud.nom) + '</title>' +
          (definitions.length ? '<defs>' + definitions.join('') + '</defs>' : '') + corps + '</svg>\n'
      },
    }
  }

  function exporterSvg(noeud) { return exporteur().svg(noeud) }

  function nomDeFichier(texte) {
    return sansAccent(texte).replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '') || 'maquette'
  }

  function telecharger(nom, contenu, type) {
    var lien = document.createElement('a')
    lien.href = URL.createObjectURL(new Blob([contenu], { type: type }))
    lien.download = nom
    document.body.appendChild(lien)
    lien.click()
    lien.remove()
    setTimeout(function () { URL.revokeObjectURL(lien.href) }, 4000)
  }

  var minuterie = 0
  function annoncer(texte) {
    var annonce = id('gd-annonce')
    annonce.textContent = texte
    annonce.hidden = false
    clearTimeout(minuterie)
    minuterie = setTimeout(function () { annonce.hidden = true }, 4200)
  }

  // ---------------------------------------------------------------- ouvrir et enregistrer

  function lireFichier(fichier) {
    if (!fichier) return
    fichier.text().then(function (texte) {
      var nouveau
      try { nouveau = JSON.parse(texte) } catch (e) { throw new Error('Ce fichier n\'est pas un document .god2 lisible.') }
      surPlace = false
      poignee = null
      return ouvrir(nouveau)
    }).then(function () {
      annoncer('« ' + doc.nom + ' » est ouvert.')
    }).catch(function (e) {
      annoncer(e.message || 'Ce fichier n\'a pas pu être ouvert.')
    })
  }

  id('gd-fichier').addEventListener('change', function (e) {
    lireFichier(e.target.files[0])
    e.target.value = ''
  })

  var survols = 0
  window.addEventListener('dragenter', function (e) {
    if (!e.dataTransfer || Array.prototype.indexOf.call(e.dataTransfer.types, 'Files') < 0) return
    survols++
    id('gd-depose').hidden = false
  }, hors)
  window.addEventListener('dragleave', function () {
    if (--survols <= 0) { survols = 0; id('gd-depose').hidden = true }
  }, hors)
  window.addEventListener('dragover', function (e) { e.preventDefault() }, hors)
  window.addEventListener('drop', function (e) {
    e.preventDefault()
    survols = 0
    id('gd-depose').hidden = true
    var fichier = e.dataTransfer && e.dataTransfer.files[0]
    if (!fichier) return
    // Une image se pose sur le cadre ou on la lache ; tout autre fichier s ouvre.
    if (fichier.type.indexOf('image/') === 0) {
      var lieu = cadreSous(e.clientX, e.clientY)
      if (!lieu) return annoncer('Déposez l\'image sur un cadre.')
      return chargerImage(fichier, function (image) { poserImage(lieu, image) })
    }
    lireFichier(fichier)
  }, hors)

  id('gd-image').addEventListener('change', function (e) {
    var fichier = e.target.files[0]
    e.target.value = ''
    if (!fichier) return prendre('deplacer')
    chargerImage(fichier, function (image) {
      imagePrete = image
      annoncer('Cliquez dans un cadre pour y poser l\'image.')
    })
  })
  id('gd-image').addEventListener('cancel', function () { prendre('deplacer') })

  // ---------------------------------------------------------------- l edition
  //
  // Une retouche se fait dans la page d un cadre, sur le calque choisi. Elle
  // est ensuite inscrite : le balisage de l ecran est reecrit dans le
  // document, les autres cadres du meme ecran (l autre format) le reprennent,
  // et les calques sont relus. Une retouche vaut donc pour tous les formats
  // d un ecran. Chaque inscription peut s annuler.

  var historique = []
  var refaits = []
  var modifie = false
  // Vrai tant que le document ouvert est celui que l hote a fourni : c est le
  // seul qu il sait enregistrer a sa place.
  var surPlace = true

  function fenetreDe(el) { return el.ownerDocument.defaultView }
  function cadresDe(ecran) { return cadres.filter(function (c) { return c.ecran === ecran }) }
  function nomDeCadre(ecran, format) { return ecran.nom + ' · ' + format.nom + ' ' + format.largeur }

  // Le chemin d un element depuis la racine de son ecran : son rang parmi les
  // enfants, niveau apres niveau. Il sert a retrouver un calque apres relecture.
  function cheminDe(el, depuis) {
    var chemin = []
    while (el && el !== depuis) {
      chemin.unshift(Array.prototype.indexOf.call(el.parentElement.children, el))
      el = el.parentElement
    }
    return chemin
  }
  function elementA(depuis, chemin) {
    var el = depuis
    for (var i = 0; i < chemin.length && el; i++) el = el.children[chemin[i]]
    return el || null
  }

  // Le balisage d un ecran, tel qu il est dans la page d un cadre.
  function balisageDe(page) {
    var boite = page.createElement('div')
    var repere = repereDe(page)
    for (var n = repere ? repere.nextSibling : page.body.firstChild; n; n = n.nextSibling) boite.appendChild(n.cloneNode(true))
    return boite.innerHTML
  }
  // Remplace le balisage d un ecran dans la page d un cadre.
  function poser(cadre, balisage) {
    var page = cadre.iframe.contentDocument
    var repere = repereDe(page)
    if (!repere) return
    while (repere.nextSibling) repere.nextSibling.remove()
    var plage = page.createRange()
    plage.selectNodeContents(page.body)
    page.body.appendChild(plage.createContextualFragment(balisage))
  }

  // Apres un changement dans un ecran : ses cadres sont remesures et relus,
  // et le calque a garder choisi est retrouve par son chemin.
  function relireEcran(ecran, cadre, chemin) {
    cadresDe(ecran).forEach(function (c) { ajusterHauteur(c); relire(c) })
    reindexer()
    disposer()
    survol = null
    var el = cadre && chemin ? elementA(cadre.racine.el, chemin) : null
    choisir((el && noeudDe.get(el)) || null)
    dessinerComposants()
    appliquer()
  }

  function noterModifie(oui) {
    modifie = oui
    id('gd-nom-fichier').parentNode.dataset.modifie = String(oui)
    if (oui) garderBrouillon()
  }

  // Inscrit dans le document ce qui vient d etre fait dans la page d un cadre.
  // `temoin` est le balisage de la page avant la retouche : s il n a pas
  // change, il n y a rien a inscrire.
  function inscrire(cadre, temoin, aGarder) {
    var page = cadre.iframe.contentDocument
    var apres = balisageDe(page)
    if (apres === temoin) return false
    var depuis = racineDe(page)
    var chemin = aGarder && depuis.contains(aGarder) ? cheminDe(aGarder, depuis) : null
    historique.push({ ecran: cadre.ecran, avant: cadre.ecran.balisage, apres: apres })
    if (historique.length > 60) historique.shift()
    refaits = []
    cadre.ecran.balisage = apres
    cadresDe(cadre.ecran).forEach(function (c) { if (c !== cadre) poser(c, apres) })
    relireEcran(cadre.ecran, cadre, chemin)
    noterModifie(true)
    return true
  }

  // Une retouche d un coup : `faire` modifie la page et rend l element a
  // garder choisi (ou rien).
  function retoucher(cadre, faire) {
    var temoin = balisageDe(cadre.iframe.contentDocument)
    return inscrire(cadre, temoin, faire())
  }

  function retablir(pas, versAvant) {
    if (pas.liste) {
      doc.ecrans = (versAvant ? pas.avant : pas.apres).slice()
      noterModifie(true)
      return monter()
    }
    if (pas.nom) return nommerEcran(pas.ecran, versAvant ? pas.avant : pas.apres)
    var balisage = versAvant ? pas.avant : pas.apres
    pas.ecran.balisage = balisage
    cadresDe(pas.ecran).forEach(function (c) { poser(c, balisage) })
    relireEcran(pas.ecran, null, null)
    noterModifie(true)
  }
  function annuler() {
    var pas = historique.pop()
    if (!pas) return annoncer('Rien à annuler.')
    refaits.push(pas)
    retablir(pas, true)
  }
  function refaire() {
    var pas = refaits.pop()
    if (!pas) return annoncer('Rien à rétablir.')
    historique.push(pas)
    retablir(pas, false)
  }

  // ---- Deplacer et dimensionner

  // Le decalage deja pose sur un element (la propriete CSS translate).
  function decalage(el) {
    var t = fenetreDe(el).getComputedStyle(el).translate
    if (!t || t === 'none') return { x: 0, y: 0 }
    var p = t.split(' ').map(parseFloat)
    return { x: p[0] || 0, y: p[1] || 0 }
  }
  // Un element "en ligne" ne se deplace ni ne se dimensionne : il devient un
  // bloc en ligne, qui garde sa place dans le texte.
  function liberer(el) {
    if (fenetreDe(el).getComputedStyle(el).display === 'inline') el.style.display = 'inline-block'
  }
  function deplacer(el, depart, dx, dy) {
    liberer(el)
    el.style.translate = arrondi(depart.x + dx) + 'px ' + arrondi(depart.y + dy) + 'px'
  }
  // Les mesures d un element : sa largeur et sa hauteur en CSS, et celles de sa boite.
  function mesures(el) {
    var s = fenetreDe(el).getComputedStyle(el)
    var b = el.getBoundingClientRect()
    return { l: parseFloat(s.width) || b.width, h: parseFloat(s.height) || b.height, bl: b.width, bh: b.height }
  }
  // Donne a la boite d un element la largeur ou la hauteur voulue (null : inchangee).
  function tailler(el, depart, largeur, hauteur) {
    liberer(el)
    if (largeur !== null) el.style.width = Math.max(1, arrondi(depart.l + largeur - depart.bl)) + 'px'
    if (hauteur !== null) el.style.height = Math.max(1, arrondi(depart.h + hauteur - depart.bh)) + 'px'
    // Dans une rangee souple, la taille demandee doit l emporter.
    var parent = el.parentElement
    if (parent && fenetreDe(el).getComputedStyle(parent).display.indexOf('flex') >= 0) el.style.flex = 'none'
  }

  // Tire un bord ou un coin : il suit le pointeur, le bord oppose reste en
  // place. `garde` conserve les proportions (Maj), `centre` dimensionne
  // autour du milieu (Alt). On repart chaque fois du style de depart : lacher
  // Maj ou Alt en cours de geste ne laisse rien derriere.
  function dimensionner(prise, depart, dx, dy, garde, centre) {
    var el = choix.el
    var m = depart.mesures
    if (depart.style === null) el.removeAttribute('style')
    else if (depart.style !== undefined) el.setAttribute('style', depart.style)
    var ouest = prise.indexOf('w') >= 0
    var est = prise.indexOf('e') >= 0
    var nord = prise.indexOf('n') >= 0
    var sud = prise.indexOf('s') >= 0
    var l = est ? m.bl + dx : ouest ? m.bl - dx : null
    var h = sud ? m.bh + dy : nord ? m.bh - dy : null
    if (centre) {
      if (l !== null) l = m.bl + (l - m.bl) * 2
      if (h !== null) h = m.bh + (h - m.bh) * 2
    }
    if (garde && m.bl > 0 && m.bh > 0) {
      var rapport = m.bl / m.bh
      if (l !== null && h !== null) { if (l / m.bl > h / m.bh) h = l / rapport; else l = h * rapport }
      else if (l !== null) h = l / rapport
      else l = h * rapport
    }
    // Un calque ne se retourne pas : il s arrete a un pixel. Et il tombe sur des pixels entiers.
    if (l !== null) l = Math.max(1, Math.round(l))
    if (h !== null) h = Math.max(1, Math.round(h))
    tailler(el, m, l, h)
    // Ce que la boite prend a gauche ou en haut se rattrape par un decalage.
    var tx = l === null ? 0 : centre || !(est || ouest) ? (m.bl - l) / 2 : ouest ? m.bl - l : 0
    var ty = h === null ? 0 : centre || !(nord || sud) ? (m.bh - h) / 2 : nord ? m.bh - h : 0
    if (ouest || nord || centre || garde) deplacer(el, depart.decalage, tx, ty)
  }

  var CURSEURS = { nw: 'nwse-resize', se: 'nwse-resize', ne: 'nesw-resize', sw: 'nesw-resize', n: 'ns-resize', s: 'ns-resize', e: 'ew-resize', w: 'ew-resize' }

  function retouchable(noeud) { return Boolean(noeud) && noeud.type !== 'ecran' && !noeud.masque }

  // Ce qu on saisit du calque choisi : un coin, ou un bord sur toute sa
  // longueur. Un bord se prend donc aussi de tres pres, quand ses coins sont
  // sortis de la vue.
  function poigneeSous(clientX, clientY) {
    if (!retouchable(choix)) return null
    var boite = toile.getBoundingClientRect()
    var b = boiteEcran(choix)
    if (b.l < 1 && b.h < 1) return null
    var x = clientX - boite.left - b.x
    var y = clientY - boite.top - b.y
    var dehors = 7
    if (x < -dehors || y < -dehors || x > b.l + dehors || y > b.h + dehors) return null
    // Vers l interieur, la prise ne mange jamais plus du quart du calque :
    // le milieu reste a qui veut le deplacer.
    var dx = Math.min(5, b.l / 4)
    var dy = Math.min(5, b.h / 4)
    var haut = y <= dy
    var bas = y >= b.h - dy
    var gauche = x <= dx
    var droite = x >= b.l - dx
    if (!haut && !bas && !gauche && !droite) return null
    // Pres d un coin, on tient les deux bords a la fois.
    var cx = Math.max(dx, Math.min(10, b.l / 3))
    var cy = Math.max(dy, Math.min(10, b.h / 3))
    var vertical = haut ? 'n' : bas ? 's' : y <= cy ? 'n' : y >= b.h - cy ? 's' : ''
    var horizontal = gauche ? 'w' : droite ? 'e' : x <= cx ? 'w' : x >= b.l - cx ? 'e' : ''
    return vertical + horizontal
  }

  // Le pointeur est-il dans la boite du calque choisi (ses bords compris) ?
  function dansLeChoix(clientX, clientY) {
    if (!retouchable(choix)) return false
    var boite = toile.getBoundingClientRect()
    var b = boiteEcran(choix)
    var x = clientX - boite.left - b.x
    var y = clientY - boite.top - b.y
    return x >= -7 && y >= -7 && x <= b.l + 7 && y <= b.h + 7
  }

  // ---- L arrondi des coins
  //
  // Quatre points ronds, un par coin, se montrent sur le calque choisi des
  // que le pointeur le survole et qu il est assez grand a l ecran (on zoome
  // pour les faire venir sur un petit calque). Tirer un point vers le centre
  // arrondit les quatre coins ; avec Alt, ce coin seulement.

  var pointsRayon = COINS.map(function () {
    var p = document.createElement('span')
    p.className = 'gd-rayon'
    p.hidden = true
    contourChoix.appendChild(p)
    return p
  })
  var dessusChoix = false

  // Un arrondi ne se voit que sur un calque qui peint sa boite.
  function arrondissable(noeud) {
    if (!retouchable(noeud) || noeud.type === 'vecteur') return false
    if (noeud.type === 'image') return true
    var s = fenetreDe(noeud.el).getComputedStyle(noeud.el)
    return Boolean(couleur(s.backgroundColor)) || s.backgroundImage !== 'none' || s.boxShadow !== 'none' ||
      (parseFloat(s.borderTopWidth) > 0 && s.borderTopStyle !== 'none') || s.overflowX !== 'visible'
  }

  function poserRayons() {
    var g = glisse
    var tire = Boolean(g && g.rayon)
    var montre = !contourChoix.hidden && (dessusChoix || tire) && !(g && (g.taille || g.deplace)) && arrondissable(choix)
    var b = montre ? boiteEcran(choix) : null
    if (b && Math.min(b.l, b.h) < 44) montre = false
    if (!montre) { pointsRayon.forEach(function (p) { p.hidden = true }); return }
    var el = choix.el
    var rayons = rayonsDe(fenetreDe(el).getComputedStyle(el), el.getBoundingClientRect())
    pointsRayon.forEach(function (p, i) {
      // Le point se tient au centre de l arrondi, jamais plus pres du coin que 14 pixels.
      var d = Math.min(Math.max(rayons[i] * vue.z, 14), Math.min(b.l, b.h) / 2)
      p.style.left = (COINS[i][1] > 0 ? d : b.l - d) + 'px'
      p.style.top = (COINS[i][2] > 0 ? d : b.h - d) + 'px'
      p.hidden = tire && g.rayon.coin !== i
      p.dataset.tire = String(tire)
    })
  }

  // Le point d arrondi sous le pointeur : son rang dans COINS, ou -1.
  function rayonSous(clientX, clientY) {
    for (var i = 0; i < pointsRayon.length; i++) {
      if (pointsRayon[i].hidden) continue
      var r = pointsRayon[i].getBoundingClientRect()
      if (Math.hypot(clientX - r.left - r.width / 2, clientY - r.top - r.height / 2) <= 9) return i
    }
    return -1
  }

  // Tire un point d arrondi : vers le centre du calque, le rayon grandit.
  function arrondir(g, dx, dy, seul) {
    var c = COINS[g.coin]
    var r = Math.round(Math.max(0, Math.min(g.max, g.depart[g.coin] + (dx * c[1] + dy * c[2]) / 2 / vue.z)))
    var valeurs = g.depart.map(function (v, i) { return seul && i !== g.coin ? arrondi(v) : r })
    var memes = valeurs.every(function (v) { return v === valeurs[0] })
    choix.el.style.borderRadius = memes ? r + 'px' : valeurs.join('px ') + 'px'
    pointsRayon[g.coin].dataset.valeur = String(r)
  }

  // ---- Les aimants
  //
  // Pendant un deplacement, les bords et le milieu du calque s accrochent a
  // ceux de son parent et de ses voisins, et un trait montre l alignement.
  // Ctrl les met de cote le temps du geste.

  var aimants = ['x', 'y'].map(function (axe) {
    var t = document.createElement('span')
    t.className = 'gd-aimant gd-aimant-' + axe
    t.hidden = true
    dessus.appendChild(t)
    return t
  })

  // Les lignes ou s accrocher, et la boite du calque avant le geste.
  function reperes(noeud, aussiDepart) {
    var r = { xs: [], ys: [], boite: noeud.el.getBoundingClientRect() }
    function noter(b) {
      r.xs.push(b.left, b.left + b.width / 2, b.left + b.width)
      r.ys.push(b.top, b.top + b.height / 2, b.top + b.height)
    }
    if (aussiDepart) noter(r.boite)
    if (noeud.parent) {
      noter(boiteDe(noeud.parent))
      noeud.parent.enfants.forEach(function (f) { if (f !== noeud && !f.masque) noter(boiteDe(f)) })
    }
    return r
  }

  // Le repere le plus proche de l une des trois lignes du calque, a portee de `seuil`.
  function accrocher(lignes, cibles, seuil) {
    var meilleur = null
    lignes.forEach(function (l) {
      cibles.forEach(function (c) {
        var e = c - l
        if (Math.abs(e) <= seuil && (!meilleur || Math.abs(e) < Math.abs(meilleur.ecart))) meilleur = { ecart: e, ou: c }
      })
    })
    return meilleur
  }

  function montrerAimants(cadre, x, y) {
    aimants[0].hidden = !x
    aimants[1].hidden = !y
    if (x) {
      aimants[0].style.transform = 'translate(' + Math.round(vue.x + (cadre.x + x.ou) * vue.z) + 'px,' + (vue.y + cadre.y * vue.z) + 'px)'
      aimants[0].style.height = cadre.hauteur * vue.z + 'px'
    }
    if (y) {
      aimants[1].style.transform = 'translate(' + (vue.x + cadre.x * vue.z) + 'px,' + Math.round(vue.y + (cadre.y + y.ou) * vue.z) + 'px)'
      aimants[1].style.width = cadre.largeur * vue.z + 'px'
    }
  }

  // Deplace le calque choisi pendant un glisser : `maj` tient un seul axe,
  // `libre` (Ctrl) coupe les aimants.
  function emporter(d, dx, dy, maj, libre) {
    if (maj) { if (Math.abs(dx) > Math.abs(dy)) dy = 0; else dx = 0 }
    var b = d.reperes.boite
    var ax = null
    var ay = null
    if (!libre) {
      var seuil = 5 / vue.z
      if (!(maj && dx === 0)) ax = accrocher([b.left + dx, b.left + b.width / 2 + dx, b.left + b.width + dx], d.reperes.xs, seuil)
      if (!(maj && dy === 0)) ay = accrocher([b.top + dy, b.top + b.height / 2 + dy, b.top + b.height + dy], d.reperes.ys, seuil)
      if (ax) dx += ax.ecart
      if (ay) dy += ay.ecart
    }
    // Sans aimant, on avance par pixels entiers.
    if (!ax) dx = Math.round(dx)
    if (!ay) dy = Math.round(dy)
    deplacer(choix.el, d.decalage, dx, dy)
    montrerAimants(choix.cadre, ax, ay)
  }

  // ---- Les ecarts
  //
  // Alt enfonce, survoler un autre calque montre ce qui le separe du calque
  // choisi : l espace entre eux, ou la distance a ses bords s il le contient.

  var ecarts = document.createElement('div')
  ecarts.className = 'gd-ecarts'
  dessus.appendChild(ecarts)
  var ecartsVus = null

  // Sur un axe, les intervalles a mesurer entre [a1, a2] et [b1, b2].
  function intervalles(a1, a2, b1, b2) {
    if (a2 <= b1) return [[a2, b1]]
    if (b2 <= a1) return [[b2, a1]]
    var s = []
    if (Math.abs(a1 - b1) >= 0.5) s.push([Math.min(a1, b1), Math.max(a1, b1)])
    if (Math.abs(a2 - b2) >= 0.5) s.push([Math.min(a2, b2), Math.max(a2, b2)])
    return s
  }

  function montrerEcarts(autre) {
    if (!autre || !retouchable(choix) || autre === choix || autre.cadre !== choix.cadre) {
      if (ecartsVus) { ecarts.innerHTML = ''; ecartsVus = null }
      return
    }
    ecartsVus = autre
    var a = boiteDe(choix)
    var b = boiteDe(autre)
    var c = choix.cadre
    var html = ''
    var my = vue.y + (c.y + a.top + a.height / 2) * vue.z
    intervalles(a.left, a.left + a.width, b.left, b.left + b.width).forEach(function (s) {
      html += '<span class="gd-ecart gd-ecart-x" style="left:' + (vue.x + (c.x + s[0]) * vue.z) + 'px;top:' + my + 'px;width:' + (s[1] - s[0]) * vue.z + 'px"><b>' + arrondi(s[1] - s[0]) + '</b></span>'
    })
    var mx = vue.x + (c.x + a.left + a.width / 2) * vue.z
    intervalles(a.top, a.top + a.height, b.top, b.top + b.height).forEach(function (s) {
      html += '<span class="gd-ecart gd-ecart-y" style="left:' + mx + 'px;top:' + (vue.y + (c.y + s[0]) * vue.z) + 'px;height:' + (s[1] - s[0]) * vue.z + 'px"><b>' + arrondi(s[1] - s[0]) + '</b></span>'
    })
    ecarts.innerHTML = html
  }

  // Le pointeur est-il sur le calque choisi, ou sur l un de ses calques ?
  function surLeChoix(clientX, clientY) {
    if (!retouchable(choix)) return false
    for (var n = calqueSous(clientX, clientY); n; n = n.parent) if (n === choix) return true
    return false
  }

  // ---- Les gestes sur le calque choisi

  function aRetoucher() {
    if (!choix) { annoncer('Choisissez d\'abord un calque.'); return null }
    if (choix.type === 'ecran') { annoncer('Un écran se duplique et se supprime depuis le menu Édition.'); return null }
    return choix
  }

  function supprimer() {
    var n = aRetoucher()
    if (n) retoucher(n.cadre, function () { n.el.remove(); return null })
  }

  function couper() {
    if (!aRetoucher()) return
    copier()
    supprimer()
  }

  // Ctrl et une fleche : le calque grandit ou retrecit d un pixel, de dix avec Maj.
  function etirer(sens, pas) {
    var n = choix
    retoucher(n.cadre, function () {
      var m = mesures(n.el)
      tailler(n.el, m, sens[0] ? Math.max(1, m.bl + sens[0] * pas) : null, sens[1] ? Math.max(1, m.bh + sens[1] * pas) : null)
      return n.el
    })
  }

  // Tab passe au calque voisin, dans le meme parent.
  function voisin(sens) {
    if (!choix || !choix.parent) return
    var f = choix.parent.enfants
    choisir(f[(f.indexOf(choix) + sens + f.length) % f.length])
  }

  function dupliquer() {
    var n = aRetoucher()
    if (!n) return
    retoucher(n.cadre, function () {
      var copie = n.el.cloneNode(true)
      copie.removeAttribute('id')
      n.el.after(copie)
      // Une copie posee librement se decale, pour ne pas cacher l original.
      if (fenetreDe(n.el).getComputedStyle(n.el).position === 'absolute') deplacer(copie, decalage(n.el), 16, 16)
      return copie
    })
  }

  var pressePapiers = null
  function copier() {
    var n = aRetoucher()
    if (!n) return
    pressePapiers = n.el.outerHTML
    annoncer('« ' + n.nom + ' » est copié.')
  }
  function coller() {
    if (!pressePapiers) return annoncer('Rien à coller : copiez d\'abord un calque.')
    if (!choix) return annoncer('Choisissez le calque, ou l\'écran, où coller.')
    var cible = choix
    retoucher(cible.cadre, function () {
      var neuf = fabriquer(cible.cadre, pressePapiers)
      neuf.removeAttribute('id')
      if (cible.type === 'ecran') cible.el.appendChild(neuf)
      else cible.el.after(neuf)
      return neuf
    })
  }

  // L ordre des calques est celui de la page : avancer passe apres le suivant.
  function ordonner(sens) {
    var n = aRetoucher()
    if (!n) return
    retoucher(n.cadre, function () {
      var voisin = sens > 0 ? n.el.nextElementSibling : n.el.previousElementSibling
      if (voisin) { if (sens > 0) voisin.after(n.el); else voisin.before(n.el) }
      return n.el
    })
  }

  // Un calque masque garde sa place dans l arbre : on peut le remontrer.
  function basculerMasque(n) {
    if (!n || n.type === 'ecran') return
    retoucher(n.cadre, function () {
      var el = n.el
      if (el.hasAttribute('data-masque')) {
        el.style.display = el.getAttribute('data-masque')
        el.removeAttribute('data-masque')
      } else {
        el.setAttribute('data-masque', el.style.display)
        el.style.display = 'none'
      }
      return el
    })
  }

  function nommerEcran(ecran, nom) {
    ecran.nom = nom
    cadresDe(ecran).forEach(function (c) {
      c.nom = nomDeCadre(ecran, c.format)
      c.etiquette.textContent = c.nom
      if (c.racine) c.racine.nom = court(c.nom)
    })
    dessinerArbre()
    dessinerFiche()
    noterModifie(true)
  }
  function renommer(n, nom) {
    nom = String(nom).trim()
    if (n.type === 'ecran') {
      var ecran = n.cadre.ecran
      if (!nom || nom === ecran.nom) return dessinerArbre()
      historique.push({ nom: true, ecran: ecran, avant: ecran.nom, apres: nom })
      refaits = []
      return nommerEcran(ecran, nom)
    }
    var fait = retoucher(n.cadre, function () {
      if (nom) n.el.setAttribute('data-nom', nom)
      else n.el.removeAttribute('data-nom')
      return n.el
    })
    if (!fait) dessinerArbre()
  }

  // Renommer sur place, dans l arbre des calques.
  function saisirNom(n) {
    if (!n) return
    var rang = id('rang-' + n.id)
    var nom = rang && rang.querySelector('.gd-rang-nom')
    if (!nom) return
    var depart = n.type === 'ecran' ? n.cadre.ecran.nom : n.nom
    var champ = document.createElement('input')
    champ.className = 'gd-rang-champ'
    champ.setAttribute('aria-label', 'Nom du calque')
    champ.value = depart
    nom.replaceWith(champ)
    champ.focus()
    champ.select()
    var fini = false
    var finir = function (garder) {
      if (fini) return
      fini = true
      if (garder && champ.value.trim() !== depart) renommer(n, champ.value)
      else dessinerArbre()
    }
    champ.addEventListener('keydown', function (e) {
      e.stopPropagation()
      if (e.key === 'Enter') finir(true)
      else if (e.key === 'Escape') finir(false)
    })
    champ.addEventListener('blur', function () { finir(true) })
  }

  // ---- Ecrire dans un calque de texte
  //
  // Les cadres ne recoivent ni clavier ni script : on ecrit dans un champ pose
  // par-dessus le calque, a sa place et dans sa typographie, et le texte est
  // recopie dans la page au fil de la frappe.

  var ecriture = null

  // Ce qui porte le texte d un element : un attribut pour une saisie, son
  // contenu s il n a que du texte, sinon son premier fragment de texte.
  function porteurDe(el) {
    if (el.tagName === 'INPUT') {
      var attribut = el.getAttribute('value') ? 'value' : 'placeholder'
      return {
        lire: function () { return el.getAttribute(attribut) || '' },
        ecrire: function (t) { el.setAttribute(attribut, t); if (attribut === 'value') el.value = t },
      }
    }
    if (!el.firstElementChild) {
      return { lire: function () { return el.textContent }, ecrire: function (t) { el.textContent = t } }
    }
    for (var n = el.firstChild; n; n = n.nextSibling) {
      if (n.nodeType !== 3 || !n.nodeValue.trim()) continue
      var fragment = n
      // Les espaces qui le separent de ses voisins comptent : on les garde.
      var avant = /^\s*/.exec(fragment.nodeValue)[0]
      var apres = /\s*$/.exec(fragment.nodeValue)[0]
      return {
        lire: function () { return fragment.nodeValue.trim() },
        ecrire: function (t) { fragment.nodeValue = avant + t + apres },
      }
    }
    return null
  }

  function ecrire(noeud) {
    if (ecriture) finirEcriture(true)
    if (!retouchable(noeud) || !(noeud.type === 'texte' || aDuTexte(noeud.el))) return false
    var el = noeud.el
    var porteur = porteurDe(el)
    if (!porteur) return false
    var champ = document.createElement('div')
    champ.className = 'gd-ecriture'
    champ.setAttribute('contenteditable', 'plaintext-only')
    if (champ.contentEditable !== 'plaintext-only') champ.setAttribute('contenteditable', 'true')
    champ.setAttribute('role', 'textbox')
    champ.setAttribute('aria-label', 'Texte du calque')
    champ.textContent = porteur.lire()
    ecriture = {
      noeud: noeud, el: el, porteur: porteur, champ: champ, depart: porteur.lire(),
      temoin: balisageDe(el.ownerDocument), visible: el.style.visibility, saisie: el.tagName === 'INPUT',
    }
    // Le texte de la page s efface le temps de l ecriture : on ne voit que le champ.
    if (!ecriture.saisie) el.style.visibility = 'hidden'
    dessus.appendChild(champ)
    placerEcriture()
    champ.focus()
    var plage = document.createRange()
    plage.selectNodeContents(champ)
    var selection = window.getSelection()
    selection.removeAllRanges()
    selection.addRange(plage)
    champ.addEventListener('input', function () {
      if (!ecriture) return
      porteur.ecrire(texteDuChamp(champ))
      placerEcriture()
      poserContour(contourChoix, choix)
    })
    champ.addEventListener('keydown', function (e) {
      e.stopPropagation()
      if (e.key === 'Escape') finirEcriture(false)
      else if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); finirEcriture(true) }
    })
    champ.addEventListener('blur', function () { finirEcriture(true) })
    return true
  }

  function texteDuChamp(champ) { return champ.innerText.replace(/\n+$/, '') }

  function placerEcriture() {
    var e = ecriture
    var s = fenetreDe(e.el).getComputedStyle(e.el)
    var b = boiteMonde(e.noeud)
    var z = vue.z
    var c = e.champ.style
    var taille = parseFloat(s.fontSize)
    var plusieursLignes = b.hauteur > taille * 2.2 && s.whiteSpace !== 'nowrap'
    c.left = vue.x + b.x * z + 'px'
    c.top = vue.y + b.y * z + 'px'
    c.minWidth = b.largeur * z + 'px'
    c.minHeight = b.hauteur * z + 'px'
    // Un paragraphe garde sa largeur et ses retours a la ligne ; un libelle s allonge.
    c.maxWidth = plusieursLignes ? b.largeur * z + 1 + 'px' : 'none'
    c.whiteSpace = plusieursLignes ? 'pre-wrap' : 'pre'
    c.fontFamily = s.fontFamily
    c.fontSize = taille * z + 'px'
    c.fontWeight = s.fontWeight
    c.fontStyle = s.fontStyle
    c.letterSpacing = s.letterSpacing === 'normal' ? 'normal' : parseFloat(s.letterSpacing) * z + 'px'
    c.lineHeight = s.lineHeight === 'normal' ? 'normal' : parseFloat(s.lineHeight) * z + 'px'
    c.textAlign = s.textAlign
    c.textTransform = s.textTransform
    c.color = e.saisie ? '' : s.color
    c.padding = ['Top', 'Right', 'Bottom', 'Left'].map(function (cote) { return (parseFloat(s['padding' + cote]) || 0) * z + 'px' }).join(' ')
    e.champ.dataset.saisie = String(e.saisie)
  }

  function finirEcriture(garder) {
    var e = ecriture
    if (!e) return
    ecriture = null
    var texte = texteDuChamp(e.champ)
    e.champ.remove()
    if (!e.saisie) {
      e.el.style.visibility = e.visible
      if (!e.el.getAttribute('style')) e.el.removeAttribute('style')
    }
    e.porteur.ecrire(garder ? texte : e.depart)
    if (!inscrire(e.noeud.cadre, e.temoin, e.el)) poserContour(contourChoix, choix)
  }

  // ---- Dessiner : cadre, formes, trait, trace, texte, image
  //
  // Ce qu on dessine est pose a la racine de l ecran, a sa place exacte, avec
  // ses styles sur lui : il ne depend d aucune feuille de style du document.

  var DESSIN = { cadre: true, forme: true, ellipse: true, trait: true, plume: true, texte: true, image: true }
  var ENCRE = '#121212'
  // R une seconde fois : le rectangle a venir aura les coins arrondis.
  var arrondie = false
  var esquisse = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
  esquisse.setAttribute('class', 'gd-esquisse')
  esquisse.innerHTML = '<path/>'
  esquisse.style.display = 'none'
  dessus.appendChild(esquisse)

  // Le cadre sous un point de la fenetre, et ce point dans sa page.
  function cadreSous(clientX, clientY) {
    var boite = toile.getBoundingClientRect()
    var mx = (clientX - boite.left - vue.x) / vue.z
    var my = (clientY - boite.top - vue.y) / vue.z
    for (var i = cadres.length - 1; i >= 0; i--) {
      var c = cadres[i]
      if (c.racine && mx >= c.x && my >= c.y && mx <= c.x + c.largeur && my <= c.y + c.hauteur) return { cadre: c, x: mx - c.x, y: my - c.y }
    }
    return null
  }
  function pointDans(cadre, clientX, clientY) {
    var boite = toile.getBoundingClientRect()
    return { x: (clientX - boite.left - vue.x) / vue.z - cadre.x, y: (clientY - boite.top - vue.y) / vue.z - cadre.y }
  }
  // Un point de la page d un cadre, sur la toile.
  function surToile(cadre, p) { return (vue.x + (cadre.x + p.x) * vue.z) + ' ' + (vue.y + (cadre.y + p.y) * vue.z) }

  function fabriquer(cadre, html) {
    var page = cadre.iframe.contentDocument
    var plage = page.createRange()
    plage.selectNodeContents(page.body)
    return plage.createContextualFragment(html).firstElementChild
  }

  // Pose un nouvel element a la racine de l ecran. `place` est en pixels dans
  // la page ; la racine devient le repere de ce qu on y pose librement.
  function poserNeuf(cadre, balise, place, styles, contenu, attributs) {
    var depuis = cadre.racine.el
    if (fenetreDe(depuis).getComputedStyle(depuis).position === 'static') depuis.style.position = 'relative'
    var b = depuis.getBoundingClientRect()
    var css = 'position:absolute;left:' + arrondi(place.x - b.left - depuis.clientLeft) + 'px;top:' + arrondi(place.y - b.top - depuis.clientTop) + 'px;' +
      (place.l !== undefined ? 'width:' + arrondi(place.l) + 'px;height:' + arrondi(place.h) + 'px;' : '') + (styles || '')
    var el = fabriquer(cadre, '<' + balise + ' ' + (attributs || '') + ' style="' + css + '">' + (contenu || '') + '</' + balise + '>')
    depuis.appendChild(el)
    return el
  }

  // Un trace : des points de la page, dans un dessin a leur mesure.
  function poserTrace(cadre, points, ferme, nom) {
    var xs = points.map(function (p) { return p.x })
    var ys = points.map(function (p) { return p.y })
    var x = Math.min.apply(null, xs)
    var y = Math.min.apply(null, ys)
    var l = Math.max(1, Math.max.apply(null, xs) - x)
    var h = Math.max(1, Math.max.apply(null, ys) - y)
    var d = points.map(function (p, i) { return (i ? 'L' : 'M') + arrondi(p.x - x) + ' ' + arrondi(p.y - y) }).join(' ') + (ferme ? ' Z' : '')
    return poserNeuf(cadre, 'svg', { x: x, y: y, l: l, h: h }, 'overflow:visible;color:' + ENCRE,
      '<path vector-effect="non-scaling-stroke" d="' + d + '"></path>',
      'data-nom="' + nom + '" viewBox="0 0 ' + arrondi(l) + ' ' + arrondi(h) + '" preserveAspectRatio="none" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"')
  }

  function dessinerEsquisse(d) {
    esquisse.style.display = d ? '' : 'none'
    if (d) esquisse.firstChild.setAttribute('d', d)
  }

  // L esquisse d un cadre, d une forme ou d un trait, entre deux points.
  function esquisser(t, p) {
    var a = surToile(t.cadre, { x: t.x, y: t.y })
    var b = surToile(t.cadre, p)
    if (outil === 'trait') return dessinerEsquisse('M' + a + ' L' + b)
    var ax = a.split(' ').map(parseFloat)
    var bx = b.split(' ').map(parseFloat)
    var x = Math.min(ax[0], bx[0])
    var y = Math.min(ax[1], bx[1])
    var l = Math.abs(bx[0] - ax[0])
    var h = Math.abs(bx[1] - ax[1])
    if (outil === 'ellipse') {
      return dessinerEsquisse('M' + x + ' ' + (y + h / 2) + ' a' + l / 2 + ' ' + h / 2 + ' 0 1 0 ' + l + ' 0 a' + l / 2 + ' ' + h / 2 + ' 0 1 0 ' + -l + ' 0 Z')
    }
    dessinerEsquisse('M' + x + ' ' + y + ' h' + l + ' v' + h + ' h' + -l + ' Z')
  }

  // Fin du geste : ce qui etait esquisse devient un calque.
  function finirDessin(t, p) {
    dessinerEsquisse(null)
    var x = Math.round(Math.min(t.x, p.x))
    var y = Math.round(Math.min(t.y, p.y))
    var l = Math.round(Math.abs(p.x - t.x))
    var h = Math.round(Math.abs(p.y - t.y))
    // Un simple clic pose une forme a une taille de depart.
    var clic = l < 3 && h < 3
    var cree = outil
    var ronde = arrondie
    retoucher(t.cadre, function () {
      if (cree === 'trait') return poserTrace(t.cadre, clic ? [{ x: t.x, y: t.y }, { x: t.x + 120, y: t.y }] : [{ x: t.x, y: t.y }, p], false, 'Trait')
      if (clic) { x = t.x; y = t.y; l = 120; h = 120 }
      var place = { x: x, y: y, l: l, h: h }
      if (cree === 'cadre') return poserNeuf(t.cadre, 'div', place, 'overflow:hidden;background:#FFFFFF;box-shadow:0 0 0 1px #0000001f', '', 'data-nom="Cadre"')
      if (cree === 'ellipse') return poserNeuf(t.cadre, 'div', place, 'border-radius:50%;background:#D9D9D9', '', 'data-nom="Ellipse"')
      return poserNeuf(t.cadre, 'div', place, 'background:#D9D9D9' + (ronde ? ';border-radius:12px' : ''), '', 'data-nom="Rectangle"')
    })
    prendre('deplacer')
  }

  function poserTexte(lieu) {
    retoucher(lieu.cadre, function () {
      return poserNeuf(lieu.cadre, 'p', { x: lieu.x, y: lieu.y }, 'margin:0;color:' + ENCRE + ';font-size:16px;line-height:1.3;white-space:nowrap', 'Texte')
    })
    prendre('deplacer')
    if (choix) ecrire(choix)
  }

  // La plume : un clic par point, un double-clic ou Entree pour finir, un clic
  // sur le premier point pour fermer le trace.
  var plume = null

  function esquisserPlume(clientX, clientY) {
    if (!plume) return
    var d = plume.points.map(function (p, i) { return (i ? 'L' : 'M') + surToile(plume.cadre, p) }).join(' ')
    if (clientX !== undefined) d += ' L' + surToile(plume.cadre, pointDans(plume.cadre, clientX, clientY))
    dessinerEsquisse(d)
  }
  function pointDePlume(clientX, clientY) {
    if (!plume) {
      var lieu = cadreSous(clientX, clientY)
      if (!lieu) return annoncer('Dessinez à l\'intérieur d\'un cadre.')
      plume = { cadre: lieu.cadre, points: [{ x: lieu.x, y: lieu.y }] }
      return esquisserPlume()
    }
    var p = pointDans(plume.cadre, clientX, clientY)
    var premier = plume.points[0]
    var dernier = plume.points[plume.points.length - 1]
    if (plume.points.length > 2 && Math.hypot(p.x - premier.x, p.y - premier.y) * vue.z < 9) return finirPlume(true)
    // Le second appui d un double-clic ne compte pas pour un point.
    if (Math.hypot(p.x - dernier.x, p.y - dernier.y) * vue.z >= 3) plume.points.push(p)
    esquisserPlume()
  }
  function finirPlume(ferme) {
    var trace = plume
    plume = null
    dessinerEsquisse(null)
    if (!trace) return
    if (trace.points.length > 1) retoucher(trace.cadre, function () { return poserTrace(trace.cadre, trace.points, ferme, 'Tracé') })
    prendre('deplacer')
  }

  // Une image : reduite si elle est tres grande, puis embarquee dans le
  // document. Elle se pose d un clic dans un cadre.
  var imagePrete = null

  function chargerImage(fichier, puis) {
    if (!fichier || fichier.type.indexOf('image/') !== 0) return annoncer('Ce fichier n\'est pas une image.')
    var lecteur = new FileReader()
    lecteur.onload = function () {
      var image = new Image()
      image.onload = function () {
        var l = image.naturalWidth || 300
        var h = image.naturalHeight || 300
        var adresse = lecteur.result
        var reduction = Math.min(1, 1600 / Math.max(l, h))
        // Un dessin vectoriel reste tel quel ; une photo est reduite et compressee.
        if (fichier.type !== 'image/svg+xml' && (reduction < 1 || adresse.length > 400000)) {
          var feuille = document.createElement('canvas')
          feuille.width = Math.round(l * reduction)
          feuille.height = Math.round(h * reduction)
          feuille.getContext('2d').drawImage(image, 0, 0, feuille.width, feuille.height)
          adresse = feuille.toDataURL('image/webp', 0.88)
        }
        puis({ adresse: adresse, l: l, h: h })
      }
      image.onerror = function () { annoncer('Cette image n\'a pas pu être lue.') }
      image.src = lecteur.result
    }
    lecteur.readAsDataURL(fichier)
  }
  function poserImage(lieu, image) {
    var echelle = Math.min(1, 480 / image.l)
    retoucher(lieu.cadre, function () {
      return poserNeuf(lieu.cadre, 'img', { x: lieu.x, y: lieu.y, l: image.l * echelle, h: image.h * echelle }, 'object-fit:cover', '',
        'data-nom="Image" alt="" src="' + image.adresse + '"')
    })
    prendre('deplacer')
  }

  // ---- Les proprietes : la fiche se modifie

  var GRAISSES_CHOIX = [['300', 'Light'], ['400', 'Regular'], ['500', 'Medium'], ['600', 'SemiBold'], ['700', 'Bold']]
  var ALIGNEMENTS = [['left', 'À gauche'], ['center', 'Centré'], ['right', 'À droite']]

  function champ(nom, prop, valeur, grande) {
    return '<div class="gd-case"' + (grande ? ' data-large="true"' : '') + '><dt>' + echapper(nom) + '</dt><dd><input class="gd-champ" type="text" data-prop="' + prop +
      '" value="' + echapper(valeur) + '" aria-label="' + echapper(nom) + '" autocomplete="off" spellcheck="false"></dd></div>'
  }
  function choixDe(nom, prop, valeur, options) {
    var connu = options.some(function (o) { return o[0] === valeur })
    return '<div class="gd-case"><dt>' + echapper(nom) + '</dt><dd><select class="gd-champ" data-prop="' + prop + '" aria-label="' + echapper(nom) + '">' +
      (connu ? '' : '<option selected>' + echapper(valeur) + '</option>') +
      options.map(function (o) { return '<option value="' + o[0] + '"' + (o[0] === valeur ? ' selected' : '') + '>' + o[1] + '</option>' }).join('') + '</select></dd></div>'
  }
  // Une couleur qui se choisit : le pave ouvre le nuancier, le champ recoit de l hexadecimal.
  function champCouleur(nom, prop, c) {
    return '<li class="gd-couleur"><input class="gd-pave gd-pave-choix" type="color" data-prop="' + prop + '" value="' + (c ? c.hex : '#D9D9D9').toLowerCase() +
      '" data-vide="' + !c + '" aria-label="' + echapper(nom) + ', nuancier"><span class="gd-couleur-nom">' + echapper(nom) + '</span>' +
      '<input class="gd-champ gd-champ-hex" type="text" data-prop="' + prop + '" value="' + (c ? c.hex : '') + '" placeholder="Aucune" aria-label="' + echapper(nom) +
      ', en hexadécimal" autocomplete="off" spellcheck="false"></li>'
  }
  function boutons(liste) {
    return '<div class="gd-rangee">' + liste.map(function (b) {
      return '<button type="button" class="gd-bouton" data-action="' + b[0] + '">' + b[1] + '</button>'
    }).join('') + '</div>'
  }

  function nombreSaisi(v) {
    var n = parseFloat(String(v).replace(',', '.'))
    return isFinite(n) ? n : null
  }
  // "#1d46fc", "1D46FC" ou "#14f" ; vide pour retirer la couleur ; null si illisible.
  function hexSaisi(v) {
    v = String(v).trim()
    if (!v) return ''
    if (v.charAt(0) !== '#') v = '#' + v
    if (/^#[0-9a-f]{3}$/i.test(v)) v = '#' + v.charAt(1) + v.charAt(1) + v.charAt(2) + v.charAt(2) + v.charAt(3) + v.charAt(3)
    return /^#[0-9a-f]{6}$/i.test(v) ? v.toUpperCase() : null
  }
  // La couleur choisie garde la transparence de celle qu elle remplace.
  function teinter(hex, ancienne) {
    if (!ancienne || ancienne.alpha >= 1) return hex
    return 'rgb(' + parseInt(hex.slice(1, 3), 16) + ' ' + parseInt(hex.slice(3, 5), 16) + ' ' + parseInt(hex.slice(5, 7), 16) + ' / ' + ancienne.alpha + ')'
  }

  var COULEURS = { fond: true, couleur: true, 'bord-couleur': true }
  var TEXTUELLES = { graisse: true, aligne: true }

  function appliquerProp(noeud, prop, brut) {
    if (prop === 'ecran-nom') return renommer(noeud, brut)
    if (prop === 'ecran-adresse') {
      noeud.cadre.ecran.adresse = String(brut).trim()
      return noterModifie(true)
    }
    if (!retouchable(noeud)) return
    var el = noeud.el
    var s = fenetreDe(el).getComputedStyle(el)
    var b = el.getBoundingClientRect()
    var n = nombreSaisi(brut)
    var hex = COULEURS[prop] ? hexSaisi(brut) : ''
    if (hex === null) return annoncer('Une couleur s\'écrit en hexadécimal, par exemple #1D46FC.')
    if (!COULEURS[prop] && !TEXTUELLES[prop] && n === null) return annoncer('Cette valeur attend un nombre.')
    var fond = couleur(s.backgroundColor)
    var encre = couleur(s.color)
    var bord = parseFloat(s.borderTopWidth) > 0 && s.borderTopStyle !== 'none' ? { epaisseur: parseFloat(s.borderTopWidth), teinte: couleur(s.borderTopColor) } : null
    retoucher(noeud.cadre, function () {
      if (prop === 'x') deplacer(el, decalage(el), n - b.left, 0)
      else if (prop === 'y') deplacer(el, decalage(el), 0, n - b.top)
      else if (prop === 'l') tailler(el, mesures(el), n, null)
      else if (prop === 'h') tailler(el, mesures(el), null, n)
      // Un nombre pour les quatre coins, ou quatre : haut gauche, haut droit, bas droit, bas gauche.
      else if (prop === 'rayon') {
        el.style.borderRadius = String(brut).trim().split(/[\s;]+/).slice(0, 4).map(function (v) { return Math.max(0, nombreSaisi(v) || 0) + 'px' }).join(' ')
      }
      // A zero, le calque sortirait de l arbre : un pour cent le garde a portee.
      else if (prop === 'opacite') el.style.opacity = String(Math.min(100, Math.max(1, n)) / 100)
      else if (prop === 'fond') el.style.background = hex ? teinter(hex, fond) : 'transparent'
      else if (prop === 'couleur') el.style.color = hex ? teinter(hex, encre) : ''
      else if (prop === 'bord-couleur') el.style.border = hex ? (bord ? bord.epaisseur : 1) + 'px solid ' + teinter(hex, bord && bord.teinte) : 'none'
      else if (prop === 'bord') el.style.border = n > 0 ? n + 'px solid ' + (bord && bord.teinte ? bord.teinte.css : ENCRE) : 'none'
      else if (prop === 'corps') el.style.fontSize = Math.max(1, n) + 'px'
      else if (prop === 'graisse') el.style.fontWeight = brut
      else if (prop === 'aligne') el.style.textAlign = brut
      else if (prop === 'trait') el.setAttribute('stroke-width', String(Math.max(0, n)))
      return el
    })
  }

  // Une valeur validee dans la fiche. La fiche est redessinee apres chaque
  // retouche : le champ ou l on allait (Tab) retrouve la main.
  fiche.addEventListener('change', function (e) {
    var saisi = e.target.closest('[data-prop]')
    if (!saisi || !choix) return
    var noeud = choix
    var prop = saisi.dataset.prop
    var valeur = saisi.value
    setTimeout(function () {
      var actif = document.activeElement
      var suite = actif && fiche.contains(actif) && actif.dataset.prop ? actif.dataset.prop : null
      var nuancier = suite && actif.type === 'color'
      appliquerProp(noeud, prop, valeur)
      dessinerFiche()
      if (!suite) return
      var retour = fiche.querySelector('[data-prop="' + suite + '"]' + (nuancier ? '[type="color"]' : ':not([type="color"])'))
      if (retour) { retour.focus(); if (retour.select) retour.select() }
    }, 0)
  })
  // Entree valide sans quitter le champ ; les raccourcis de l atelier ne s y appliquent pas.
  fiche.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && e.target.matches('input.gd-champ')) e.target.blur()
  })

  // ---- Les ecrans : en ajouter, en dupliquer, en supprimer

  function changerEcrans(faire) {
    var avant = doc.ecrans.slice()
    var aVoir = faire()
    historique.push({ liste: true, avant: avant, apres: doc.ecrans.slice() })
    refaits = []
    noterModifie(true)
    return monter().then(function () {
      var premier = aVoir && cadresDe(aVoir)[0]
      if (premier) { choisir(premier.racine); voirChoix() }
    })
  }
  function idEcran() {
    var n = doc.ecrans.length + 1
    while (doc.ecrans.some(function (e) { return e.id === 'ecran-' + n })) n++
    return 'ecran-' + n
  }
  function ecranVise() {
    if (choix) return choix.cadre.ecran
    annoncer('Choisissez d\'abord un calque de l\'écran voulu, ou son titre sur la toile.')
    return null
  }

  // ---- Garder le travail : un brouillon dans le navigateur, puis le fichier

  var CLE_BROUILLON = 'god2-design:brouillon:'
  var attenteBrouillon = 0

  function ecrireBrouillon() {
    clearTimeout(attenteBrouillon)
    attenteBrouillon = 0
    if (!modifie) return
    try { localStorage.setItem(CLE_BROUILLON + doc.nom, JSON.stringify(doc)) } catch (e) { /* trop lourd ou stockage ferme : pas de brouillon */ }
  }
  function garderBrouillon() {
    clearTimeout(attenteBrouillon)
    attenteBrouillon = setTimeout(ecrireBrouillon, 900)
  }
  function lireBrouillon() {
    try { return localStorage.getItem(CLE_BROUILLON + doc.nom) } catch (e) { return null }
  }
  function oublierBrouillon() {
    clearTimeout(attenteBrouillon)
    try { localStorage.removeItem(CLE_BROUILLON + doc.nom) } catch (e) { /* stockage ferme */ }
  }
  // A l ouverture : des retouches gardees pour cette maquette sont proposees.
  function proposerReprise() {
    var brouillon = lireBrouillon()
    id('gd-reprise').hidden = !brouillon || brouillon === JSON.stringify(doc)
  }
  // En quittant la page, le brouillon en attente est ecrit tout de suite.
  window.addEventListener('pagehide', function () { if (attenteBrouillon) ecrireBrouillon() }, hors)

  var poignee = null
  var TYPE_GOD2 = [{ description: 'Maquette god2', accept: { 'application/json': ['.god2'] } }]

  // Enregistre la maquette : a sa place chez un hote qui sait le faire, sinon
  // dans un fichier choisi une fois, sinon dans les telechargements.
  function enregistrer(copie) {
    if (ecriture) finirEcriture(true)
    var contenu = JSON.stringify(doc)
    var echec = function () { annoncer('L\'enregistrement a échoué. Essayez « Enregistrer une copie ».') }
    if (!copie && surPlace && hote && hote.enregistrer) {
      return hote.enregistrer(contenu).then(function () {
        noterModifie(false)
        oublierBrouillon()
        annoncer('La maquette est enregistrée.')
      }, echec)
    }
    if (!window.showSaveFilePicker) {
      telecharger(nomDeFichier(doc.nom) + '.god2', contenu, 'application/json')
      noterModifie(false)
      return annoncer('Le fichier .god2 est enregistré dans vos téléchargements.')
    }
    var choisi = poignee && !copie ? Promise.resolve(poignee) : window.showSaveFilePicker({ suggestedName: nomDeFichier(doc.nom) + '.god2', types: TYPE_GOD2 })
    return choisi.then(function (p) {
      if (!copie) poignee = p
      return p.createWritable().then(function (flux) { return flux.write(contenu).then(function () { return flux.close() }) }).then(function () {
        if (!copie) noterModifie(false)
        annoncer('« ' + p.name + ' » est enregistré.')
      })
    }).catch(function (e) {
      if (e && e.name === 'AbortError') return
      // Le navigateur a refuse d ecrire le fichier : il reste le telechargement.
      telecharger(nomDeFichier(doc.nom) + '.god2', contenu, 'application/json')
      annoncer('Le fichier .god2 est enregistré dans vos téléchargements.')
    })
  }

  // ---------------------------------------------------------------- le pointeur sur la toile

  var outil = 'deplacer'
  var espace = false
  var pointeurs = new Map()
  var glisse = null
  var pince = null

  function mainActive(e) { return outil === 'main' || espace || e.button === 1 || e.pointerType === 'touch' }

  capteur.addEventListener('pointerdown', function (e) {
    fermerMenus()
    capteur.setPointerCapture(e.pointerId)
    pointeurs.set(e.pointerId, { x: e.clientX, y: e.clientY })
    if (pointeurs.size === 2) {
      var p = Array.from(pointeurs.values())
      pince = { ecart: Math.hypot(p[0].x - p[1].x, p[0].y - p[1].y), z: vue.z }
      glisse = null
      return
    }
    glisse = { x: e.clientX, y: e.clientY, vx: vue.x, vy: vue.y, bouge: false, main: mainActive(e), toucher: e.pointerType === 'touch' }
    if (glisse.main) { e.preventDefault(); return }
    if (e.button !== 0) return
    if (DESSIN[outil]) {
      // Cadre, forme et trait se tracent d un geste ; plume, texte et image, d un clic.
      if (outil !== 'plume' && outil !== 'texte' && outil !== 'image') {
        glisse.dessin = cadreSous(e.clientX, e.clientY)
        if (!glisse.dessin) annoncer('Dessinez à l\'intérieur d\'un cadre.')
      }
      return
    }
    // Sur le calque choisi : un point l arrondit, un bord ou un coin le
    // dimensionne, le reste le deplace.
    var coin = rayonSous(e.clientX, e.clientY)
    var prise = coin < 0 ? poigneeSous(e.clientX, e.clientY) : null
    // Glisser un calque qui n est pas choisi le choisit et l emporte d un seul geste.
    if (coin < 0 && !prise && !surLeChoix(e.clientX, e.clientY)) {
      var vise = calqueSous(e.clientX, e.clientY)
      if (retouchable(vise)) { choisir(vise); glisse.pris = true }
      else return
    }
    var el = choix.el
    if (coin >= 0) {
      var boiteChoix = el.getBoundingClientRect()
      glisse.rayon = { coin: coin, depart: rayonsDe(fenetreDe(el).getComputedStyle(el), boiteChoix), max: Math.floor(Math.min(boiteChoix.width, boiteChoix.height) / 2) }
    } else if (prise) glisse.taille = { prise: prise, mesures: mesures(el), decalage: decalage(el), style: el.getAttribute('style') }
    else glisse.deplace = { decalage: decalage(el), copie: e.altKey }
    glisse.temoin = balisageDe(el.ownerDocument)
  })

  capteur.addEventListener('pointermove', function (e) {
    if (pointeurs.has(e.pointerId)) pointeurs.set(e.pointerId, { x: e.clientX, y: e.clientY })
    if (pince && pointeurs.size === 2) {
      var p = Array.from(pointeurs.values())
      var boite = toile.getBoundingClientRect()
      var ecart = Math.hypot(p[0].x - p[1].x, p[0].y - p[1].y)
      zoomer(pince.z * (ecart / pince.ecart), (p[0].x + p[1].x) / 2 - boite.left, (p[0].y + p[1].y) / 2 - boite.top)
      return
    }
    if (glisse) {
      var dx = e.clientX - glisse.x
      var dy = e.clientY - glisse.y
      if (Math.abs(dx) + Math.abs(dy) > 4) glisse.bouge = true
      if (!glisse.bouge) return
      if (glisse.main) {
        racine.dataset.glisse = 'true'
        vue.x = glisse.vx + dx
        vue.y = glisse.vy + dy
        appliquer()
      } else if (glisse.dessin) {
        esquisser(glisse.dessin, pointDans(glisse.dessin.cadre, e.clientX, e.clientY))
      } else if (glisse.rayon) {
        contourChoix.dataset.geste = 'rayon'
        arrondir(glisse.rayon, dx, dy, e.altKey)
        poserContour(contourChoix, choix)
      } else if (glisse.taille) {
        // Maj garde les proportions, Alt dimensionne autour du centre.
        contourChoix.dataset.geste = 'taille'
        dimensionner(glisse.taille.prise, glisse.taille, dx / vue.z, dy / vue.z, e.shiftKey, e.altKey)
        poserContour(contourChoix, choix)
      } else if (glisse.deplace) {
        var d = glisse.deplace
        if (!d.reperes) {
          // Alt : une copie reste a la place du calque, et c est lui qu on emporte.
          if (d.copie) { choix.el.before(choix.el.cloneNode(true)); choix.el.removeAttribute('id') }
          d.reperes = reperes(choix, d.copie)
        }
        contourChoix.dataset.geste = 'deplace'
        emporter(d, dx / vue.z, dy / vue.z, e.shiftKey, e.ctrlKey || e.metaKey)
        poserContour(contourChoix, choix)
      }
      return
    }
    if (e.pointerType === 'touch') return
    if (plume) esquisserPlume(e.clientX, e.clientY)
    var libre = outil === 'deplacer' && !espace
    var vise = libre ? calqueSous(e.clientX, e.clientY) : null
    survoler(vise)
    // Les points d arrondi viennent quand le pointeur est sur le calque choisi.
    var dessusAvant = dessusChoix
    dessusChoix = libre && dansLeChoix(e.clientX, e.clientY)
    if (dessusChoix !== dessusAvant) poserRayons()
    var coin = libre ? rayonSous(e.clientX, e.clientY) : -1
    var prise = libre && coin < 0 ? poigneeSous(e.clientX, e.clientY) : null
    capteur.style.cursor = coin >= 0 ? 'pointer' : prise ? CURSEURS[prise] : libre && surLeChoix(e.clientX, e.clientY) ? 'move' : ''
    montrerEcarts(libre && e.altKey ? vise : null)
  })

  function lacher(e) {
    pointeurs.delete(e.pointerId)
    if (pointeurs.size < 2) pince = null
    if (!glisse) return
    var g = glisse
    glisse = null
    racine.dataset.glisse = 'false'
    var leve = e.type === 'pointerup'
    if (g.dessin) return leve ? finirDessin(g.dessin, pointDans(g.dessin.cadre, e.clientX, e.clientY)) : dessinerEsquisse(null)
    contourChoix.dataset.geste = ''
    montrerAimants(null, null, null)
    if ((g.rayon || g.taille || g.deplace) && g.bouge) {
      if (!inscrire(choix.cadre, g.temoin, choix.el)) poserContour(contourChoix, choix)
      return
    }
    if (g.bouge || !leve || e.button === 1 || espace) return
    // Un appui sans deplacement choisit le calque sous le pointeur...
    if (g.pris) return
    if (g.toucher || outil === 'deplacer') return choisir(calqueSous(e.clientX, e.clientY))
    if (g.main) return
    // ... ou, avec un outil de dessin, pose un point, un texte ou une image.
    if (outil === 'plume') return pointDePlume(e.clientX, e.clientY)
    var lieu = cadreSous(e.clientX, e.clientY)
    if (!lieu) { if (outil === 'texte' || outil === 'image') annoncer('Cliquez à l\'intérieur d\'un cadre.'); return }
    if (outil === 'texte') poserTexte(lieu)
    else if (outil === 'image' && imagePrete) {
      var image = imagePrete
      imagePrete = null
      poserImage(lieu, image)
    }
  }
  capteur.addEventListener('pointerup', lacher)
  capteur.addEventListener('pointercancel', lacher)
  capteur.addEventListener('pointerleave', function () {
    if (glisse) return
    survoler(null)
    montrerEcarts(null)
    if (dessusChoix) { dessusChoix = false; poserRayons() }
  })
  // Un double-clic ouvre un texte a l ecriture, ou termine un trace a la plume.
  capteur.addEventListener('dblclick', function (e) {
    if (plume) return finirPlume(false)
    if (outil !== 'deplacer') return
    var noeud = calqueSous(e.clientX, e.clientY)
    if (noeud && noeud !== choix) choisir(noeud)
    if (noeud) ecrire(noeud)
  })

  // La molette deplace la toile ; avec Ctrl (ou un pincement au pave tactile), elle zoome.
  toile.addEventListener('wheel', function (e) {
    if (e.target.closest('.gd-volet')) return
    e.preventDefault()
    var boite = toile.getBoundingClientRect()
    if (e.ctrlKey || e.metaKey) {
      zoomer(vue.z * Math.exp(-e.deltaY * (e.deltaMode ? 0.05 : 0.0022)), e.clientX - boite.left, e.clientY - boite.top)
    } else {
      var pas = e.deltaMode ? 32 : 1
      vue.x -= (e.shiftKey ? e.deltaY : e.deltaX) * pas
      vue.y -= (e.shiftKey ? 0 : e.deltaY) * pas
      appliquer()
    }
  }, { passive: false })

  function prendre(nom) {
    if (plume && nom !== 'plume') { plume = null; dessinerEsquisse(null) }
    outil = nom
    if (nom !== 'forme') arrondie = false
    racine.dataset.outil = nom
    capteur.style.cursor = ''
    document.querySelectorAll('.gd-outil[data-outil]').forEach(function (b) { b.setAttribute('aria-pressed', String(b.dataset.outil === nom)) })
    if (nom !== 'deplacer') survoler(null)
    // L outil Image commence par demander laquelle.
    if (nom === 'image') { imagePrete = null; id('gd-image').click() }
  }

  // ---------------------------------------------------------------- menus, volets, theme

  function fermerMenus(sauf) {
    document.querySelectorAll('.gd-menu').forEach(function (m) {
      if (m.id === sauf) return
      m.hidden = true
      var titre = document.querySelector('[data-menu="' + m.id + '"]')
      if (titre) titre.setAttribute('aria-expanded', 'false')
    })
  }

  function volet(nom, ouvert) {
    var v = id(nom)
    if (ouvert === undefined) ouvert = v.dataset.ouvert !== 'true'
    v.dataset.ouvert = String(ouvert)
    document.querySelectorAll('.gd-barre [aria-controls="' + nom + '"]').forEach(function (b) { b.setAttribute('aria-expanded', String(ouvert)) })
  }

  function montrerOnglet(nom) {
    document.querySelectorAll('.gd-onglet').forEach(function (o) { o.setAttribute('aria-selected', String(o.dataset.onglet === nom)) })
    fiche.hidden = nom !== 'design'
    id('gd-export').hidden = nom !== 'export'
  }

  var ACTIONS = {
    'ouvrir': function () { id('gd-fichier').click() },
    'enregistrer': function () { enregistrer(false) },
    'enregistrer-copie': function () { enregistrer(true) },
    'annuler': annuler,
    'refaire': refaire,
    'copier': copier,
    'couper': couper,
    'coller': coller,
    'dupliquer': dupliquer,
    'supprimer': supprimer,
    'avancer': function () { ordonner(1) },
    'reculer': function () { ordonner(-1) },
    'masquer': function () { if (aRetoucher()) basculerMasque(choix) },
    'renommer': function () {
      if (!choix) return annoncer('Choisissez d\'abord un calque.')
      montrerSection('calques')
      saisirNom(choix)
    },
    'ecrire': function () {
      if (!choix) return annoncer('Choisissez d\'abord un calque de texte.')
      if (!ecrire(choix)) annoncer('Ce calque ne porte pas de texte.')
    },
    'ecran-nouveau': function () {
      changerEcrans(function () {
        var neuf = { id: idEcran(), nom: 'Nouvel écran', balisage: '<div data-nom="Page" style="position:relative;min-height:100vh;background:#FFFFFF"></div>' }
        doc.ecrans.push(neuf)
        return neuf
      })
    },
    'ecran-dupliquer': function () {
      var source = ecranVise()
      if (!source) return
      changerEcrans(function () {
        var copie = {}
        Object.keys(source).forEach(function (cle) { copie[cle] = source[cle] })
        copie.id = idEcran()
        copie.nom = source.nom + ' (copie)'
        doc.ecrans.splice(doc.ecrans.indexOf(source) + 1, 0, copie)
        return copie
      })
    },
    'ecran-supprimer': function () {
      var vise = ecranVise()
      if (!vise) return
      if (doc.ecrans.length < 2) return annoncer('Une maquette garde au moins un écran.')
      changerEcrans(function () { doc.ecrans.splice(doc.ecrans.indexOf(vise), 1) })
    },
    'reprendre': function () {
      var brouillon = lireBrouillon()
      if (!brouillon) return
      var garde = surPlace
      ouvrir(JSON.parse(brouillon))
      surPlace = garde
      noterModifie(true)
      annoncer('Vos retouches sont reprises.')
    },
    'oublier': function () {
      oublierBrouillon()
      id('gd-reprise').hidden = true
    },
    'exporter-choix': function () {
      if (!choix) return ACTIONS['exporter-tout']()
      telecharger(nomDeFichier(choix.cadre.nom + (choix.type === 'ecran' ? '' : ' ' + choix.nom)) + '.svg', exporterSvg(choix), 'image/svg+xml')
      annoncer('« ' + choix.nom + ' » est exporté en SVG.')
    },
    'exporter-tout': function () {
      cadres.forEach(function (c, i) {
        setTimeout(function () { telecharger(nomDeFichier(c.nom) + '.svg', exporterSvg(c.racine), 'image/svg+xml') }, i * 350)
      })
      annoncer(cadres.length + ' cadres exportés en SVG. Le navigateur peut demander d\'autoriser plusieurs téléchargements.')
    },
    'volet-gauche': function () { volet('gd-volet-droit', false); volet('gd-volet-gauche') },
    'volet-droit': function () { volet('gd-volet-gauche', false); volet('gd-volet-droit') },
    'zoom-moins': function () { zoomer(vue.z / 1.25) },
    'zoom-plus': function () { zoomer(vue.z * 1.25) },
    'zoom-ajuster': toutVoir,
    'zoom-choix': voirChoix,
    'zoom-50': function () { zoomer(0.5) },
    'zoom-100': function () { zoomer(1) },
    'zoom-200': function () { zoomer(2) },
    'theme': function () {
      var html = document.documentElement
      html.dataset.theme = html.dataset.theme === 'sombre' ? 'clair' : 'sombre'
      try { localStorage.setItem('god2-design:theme', html.dataset.theme) } catch (e) { /* stockage ferme : le theme ne sera pas retenu */ }
      if (!choix) dessinerFiche()
    },
    'aide': function () { id('gd-aide').showModal() },
    'presenter': function () { presenter(choix ? doc.ecrans.indexOf(choix.cadre.ecran) : 0) },
    'quitter-presentation': function () { quitterPresentation() },
    'presentation-avant': function () { presenter((presente + doc.ecrans.length - 1) % doc.ecrans.length) },
    'presentation-apres': function () { presenter((presente + 1) % doc.ecrans.length) },
  }

  document.addEventListener('click', function (e) {
    var titre = e.target.closest('[data-menu]')
    if (titre) {
      var menu = id(titre.dataset.menu)
      fermerMenus(menu.id)
      menu.hidden = !menu.hidden
      titre.setAttribute('aria-expanded', String(!menu.hidden))
      return
    }
    var bouton = e.target.closest('[data-action], .gd-outil[data-outil], [data-section], [data-onglet]')
    fermerMenus()
    if (!bouton || bouton === racine || bouton.getAttribute('aria-disabled') === 'true') return
    if (bouton.dataset.action) ACTIONS[bouton.dataset.action]()
    else if (bouton.dataset.outil) prendre(bouton.dataset.outil)
    else if (bouton.dataset.section) montrerSection(bouton.dataset.section)
    else if (bouton.dataset.onglet) montrerOnglet(bouton.dataset.onglet)
  }, hors)

  // ---------------------------------------------------------------- la presentation

  var presente = -1
  // Le format presente : l indice d un format du document, ou -1 pour la
  // fenetre entiere. Au depart, le plus etroit (le telephone) si la fenetre
  // est plus large que lui ; sur un telephone, la fenetre.
  var formatPresente = null

  function formatsTries() {
    return (doc.formats || []).map(function (f, i) { return { f: f, i: i } }).sort(function (a, b) { return a.f.largeur - b.f.largeur })
  }
  function poserFormat() {
    var f = formatPresente >= 0 ? doc.formats[formatPresente] : null
    presentationEcran.classList.toggle('gd-au-format', !!f)
    Array.prototype.forEach.call(presentationFormats.children, function (b) {
      b.setAttribute('aria-pressed', String(Number(b.dataset.format) === formatPresente))
    })
    if (!f) {
      presentationEcran.style.cssText = ''
      return
    }
    var marge = 24
    var echelle = Math.min(1, (presentationScene.clientWidth - 2 * marge) / f.largeur, (presentationScene.clientHeight - 2 * marge) / f.hauteur)
    presentationEcran.style.cssText =
      'position:absolute;left:50%;top:50%;width:' + f.largeur + 'px;height:' + f.hauteur + 'px;' +
      'transform:translate(-50%,-50%) scale(' + echelle + ')'
  }
  function remplirFormats() {
    var boutons = formatsTries().map(function (x) {
      return '<button type="button" class="gd-bouton" data-format="' + x.i + '">' + echapper(x.f.nom) + '</button>'
    })
    boutons.push('<button type="button" class="gd-bouton" data-format="-1">Fenêtre</button>')
    presentationFormats.innerHTML = boutons.join('')
  }
  presentationFormats.addEventListener('click', function (e) {
    var b = e.target.closest('[data-format]')
    if (!b) return
    formatPresente = Number(b.dataset.format)
    poserFormat()
  })
  window.addEventListener('resize', function () { if (presente >= 0) poserFormat() })

  // Les liens du prototype (le champ `liens` d un ecran) : comme dans Figma,
  // un clic sur une zone liee ouvre l ecran vise, ou revient au precedent ;
  // un clic ailleurs fait clignoter les zones cliquables. Le script tourne
  // dans la page de l ecran et ne parle a l atelier que par postMessage.
  function scriptLiens(liens) {
    return '(function(){var L=' + JSON.stringify(liens || []).replace(/</g, '\\u003c') + ';' +
      'function ok(el,l){return !l.texte||el.textContent.replace(/\\s+/g," ").indexOf(l.texte)>=0}' +
      'function lien(t){for(var i=0;i<L.length;i++){try{var el=t.closest&&t.closest(L[i].selecteur);' +
      'while(el&&!ok(el,L[i]))el=el.parentElement&&el.parentElement.closest(L[i].selecteur);if(el)return L[i]}catch(_){}}return null}' +
      'function zones(){var z=[];L.forEach(function(l){try{document.querySelectorAll(l.selecteur).forEach(function(el){if(!ok(el,l))return;var b=el.getBoundingClientRect();' +
      'if(b.width&&b.height&&b.bottom>0&&b.top<innerHeight)z.push(b)})}catch(_){}});return z}' +
      'function clignoter(){zones().forEach(function(b){var d=document.createElement("div");' +
      'd.style.cssText="position:fixed;z-index:2147483647;pointer-events:none;left:"+b.left+"px;top:"+b.top+"px;width:"+b.width+"px;height:"+b.height+"px;' +
      'border-radius:10px;background:rgba(13,153,255,.18);box-shadow:inset 0 0 0 2px rgba(13,153,255,.85);transition:opacity .45s .3s";' +
      'document.body.appendChild(d);requestAnimationFrame(function(){requestAnimationFrame(function(){d.style.opacity="0"})});setTimeout(function(){d.remove()},900)})}' +
      'addEventListener("click",function(e){var l=lien(e.target);if(l){e.preventDefault();e.stopPropagation();parent.postMessage({god2:"lien",vers:l.vers},"*")}else clignoter()},true);' +
      'addEventListener("keydown",function(e){if(/^(Escape|ArrowLeft|ArrowRight|Backspace)$/.test(e.key)&&!(e.target.closest&&e.target.closest("input,textarea,[contenteditable]")))parent.postMessage({god2:"touche",touche:e.key},"*")})' +
      '})()'
  }

  // Le chemin suivi par les liens, pour « retour ». Changer d ecran par les
  // fleches ou la barre repart d un chemin vide.
  var chemin = []
  function suivreLien(vers) {
    if (vers === 'retour') {
      if (chemin.length) presenter(chemin.pop(), true)
      return
    }
    var i = -1
    doc.ecrans.some(function (x, k) { if (x.id === vers) { i = k; return true } return false })
    if (i < 0 || i === presente) return
    chemin.push(presente)
    presenter(i, true)
  }
  window.addEventListener('message', function (e) {
    if (presente < 0 || e.source !== presentationEcran.contentWindow || !e.data || typeof e.data !== 'object') return
    if (e.data.god2 === 'lien' && typeof e.data.vers === 'string') suivreLien(e.data.vers)
    else if (e.data.god2 === 'touche') toucheDePresentation(e.data.touche)
  }, hors)
  function toucheDePresentation(touche) {
    if (touche === 'Escape') quitterPresentation()
    else if (touche === 'ArrowRight') ACTIONS['presentation-apres']()
    else if (touche === 'ArrowLeft') ACTIONS['presentation-avant']()
    else if (touche === 'Backspace') suivreLien('retour')
  }

  // Un ecran en vrai, avec ses survols, ses animations, ses scripts et ses
  // liens : a la taille d un format, ou de la fenetre. Sur un telephone, c est
  // la vue de depart.
  function presenter(i, parLien) {
    if (!parLien) chemin = []
    presente = i < 0 ? 0 : i
    var ecran = doc.ecrans[presente]
    presentationTitre.textContent = 'Écran ' + (presente + 1) + ' sur ' + doc.ecrans.length + ' · ' + ecran.nom
    presentation.hidden = false
    if (formatPresente === null) {
      var etroit = formatsTries()[0]
      formatPresente = etroit && window.innerWidth > etroit.f.largeur * 1.5 ? etroit.i : -1
      remplirFormats()
    }
    poserFormat()
    presentationEcran.srcdoc = pageDe(ecran, '', LUMIERE + ';' + scriptLiens(ecran.liens))
    presentation.querySelector('[data-action="quitter-presentation"]').focus()
  }
  function quitterPresentation() {
    presentation.hidden = true
    presentationEcran.srcdoc = ''
    presente = -1
    toutVoir()
  }

  // ---------------------------------------------------------------- le clavier

  var FLECHES = { ArrowLeft: [-1, 0], ArrowRight: [1, 0], ArrowUp: [0, -1], ArrowDown: [0, 1] }
  var TOUCHES_OUTILS = { v: 'deplacer', h: 'main', f: 'cadre', r: 'forme', o: 'ellipse', l: 'trait', t: 'texte', i: 'image' }

  window.addEventListener('keydown', function (e) {
    if (e.target.closest && e.target.closest('input, textarea, select, dialog, [contenteditable]')) return
    if (!presentation.hidden) {
      toucheDePresentation(e.key)
      return
    }
    var touche = e.key.toLowerCase()
    if (e.ctrlKey || e.metaKey) {
      // Les raccourcis d edition. Copier laisse aussi faire le navigateur.
      var faire = null
      if (touche === 'z') faire = e.shiftKey ? refaire : annuler
      else if (touche === 'y') faire = refaire
      else if (touche === 's') faire = function () { enregistrer(false) }
      else if (touche === 'd') faire = dupliquer
      else if (touche === 'v') faire = coller
      else if (touche === 'x') faire = couper
      else if (FLECHES[e.key] && retouchable(choix)) faire = function () { etirer(FLECHES[e.key], e.shiftKey ? 10 : 1) }
      else if (touche === 'h' && e.shiftKey) faire = ACTIONS.masquer
      else if (e.key === ']') faire = function () { ordonner(1) }
      else if (e.key === '[') faire = function () { ordonner(-1) }
      if (touche === 'c' && retouchable(choix)) copier()
      if (faire) { e.preventDefault(); faire() }
      return
    }
    // Alt seul montre les ecarts ; on empeche le navigateur d y voir l appel de son menu.
    if (e.key === 'Alt') { e.preventDefault(); if (!glisse) montrerEcarts(survol); return }
    if (e.altKey) return
    if (e.code === 'Space') { espace = true; racine.dataset.outil = 'main'; e.preventDefault(); return }
    if (e.shiftKey && e.code === 'Digit1') return toutVoir()
    if (e.shiftKey && e.code === 'Digit2') return voirChoix()
    if (e.shiftKey && e.code === 'Digit0') return zoomer(1)
    if (e.key === 'Escape') {
      // D abord quitter l outil en cours, ensuite seulement lacher la selection.
      if (plume || DESSIN[outil]) return prendre('deplacer')
      fermerMenus()
      return choisir(null)
    }
    if (e.key === 'Enter') {
      if (plume) return finirPlume(false)
      if (e.shiftKey) { if (choix && choix.parent) choisir(choix.parent); return }
      if (choix && ecrire(choix)) e.preventDefault()
      return
    }
    if (e.key === 'Delete' || e.key === 'Backspace') {
      if (choix) { e.preventDefault(); supprimer() }
      return
    }
    if (FLECHES[e.key] && retouchable(choix)) {
      // Les fleches poussent le calque d un pixel, de dix avec Maj.
      e.preventDefault()
      var pas = e.shiftKey ? 10 : 1
      var pousse = choix
      retoucher(pousse.cadre, function () {
        deplacer(pousse.el, decalage(pousse.el), FLECHES[e.key][0] * pas, FLECHES[e.key][1] * pas)
        return pousse.el
      })
      return
    }
    if (e.key === 'F2') { e.preventDefault(); return ACTIONS.renommer() }
    // Tab passe au calque voisin, tant que le clavier n est pas dans un volet ou une barre.
    if (e.key === 'Tab') {
      if (choix && choix.parent && (document.activeElement === document.body || !document.activeElement)) { e.preventDefault(); voisin(e.shiftKey ? -1 : 1) }
      return
    }
    // Un chiffre regle l opacite du calque choisi : 1 pour 10 %, 5 pour 50 %,
    // 0 pour 100 %. On lit le caractere, pas la touche : sur un clavier
    // francais, la touche du 6 ecrit le tiret qui dezoome.
    if (/^\d$/.test(e.key) && retouchable(choix)) {
      appliquerProp(choix, 'opacite', e.key === '0' ? 100 : e.key * 10)
      return
    }
    // R une seconde fois : le rectangle sera arrondi.
    if (touche === 'r' && outil === 'forme') {
      arrondie = !arrondie
      return annoncer(arrondie ? 'Rectangle arrondi : tracez-le.' : 'Rectangle : tracez-le.')
    }
    if (touche === 'p') { if (e.shiftKey) prendre('plume'); else ACTIONS.presenter(); return }
    if (TOUCHES_OUTILS[touche]) return prendre(TOUCHES_OUTILS[touche])
    if (e.key === '+' || e.key === '=') zoomer(vue.z * 1.25)
    else if (e.key === '-') zoomer(vue.z / 1.25)
  }, hors)
  window.addEventListener('keyup', function (e) {
    if (e.code === 'Space') { espace = false; racine.dataset.outil = outil }
    if (e.key === 'Alt') { e.preventDefault(); montrerEcarts(null) }
  }, hors)
  window.addEventListener('resize', appliquer, hors)

  // ---------------------------------------------------------------- demarrage

  try {
    var retenu = localStorage.getItem('god2-design:theme')
    if (retenu === 'clair' || retenu === 'sombre') document.documentElement.dataset.theme = retenu
  } catch (e) { /* stockage ferme : theme par defaut */ }

  // Chez un hote qui range plusieurs maquettes, le menu Fichier y ramene.
  if (hote && hote.accueil) {
    id('gd-accueil').href = hote.accueil
    id('gd-accueil').hidden = false
    id('gd-accueil-filet').hidden = false
  }

  // De quoi piloter l atelier : pour l hote, les scripts et les essais.
  var atelier = {
    document: function () { return doc },
    cadres: function () { return cadres.map(function (c) { return c.nom }) },
    exporterSvg: function (i) { return exporterSvg(cadres[i || 0].racine) },
    arreter: function () { fin.abort() },
  }
  window.godDesign = atelier

  ouvrir(depart).then(function () {
    // Sur un petit ecran, ou a la demande (#presentation), on montre d abord l ecran en vrai.
    if (location.hash === '#presentation' || !large.matches) presenter(0)
  })
  return atelier
}

// Deux facons de demarrer. Le fichier autonome porte son document dans la
// page : l atelier s ouvre dessus. Dans l application god2-design, c est elle
// qui appelle atelierGod2, une fois la coque posee et le document charge.
window.atelierGod2 = atelierGod2
if (document.getElementById('document-god2')) atelierGod2(JSON.parse(document.getElementById('document-god2').textContent))
