#import "@preview/cetz:0.3.0": canvas, draw, tree
#import draw: content

#set page(
  "us-letter",
  margin: 0.5in,
  flipped: false,
)

// Overall scale (everything is in em)
#set text(size: 9.5pt)

// Color definitions
#let text-color = rgb("#47423c")
#let edge-color = text-color
#let node-color = rgb("#e2c093")
#let bookmark-color = rgb("#7a8295")
#let description-color = rgb("#6c630b")
#let working-color = rgb("#cc3516")
#let repository-background-color = rgb("#faf2e0")
#let repository-border-color = rgb("f8e8c8")
#let highlight-color = rgb("#f4d960")

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
#let command-spacing = -0.4em
#let explanation-spacing = -0.4em

// Two primary fonts
#let font-mono(some-text) = text(
  font: "IBM Plex Mono",
  size: 9.5pt,
  weight: "bold",
  fill: text-color,
  some-text
)
#let font-sans(some-text) = text(
  font: "IBM Plex Sans",
  size: 9.5pt,
  weight: "regular",
  fill: text-color,
  some-text
)

// Text styles
#let text-command(command) = font-mono(command)
#let text-bookmark(bookmark-name) = font-mono(text(fill: bookmark-color, bookmark-name))
#let text-description(description) = font-mono(text(fill: description-color)["#description"])
#let text-edit(label) = font-mono(text(style: "normal")[_#[Edit#label]_])
#let text-files(label) = font-mono(text(style: "normal")[_#[Files#label]_])
#let text-explanation(explanation) = font-sans(text(style: "normal", explanation))
#let text-highlight(stuff) = stuff
// #let text-highlight(stuff) = [#stuff#h(0.2em)#super(box(circle(
//   radius: 0.5em,
//   fill: highlight-color,
// )))]
#let text-attribution(attr) = font-mono(text(weight: "semibold", attr))

// Draw a box around a repo state
#let repository(contents) = align(center, {
  rect(
    stroke: (
      paint: text-color,
      thickness: 0.05em,
    ),
    radius: 0.5em,
    inset: 0.75em,
    contents
  )
})

#let working-glyph = font-mono(text(fill: working-color, "@"))

#let node(change-id, row-and-col) = {
  draw.circle(
    pos(row-and-col),
    name: change-id,
    radius: node-radius,
    stroke: none,
    fill: node-color,
  )
  content((rel: (0, 0.03), to: change-id), font-mono(change-id))
}

