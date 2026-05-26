// ==============================================================================
// PAGE DE GARDE — Version simplifiée
// ==============================================================================

#import "../variables.typ": *

#let cover-page = {
  set page(
    margin: (left: 2.2cm, right: 2.2cm, top: 2.2cm, bottom: 2.2cm),
    paper: "a4"
  )
  
  set page(numbering: none)
  set text(font: ("Libertinus Serif", "DejaVu Serif"), size: 12pt)
  
  // Add a border
  show: box.with(
    stroke: (paint: rgb(0, 102, 153), thickness: 1.5pt),
    inset: (x: 0.8cm, y: 0.8cm)
  )
  
  align(center)[
    #v(3cm)
    
    #text(weight: "bold", size: 16pt, Institute)
    #text(style: "italic", size: 11pt, Location)
    
    #v(1.5cm)
    
    #if logo-path != "" [
      #image(logo-path, width: 3.5cm)
      #v(0.5cm)
    ]
    
    #line(length: 70%, stroke: 0.5pt)
    #v(1cm)
    
    #box(
      fill: rgb(255, 255, 0),
      inset: (x: 12pt, y: 6pt),
      text(weight: "bold", size: 16pt, projectType)
    )
    
    #v(0.8cm)
    
    #text(size: 11pt)[Pour l'obtention de :]
    #box(
      fill: rgb(255, 255, 0),
      inset: (x: 12pt, y: 6pt),
      text(weight: "bold", size: 13pt, degree)
    )
    
    #v(1.5cm)
    
    #text(weight: "bold", size: 12pt)[Thème :]
    #v(0.5cm)
    
    #block(
      width: 85%,
      stroke: (paint: rgb(0, 102, 153), thickness: 0.8pt),
      inset: (x: 15pt, y: 15pt),
      align(center)[
        #text(weight: "bold", size: 11pt, projectTitle)
      ]
    )
    
    #v(2cm)
    
    #grid(
      columns: (auto, 1fr),
      column-gap: 1.5cm,
      align(left)[
        #text(style: "italic", size: 11pt)[Élaboré par :]
      ],
      align(center)[
        #box(
          fill: rgb(255, 255, 0),
          inset: (x: 12pt, y: 6pt),
          text(weight: "bold", size: 11pt, studentA)
        )
      ]
    )
    
    #v(1cm)
    
    #grid(
      columns: (auto, 1fr),
      column-gap: 1.5cm,
      align(left)[
        #text(style: "italic", size: 11pt)[Encadré par :]
      ],
      align(center)[
        #box(
          fill: rgb(255, 255, 0),
          inset: (x: 12pt, y: 6pt),
          text(weight: "bold", size: 11pt, supervisor)
        )
      ]
    )
    
    #v(3cm)
    
    #text(style: "italic", size: 11pt)[Année Universitaire : #academicYear]
  ]
  
  pagebreak()
}

#cover-page