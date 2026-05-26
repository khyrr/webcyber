// Figure 07 — Diagramme de séquence : Création / lecture de note
// Requires: @preview/cetz:0.5.2  (Typst >= 0.14.0)

#import "@preview/cetz:0.5.2": canvas, draw

#canvas(length: 1cm, {
  import draw: *

  // ── Palette ──────────────────────────────────────────────────────────
  let c-box    = rgb("#ddeeff")
  let c-box-s  = rgb("#4477aa")
  let c-life   = rgb("#aaaaaa")
  let c-act    = rgb("#ffd49933")   // activation bar fill
  let c-act-s  = rgb("#cc8800")
  let c-msg    = rgb("#222222")
  let c-ret    = rgb("#888888")
  let c-sql    = rgb("#aa1111")
  let c-ok     = rgb("#226622")
  let c-note-f = rgb("#fffbe6")
  let c-note-s = rgb("#ccaa00")

  // ── Positions X des participants ──────────────────────────────────────
  let xu = 0.0     // Utilisateur
  let xb = 3.5     // Navigateur
  let xn = 7.0     // Nginx
  let xf = 10.5    // Flask
  let xd = 14.0    // PostgreSQL

  let bottom = -15.0

  // ── Helper : boîte participant ────────────────────────────────────────
  let lifeline-box(x, lbl) = {
    line((x - 1.2, 0.4), (x + 1.2, 0.4), (x + 1.2, -0.4),
         (x - 1.2, -0.4), close: true,
         fill: c-box, stroke: (paint: c-box-s, thickness: 0.6pt))
    content((x, 0.0), text(size: 7.5pt, weight: "bold", fill: rgb("#223355"), lbl))
  }

  // ── Helper : ligne de vie (pointillée grise) ──────────────────────────
  let lifeline(x) = {
    line((x, -0.4), (x, bottom),
         stroke: (paint: c-life, thickness: 0.5pt, dash: "dashed"))
  }

  // ── Helper : barre d'activation ───────────────────────────────────────
  let act(x, y0, y1) = {
    line((x - 0.15, y0), (x + 0.15, y0), (x + 0.15, y1),
         (x - 0.15, y1), close: true,
         fill: rgb("#ffdd9966"),
         stroke: (paint: c-act-s, thickness: 0.4pt))
  }

  // ── Helper : message ──────────────────────────────────────────────────
  let msg(y, x1, x2, lbl, clr: c-msg, dashed: false, offset: 0.18) = {
    let ds = if dashed { "dashed" } else { "solid" }
    line((x1, y), (x2, y),
         stroke: (paint: clr, thickness: 0.6pt, dash: ds),
         mark: (end: (symbol: ">", size: 0.22, fill: clr)))
    // label au-dessus du segment
    let mx = (x1 + x2) / 2
    content((mx, y + offset),
      box(fill: white, inset: (x: 2pt, y: 0.5pt),
        text(size: 6pt, fill: clr, lbl)))
  }

  // ── Helper : message auto (boucle sur soi-même) ───────────────────────
  let self-msg(x, y0, y1, lbl) = {
    let dx = 1.0
    line((x, y0), (x + dx, y0), (x + dx, y1), (x, y1),
         stroke: (paint: c-msg, thickness: 0.6pt),
         mark: (end: (symbol: ">", size: 0.22, fill: c-msg)))
    content((x + dx + 0.08, (y0 + y1) / 2),
      box(fill: white, inset: (x: 2pt, y: 0.5pt),
        text(size: 6pt, fill: c-msg, lbl)))
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PARTICIPANTS
  // ═══════════════════════════════════════════════════════════════════════
  for x in (xu, xb, xn, xf, xd) { lifeline(x) }

  lifeline-box(xu, "Utilisateur")
  lifeline-box(xb, "Navigateur")
  lifeline-box(xn, "Nginx")
  lifeline-box(xf, "Flask")
  lifeline-box(xd, "PostgreSQL")

  // ═══════════════════════════════════════════════════════════════════════
  // PHASE 1 — Affichage du formulaire
  // ═══════════════════════════════════════════════════════════════════════

  // Séparateur de phase
  content((xu + 0.1, -0.95),
    box(fill: rgb("#eef4ff"), inset: (x:3pt, y:1.5pt),
      text(size: 6.5pt, weight: "bold", fill: rgb("#334466"),
           "Phase 1 — Affichage du formulaire")))

  // 1. Clic utilisateur
  msg(-1.4, xu, xb, "1. Clic « Nouvelle note »")

  // 2. GET /notes/create
  msg(-2.0, xb, xn, "2. GET /notes/create")

  // barres d'activation
  act(xn, -2.0, -3.8)
  act(xf, -2.5, -3.4)

  // 3. proxy_pass
  msg(-2.5, xn, xf, "3. proxy_pass")

  // 4. HTML formulaire (retour Flask→Nginx)
  msg(-3.2, xf, xn, "4. HTML formulaire (CSRF token inclus)",
      clr: c-ok, dashed: true)

  // 5. réponse HTTPS
  msg(-3.6, xn, xb, "5. Réponse HTTPS", clr: c-ret, dashed: true)

  // ═══════════════════════════════════════════════════════════════════════
  // PHASE 2 — Soumission
  // ═══════════════════════════════════════════════════════════════════════

  content((xu + 0.1, -4.45),
    box(fill: rgb("#eef4ff"), inset: (x:3pt, y:1.5pt),
      text(size: 6.5pt, weight: "bold", fill: rgb("#334466"),
           "Phase 2 — Soumission")))

  // 6. Saisie utilisateur
  msg(-4.9, xu, xb, "6. Saisit titre + contenu, valide")

  // 7. POST
  msg(-5.5, xb, xn, "7. POST /notes/create  (titre, contenu, csrf_token)")

  // barres d'activation Nginx et Flask
  act(xn, -5.5, -12.0)
  act(xf, -6.1, -11.4)

  // 8. proxy_pass
  msg(-6.1, xn, xf, "8. proxy_pass")

  // 9. @login_required + CSRF (auto-message Flask)
  self-msg(xf, -6.8, -7.5, "9. @login_required + CSRF check")

  // 10. INSERT
  msg(-8.2, xf, xd,
    "10. INSERT INTO notes (title, content, user_id) VALUES ($1, $2, uid)",
    clr: c-sql)
  act(xd, -8.2, -9.2)

  // 11. RETURNING id
  msg(-9.0, xd, xf, "11. RETURNING id", clr: c-ret, dashed: true)

  // 12. 302 → /notes
  msg(-10.2, xf, xn, "12. 302 → /notes", clr: c-ok, dashed: true)

  // 13. réponse HTTPS
  msg(-11.0, xn, xb, "13. Réponse HTTPS", clr: c-ret, dashed: true)

  // 14. Nouvelle note affichée
  msg(-11.8, xb, xu, "14. Nouvelle note affichée", clr: c-ret, dashed: true)

  // ═══════════════════════════════════════════════════════════════════════
  // NOTE D'ISOLATION
  // ═══════════════════════════════════════════════════════════════════════
  let nx0 = xu - 0.2
  let ny0 = -12.5
  let nx1 = xd + 0.8
  let ny1 = -14.2

  line((nx0,ny0),(nx1,ny0),(nx1,ny1),(nx0,ny1),
       close: true,
       fill: c-note-f,
       stroke: (paint: c-note-s, thickness: 0.5pt, dash: "dashed"))

  content(((nx0+nx1)/2, (ny0+ny1)/2),
    box(width: (nx1 - nx0 - 0.4) * 1cm,
      text(size: 6pt, fill: rgb("#443300"),
        [*Isolation par utilisateur :* toutes les requêtes de lecture filtrent par
         #raw("WHERE user_id = current_user.id"). Aucun utilisateur ne peut accéder
         aux notes d'un autre, même en forçant un identifiant dans l'URL (IDOR bloqué).]
    )))
})