// Draw a node.
#let change(
  change-id,
  row-and-col,
  working: false,
  bookmark: none,
  highlighted-bookmark: none,
  description: none,
  highlighted-description: none,
  edit: none,
  highlighted-edit: none,
  files: none,
  highlighted-files: none,
) = {
  node(change-id, row-and-col)

  if working {
    content(
      (rel: (-(node-radius + 0.15), 0), to: change-id),
      working-glyph
    )
  }

  let rhs = ()
  if bookmark != none {
    rhs.push(text-bookmark[#h(0.25em)---#h(0.25em)#bookmark])
  }
  if highlighted-bookmark != none {
    rhs.push(text-bookmark[#h(0.25em)---#h(0.25em)#text-highlight(highlighted-bookmark)])
  }
  if description != none {
    rhs.push[#h(0.25em)#text-description(description)]
  }
  if highlighted-description != none {
    rhs.push[#h(0.25em)#text-highlight(text-description(highlighted-description))]
  }
  if files != none {
    rhs.push[#h(0.25em)#text-files(files)]
  }
  if highlighted-files != none {
    rhs.push[#h(0.3em)#text-highlight(text-files(highlighted-files))]
  }
  if edit != none {
    rhs.push[#h(0.25em)#text-edit(edit)]
  }
  if highlighted-edit != none {
    rhs.push[#h(0.3em)#text-highlight(text-edit(highlighted-edit))]
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
  content((x, y + 0.21), font-mono(text(size: 12pt, weight: "regular")[...]))
}

// Draw an edge.
#let edge(from-change-id, to-change-id) = {
  draw.line(
    (from-change-id, node-radius + 0.075, to-change-id),
    (to-change-id, node-radius + 0.075, from-change-id),
    // Options: "triangle", "stealth", "straight", "barbed"
    mark: (
      length: 0.1,
      width: 0.08,
      fill: edge-color,
      end: "triangle",
    ),
    //mark: (
    //  length: 0.1,
    //  width: 0.15,
    //  end: "straight"
    //),
    stroke: (
      paint: edge-color,
      thickness: 0.13em,
    ),
  )
}

#let command-wrapper(stuff) = block(breakable: false, rect(
  radius: 0.5em,
  inset: 0.75em,
  stroke: (
    paint: repository-border-color,
    thickness: 0.15em,
  ),
  fill: repository-background-color,
  align(center, stuff)
))

#let read-command(cmd, repo, explanation) = command-wrapper({
  text-command(cmd)
  v(command-spacing)
  repository(canvas(repo))
  v(explanation-spacing)
  text-explanation(explanation)
})

#let write-command(repo-before, cmd, repo-after) = command-wrapper({
  text-command(cmd)
  v(command-spacing)
  grid(
    columns: (auto, 2em, auto),
    repository(canvas(repo-before)),
    align(horizon + center,
      move(dy: -0.2em,
        text(
          size: 20pt,
          weight: "regular",
          math.angle.r
        )
      )
    ),
    repository(canvas(repo-after))
  )
})

#let freeform-command(cmd, explanation) = command-wrapper({
    text-command(cmd)
    v(explanation-spacing)
    text-explanation(explanation)
})

// ~~~~
// Info
// ~~~~

#let jj-status = freeform-command(
  [jj status],
  [Shows current and \ parent change, \ and file modifications.],
)

#let jj-plain = freeform-command(
  [jj],
  [Shows important changes \ in the repo.],
)

#let jj-log = freeform-command(
  [jj log -r ..],
  [Shows all changes \ in the repo.],
)

// ~~~~~~~~~
// Bookmarks
// ~~~~~~~~~

#let jj-bookmark-create = write-command(
  change("r", (0, 0), working: true),
  [jj bookmark create #text-bookmark("feat/ui")],
  change("r", (0, 0), working: true, bookmark: "feat/ui")
)

#let jj-bookmark-rename = write-command(
  change("r", (0, 0), bookmark: "feat/ui"),
  [jj bookmark rename #text-bookmark("feat/ui") #text-bookmark("feat/ux")],
  change("r", (0, 0), bookmark: "feat/ux")
)

#let jj-bookmark-delete = write-command(
  change("r", (0, 0), bookmark: "feat/ui"),
  [jj bookmark delete #text-bookmark("feat/ui")],
  change("r", (0, 0))
)

#let jj-bookmark-move = write-command(
  {
    change("q", (0, 0), bookmark: "feat/ui")
    change("r", (0, 5.5), working: true)
  },
  [jj bookmark move #text-bookmark("feat/ui")],
  {
    change("q", (0, 0))
    change("r", (0, 2.5), working: true, bookmark: "feat/ui")
  }
)

#let jj-bookmark-list = read-command(
  [jj bookmark list],
  {
    change("r", (0, 0), highlighted-bookmark: "feat/ui")
    change("q", (0, 4.8), highlighted-bookmark: "feat/api")
  },
  [#text-highlight[] Prints all bookmarks.]
)

// ~~~~~~~~~~~~
// Descriptions
// ~~~~~~~~~~~~

#let jj-show = read-command(
  [jj show],
  change("r", (0, 0), working: true, highlighted-description: "edit foo"),
  [#text-highlight[] Prints this change's description.]
)

#let jj-describe = write-command(
  change("r", (0, 0), working: true, description: "edti foo"),
  [jj describe -m #text-description("edit foo")],
  change("r", (0, 0), working: true, description: "edit foo")
)

// ~~~~~
// Graph
// ~~~~~

#let jj-edit = write-command(
  {
    change("r", (0, 0), working: true)
    change("q", (0, 2.4))
  },
  [jj edit q],
  {
    change("r", (0, 0))
    change("q", (0, 2.4), working: true)
  }
)

