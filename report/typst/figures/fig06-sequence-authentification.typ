// Figure 06 — Diagramme de séquence : Authentification
// Requires: @preview/cetz:0.5.2  (Typst >= 0.14.0)

#import "@preview/cetz:0.5.2": canvas, draw

#canvas(length: 1cm, {
  import draw: *

  // ── Palette ──────────────────────────────────────────────────────────
  let c-box-f  = rgb("#ddeeff")
  let c-box-s  = rgb("#3366aa")
  let c-box-t  = rgb("#1a3a6a")
  let c-life   = rgb("#b0b0b0")
  let c-act-f  = rgb("#ffe0a0")
  let c-act-s  = rgb("#cc8800")
  let c-msg    = rgb("#1a1a2e")
  let c-ret    = rgb("#666688")
  let c-ok     = rgb("#1a6622")
  let c-sql    = rgb("#aa1111")
  let c-note-f = rgb("#fffbe6")
  let c-note-s = rgb("#c8a800")
  let c-phase  = rgb("#eef3ff")
  let c-phase-t= rgb("#334466")

  // ── Participants (x-positions) ────────────────────────────────────────
  let xu = 0.0
  let xb = 3.6
  let xn = 7.2
  let xf = 10.8
  let xd = 14.4
  let bottom = -13.8
  let bw = 1.25   // demi-largeur des boîtes

  // ── Boîte participant ─────────────────────────────────────────────────
  let pbox(x, lbl) = {
    line(
      (x - bw, 0.45), (x + bw, 0.45),
      (x + bw, -0.45), (x - bw, -0.45),
      close: true,
      fill: c-box-f,
      stroke: (paint: c-box-s, thickness: 0.65pt),
    )
    content((x, 0.0),
      text(size: 8pt, weight: "bold", fill: c-box-t, lbl))
  }

  // ── Ligne de vie ──────────────────────────────────────────────────────
  let lifeline(x) = {
    line((x, -0.45), (x, bottom),
      stroke: (paint: c-life, thickness: 0.5pt, dash: "dashed"))
  }

  // ── Barre d'activation ────────────────────────────────────────────────
  let act(x, y0, y1) = {
    line(
      (x - 0.16, y0), (x + 0.16, y0),
      (x + 0.16, y1), (x - 0.16, y1),
      close: true,
      fill: c-act-f,
      stroke: (paint: c-act-s, thickness: 0.4pt),
    )
  }

  // ── Message (appel ou retour) ─────────────────────────────────────────
  // dir: 1 = gauche→droite, -1 = droite→gauche
  let msg(y, x1, x2, lbl,
          clr: c-msg,
          ret: false,
          lbl-clr: none,
          gap: 0.16) = {
    let tc = if lbl-clr != none { lbl-clr } else { clr }
    let ds = if ret { "dashed" } else { "solid" }
    // on recule les extrémités des barres d'activation
    let sx = if x2 > x1 { x1 + gap } else { x1 - gap }
    let ex = if x2 > x1 { x2 - gap } else { x2 + gap }
    line((sx, y), (ex, y),
      stroke: (paint: clr, thickness: 0.6pt, dash: ds),
      mark: (end: (symbol: ">", size: 0.24, fill: clr)))
    let mx = (x1 + x2) / 2
    content((mx, y + 0.22),
      box(fill: white, inset: (x: 2.5pt, y: 1pt),
        text(size: 6.2pt, fill: tc, lbl)))
  }

  // ── Message auto (boucle sur soi-même) ────────────────────────────────
  let self-msg(x, y0, y1, lbl) = {
    let dx = 1.1
    line((x + 0.16, y0), (x + dx, y0),
      stroke: (paint: c-msg, thickness: 0.6pt))
    line((x + dx, y0),   (x + dx, y1),
      stroke: (paint: c-msg, thickness: 0.6pt))
    line((x + dx, y1),   (x + 0.16, y1),
      stroke: (paint: c-msg, thickness: 0.6pt),
      mark: (end: (symbol: ">", size: 0.24, fill: c-msg)))
    content((x + dx + 0.12, (y0 + y1) / 2),
      box(fill: white, inset: (x: 2.5pt, y: 1pt),
        text(size: 6.2pt, fill: c-msg, lbl)))
  }

  // ── Bandeau de phase ──────────────────────────────────────────────────
  let phase(y, lbl) = {
    line(
      (xu - 0.3, y + 0.22), (xd + 0.5, y + 0.22),
      (xd + 0.5, y - 0.22), (xu - 0.3, y - 0.22),
      close: true, fill: c-phase,
      stroke: (paint: rgb("#aabbdd"), thickness: 0.4pt))
    content(((xu + xd) / 2, y),
      text(size: 6.5pt, weight: "bold", fill: c-phase-t, lbl))
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DESSIN
  // ═══════════════════════════════════════════════════════════════════════

  // Lignes de vie (derrière tout le reste)
  for x in (xu, xb, xn, xf, xd) { lifeline(x) }

  // Boîtes participants
  pbox(xu, "Utilisateur")
  pbox(xb, "Navigateur")
  pbox(xn, "Nginx")
  pbox(xf, "Flask")
  pbox(xd, "PostgreSQL")

  // ── Barres d'activation ───────────────────────────────────────────────
  act(xn, -2.2, -10.2)
  act(xf, -3.0, -9.4)
  act(xd, -5.2, -6.4)

  // ── Phase 1 — Saisie ─────────────────────────────────────────────────
  phase(-0.85, "Saisie des identifiants")

  // 1
  msg(-1.3, xu, xb, "1. Saisit login + password")

  // ── Phase 2 — Envoi & traitement ─────────────────────────────────────
  phase(-1.85, "Envoi & traitement")

  // 2
  msg(-2.2, xb, xn, "2. POST /login  (HTTPS)")
  // 3
  msg(-3.0, xn, xf, "3. proxy_pass  →  http://app:5000")
  // 4
  self-msg(xf, -3.8, -4.5, "4. Validation CSRF + formulaire")
  // 5
  msg(-5.2, xf, xd, "5. SELECT * FROM users WHERE username = ?",
      clr: c-sql)
  // 6
  msg(-6.2, xd, xf, "6. tuple user  (id, password_hash)",
      clr: c-ret, ret: true, lbl-clr: c-ret)
  // 7
  self-msg(xf, -7.0, -7.7, "7. check_password_hash()  [PBKDF2-SHA256]")

  // ── Phase 3 — Réponse ────────────────────────────────────────────────
  phase(-8.35, "Réponse & session")

  // 8
  msg(-8.7, xf, xn,
    "8. 302 + Set-Cookie: session=…  (HttpOnly, Secure)",
    clr: c-ok, ret: true, lbl-clr: c-ok)
  // 9
  msg(-9.5, xn, xb, "9. Réponse HTTPS",
      clr: c-ret, ret: true, lbl-clr: c-ret)
  // 10
  msg(-10.3, xb, xu, "10. Redirection → /notes",
      clr: c-ret, ret: true, lbl-clr: c-ret)

  // ── Note de sécurité ─────────────────────────────────────────────────
  let ny0 = -11.2
  let ny1 = -13.5
  let nx0 = xu - 0.2
  let nx1 = xd + 0.6

  line((nx0,ny0),(nx1,ny0),(nx1,ny1),(nx0,ny1),
    close: true,
    fill: c-note-f,
    stroke: (paint: c-note-s, thickness: 0.5pt, dash: "dashed"))

  content(((nx0 + nx1) / 2, (ny0 + ny1) / 2),
    box(width: (nx1 - nx0 - 0.6) * 1cm,
      [#text(size: 6.5pt, weight: "bold", fill: rgb("#443300"),
             "Notes de sécurité") \
       #text(size: 6pt, fill: rgb("#554400"),
         [• Le mot de passe ne transite jamais en clair (HTTPS de bout en bout). \
          • Hachage Werkzeug PBKDF2-SHA256 avec sel aléatoire automatique. \
          • Cookie de session signé HMAC avec SECRET_KEY ; flags Secure, HttpOnly, SameSite=Lax.])
      ]))
})