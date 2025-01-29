# Oh Shit, JJ!

I've been learning [Jujutsu](https://jj-vcs.github.io/jj/latest/) a.k.a. `jj`, a version control
system that's compatible with `git` repos. It's clicked for me in a way that `git` hasn't even after
many years of use.




If you want to learn `jj`, I'd recommend reading [Steve Klabnik's
tutorial](https://steveklabnik.github.io/jujutsu-tutorial/introduction/how-to-read.html).

If


https://ohshitgit.com/
https://github.blog/open-source/git/how-to-undo-almost-anything-with-git/

### Oh shit, I did something terribly wrong, please tell me git has a magic time machine!?!

**git:**

```
git reflog
# you will see a list of every thing you've
# done in git, across all branches!
# each one has an index HEAD@{index}
# find the one before you broke everything
git reset HEAD@{index}
# magic time machine
```

**jj:**

```
jj reflog
# You will see a list of every thing you've
# done in jj, across all branches!
# Each one has a change index.
# Find the one before you broke everything.
jj reset CHANGE_ID
# Magic time machine.
```

Better yet, use the operation log!
https://jj-vcs.github.io/jj/latest/operation-log/

TODO

### Oh shit, I committed and immediately realized I need to make one small change!

**git:**

```
# make your change
git add . # or add individual files
git commit --amend --no-edit
# now your last commit contains that change!
# WARNING: never amend public commits
```

**jj:**

```
# make your change
jj squash
# now your last commit contains that change!
```

### Oh shit, I need to change the message on my last commit!

**git:**

```
git commit --amend
```

**jj:**

```
jj describe
```

### Oh shit, I accidentally committed something to master that should have been on a brand new branch!

**git:**

```
# create a new branch from the current state of master
git branch some-new-branch-name
# remove the last commit from the master branch
git reset HEAD~ --hard
git checkout some-new-branch-name
# your commit lives in this branch now :)
```

**jj:**

```
# Move the `main` bookmark to the previous change
jj bookmark set main --revision @- --allow-backwards
# Make a new branch for this change
jj bookmark set new-branch
```

### Oh shit, I accidentally committed to the wrong branch!

**git:**

```
# undo the last commit, but leave the changes available
git reset HEAD~ --soft
git stash
# move to the correct branch
git checkout name-of-the-correct-branch
git stash pop
git add . # or add individual files
git commit -m "your message here";
# now your changes are on the correct branch
```

**jj:**

```
jj rebase --source @ --destination name-of-the-correct-branch
```

### Oh shit, I tried to run a diff but nothing happened?!

**git:**

```
git diff --staged
```

**jj:**

No need to run something different, jj has no staging area. 

### Oh shit, I need to undo a commit from like 5 commits ago!

**git:**

```
# find the commit you need to undo
git log
# use the arrow keys to scroll up and down in history
# once you've found your commit, save the hash
git revert [saved hash]
# git will create a new commit that undoes that commit
# follow prompts to edit the commit message
# or just save and commit
```

**jj:**

```
# find the change you need to undo
jj log
# save its change id
# (TODO: will you definitely find them? may need --limit or --revisions ..@?)
jj backout --revisions [change id]
# jj will create a new commit that undoes that commit
# follow prompts to edit the commit message
# or just save and commit
```

### Oh shit, I need to undo my changes to a file!

**git:**

```
# find a hash for a commit before the file was changed
git log
# use the arrow keys to scroll up and down in history
# once you've found your commit, save the hash
git checkout [saved hash] -- path/to/file
# the old version of the file will be in your index
git commit -m "Wow, you don't have to copy-paste to undo"
```

**jj:**

```
# find the change you need to undo
jj log
# save its change id
# (TODO: will you definitely find them? may need --limit or --revisions ..@?)
jj new
jj restore --from [change id] path/to/file
jj describe -m "Wow, you don't have to copy-paste to undo"
```

### Fuck this noise, I give up.

**git:**

```
# get the lastest state of origin
git fetch origin
git checkout master
git reset --hard origin/master
# delete untracked files and directories
git clean -d --force
# repeat checkout/reset/clean for each borked branch
```

**jj:**

TODO
```
```

## [Branch in time saves nine](https://github.blog/open-source/git/how-to-undo-almost-anything-with-git/#branch-in-time-saves-nine)

Scenario: You started a new branch feature based on master, but master was pretty far behind
origin/master. Now that master branch is in sync with origin/master, you wish commits on feature
were starting now, instead of being so far behind.

**git:**

```
git checkout FEATURE_BRANCH
git rebase main
```

## [Stop tracking a tracked file](https://github.blog/open-source/git/how-to-undo-almost-anything-with-git/#stop-tracking-a-tracked-file)

Scenario: You accidentally added application.log to the repository, now every time you run the
application, Git reports there are unstaged changes in application.log. You put *.log in the
.gitignore file, but it’s still there—how do you tell git to to “undo” tracking changes in this
file?

**git:**

```
git rm --cached application.log
```

## [Fix an earlier commit](https://github.blog/open-source/git/how-to-undo-almost-anything-with-git/#fix-an-earlier-commit)

Scenario: You failed to include a file in an earlier commit, it’d be great if that earlier commit
could somehow include the stuff you left out. You haven’t pushed, yet, but it wasn’t the most recent
commit, so you can’t use commit --amend.

**git:**

```
git commit --squash <SHA of the earlier commit>
git rebase --autosquash -i <even earlier SHA>
```

## Concepts

**git:**

```
# Basic git usage:
git add PATH
git commit
git commit -m "COMMIT MESSAGE"
git branch BRANCH_NAME
git checkout BRANCH_NAME
git diff
git diff --staged

# Used during "oh shit" moments:
git commit --amend
git commit --squash REVISION # --squash needed?
git reset REVISION --hard
git reset REVISION --soft
git reset HEAD@{index}
git stash
git stash pop
git log
git revert HASH
git checkout HASH -- PATH
git rebase BRANCH
git rebase --autosquash -i REVISION # --autosquash needed?
git reflog
```

**jj:**

```
# Basic jj usage:
jj new
jj describe
jj describe -m "COMMIT MESSAGE"
jj bookmark set BOOKMARK_NAME
jj diff

# Used during "oh shit" moments:
jj squash
jj bookmark set BOOKMARK_NAME --revsion REVISION --allow-backwards
jj rebase --source REVISION --destination REVISION
jj log
jj backout --revisions CHANGE_ID
jj restore --from CHANGE_ID PATH
```
