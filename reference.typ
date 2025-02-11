#let emph-color = rgb("#177")
#let command-color = rgb("#911")

#set page(
  "us-letter",
  margin: 0.5in,
  columns: 2,
)

#set text(
  size: 9pt,
  font: "IBM Plex Sans"
)
#show heading.where(level: 1): set align(center)

#show raw: it => text(font: "IBM Plex Mono", weight: "semibold", fill: command-color, it)
#show emph: it => text(fill: emph-color, weight: "semibold", it)


= JJ Reference

// This is a _reference_ for the Jujutsu version control system. It exists to help you learn and
// remember the details of Jujutsu, once you have already grokked the basics.

== Model

A Jujutsu repository is a DAG (directed acyclic graph) whose nodes are called _changes_. Each change
has:

- A state of the filesystem within the repository directory. You can imagine each change storing a
  full copy of the directory and all the files in it, though `jj` is more efficient than this.
- File _conflicts_. Some files in a change may contain conflicts, from a variety of different
  sources. These conflicts are local to the change. (Unlike `git`, they do not block your use of
  `jj`.)
- One or more _parent_ changes. Though there is a root change which has no parents and always has
  an empty directory.
- A textual _description_ of the change, a.k.a. a commit message. This is always present, but
  defaults to the empty string.

There is some additional information attached to the DAG:

- Exactly one of the changes is the _working change_, written `@`. The docs call this the "working
  copy revision". (This is analogous to `git`'s `HEAD`.)
- There may be some _bookmarks_, which are unique string labels on changes. (When interfacing with
  `git`, these bookmarks act as branch names.)
- The repository may also be linked to a _remote repository_ (e.g. Github). If so, when `push`ing
  and `fetch`ing, `jj` records the _last known position_ of each remote bookmark, written
  `BOOKMARK@REMOTE` (e.g. `feat-ui@origin`).

Most `jj` commands modify your local repository DAG in some way. Some general rules will help you
predict how it responds to modifications:

- When you make `@` point at a change, your repository directory is updated to match that change's
  files.
- If you delete the change that `@` is pointing at, `@` moves to a new empty change off of its
  parent(s).
- If a change has no file modifications and no description, and is not referenced by `@` or by a
  bookmark, it disappears silently into the night.
- A change represents a diff. Moving a change tries to apply the diff to its new parent. This
  may cause merge conflicts.
- Many commands act on `@` by default. Almost all of them can take a `-r/--revision` argument to act
  on a different change.
  // (Of the commands in the Cheat Sheet that show `@`, all can be applied to a
  // different change using `-r` except for `jj bookmark move` and `jj restore`, which take `--from`
  // and `--to` arguments instead.)

=== File Conflicts

