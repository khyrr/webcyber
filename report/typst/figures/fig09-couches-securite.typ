// Figure 09 — Couches de sécurité (defense-in-depth)
// Six couches concentriques avec annotations latérales

// ── Palette ──────────────────────────────────────────────────────────────────
#let c-sg     = rgb("#c0392b")   // Security Group — rouge
#let c-host   = rgb("#b36b00")   // Hôte Ubuntu    — ambre
#let c-docker = rgb("#185fa5")   // Docker         — bleu
#let c-nginx  = rgb("#0f6e56")   // Nginx/TLS      — teal
#let c-flask  = rgb("#534ab7")   // Flask          — violet
#let c-pg     = rgb("#3b6d11")   // PostgreSQL     — vert
#let c-muted  = rgb("#888780")

// ── Helpers ───────────────────────────────────────────────────────────────────
#let layer-label(body, clr) = text(
  size: 7.5pt,
  weight: "bold",
  fill: clr,
  font: "New Computer Modern",
  body
)

#let annotation(title, items, clr) = block(
  stroke: 0.5pt + clr,
  fill: clr.lighten(90%),
  inset: (x: 7pt, y: 6pt),
  radius: 4pt,
  width: 4.2cm,
)[
  #text(size: 7.5pt, weight: "bold", fill: clr, font: "New Computer Modern")[#title]
  #v(3pt)
  #for item in items [
    #text(size: 6.5pt, fill: clr.darken(15%), font: "New Computer Modern")[• #item \ ]
  ]
]

// ── Diagram ───────────────────────────────────────────────────────────────────
// No #set page — managed by main.typ

#let inner-pad = 9pt

// Concentric layers via nested blocks with relative labelling
#stack(
  dir: ltr,
  spacing: 5pt,
)[
  // ── Concentric layers (centre column) ────────────────────────────────────
  #block(
    fill: c-sg.lighten(92%),
    stroke: 0.8pt + c-sg,
    inset: inner-pad,
    radius: 8pt,
    width: 9.4cm,
  )[
    #align(center, layer-label("1 · AWS Security Group — pare-feu réseau périmétrique", c-sg))
    #v(4pt)
    #block(
      fill: c-host.lighten(90%),
      stroke: 0.7pt + c-host,
      inset: inner-pad,
      radius: 7pt,
      width: 100%,
    )[
      #align(center, layer-label("2 · Hôte Ubuntu 22.04 — SSH clé, mises à jour, ufw", c-host))
      #v(4pt)
      #block(
        fill: c-docker.lighten(90%),
        stroke: 0.7pt + c-docker,
        inset: inner-pad,
        radius: 6pt,
        width: 100%,
      )[
        #align(center, layer-label("3 · Docker — isolation, utilisateur non-root", c-docker))
        #v(4pt)
        #block(
          fill: c-nginx.lighten(90%),
          stroke: 0.7pt + c-nginx,
          inset: inner-pad,
          radius: 5pt,
          width: 100%,
        )[
          #align(center, layer-label("4 · Nginx + TLS — HTTPS, en-têtes de sécurité", c-nginx))
          #v(4pt)
          #block(
            fill: c-flask.lighten(90%),
            stroke: 0.7pt + c-flask,
            inset: inner-pad,
            radius: 4pt,
            width: 100%,
          )[
            #align(center, layer-label("5 · Flask — auth, CSRF, sessions, validation", c-flask))
            #v(4pt)
            // Innermost: PostgreSQL
            #align(center, block(
              fill: c-pg.lighten(85%),
              stroke: 0.7pt + c-pg,
              inset: (x: 14pt, y: 8pt),
              radius: 4pt,
            )[
              #text(size: 8pt, weight: "bold", fill: c-pg, font: "New Computer Modern")[
                6 · Données — PostgreSQL
              ]\
              #text(size: 6.8pt, fill: c-pg.darken(10%), font: "New Computer Modern")[
                requêtes paramétrées (SQLAlchemy)
              ]
            ])
          ]
        ]
      ]
    ]
  ]
]