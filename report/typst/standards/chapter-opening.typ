// standards/chapter-opening.typ - Unified chapter opening style

// Chapter opening for main chapters (1-5)
#let chapter-opening(
  number: "",
  title: "",
) = {
  // Set the heading counter to the chapter number minus 1
  // so that subsequent == headings start at X.1
  let ch = int(number)
  counter(heading).update(ch - 1)

  
  v(10cm)

  
  
  align(center)[
    #set text(size: 13pt, style: "italic")
    Chapitre #number
    #v(0.3cm)
    #line(length: 35%, stroke: 0.7pt + black)
  ]
 
  
  
  heading(
    level: 1,
  )[#smallcaps[#title]]

  v(0.8cm)

 align(center)[
  #line(length: 35%, stroke: 0.7pt + black)
]

  v(2cm)
}

// Opening for introduction and conclusion (unnumbered chapters)
#let special-chapter-opening(
  title: "",
) = {
  heading(
    level: 1,
    numbering: none,
  )[#title]
  
  v(1cm)
}

// Simplified opening for front matter
#let frontmatter-opening(
  title: "",
) = {
  align(center)[
    #v(2cm)
    #set text(size: 18pt, weight: "bold")
    *#title*
    #v(1.5cm)
  ]
}