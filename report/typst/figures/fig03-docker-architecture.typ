// Figure 03 — Docker Compose Architecture
// Stack: nginx → app → db · bridge network · named volumes

// ── Palette ──────────────────────────────────────────────────────────────────
#let c-host-bg     = rgb("#f0f4f8")
#let c-host-stroke = rgb("#1a2637")
#let c-compose-bg  = rgb("#e8f7fc")
#let c-compose-str = rgb("#0db7ed")
#let c-nginx-bg    = rgb("#e6f7ee")
#let c-nginx-str   = rgb("#009e45")
#let c-app-bg      = rgb("#f0f0f0")
#let c-app-str     = rgb("#444444")
#let c-pg-bg       = rgb("#e3eef5")
#let c-pg-str      = rgb("#336791")
#let c-net-bg      = rgb("#fff8e6")
#let c-net-str     = rgb("#b36b00")
#let c-vol-bg      = rgb("#fef3f3")
#let c-vol-str     = rgb("#c0392b")
#let c-arrow       = rgb("#888888")
#let c-label       = rgb("#333333")
#let c-muted       = rgb("#888888")

// ── Helpers ───────────────────────────────────────────────────────────────────
#let badge(body, fill: white, stroke: gray) = box(
  fill: fill,
  stroke: 0.6pt + stroke,
  inset: (x: 4pt, y: 2pt),
  radius: 2pt,
  text(size: 6.2pt, font: "DejaVu Sans Mono", body)
)

#let service-card(title, image, detail, port-text, bg, strk) = block(
  width: 3.7cm,
  fill: bg,
  stroke: 1pt + strk,
  inset: (x: 7pt, y: 8pt),
  radius: 4pt,
)[
  // title bar
  #block(
    width: 100%,
    fill: strk.lighten(70%),
    inset: (x: 5pt, y: 3pt),
    radius: 2pt,
  )[
    #text(size: 9pt, weight: "bold", fill: strk, font: "DejaVu Sans Mono")[#title]
  ]
  #v(5pt)
  #badge(image, fill: bg, stroke: strk.lighten(40%))
  #v(4pt)
  #text(size: 7pt, fill: c-label)[#detail]
  #v(4pt)
  #block(
    width: 100%,
    fill: strk.lighten(82%),
    inset: (x: 4pt, y: 3pt),
    radius: 2pt,
  )[
    #text(size: 6.5pt, font: "DejaVu Sans Mono", fill: strk.darken(10%))[#port-text]
  ]
]

// ── Diagram ───────────────────────────────────────────────────────────────────
// Note: no #set page here — page is configured in main.typ

