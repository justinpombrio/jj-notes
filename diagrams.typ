#import "@preview/cetz:0.3.0": canvas, draw, tree
#import draw: circle, line, content

#set page(
  "us-letter",
  margin: 0.5in,
)

// Color definitions
#let text-color = rgb("#47423c")
#let primary-color = rgb("#e2c093")
#let secondary-color-1 = rgb("#7a8295")
#let secondary-color-2 = rgb("#6c630b")
#let accent-color = rgb("#cc3516")
#let background-color = rgb("#eeeeee")
#let highlight-color = yellow

// Color aliases
#let node-color = primary-color
#let arrow-color = primary-color
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
  (col, -2 * row)
}

// Sizes
#let node-radius = 0.45
#let arrow-tail-gap = 0.10
#let arrow-head-gap = 0.10

// Settings
#set text(font: "IBM Plex Mono")
#set text(weight: "semibold")
#set text(fill: text-color)

// Mention a bookmark name in text
#let text-bookmark(bookmark-name) = text(fill: bookmark-color, bookmark-name)

// Mention a description in text
#let text-description(description) = text(fill: description-color)["#description"]

// Freeform text, for describing operations that don't lend themselves to pictures.
#let text-freeform(freeform) = text(style: "italic", font: "IBM Plex Sans", freeform)

// Highlight a piece of text
#let text-highlight(stuff) = highlight(
  fill: highlight-color,
  top-edge: 1.5em,
  bottom-edge: -0.75em,
  extent: 0.25em,
  radius: 1.25em,
  stuff
)

// Draw a box around a repo state
#let repository(contents) = align(left, {
  rect(
    stroke: none,
    radius: 0.5em,
    inset: 0.75em,
    width: 12em,
    fill: repository-color,
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
  circle(
    pos(row-and-col),
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
  if highlighted-bookmark != none {
    rhs.push(text(fill: bookmark-color)[#h(0.25em)--- #text-highlight(highlighted-bookmark)])
  }
  if description != none {
    rhs.push(text(fill: description-color)[#h(0.25em) "#description"])
  }
  if highlighted-description != none {
    rhs.push(text(fill: description-color)[#h(0.25em) #text-highlight["#highlighted-description"]])
  }
  if files != none {
    rhs.push[#h(0.5em)_#[F#files]_]
  }
  if highlighted-files != none {
    rhs.push[#h(0.5em)#text-highlight[_#[F#highlighted-files]_]]
  }

  if rhs.len() > 0 {
    let rhs-content = rhs.join(linebreak())
    if rhs.len() > 1 {
      rhs-content = [#v(0.5em) #rhs-content]
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
  let (x, y) = pos(row-and-col)
  content((x, y + 0.19), "...")
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
#let operation(label) = {
  line(
    (0, 0),
    (0, -1.5),
    // Options: "triangle", "stealth", "straight", "barbed"
    mark: (end: "triangle"),
    stroke: (
      paint: operation-color,
      thickness: 0.25em,
    ),
  )
  content(
    (0.5, -0.75),
    anchor: "west",
    {
      set par(leading: 0.5em)
      label
    }
  )
}

#let read-op(op, repo) = align(center, {
  canvas(operation(op))
  repository(canvas(repo))
})

#let write-op(before, op, after) = align(center, {
  repository(canvas(before))
  canvas(operation(op))
  repository(canvas(after))
})

#let freeform-op(op, what-it-does) = align(center, {
  canvas(operation(op))
  text-freeform(what-it-does)
})

// ~~~~
// Info
// ~~~~

#let jj-status = freeform-op(
  [jj status],
  [Shows current&parent change and file modifications.]
)

#let jj-log = freeform-op(
  [jj log -r ..],
  [Shows all changes in the repo.]
)

// ~~~~~~~~~
// Bookmarks
// ~~~~~~~~~

#let jj-bookmark-create = write-op(
  change("r", (0, 0), working: true),
  [jj bookmark create \ #text-bookmark("my-branch")],
  change("r", (0, 0), working: true, bookmark: "my-branch")
)

#let jj-bookmark-rename = write-op(
  change("r", (0, 0), bookmark: "old-name"),
  [jj bookmark rename \ #text-bookmark("old-name") \ #text-bookmark("new-name")],
  change("r", (0, 0), bookmark: "new-name")
)

#let jj-bookmark-delete = write-op(
  change("r", (0, 0), bookmark: "my-branch"),
  [jj bookmark delete \ #text-bookmark("my-branch")],
  change("r", (0, 0))
)

#let jj-bookmark-move = write-op(
  {
    change("r", (0, 0), working: true)
    ellipsis((0.5, 0))
    change("q", (1, 0), bookmark: "my-branch")
  },
  [jj bookmark move \ #text-bookmark("my-branch")],
  {
    change("r", (0, 0), working: true, bookmark: "my-branch")
    ellipsis((0.5, 0))
    change("q", (1, 0))
  }
)

#let jj-bookmark-list = read-op(
  [jj bookmark list],
  {
    change("r", (0, 0), highlighted-bookmark: "branch-1")
    ellipsis((0.5, 0))
    change("q", (1, 0), highlighted-bookmark: "branch-2")
  }
)

// ~~~~~~~~~~~~
// Descriptions
// ~~~~~~~~~~~~

#let jj-show = read-op(
  [jj show],
  change("r", (0, 0), working: true, highlighted-description: "commit msg")
)

#let jj-describe = write-op(
  change("r", (0, 0), working: true, description: "old msg"),
  [jj describe \ -m #text-description("new msg")],
  change("r", (0, 0), working: true, description: "new msg")
)

// ~~~~~
// Graph
// ~~~~~

#let jj-edit = write-op(
  {
    change("r", (0, 0), working: true)
    ellipsis((0.5, 0))
    change("q", (1, 0))
  },
  [jj edit q],
  {
    change("r", (0, 0))
    ellipsis((0.5, 0))
    change("q", (1, 0), working: true)
  }
)

#let jj-new = write-op(
  change("q", (1, 0), working: true, bookmark: "my-branch", description: "commit msg"),
  [jj new],
  {
    change("r", (0, 0), working: true)
    change("q", (1, 0), bookmark: "my-branch", description: "commit msg")
    edge("r", "q")
  }
)

