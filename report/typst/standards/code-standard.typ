// standards/code-standard.typ - Classic code block formatting

#let standard-code(
  code: "",
  lang: "python",
  caption: none,
  label: none,
) = {
  figure(
    kind: "code",
    supplement: [Code],
    caption: caption,
  )[
    #set raw(
      size: 9pt,
      font: "Courier New",
      inset: 10pt,
      stroke: 0.5pt + rgb(200, 200, 200),  // Use direct RGB instead of variable
    )
    #raw(code, lang: lang)
  ]
}

#let terminal-block(
  command: "",
  output: none,
  caption: none,
  label: none,
) = {
  let full-code = if output != none {
    "$ " + command + "\n" + output
  } else {
    "$ " + command
  }
  
  figure(
    kind: "code",
    supplement: [Terminal],
    caption: caption,
  )[
    #set raw(
      size: 9pt,
      font: "Courier New",
      inset: 10pt,
      stroke: 0.5pt + rgb(200, 200, 200),  // Use direct RGB
    )
    #raw(full-code, lang: "bash")
  ]
}

#let config-block(
  code: "",
  caption: none,
  label: none,
) = {
  standard-code(
    code: code,
    lang: "yaml",
    caption: caption,
    label: label,
  )
}