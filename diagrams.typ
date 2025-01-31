#import "@preview/cetz:0.3.0": canvas, draw, tree
#import draw: content

// TODO:
// - chevrons instead of op arrow
// - play tetris

#set page(
  "us-letter",
  margin: 0.5in,
  flipped: false,
)

// Color definitions
#let text-color = rgb("#47423c")
#let primary-color = rgb("#e2c093")
#let secondary-color-1 = rgb("#7a8295")
#let secondary-color-2 = rgb("#6c630b")
#let accent-color = rgb("#cc3516")
#let background-color = rgb("#faf2e0")
#let highlight-color = rgb("#f4d960")
#let outer-border-color = rgb("f8e8c8")

// Color aliases
#let node-color = primary-color
#let arrow-color = text-color
#let working-color = accent-color // color of @
#let bookmark-color = secondary-color-1
#let description-color = secondary-color-2
#let operation-color = text-color
#let repository-color = background-color

// Positions are specified as a (row, col) pair:
//
//     0,0
//      |
//     1,0
//    /   \
//  2,-1  2,1
#let pos(row-and-col) = {
  let (row, col) = row-and-col
  (0.55*col, -1.25 * row)
}

// Sizes
#let node-radius = 0.3
#let arrow-tail-gap = 0.075
#let arrow-head-gap = 0.075

// Settings
#set text(font: "IBM Plex Mono")
#set text(weight: "bold")
#set text(fill: text-color)
#set text(size: 9.5pt)

// Mention a bookmark name in text
#let text-bookmark(bookmark-name) = text(fill: bookmark-color, bookmark-name)

// Mention a description in text
#let text-description(description) = text(fill: description-color)["#description"]

// Freeform text, for describing operations that don't lend themselves to pictures.
#let text-freeform(freeform) = text(style: "italic", weight: "regular", font: "IBM Plex Sans", freeform)

// Text mentioning the state of the filesystem at a change.
#let text-files(label) = {
  text(font: "IBM Plex Mono", weight: "bold", style: "normal")[_#[Files#label]_]
}

// Highlight a piece of text
#let text-highlight(stuff) = highlight(
  fill: highlight-color,
  top-edge: 1.5em,
  bottom-edge: -0.75em,
  extent: 0.25em,
  radius: 1.25em,
  stuff
)
#let text-highlight(stuff) = [#stuff#h(0.2em)#super(box(circle(
  radius: 0.5em,
  fill: highlight-color,
)))]

// Draw a box around a repo state
#let repository(contents) = align(left, {
  rect(
    stroke: (
      paint: text-color,
      thickness: 0.05em,
    ),
    radius: 0.5em,
    inset: 0.75em,
    //fill: repository-color,
    contents
  )
})

