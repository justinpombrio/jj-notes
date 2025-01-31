# JJ Quick Reference

I've been learning [Jujutsu](https://jj-vcs.github.io/jj/latest/) a.k.a. `jj`, a version control
system that's compatible with `git` repos. It's clicked for me in a way that `git` hasn't even after
many years of use.

The best way to learn something is to teach it, so I wrote a _reference_ and _cheat sheet_ for `jj`
with the help of [a friend](https://lark.gay):

- The _reference_ describes the state space of a `jj` repository and how it changes when you
  `fetch` and `push`.
- The _cheat sheet_ visually shows what all of the common editing operations do to the repo state.

While there have been several excellent tutorials on Jujutsu, I haven't seen anything that quite
fills these two roles. And importantly, these each fit on a page, so it's possible to print it out
double sided and keep it on your desk while learning `jj`!

While you can of course approach `jj` any way you please, if you're truly new to it I would suggest
first reading a tutorial first to grok some of the basics.
[Steve Klabnik's tutorial](https://steveklabnik.github.io/jujutsu-tutorial/introduction/introduction.html),
and [Kuba Martin's introduction](https://kubamartin.com/posts/introduction-to-the-jujutsu-vcs)
are both excellent.

(A word about _why_ you should read a tutorial first. If you're coming from `git`, you may think of a
repo as a collection of branches, or a merge conflict as part of an operation. These intuitions will
stand in the way of you learning `jj`, and a tutorial is a better way to unlearn them than a
reference.)