#let jj-new = write-command(
  {
    blank((0, 0))
    change("q", (1, 0), working: true, bookmark: "feat/ui", description: "edit foo")
  },
  [jj new],
  {
    change("r", (0, 0), working: true)
    change("q", (1, 0), bookmark: "feat/ui", description: "edit foo")
    edge("r", "q")
  }
)

#let jj-merge = write-command(
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

#let jj-abandon = write-command(
  {
    blank((2.14, 0))
    change("r", (0, 0), edit: 3)
    change("q", (1, 0), edit: 2)
    change("p", (2, 0), edit: 1)
    edge("r", "q")
    edge("q", "p")
  },
  [jj abandon q],
  {
    blank((2.14, 0))
    change("r", (0, 0), edit: 3)
    change("p", (2, 0), edit: 1)
    edge("r", "p")
  }
)

// ~~~~~
// Files
// ~~~~~

#let jj-diff = read-command(
  [jj diff (paths..)],
  {
    change("r", (0, 0), working: true, highlighted-files: 2)
    change("q", (1, 0), highlighted-files: 1)
    edge("r", "q")
  },
  [#text-highlight[] Prints the diff between \ #text-files(1) and #text-files(2).]
)

#let jj-restore = write-command(
  {
    change("r", (0, 0), working: true, files: 2)
    change("q", (0, 4), files: 1)
  },
  [jj restore \-\-from q (paths..)],
  {
    change("r", (0, 0), working: true, files: 1)
    change("q", (0, 4), files: 1)
  }
)

#let jj-squash = write-command(
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

#let jj-backout = write-command(
  {
    blank((0, 0))
    blank((2.14, 0))
    change("r", (1, 0), working: true, description: "msg", files: 2)
    change("q", (2, 0), files: 1)
    edge("r", "q")
  },
  [jj backout],
  {
    change("s", (0, 0), description: text(tracking: -0.5pt)[Backout 'msg'], files: 1)
    change("r", (1, 0), working: true, description: "msg", files: 2)
    change("q", (2, 0), files: 1)
    edge("s", "r")
    edge("r", "q")
  }
)

// ~~~~~~~~~~~~~
// Miscellaneous
// ~~~~~~~~~~~~~

#let jj-undo = freeform-command(
  [jj undo],
  [Undoes the last command.#h(-0.35em)],
)

// ~~~~~~
// Legend
// ~~~~~~

#let make-legend(args) = {
  let cells = ()
  for (thing, explanation) in args {
    cells.push(thing)
    cells.push(font-mono[---])
    cells.push(text-explanation(explanation))
  }
  grid(
    columns: (auto, 2em, auto),
    align: (right+horizon, center+horizon, left+horizon),
    row-gutter: (0.4em, 0.75em, 0.75em, 0.75em, 0.75em),
    ..cells
  )
}
#let legend = make-legend((
  (canvas(node("r", (0, 0))), [a _change_]),
  (working-glyph, [the _working change_ ("working copy revision")]),
  (text-description("edit foo"), [a change's _description_]),
  (text-bookmark("feat/ui"), [a _bookmark_]),
  (text-files(1), [a state of the filesystem]),
  (text-edit(1), [a change's diff]),
))

// ~~~~~~~~~~~
// Cheat Sheet
// ~~~~~~~~~~~

#align(center)[#text(font: "IBM Plex Sans")[= JJ Cheat Sheet]]
#v(1em)

#let row(..args) = {
  stack(dir: ltr, spacing: 1.8em, ..args)
  v(0.5em)
}
#let col(..args) = {
  stack(dir: ttb, spacing: 1.0em, ..args)
}

#row(
  col(
    jj-plain,
    jj-undo,
  ),
  jj-new,
  jj-merge,
)
#row(
  jj-status,
  jj-describe,
  jj-show,
)
#row(
  jj-bookmark-list,
  jj-bookmark-create,
  jj-bookmark-delete,
)
#row(
  jj-bookmark-move,
  jj-bookmark-rename,
)
#row(
  jj-edit,
  jj-restore,
)
#row(
  jj-backout,
  jj-abandon,
  jj-diff,
)
#row(
  jj-squash,
  legend,
)

#place(bottom + right, text-attribution[justinpombrio.net \ & lark.gay \ Feb 2025])