If the working change (`@`) has a _file conflict_, resolving it is as simple as editing the file so
as to no longer have conflict markers (`<<<<<<<`, `=======`, etc.) in it. For a binary file,
replace the file with the version you want. `jj restore` may be useful for this purpose. (Unlike
`git`, file conflicts don't block you.)

=== jj git push

`jj git push` copies changes from the local repo into the remote repo. If a local change has been
modified since it was last pushed, it becomes a brand new change in the remote repo (just like
force pushing in `git` replaces old commits with new commits). To prevent you from accidentally
doing this to `main`, `jj git push` makes all pushed changes in the primary branch immutable. You
can still edit them if you want, but you have to pass the `--ignore-immutable` flag.

All local bookmarks are similarly copied to the remote repo. If a bookmark is present
both locally and remotely, `jj` checks if its (locally recorded) _last seen position_ matches its
current position in the remote repo. If so, the bookmark's position in the remote repo is updated.
If not, this command fails and tells you to `jj git fetch` first (because it means that someone else
updated the bookmark since you last pushed it).

=== jj git fetch

`jj git fetch` copies changes from the remote repo into the local repo. If a change has been
modified in the remote repo, it turns into a new change locally. Though most of the time you're just
fetching fresh new changes.

Local bookmarks are advanced to match the change that they're on in the remote repo. However, if the
change a bookmark is on in the remote is not a descendant of the change it's on locally,
`jj git fetch` creates a second copy of that bookmark.
This is called a _bookmark conflict_ because it violates the invariant that bookmark names
are unique. (This is analogous to `git pull` producing a merge conflict.) It is
up to you how to resolve this "bookmark conflict". Some of the options available to you:

- If you want to merge the two changes, say `jj new CHANGE-ID-1 CHANGE-ID-2`, resolve any file
  conflicts, then update the bookmark with `jj bookmark move BOOKMARK-NAME`.
  (You can get the change ids by running `jj bookmark list BOOKMARK-NAME`.)
- If you want to discard one of the two changes and just use the other one, say
  `jj bookmark move BOOKMARK-NAME -r CHANGE-ID` for the change you want to keep.
- If you want to rebase one of the changes to come _after_ the other, say
  `jj rebase -b CHANGE-ID-2 -d CHANGE-ID-1`, then
  `jj bookmark move BOOKMARK-NAME -r CHANGE-ID-2`.
  This will rebase not only the second change itself, but all changes after it forked away from the
  first change.

== Commands

=== Global Setup Commands

```
jj config set --user user.name  MY_NAME
jj config set --user user.email MY_EMAIL
jj config set --user ui.editor  MY_EDITOR

jj config edit --user  // Manually edit config file
```

Instead of `--user`, you can pass `--repo` to change the repository specific config, which takes
priority.

=== Repository Commands

- `jj git init`, or `jj git clone URL [DESTINATION]`. Make or clone a git-backed repo.
- `jj git init --colocate`. Make an existing `git` repo also be a `jj` repo.

=== Editing your Local Repo

The attached JJ Cheat Sheet visually describes the most common/fundamental commands for editing a
`jj` repo.

There are also a couple of "alias" commands that are best thought of as combinations of other `jj`
commands:

- `jj commit`. Shorthand for `jj describe; jj new`.
- `jj bookmark set BOOKMARK`. Either `create` or `move` the bookmark, whichever is valid.

// ## Commands
// 
// - `jj abandon REVISION`: REVISION defaults to `@`. Delete the change (delete that node in the
//   graph). It's children now point at its parent(s). This could introduce conflicts. If `@` is the
//   same as `REVISION`, make `@` be a new empty change on top of the parent.
// - `jj backout -r REVISION_r -d REVISION_d`: Create a new change (new node). Its parent is
//   `REVISION_d`. Its modification is the opposite of the modification of `REVISION_r`. Its
//   description is `Back out "THE DESCRIPTION OF REVISION_r"`.
// - `jj bookmark create BOOKMARK -r REVISION`. REVISION defaults to `@`. Label REVISION with a
//   bookmark named BOOKMARK. (Does propagate to remote.)
// - `jj bookmark delete BOOKMARK`. Deletes the bookmark label named BOOKMARK. (Does propagate to
//   remote.)
// - `jj bookmark list`. Lists all bookmarks and the changes they point at.
// - `jj bookmark rename BOOKMARK_OLD BOOKMARK_NEW`. Renames the bookmark. (QUESTION: Is this the same
//   as delete and then create? How does it interact with pushing? If you rename&push, does it delete
//   the old branch on the remote?) Is local only!
// - `jj bookmark move BOOKMARK --to REVISION`. Move the bookmark label to point at REVISION instead.
//   REVISION defaults to `@`.
// - `jj describe`. Open an editor to set the description of the current change. Or say `jj describe -m
//   "COMMIT MESSAGE"` to specify it on the command line.
// - `jj show`. Print the description for `@`.
// - `jj diff PATHS...`. Show the diff for the files at PATHS, between this revision (`@`) and its
//   parent (`@-`). You can pass `--from REVISION` and `--to REVISION` to see the diff between
//   arbitrary changes. TODO: compare to `jj interdiff`.
// - `jj interdiff PATHS...`. TODO. Is this advanced?
// - `jj edit REVISION`. Move `@` (the "working-copy revision") to point at REVISION.
// - `jj file track/untrack`.
// - `jj log PATHS...`. Prints the DAG, limited to those nodes that modified PATHS. QUESTION: when do
//   you need to run `jj log -r ..`?
// - `jj new`. Create a new empty commit on top of `@`, and edit it (move `@` to it). `-m "MESSAGE"`
//   additionally sets its description. `jj new REVISIONS...` specifies the parents of the new commit;
//   if there are multiple parents you're making a merge commit.
// - `jj status` (alias: `jj st`). Print some basic info about the repo.
// - `jj restore --from REVISION PATHS...`. Make the files for this commit match those at REVISION.
// - `jj undo`. Undo the last thing you did.
// - `jj squash`. Move all changes from this revision to its parent.
// - `jj rebase`. TODO.
// - `jj resolve!!`. TODO.
// 
// ## Alias Commands
// 
// - `jj commit`. Identical to `jj describe; jj new`.
// - `jj bookmark set BOOKMARK -r REVISION`. Either `create` or `move` the bookmark, whichever is
//   valid. `REVISION` defaults to `@`.
// 
// ## Advanced Commands
// 
// - `jj bookmark forget BOOKMARK`. Deletes the bookmark label named BOOKMARK, but "forgets" that it
//   exists remotely. It will be recreated if you pull again!
// - `jj bookmark track BOOKMARK@REMOTE`. TODO
// - `jj bookmark untrack BOOKMARK@REMOTE`. TODO
// - `jj duplicate`. TODO
// - `jj new --insert-before REVISION` and `jj new --insert-after REVISION`. TODO.
// - `jj prev` and `jj next`?
// - `jj simplify-parents`. Simplifies the DAG in a lossless way. (A -> B, A -> C, B ->+ C becomes A ->
//   B, B ->+ C).
// - `jj workspace`. TODO.
// - `jj undo OPERATION`. TODO.
// - `jj split`. Split a commit in two, with an editor.
// - `jj parallelize`. TODO.