// Draw a node.
#let change(
  change-id,
  row-and-col,
  working: false,
  bookmark: none,
  highlighted-bookmark: none,
  description: none,
  highlighted-description: none,
  files: none,
  highlighted-files: none,
) = {
  draw.circle(
    pos(row-and-col),
    name: change-id,
    radius: node-radius,
    stroke: none,
    fill: node-color,
  )
  content((rel: (0, 0.03), to: change-id), change-id)

  if working {
    content(
      (rel: (-(node-radius + 0.15), 0), to: change-id),
      text(fill: working-color, "@")
    )
  }

  let rhs = ()
  if bookmark != none {
    rhs.push(text(fill: bookmark-color)[#h(0.25em)---#h(0.25em)#bookmark])
  }
  if highlighted-bookmark != none {
    rhs.push(text(fill: bookmark-color)[#h(0.25em)---#h(0.25em)#text-highlight(highlighted-bookmark)])
  }
  if description != none {
    rhs.push(text(fill: description-color)[#h(0.25em) "#description"])
  }
  if highlighted-description != none {
    rhs.push(text(fill: description-color)[#h(0.25em) #text-highlight["#highlighted-description"]])
  }
  if files != none {
    rhs.push[#h(0.5em)_#[Files#files]_]
  }
  if highlighted-files != none {
    rhs.push[#h(0.5em)#text-highlight[_#[Files#highlighted-files]_]]
  }

  if rhs.len() > 0 {
    let rhs-content = rhs.join(linebreak())
    if rhs.len() > 1 {
      rhs-content = [#v(0.5em) #rhs-content]
    }
    content(
      (name: change-id, anchor: "east"),
      anchor: "west",
      rhs-content,
    )
  }
}

// Leave a blank space at this position.
// (Used to align nodes between different repo drawings.)
#let blank(row-and-col) = {
  draw.circle(pos(row-and-col), radius: node-radius, stroke: none, fill: none)
}

// Draw an ellipsis
#let ellipsis(row-and-col) = {
  let (x, y) = pos(row-and-col)
  content((x, y + 0.19), "...")
}

// Draw an edge.
#let edge(from-change-id, to-change-id) = {
  draw.line(
    (from-change-id, node-radius + arrow-tail-gap, to-change-id),
    (to-change-id, node-radius + arrow-head-gap, from-change-id),
    // Options: "triangle", "stealth", "straight", "barbed"
    mark: (
      length: 0.1,
      width: 0.15,
      end: "straight"
    ),
    stroke: (
      paint: arrow-color,
      thickness: 0.13em,
    ),
    //fill: arrow-color,
  )
}

#let operation(label) = {
  content(
    (0.5, -0.75),
    anchor: "west",
    {
      set par(leading: 0.5em)
      label
    }
  )
}

#let operation-arrow = {
  draw.line(
    (0, 0),
    (0.55, 0),
    // Options: "triangle", "stealth", "straight", "barbed"
    mark: (
      end: "triangle",
      length: 0.1,
      width: 0.1,
    ),
    stroke: (
      paint: operation-color,
      thickness: 0.4em,
    ),
    fill: operation-color,
  )
}

#let op-wrapper(stuff) = block(breakable: false, rect(
  //stroke: none,
  radius: 0.5em,
  inset: 0.75em,
  stroke: (
    paint: outer-border-color,
    thickness: 0.15em,
  ),
  fill: repository-color,
  align(center, stuff)
))
#let op-spacing = -0.4em

#let read-op(op, repo) = op-wrapper({
  canvas(operation(op))
  v(op-spacing)
  repository(canvas(repo))
})

#let freeform-read-op(op, repo, what-it-does) = op-wrapper({
  canvas(operation(op))
  v(op-spacing)
  repository(canvas(repo))
  v(op-spacing)
  text-freeform(what-it-does)
})

#let write-op(before, op, after) = op-wrapper({
  canvas(operation(op))
  v(op-spacing)
  grid(
    columns: (auto, 2em, auto),
    repository(canvas(before)),
    align(horizon+left, canvas(operation-arrow)),
    repository(canvas(after))
  )
})

#let freeform-op(op, what-it-does) = op-wrapper({
    canvas(operation(op))
    v(op-spacing)
    text-freeform(what-it-does)
})

// ~~~~
// Info
// ~~~~

#let jj-status = freeform-op(
  [jj status],
  [Shows current&parent \ change and file \ modifications.],
)

#let jj-log = freeform-op(
  [jj log -r ..],
  [Shows all changes \ in the repo.],
)

// ~~~~~~~~~
// Bookmarks
// ~~~~~~~~~

#let jj-bookmark-create = write-op(
  change("r", (0, 0), working: true),
  [jj bookmark create #text-bookmark("feat/ui")],
  change("r", (0, 0), working: true, bookmark: "feat/ui")
)

#let jj-bookmark-rename = write-op(
  change("r", (0, 0), bookmark: "feat/ui"),
  [jj bookmark rename #text-bookmark("feat/ui") #text-bookmark("feat/ux")],
  change("r", (0, 0), bookmark: "feat/ux")
)

#let jj-bookmark-delete = write-op(
  change("r", (0, 0), bookmark: "feat/ui"),
  [jj bookmark delete #text-bookmark("feat/ui")],
  change("r", (0, 0))
)

#let jj-bookmark-move = write-op(
  {
    change("r", (0, 0), working: true)
    ellipsis((0.5, 0))
    change("q", (1, 0), bookmark: "feat/ui")
  },
  [jj bookmark move #text-bookmark("feat/ui")],
  {
    change("r", (0, 0), working: true, bookmark: "feat/ui")
    ellipsis((0.5, 0))
    change("q", (1, 0))
  }
)

#let jj-bookmark-list = freeform-read-op(
  [jj bookmark list],
  {
    change("r", (0, 0), highlighted-bookmark: "feat/ui")
    ellipsis((0.5, 0))
    change("q", (1, 0), highlighted-bookmark: "feat/api")
  },
  [#text-highlight[] Prints all bookmarks.]
)

// ~~~~~~~~~~~~
// Descriptions
// ~~~~~~~~~~~~

#let jj-show = freeform-read-op(
  [jj show],
  change("r", (0, 0), working: true, highlighted-description: "edit foo"),
  [#text-highlight[] Prints this change's description.]
)

