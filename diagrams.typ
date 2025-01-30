#import "@preview/cetz:0.3.0": canvas, draw, tree
#import draw: *

// Color definitions
#let text-color = rgb("#47423c")
#let primary-color = rgb("#e2c093")
#let secondary-color-1 = rgb("#7a8295")
#let secondary-color-2 = rgb("#6c630b")
#let accent-color = rgb("#cc3516")

// Color aliases
#let node-color = primary-color
#let arrow-color = primary-color
#let working-color = accent-color // color of @
#let bookmark-color = secondary-color-1
#let description-color = secondary-color-2
#let operation-color = accent-color

// Positions are specified as a (row, col) pair:
//
//     0,0
//      |
//     1,0
//    /   \
//  2,-1  2,1
#let pos(row, col) = (col, -2 * row)

// Sizes
#let node-radius = 0.45
#let arrow-tail-gap = 0.10
#let arrow-head-gap = 0.10

// Settings
#set text(font: "IBM Plex Sans")
#set text(weight: "semibold")
#set text(fill: text-color)

// Mention a bookmark name in text
#let text-bookmark(bookmark-name) = text(fill: bookmark-color, bookmark-name)

// Mention a description in text
#let text-description(description) = text(fill: description-color)["#description"]

// Draw a node.
#let change(
  change-id,
  row-and-col,
  working: false,
  bookmark: none,
  description: none,
  files: none,
) = {
  let (row, col) = row-and-col
  circle(
    pos(row, col),
    name: change-id,
    radius: node-radius,
    stroke: none,
    fill: node-color,
  )
  content(change-id, change-id)

  if working {
    content(
      (rel: (-(node-radius + 0.25), 0), to: change-id),
      text(fill: working-color, "@")
    )
  }

  let rhs = ()
  if bookmark != none {
    rhs.push(text(fill: bookmark-color)[#h(0.25em)--- #bookmark])
  }
  if description != none {
    rhs.push(text(fill: description-color)[#h(0.25em) "#description"])
  }
  if files != none {
    rhs.push($F_#files$)
  }

  if rhs.len() > 0 {
    let rhs-content = rhs.join(linebreak())
    if rhs.len() > 1 {
      rhs-content = [#v(1.0em) #rhs-content]
    }
    content(
      (name: change-id, anchor: 0deg),
      anchor: "west",
      rhs-content,
    )
  }
}

// Draw an ellipsis
#let ellipsis(row-and-col) = {
  let (row, col) = row-and-col
  content(pos(row, col), "...")
}

// Draw an edge.
#let edge(from-change-id, to-change-id) = {
  line(
    (from-change-id, node-radius + arrow-tail-gap, to-change-id),
    (to-change-id, node-radius + arrow-head-gap, from-change-id),
    // Options: "triangle", "stealth", "straight", "barbed"
    mark: (end: "straight"),
    stroke: (
      paint: arrow-color,
      thickness: 0.25em,
    ),
  )
}

// Draw a big labeled operation arrow.
#let operation(row-and-col, label) = {
  let (row, col) = row-and-col
  let (x, y) = pos(row, col)
  line(
    (x - 1.25, y),
    (x + 1.50, y),
    // Options: "triangle", "stealth", "straight", "barbed"
    mark: (end: "triangle"),
    stroke: (
      paint: operation-color,
      thickness: 0.5em,
    ),
  )
  content(
    (x, y - 0.25),
    anchor: "north",
    {
      set par(leading: 0.5em)
      label
    }
  )
}

#canvas({
  change("p", (0, 0), bookmark: "main")
  change("r1", (1, -1), working: true, files: 1)
  change("r2", (1, 1), bookmark: "branch", description: "commit msg")
  change("s", (2, 0), bookmark: "branch", description: "other msg", files: 2)

  ellipsis((3, 0))

  edge("p", "r1")
  edge("p", "r2")
  edge("r1", "s")
  edge("r2", "s")

  operation((1, 6), [bookmark \ create \ #text-bookmark("branch")])
})
