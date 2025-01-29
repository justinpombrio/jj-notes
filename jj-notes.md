# JJ Quick Reference

I've been learning [Jujutsu](https://jj-vcs.github.io/jj/latest/) a.k.a. `jj`, a version control
system that's compatible with `git` repos. It's clicked for me in a way that `git` hasn't even after
many years of use.

If you want to learn `jj`, I'd recommend reading [Steve Klabnik's
tutorial](https://steveklabnik.github.io/jujutsu-tutorial/introduction/how-to-read.html).

TODO:

- Say how to set email&editor.
- Terminology: commit or change?
- For `jj log`, mention `jj log -r ..`. Shows all commits.
- Figure out what to say (if anything) about this:
  https://jj-vcs.github.io/jj/latest/FAQ/#how-do-i-resume-working-on-an-existing-change

MODEL:

- DAG of changes (commits?). Each change has parents and children, a file system diff, and a
  description (which starts empty).
- One node in the DAG is the "working-copy revision", a.k.a. `@`. It's your current change
  (commit?). If you delete the node that `@` is pointing at, `@` moves to a new empty commit off of
  its parent.
- Bookmarks: unique string labels on nodes. Propagated to/from remote on push/pull. (Tracked and
  untracked, last known position at remote of tracked bookmarks.)

## Revisions

- `@`: TODO
- `x-`: TODO

## Commands

- `jj abandon REVISION`: REVISION defaults to `@`. Delete the change (delete that node in the
  graph). It's children now point at its parent(s). This could introduce conflicts. If `@` is the
  same as `REVISION`, make `@` be a new empty change on top of the parent.
- `jj backout -r REVISION_r -d REVISION_d`: Create a new change (new node). Its parent is
  `REVISION_d`. Its modification is the opposite of the modification of `REVISION_r`. Its
  description is `Back out "THE DESCRIPTION OF REVISION_r"`.
- `jj bookmark create BOOKMARK -r REVISION`. REVISION defaults to `@`. Label REVISION with a
  bookmark named BOOKMARK. (Does propagate to remote.)
- `jj bookmark delete BOOKMARK`. Deletes the bookmark label named BOOKMARK. (Does propagate to
  remote.)
- `jj bookmark list`. Lists all bookmarks and the changes they point at.
- `jj bookmark rename BOOKMARK_OLD BOOKMARK_NEW`. Renames the bookmark. (QUESTION: Is this the same
  as delete and then create? How does it interact with pushing? If you rename&push, does it delete
  the old branch on the remote?) Is local only!
- `jj bookmark move BOOKMARK --to REVISION`. Move the bookmark label to point at REVISION instead.
  REVISION defaults to `@`.
- `jj describe`. Open an editor to set the description of the current change. Or say `jj describe -m
  "COMMIT MESSAGE"` to specify it on the command line.
- `jj show`. Print the description for `@`.
- `jj diff PATHS...`. Show the diff for the files at PATHS, between this revision (`@`) and its
  parent (`@-`). You can pass `--from REVISION` and `--to REVISION` to see the diff between
  arbitrary changes. TODO: compare to `jj interdiff`.
- `jj interdiff PATHS...`. TODO. Is this advanced?
- `jj edit REVISION`. Move `@` (the "working-copy revision") to point at REVISION.
- `jj file track/untrack`.
- `jj log PATHS...`. Prints the DAG, limited to those nodes that modified PATHS. QUESTION: when do
  you need to run `jj log -r ..`?
- `jj new`. Create a new empty commit on top of `@`, and edit it (move `@` to it). `-m "MESSAGE"`
  additionally sets its description. `jj new REVISIONS...` specifies the parents of the new commit;
  if there are multiple parents you're making a merge commit.
- `jj status` (alias: `jj st`). Print some basic info about the repo.
- `jj restore --from REVISION PATHS...`. Make the files for this commit match those at REVISION.
- `jj undo`. Undo the last thing you did.
- `jj squash`. Move all changes from this revision to its parent.
- `jj rebase`. TODO.
- `jj resolve!!`. TODO.

## Setup Commands

- `jj config edit --user|--repo`. Edit the configuration: either your personal
  config, or the repo config.
- `jj config set --user|--repo NAME VALUE`. TODO: e.g. email, editor.

##  Repository Commands

- `jj git init`, or `jj git clone URL [DESTINATION]`.
- `jj git push`. Push your DAG to remote, and update its branches by your bookmarks. Refuses to
  update the remote bookmarks if it was updated on the remote.
- `jj git fetch`. QUESTION: What happens if you update a bookmark, remote does too, and then you
  fetch? You likely want to do `jj new main` after.

## Alias Commands

- `jj commit`. Identical to `jj describe; jj new`.
- `jj bookmark set BOOKMARK -r REVISION`. Either `create` or `move` the bookmark, whichever is
  valid. `REVISION` defaults to `@`.

## Advanced Commands

- `jj bookmark forget BOOKMARK`. Deletes the bookmark label named BOOKMARK, but "forgets" that it
  exists remotely. It will be recreated if you pull again!
- `jj bookmark track BOOKMARK@REMOTE`. TODO
- `jj bookmark untrack BOOKMARK@REMOTE`. TODO
- `jj duplicate`. TODO
- `jj new --insert-before REVISION` and `jj new --insert-after REVISION`. TODO.
- `jj prev` and `jj next`?
- `jj simplify-parents`. Simplifies the DAG in a lossless way. (A -> B, A -> C, B ->+ C becomes A ->
  B, B ->+ C).
- `jj workspace`. TODO.
- `jj undo OPERATION`. TODO.
- `jj split`. Split a commit in two, with an editor.
- `jj parallelize`. TODO.
