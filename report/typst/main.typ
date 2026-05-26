// ==============================================================================
// ISCAE PFE — Rapport de fin d'études
// Sujet : WebCyber — Conception, déploiement et analyse de sécurité
// ==============================================================================

// ---------- IMPORTS ----------
#import "variables.typ": *
#import "standards/colors.typ": *
#import "standards/tables-standard.typ": *
#import "standards/figures-standard.typ": *
#import "standards/code-standard.typ": *




// ---------- MISE EN PAGE ----------
#set page(
  paper: "a4",
  margin: (left: 2.2cm, right: 2.2cm, top: 2.2cm, bottom: 2.2cm),
)

#set text(
  font: ("Libertinus Serif", "DejaVu Serif"),
  size: 12pt,
  lang: "fr"
)

#set par(justify: true, leading: 0.65em)

// ---------- STYLES DES TITRES ----------
#set heading(numbering: "1. 1.1 1.1.1")

#show heading.where(level: 1): it => {
  set align(center)
  set text(size: 22pt, weight: "bold")
  v(12pt)
  it
  v(12pt)
}

#show heading.where(level: 2): it => {
  set text(size: 14pt, weight: "bold")
  v(12pt)
  it
  v(6pt)
}

#show heading.where(level: 3): it => {
  set text(size: 12pt, weight: "bold")
  v(10pt)
  it
  v(4pt)
}

// ---------- STYLES DES LISTES ----------
#set list(
  indent: 2em,
  body-indent: 1em,
  marker: [-],
)

#set enum(
  indent: 2em,
  body-indent: 1em,
  numbering: "1.",
)

// ==============================================================================
// PAGE DE GARDE
// ==============================================================================
#import "pages/01-couv-carte.typ": *
#cover-page

// ---------- Dédicaces ----------
// #include "chapitres/00a-dedicaces.typ"
// #pagebreak()

// ---------- Remerciements ----------
#include "chapitres/00b-remerciements.typ"
#pagebreak()

// ---------- Résumé ----------
#include "chapitres/00c-resume.typ"
#pagebreak()

// ---------- Table des matières ----------
#set page(numbering: "i")
#outline(title: [Table des matières], depth: 3)
#pagebreak()

// ---------- Liste des figures ----------
#outline(title: [Liste des figures], target: figure.where(kind: image))
#pagebreak()

// ---------- Liste des tableaux ----------
#outline(title: [Liste des tableaux], target: figure.where(kind: table))
#pagebreak()

// ---------- Acronymes ----------
#include "chapitres/00d-acronymes.typ"
#pagebreak()

// ---------- Introduction ----------
#set page(numbering: "1")
#include "chapitres/00e-introduction.typ"
#pagebreak()

// ---------- Chapitres ----------
#include "chapitres/01-contexte.typ"
#pagebreak()

#include "chapitres/02-besoins.typ"
#pagebreak()

#include "chapitres/03-conception.typ"
#pagebreak()

#include "chapitres/04-realisation.typ"
#pagebreak()

#include "chapitres/05-tests.typ"
#pagebreak()

#include "chapitres/06-conclusion.typ"
#pagebreak()

// ---------- Bibliographie ----------
#include "chapitres/07-bibliographie.typ"