#let jj-describe = write-op(
  change("r", (0, 0), working: true, description: "edti foo"),
  [jj describe -m #text-description("edit foo")],
  change("r", (0, 0), working: true, description: "edit foo")
)

// ~~~~~
// Graph
// ~~~~~

#let jj-edit = write-op(
  {
    change("r", (0, 0), working: true)
    ellipsis((0.57, 0))
    change("q", (1.14, 0))
  },
  [jj edit q],
  {
    change("r", (0, 0))
    ellipsis((0.57, 0))
    change("q", (1.14, 0), working: true)
  }
)

#let jj-new = write-op(
  {
    blank((0, 0))
    change("q", (1, 0), working: true, bookmark: "bmark", description: "edit foo")
  },
  [jj new],
  {
    change("r", (0, 0), working: true)
    change("q", (1, 0), bookmark: "bmark", description: "edit foo")
    edge("r", "q")
  }
)

#let jj-merge = write-op(
  {
    blank((0, 0))
    blank((1.14, 0))
    change("p", (1, -1))
    change("q", (1, 1))
  },
  [jj new p q],
  {
    blank((1.14, 0))
    change("r", (0, 0), working: true)
    change("p", (1, -1))
    change("q", (1, 1))
    edge("r", "p")
    edge("r", "q")
  }
)

#let jj-abandon = write-op(
  {
    blank((2.14, 0))
    change("r", (0, 0), files: 3)
    change("q", (1, 0), files: 2)
    change("p", (2, 0), files: 1)
    edge("r", "q")
    edge("q", "p")
  },
  [jj abandon q],
  {
    blank((2.14, 0))
    change("r", (0, 0), files: 3)
    change("p", (2, 0), files: 1)
    edge("r", "p")
  }
)

// ~~~~~
// Files
// ~~~~~

#let jj-diff = freeform-read-op(
  [jj diff (paths..)],
  {
    change("r", (0, 0), working: true, highlighted-files: 2)
    change("q", (1, 0), highlighted-files: 1)
    edge("r", "q")
  },
  [#text-highlight[] Prints the diff between \ #text-files(1) and #text-files(2).]
)

#let jj-restore = write-op(
  {
    change("r", (0, 0), working: true, files: 2)
    ellipsis((0.5, 0))
    change("q", (1, 0), files: 1)
  },
  [jj restore \-\-from q (paths..)],
  {
    change("r", (0, 0), working: true, files: 1)
    ellipsis((0.5, 0))
    change("q", (1, 0), files: 1)
  }
)

#let jj-squash = write-op(
  {
    change("r", (0, 0), working: true, files: 2)
    change("q", (1, 0), files: 1)
    edge("r", "q")
  },
  [jj squash],
  {
    change("r", (0, 0), working: true, files: 2)
    change("q", (1, 0), files: 2)
    edge("r", "q")
  }
)

#let jj-backout = write-op(
  {
    blank((0, 0))
    blank((2.14, 0))
    change("r", (1, 0), working: true, description: "msg", files: 2)
    change("q", (2, 0), files: 1)
    edge("r", "q")
  },
  [jj backout],
  {
    change("s", (0, 0), description: [Backout 'msg'], files: 1)
    change("r", (1, 0), working: true, description: "msg", files: 2)
    change("q", (2, 0), files: 1)
    edge("s", "r")
    edge("r", "q")
  }
)

// ~~~~~~~~~~~~~
// Miscellaneous
// ~~~~~~~~~~~~~

#let jj-undo = freeform-op(
  [jj undo],
  [Undoes the \ last command.],
)

// ~~~~~~~~~~~
// Cheat Sheet
// ~~~~~~~~~~~

#align(center)[= JJ Cheat Sheet]
#v(1em)

#let row(..args) = {
  stack(dir: ltr, spacing: 2.5em, ..args)
  v(0.5em)
}

#row(
  jj-edit,
  jj-new,
  jj-merge,
)
#row(
  jj-status,
  jj-show,
  jj-describe,
)
#row(
  jj-bookmark-list,
  jj-bookmark-create,
  jj-bookmark-move,
)
#row(
  jj-bookmark-rename,
  jj-bookmark-delete,
  jj-log,
)
#row(
  jj-diff,
  jj-restore,
  jj-squash,
)
#row(
  jj-backout,
  jj-abandon,
  jj-undo,
)

#place(bottom + right)[
  #set text(weight: "regular")
  #set align(center)
  justinpombrio.net \ & lark.gay
]