// ── EC2 Host ──────────────────────────────────────────────────────────────────
#block(
  width: 100%,
  fill: c-host-bg,
  stroke: (paint: c-host-stroke, thickness: 1.2pt, dash: "dashed"),
  inset: 10pt,
  radius: 6pt,
)[

  // Host header row
  #grid(
    columns: (auto, 1fr, auto),
    align: (left, center, right),
    gutter: 0pt,
  )[
    #box(
      fill: c-host-stroke,
      inset: (x: 6pt, y: 3pt),
      radius: 3pt,
    )[#text(size: 7pt, fill: white, weight: "bold")[EC2 HOST]]
  ][
    #text(size: 8pt, weight: "bold", fill: c-host-stroke)[
      Ubuntu 22.04 LTS · Docker Engine 24.x
    ]
  ][
    #badge("t3.medium", fill: rgb("#fff3e0"), stroke: rgb("#e67e22"))
  ]

  #v(8pt)

  // ── Docker Compose stack ──────────────────────────────────────────────────
  #block(
    width: 100%,
    fill: c-compose-bg,
    stroke: (paint: c-compose-str, thickness: 1pt),
    inset: 10pt,
    radius: 4pt,
  )[

    // Compose header
    #grid(
      columns: (auto, 1fr),
      gutter: 6pt,
      align: (left, left),
    )[
      #box(
        fill: c-compose-str,
        inset: (x: 6pt, y: 3pt),
        radius: 3pt,
      )[#text(size: 7pt, fill: white, weight: "bold")[COMPOSE STACK]]
    ][
      #text(size: 7.5pt, fill: c-compose-str.darken(20%), font: "DejaVu Sans Mono")[
        docker-compose.yml
      ]
    ]

    #v(10pt)

    // ── Services row ─────────────────────────────────────────────────────────
    #grid(
      columns: (3.7cm, 0.8cm, 3.7cm, 0.8cm, 3.7cm),
      align: (center, center, center, center, center),
      gutter: 0pt,
    )[
      #service-card(
        "nginx",
        "nginx:1.25-alpine",
        "Reverse proxy · TLS termination\nLet's Encrypt / Certbot",
        "80:80  ·  443:443  (publics)",
        c-nginx-bg,
        c-nginx-str,
      )
    ][
      #align(center + horizon)[
        #text(size: 14pt, fill: c-arrow)[→]
        #v(-6pt)
        #text(size: 5.8pt, fill: c-muted)[proxy]
      ]
    ][
      #service-card(
        "app",
        "python:3.11-slim",
        "Flask 3 · Gunicorn 4w\nREST API / business logic",
        "5000  (interne uniquement)",
        c-app-bg,
        c-app-str,
      )
    ][
      #align(center + horizon)[
        #text(size: 14pt, fill: c-arrow)[→]
        #v(-6pt)
        #text(size: 5.8pt, fill: c-muted)[SQL]
      ]
    ][
      #service-card(
        "db",
        "postgres:15-alpine",
        "PostgreSQL 15\nPersistence relationnelle",
        "5432  (interne uniquement)",
        c-pg-bg,
        c-pg-str,
      )
    ]

    #v(10pt)

    // ── Bridge network ────────────────────────────────────────────────────────
    #block(
      width: 100%,
      fill: c-net-bg,
      stroke: (paint: c-net-str, thickness: 0.7pt, dash: "dotted"),
      inset: (x: 10pt, y: 6pt),
      radius: 3pt,
    )[
      #grid(
        columns: (auto, 1fr, auto),
        align: (left, center, right),
      )[
        #text(size: 6.5pt, weight: "bold", fill: c-net-str)[RESEAU]
      ][
        #text(size: 7pt, font: "DejaVu Sans Mono", fill: c-net-str.darken(10%))[
          webcyber-net  ·  bridge  ·  172.20.0.0/16
        ]
      ][
        #text(size: 6.2pt, fill: c-muted)[isolation DNS interne]
      ]
    ]

    #v(7pt)

    // ── Volumes ───────────────────────────────────────────────────────────────
    #block(
      width: 100%,
      fill: c-vol-bg,
      stroke: (paint: c-vol-str, thickness: 0.7pt),
      inset: (x: 10pt, y: 6pt),
      radius: 3pt,
    )[
      #grid(
        columns: (auto, 1fr),
        gutter: 8pt,
        align: (left, left),
      )[
        #text(size: 6.5pt, weight: "bold", fill: c-vol-str)[VOLUMES]
      ][
        #grid(
          columns: (1fr, 1fr, 1fr),
          gutter: 6pt,
        )[
          #text(size: 6.2pt, font: "DejaVu Sans Mono")[
            *db-data*\
            #text(fill: c-muted)[/var/lib/postgresql/data]
          ]
        ][
          #text(size: 6.2pt, font: "DejaVu Sans Mono")[
            *certbot-etc*\
            #text(fill: c-muted)[/etc/letsencrypt]
          ]
        ][
          #text(size: 6.2pt, font: "DejaVu Sans Mono")[
            *certbot-var*\
            #text(fill: c-muted)[/var/lib/letsencrypt]
          ]
        ]
      ]
    ]

  ] // end compose block

  #v(6pt)

  // ── External traffic note ─────────────────────────────────────────────────
  #align(right)[
    #text(size: 6.5pt, fill: c-muted)[
      trafic entrant : Internet -> Security Group AWS ->
      #text(fill: c-nginx-str, weight: "bold")[nginx] :80 / :443
    ]
  ]

] // end host block