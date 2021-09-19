First tell Git about yourself and set some options.

```
$ git config --global user.name "Kevin Williams"
$ git config --global user.email kevin@k9w.org
```

Tell Git to name the first branch 'main' when initializing a new repo
instead of the default branch name 'master'.

```
$ git config --global init.defaultBranch main
```

On Linux and FreeBSD, 'git diff' passes certain flags to less and
displays correctly. But on OpenBSD, it fills up the entire screen with
blanks and exits.

To fix it on OpenBSD, set core.pager to either pass the correct flags
to less(1), compare to the manpage on FreeBSD, or set core.pager to
cat(1) instead of less(1).

```
$ git config --global core.pager cat
```

Keep in mind if the output is long enough for commands such as 'git
log' that you choose to pipe it into less, you'll lose the color
highlighting.


To make a git repo of your dotfiles, start in you home directory:

```
$ cd
```

Initialize the git repository for dotfiles. Don't worry about how to
name it that yet.

```
$ git init
```

Rename the default branch from 'master' to 'main'.

```
$ git branch -m main
```

Add the initial list of files to be tracked.

```
$ git add .Xresources .cwmrc .emacs.d/init.el .gitconfig .init.ee .kshrc .mg .nexrc
```

Check to see if you missed any files.

```
$ ls -a
```

Add the rest of the files you want. Remember you are not looking to
necessarily track all dotfiles shipped with the OS.

```
$git add .profile .tmux.conf .vimrc .xsession
```

Check the status, with 'less' if the output is too long.

```
$ git status
$ git status | less
```

Add all files in the current directory to gitignore, including the
ones you already added to the index (staging area) with 'git add'
above.

```
$ ls -a > .gitignore
```

Git does not ignore files or files which match patterns listed in
.gitignore if they are already tracked by git. That's why we added the
files first, above.

check the status, commit what you have thus far, and print the
commands you just typed.

```
$ git commit -m 'Initial commit.'
$ git status
$ history
```

To show files currently tracked by git:

```
$ git ls-tree -r main
```

To see what already-tracked files have been modified since they were
last staged:

```
$ git diff
```

Be sure 'git diff' is blank with no output before you commit, to
ensure no changes are missed.

To show how currently staged files differ from the latest commit:

```
$ git diff --staged
```

If you add a file to the index (staging area) and then decide you
don't want it tracked, you can reset the staging area back to match
the last commit.

```
$ git reset HEAD
```

To rename an already-tracked file:

```
$ git mv test-file test-file1
```

This changes the file name in the working directory just like mv(1)
and stages the new filename in the index, ready for the next commit.
Interestingly, if you had already modified the file before renaming
it, but didn't stage it with 'git add', Git won't stage the changed
file contents when it stages the file name change. In my test, I did
that separately after committing the rename.


To remove an already-tracked file from git and from the local directory:

```
$ git rm test-file1
```

And then commit as normal.


To remove an already-tracked file from Git but keep the local file:

```
$ git rm --cached test-file2
```

And then commit as normal.


Setup the server this way:
<https://git-scm.com/book/en/v2/Git-on-the-Server-Setting-Up-the-Server>

