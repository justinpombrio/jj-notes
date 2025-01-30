#import "@preview/cetz:0.3.0": canvas, draw, tree
#import draw: *

// Color definitions
#let text-color = rgb("#47423c")
#let primary-color = rgb("#e2c093")
#let secondary-color-1 = rgb("#7a8295")
#let secondary-color-2 = rgb("#6c630b")
#let accent-color = rgb("#cc3516")
#let arrow-color = text-color

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

// Draw a node.
#let change(change-id, row, col) = {
  // anchor(change-id, pos(row, col))
  circle(
    pos(row, col),
    name: change-id,
    radius: node-radius,
    stroke: none,
    fill: primary-color,
  )
  content(change-id, change-id)
}
// Draw an edge.
#let edge(from-change-id, to-change-id) = {
  line(
    (from-change-id, node-radius + arrow-tail-gap, to-change-id),
    (to-change-id, node-radius + arrow-head-gap, from-change-id),
    mark: (end: ">"),
    stroke: (
      paint: primary-color,
      thickness: 0.25em,
    ),
  )
}

// Mark a node as the working change (@).
#let working(change-id) = {
  content(
    (rel: (-(node-radius + 0.25), 0), to: change-id),
    text(fill: accent-color, "@")
  )
}

// Mark a node as having a bookmark.
#let bookmark-content(bookmark-name) = {
    text(fill: secondary-color-1)[#h(0.25em)--- #bookmark-name]
}
#let bookmark(change-id, bookmark-name) = {
  content(
    (name: change-id, anchor: 0deg),
    anchor: "west",
    bookmark-content(bookmark-name),
  )
}

// Show the commit message (description) for a node.
#let description-content(message) = {
    text(fill: secondary-color-2)[#h(0.25em) "#message"]
}
#let description(change-id, message) = {
  content(
    (name: change-id, anchor: 0deg),
    anchor: "west",
    description-content(message),
  )
}

#let bookmark-and-description(change-id, bookmark-name, message) = {
  content(
    (name: change-id, anchor: 0deg),
    anchor: "west",
    [\ #bookmark-content(bookmark-name) \ #description-content(message)]
  )
}

// Label the file system contents of this change.
#let file-contents(change-id, label) = {
  content(
    (rel: (node-radius + 0.25, 0), to: change-id),
    $F_#label$
  )
}

#canvas({
  change("p", 0, 0)
  change("r1", 1, -1)
  change("r2", 1, 1)
  change("s", 2, 0)

  edge("p", "r1")
  edge("p", "r2")
  edge("r1", "s")
  edge("r2", "s")

  working("r1")
  file-contents("r1", 1)
  description("r2", "commit msg")
  bookmark("p", "main")
  bookmark-and-description("s", "branch", "other msg")
})
