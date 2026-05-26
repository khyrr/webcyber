// Figure 04 — Diagramme de cas d'utilisation UML
// Requires: @preview/cetz:0.5.2  (Typst >= 0.14.0)

#import "@preview/cetz:0.5.2": canvas, draw

#canvas(length: 1cm, {
  import draw: *

  // ═══════════════════════════════════════════════════════════════════════
  // GRILLE DE RÉFÉRENCE
  //   Frontière :  x ∈ [2.5 ; 14.5]   y ∈ [-0.5 ; -9.0]
  //   Acteur gauche  : x = 1.0
  //   Acteur droit   : x = 16.0
  //   Col. gauche UC : x = 5.2    (UCs visiteur)
  //   Col. centrale  : x = 8.8    (UCs principales)
  //   Col. droite    : x = 12.8   (UCs secondaires)
  //   Lignes y  : -1.8 / -3.0 / -4.2 / -5.4 / -6.6 / -7.8
  // ═══════════════════════════════════════════════════════════════════════

  // ── Palette ──────────────────────────────────────────────────────────
  let uc-fill   = rgb("#ddeeff")
  let uc-stroke = (paint: rgb("#4477aa"), thickness: 0.55pt)
  let sys-fill  = rgb("#f7f7f7")
  let sys-str   = (paint: rgb("#999999"), thickness: 0.7pt, dash: "dashed")
  let lnk-str   = (paint: rgb("#555555"), thickness: 0.55pt)
  let inc-str   = (paint: rgb("#cc2222"), thickness: 0.55pt, dash: "dashed")
  let act-str   = (paint: rgb("#111111"), thickness: 0.8pt)

  // ── Helper : acteur (bonhomme) ────────────────────────────────────────
  let actor(x, y, lbl, anchor: "center") = {
    let r = 0.38
    circle((x, y), radius: r, stroke: act-str, fill: white)
    line((x, y - r),       (x, y - 1.15),  stroke: act-str)
    line((x - 0.48, y - 0.72), (x + 0.48, y - 0.72), stroke: act-str)
    line((x, y - 1.15),    (x - 0.42, y - 1.85), stroke: act-str)
    line((x, y - 1.15),    (x + 0.42, y - 1.85), stroke: act-str)
    content((x, y - 2.45), text(size: 8pt, weight: "bold",
      align(center, lbl)))
  }

  // ── Helper : ellipse UC ───────────────────────────────────────────────
  // w = largeur totale, h = hauteur totale
  let uc(x, y, lbl, w: 3.2, h: 0.78) = {
    circle((x, y), radius: (w / 2, h / 2),
           stroke: uc-stroke, fill: uc-fill)
    content((x, y), text(size: 7pt, align(center, lbl)))
  }

  // ── Helper : ligne d'association simple (pas de flèche) ───────────────
  let assoc(p1, p2) = {
    line(p1, p2, stroke: lnk-str)
  }

  // ── Helper : relation include ──────────────────────────────────────────
  // Ligne pointillée rouge avec flèche ouverte et étiquette centrée
  let include-rel(p1, p2) = {
    line(p1, p2, stroke: inc-str,
         mark: (end: (symbol: ">", size: 0.28, fill: none)))
    // étiquette au milieu du segment
    let mx = (p1.at(0) + p2.at(0)) / 2
    let my = (p1.at(1) + p2.at(1)) / 2
    // fond blanc pour lisibilité
    content((mx, my),
      box(fill: white, inset: (x: 1.5pt, y: 0.5pt),
        text(size: 6pt, fill: rgb("#cc2222"),
             style: "italic", "«include»")))
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FRONTIÈRE SYSTÈME
  // ═══════════════════════════════════════════════════════════════════════
  let bx0 = 2.8;  let by0 = -0.2
  let bx1 = 14.8; let by1 = -8.6

  line((bx0,by0),(bx1,by0),(bx1,by1),(bx0,by1),
       close: true, fill: sys-fill, stroke: none)
  line((bx0,by0),(bx1,by0),(bx1,by1),(bx0,by1),
       close: true, stroke: sys-str, fill: none)

  // Titre système — à l'intérieur du bord supérieur
  content(((bx0+bx1)/2, by0 + 0.38),
    text(size: 8pt, weight: "bold", fill: rgb("#666666"),
         "Système — WebCyber Notes"))

  // ═══════════════════════════════════════════════════════════════════════
  // ACTEURS
  // ═══════════════════════════════════════════════════════════════════════
  // Visiteur : centré verticalement sur ses 2 UCs (y = -1.8 et -3.2) → -2.5
  actor(1.4, -1.8, "Visiteur")

  // Utilisateur authentifié : centré sur 6 UCs (y = -1.8 à -7.2) → -4.5
  actor(15.6, -3.2, [Utilisateur\ authentifié])

  // ═══════════════════════════════════════════════════════════════════════
  // CAS D'UTILISATION
  // Colonne A (x=5.5)  : UCs Visiteur
  // Colonne B (x=8.8)  : UCs principales Authentifié
  // Colonne C (x=12.5) : UCs secondaires Authentifié
  // ═══════════════════════════════════════════════════════════════════════

  // — Colonne A : accès non authentifié —
  let xa = 5.5
  uc(xa, -1.8, "S'inscrire")
  uc(xa, -3.2, "Se connecter")

  // — Colonne B : gestion des notes —
  let xb = 9.2
  uc(xb, -1.8, "Créer une note")
  uc(xb, -3.2, "Consulter ses notes", w: 3.4)
  uc(xb, -4.6, "Éditer une note")
  uc(xb, -6.0, "Supprimer une note")

  // — Colonne C : fonctions avancées —
  let xc = 13.1
  uc(xc, -1.8, "Rechercher une note",  w: 3.4)
  uc(xc, -3.2, "Se déconnecter",       w: 3.4)
  uc(xc, -4.6, "Archiver / désarchiver", w: 3.4)
  uc(xc, -6.0, "Corbeille + restauration", w: 3.4)

  // ═══════════════════════════════════════════════════════════════════════
  // ASSOCIATIONS — lignes simples sans flèche (style UML standard)
  // ═══════════════════════════════════════════════════════════════════════

  // Visiteur → S'inscrire
  assoc((1.78, -2.0), (3.9, -1.8))
  // Visiteur → Se connecter
  assoc((1.78, -2.2), (3.9, -3.2))

  // Utilisateur ← colonne B
  assoc((10.9, -1.8), (15.22, -2.8))
  assoc((10.9, -3.2), (15.22, -3.0))
  assoc((10.9, -4.6), (15.22, -3.4))
  assoc((10.9, -6.0), (15.22, -3.8))

  // Utilisateur ← colonne C
  assoc((14.8, -1.8), (15.22, -2.9))
  assoc((14.8, -3.2), (15.22, -3.1))
  assoc((14.8, -4.6), (15.22, -3.5))
  assoc((14.8, -6.0), (15.22, -3.9))

  // ═══════════════════════════════════════════════════════════════════════
  // RELATIONS «include»
  // Créer une note   ──include──▶ Se connecter
  // Éditer une note  ──include──▶ Se connecter
  // Les flèches partent du bord gauche des UCs colonne B
  // et arrivent au bord droit de "Se connecter" (colonne A)
  // ═══════════════════════════════════════════════════════════════════════

  // "Se connecter" bord droit : x = 5.5 + 3.2/2 = 7.1,  y = -3.2
  // "Créer une note" bord gauche : x = 9.2 - 3.2/2 = 7.6,  y = -1.8
  // "Éditer une note" bord gauche : x = 9.2 - 3.2/2 = 7.6,  y = -4.6

  include-rel((7.6, -1.8), (7.1, -3.2))
  include-rel((7.6, -4.6), (7.1, -3.2))
})