// standards/tables-standard.typ - WORKING VERSION

#let standard-table(
  columns: (),
  header: (),
  data: (),
  caption: none,
  label: none,
  placement: none,
) = {
  if label != none {
    // Return as markup with label
    return [
      #figure(
        kind: table,
        supplement: [Tableau],
        caption: caption,
        placement: placement,
      )[
        #table(
          columns: columns,
          align: (left,) + (center,) * (columns.len() - 1),
          stroke: (x, y) => {
            if y == 0 { return 1pt + black }
            if y == 1 { return 0.5pt + black }
            return 0.3pt + rgb(200, 200, 200)
          },
          inset: 6pt,
          ..header.map(h => [*#h*]),
          ..data.flatten(),
        )
      ] <label>
    ]
  } else {
    // Return without label
    return [
      #figure(
        kind: table,
        supplement: [Tableau],
        caption: caption,
        placement: placement,
      )[
        #table(
          columns: columns,
          align: (left,) + (center,) * (columns.len() - 1),
          stroke: (x, y) => {
            if y == 0 { return 1pt + black }
            if y == 1 { return 0.5pt + black }
            return 0.3pt + rgb(200, 200, 200)
          },
          inset: 6pt,
          ..header.map(h => [*#h*]),
          ..data.flatten(),
        )
      ]
    ]
  }
}