#let jj-merge = write-op(
  {
    change("p", (1, -1))
    change("q", (1, 1))
  },
  [jj new p q],
  {
    change("r", (0, 0), working: true)
    change("p", (1, -1))
    change("q", (1, 1))
    edge("r", "p")
    edge("r", "q")
  }
)

#let jj-abandon = write-op(
  {
    change("r", (0, 0), files: 3)
    change("q", (1, 0), files: 2)
    change("p", (2, 0), files: 1)
    edge("r", "q")
    edge("q", "p")
  },
  [jj abandon r],
  {
    change("r", (0, 0), files: 3)
    change("p", (1, 0), files: 1)
    edge("r", "p")
  }
)

// ~~~~~
// Files
// ~~~~~

#let jj-diff = read-op(
  [jj diff \ (paths..)],
  {
    change("r", (0, 0), working: true, highlighted-files: 2)
    change("q", (1, 0), highlighted-files: 1)
    edge("r", "q")
  }
)

#let jj-restore = write-op(
  {
    change("r", (0, 0), working: true, files: 2)
    ellipsis((0.5, 0))
    change("q", (1, 0), files: 1)
  },
  [jj restore \ \-\-from q \ (paths..)],
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
    change("r", (0, 0), working: true, description: "msg", files: 2)
    change("q", (1, 0), files: 1)
    edge("r", "q")
  },
  [jj backout],
  {
    change("s", (-1, 0), description: "Backout 'msg'", files: 1)
    change("r", (0, 0), working: true, description: "msg", files: 2)
    change("q", (1, 0), files: 1)
    edge("s", "r")
    edge("r", "q")
  }
)

// ~~~~~~~~~~~~~
// Miscellaneous
// ~~~~~~~~~~~~~

#let jj-undo = freeform-op(
  [jj undo],
  [Undoes the last command.]
)

// ~~~~~~~~~~~
// Cheat Sheet
// ~~~~~~~~~~~

#grid(
  columns: (1fr, 1fr, 1fr, 1fr),
  column-gutter: 3em,
  row-gutter: 2em,
)[
  #jj-status
][
  #jj-log
][
  #jj-bookmark-list
][
  #jj-bookmark-create
][
  #jj-bookmark-rename
][
  #jj-bookmark-delete
][
  #jj-bookmark-move
][
  #jj-show
][
  #jj-describe
][
  #jj-edit
][
  #jj-new
][
  #jj-merge
][
  #jj-diff
][
  #jj-restore
][
  #jj-squash
][
  #jj-backout
][
  #jj-abandon
][
  #jj-undo
]
