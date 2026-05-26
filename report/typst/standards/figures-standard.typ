// standards/figures-standard.typ - Classic figure formatting

#let standard-figure(
  image-path: none,
  caption: none,
  label: none,
  width: 100%,
  placement: none,
) = {
  // Create the figure
  let fig = figure(
    kind: image,
    supplement: [Figure],
    caption: caption,
    placement: placement,
  )[
    #align(center)[
      #image(image-path, width: width)
    ]
  ]
  
  // Return the figure with label if provided
  if label != none {
    return [ #fig <label> ]
  } else {
    return fig
  }
}

#let tex-diagram(
  name: "",
  caption: none,
  label: none,
  width: 100%,
) = {
  let path = "../figures/img/" + name + ".png"
  standard-figure(
    image-path: path,
    caption: caption,
    label: label,
    width: width,
  )
}

#let plantuml-diagram(
  name: "",
  caption: none,
  label: none,
  width: 90%,
) = {
  let path = "../figures/img/" + name + ".png"
  standard-figure(
    image-path: path,
    caption: caption,
    label: label,
    width: width,
  )
}

#let screenshot(
  image-path: none,
  caption: none,
  label: none,
  width: 95%,
) = {
  standard-figure(
    image-path: image-path,
    caption: caption,
    label: label,
    width: width,
  )
}