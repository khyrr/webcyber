// Cover page for iTeam University PFE - Professional Version
// Import this file in your main.typ

#import "../variables.typ": *

// Colors
#let iscae-blue = rgb(0, 102, 153)
#let iscae-blue-dark = rgb(0, 51, 102)
#let text-dark = rgb(34, 34, 34)

// Cover page template
#let cover-page = {
  set page(
    margin: (left: 2.2cm, right: 2.2cm, top: 2.2cm, bottom: 2.2cm),
    paper: "a4"
  )
  
  set text(size: 12pt, fill: text-dark)
  
  // No page number on cover
  set page(numbering: none)
  
  // Outer frame
  place(
    top + left,
    dx: -1.8cm,
    dy: -1.8cm,
    rect(
      width: 100% + 3.6cm,
      height: 100% + 3.6cm,
      stroke: (paint: iscae-blue, thickness: 2pt),
      fill: none,
      radius: 0pt
    )
  )
  
  place(
    top + left,
    dx: -1.6cm,
    dy: -1.6cm,
    rect(
      width: 100% + 3.2cm,
      height: 100% + 3.2cm,
      stroke: (paint: iscae-blue, thickness: 0.5pt),
      fill: none,
      radius: 0pt
    )
  )
  
  align(center)[
    #v(2cm)
    
    // Institute name
    #text(weight: "bold", size: 16pt, fill: iscae-blue-dark, Institute)\
    #text(style: "italic", size: 11pt, fill: iscae-blue, Location)
    
    #v(0.8cm)
    
    // Logo
    #image(LogoFile, width: 3.2cm)
    
    #v(0.5cm)
    #line(length: 70%, stroke: (paint: iscae-blue, thickness: 0.3pt))
    #v(0.5cm)
    
    // Project type
    #text(weight: "bold", size: 14pt, fill: iscae-blue-dark, projectType)
    
    #v(0.3cm)
    
    // Degree
    #text(size: 11pt, fill: text-dark)[Dans le cadre du :]
    #text(weight: "bold", size: 12pt, fill: iscae-blue-dark, degree)
    
    #v(0.8cm)
    
    #text(weight: "bold", size: 12pt, fill: iscae-blue-dark)[Thème :]
    
    #v(0.3cm)
    
    // Project title box
    #box(
      width: 100%,
      stroke: (paint: iscae-blue, thickness: 0.4pt),
      fill: none,
      inset: (x: 15pt, y: 12pt),
      radius: 0pt,
      align(center)[
        #text(weight: "bold", size: 15pt, fill: iscae-blue-dark, projectTitle)
      ]
    )
    
    #v(1.2cm)
    
    // Author and supervisor - Clean aligned block (without column-gap)
    #align(left)[
      #set text(size: 11pt)
      #let names = align(center)[
        #box(width: 100%, align(left)[
          #text(weight: "bold", style: "italic", fill: iscae-blue-dark)[Élaboré par :] 
          #h(1cm)
          #text(weight: "bold", fill: text-dark)[#studentA]
        ])
        #v(0.6cm)
        #box(width: 100%, align(left)[
          #text(weight: "bold", style: "italic", fill: iscae-blue-dark)[Encadré par :] 
          #h(1cm)
          #text(weight: "bold", fill: text-dark)[#supervisor]
        ])
      ]
      #names
    ]
    
    #v(3.5cm)
    
    #text(style: "italic", size: 10pt, fill: iscae-blue)[Année Universitaire : #academicYear]
  ]
  
  pagebreak()
}

// Display the cover page
#cover-page