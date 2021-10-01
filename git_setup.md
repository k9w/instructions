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


If you add a file to the index (staging area) and then decide you
don't want it tracked, you can reset the staging area back to match
the last commit.

```
$ git reset HEAD
```

If you have multiple files in the staging area and only want to remove
one, or some, but not all, specify the file, files, or a wildcard.

```
$ git reset HEAD test-file1
```

To restore from the version you have staged:

```
$ git restore --staged test-file1
```

To restore from the version you have committed:

```
$ git restore test-file1
```

If you modify a tracked file and want to revert the change, here is how
to revert it back to the currently-staged version, or the latest
committed version if none is staged:

```
$ git checkout -- test-file
```


Setup the server this way:
<https://git-scm.com/book/en/v2/Git-on-the-Server-Setting-Up-the-Server>

```
9$ cd ~/git-repos
9$ mkdir dotfiles && cd dotfiles
9$ git init
Initialized empty Git repository in /home/kevin/git-repos/dotfiles/.git/
9$ cd ..
9$ git clone --bare dotfiles dotfiles.git
Cloning into bare repository 'dotfiles.git'...
warning: You appear to have cloned an empty repository.
done
```

Then on the local origin, setup the remote.

```
$ git remote add 9 9.k9w.org:/home/kevin/git-repos/dotfiles.git
$ git remote -v
9       9.k9w.org:/home/kevin/git-repos/dotfiles.git (fetch)
9       9.k9w.org:/home/kevin/git-repos/dotfiles.git (push)
```

And push to the server.

```
$ git push 9
Enumerating objects: 36, done.
Counting objects: 100% (36/36), done.
Delta compression using up to 2 threads
Compressing objects: 100% (34/34), done.
Writing objects: 100% (36/36), 6.25 KiB | 533.00 KiB/s, done.
Total 36 (delta 9), reused 0 (delta 0), pack-reused 0
To 9.k9w.org:/home/kevin/git-repos/dotfiles.git
 * [new branch]      main -> main
$
```

I plan to use dotfiles for all my local machines and cloud VMs. So
here I rename the local branch from 'main' to 'openbsd-thinkpad'.

```
$ git branch -m openbsd-thinkpad
$ git push 9
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
To 9.k9w.org:/home/kevin/git-repos/dotfiles.git
 * [new branch]      openbsd-thinkpad -> openbsd-thinkpad
$
```

On the same machine serving the repo.git repositories, to clone
dotfiles repo directly into the home directory, the current directory
and not make a 'dotfiles' directory:

```
9$ cd ~
9$ git clone git-repos/dotfiles.git .
```

On another machine with the same user, home directory, and ssh key for
the server, to clone the instructions repo:

```
$ git clone 9.k9w.org:~/git-repos/instructions.git
Cloning into 'instructions'...
remote: Enumerating objects: 138, done.
remote: Counting objects: 100% (138/138), done.
remote: Compressing objects: 100% (106/106), done.
remote: Total 138 (delta 31), reused 126 (delta 25), pack-reused 0
Receiving objects: 100% (138/138), 71.60 KiB | 748.00 KiB/s, done.
Resolving deltas: 100% (31/31), done.
```

When you try to clone into the current directory, git may complain the
path already exists.

```
$ git clone 9.k9w.org:~/git-repos/dotfiles.git .
fatal: destination path '.' already exists and is not an empty directory.
```

Instead, leave off the trailing dot and let git clone into a new
directory called 'dotfiles'.

```
$ git clone 9.k9w.org:~/git-repos/dotfiles.git
Cloning into 'dotfiles'...
remote: Enumerating objects: 36, done.
remote: Counting objects: 100% (36/36), done.
remote: Compressing objects: 100% (34/34), done.
remote: Total 36 (delta 9), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (36/36), 6.25 KiB | 6.25 MiB/s, done.
Resolving deltas: 100% (9/9), done.
```

You can then copy the files into your intended directory after
ensuring it won't overwrite anything you want to keep. If necessary,
move or rename files which would have been overwritten by the repo
files.

```
$ mv dotfiles/* .
```


Unlike Subversion and CVS, Git refers to HEAD as the currently
selected branch.


To create a branch:

```
$ git branch <name-of-new-branch>
```


Rename the currently selected branch:

```
$ git branch -m <new-name-of-current-branch>
```

To switch HEAD and select another branch

```
$ git checkout <other-branch-name>
```


Here is a case on my openbsd-laptop in the 'instructions' repo branch
'main' where I had a remote setup called '9' for
9.k9w.org:~/git-repos/instructions.git and where the local repo on
openbsd-laptop had fallen behind 9.k9w.org after I had cloned from 9
onto fedora-laptop, committed changes, pushed them to 9, rebooted
laptop from openbsd to fedora (two SSDs in same laptop), did a
successfull 'git pull', and couldn't push because the local branch was
behind the remote. Here is how I resolved it:

```
$ git fetch 9
o$ git merge
fatal: No remote for the current branch.
o$ git merge 9
merge: 9 - not something we can merge
o$ git remote rename 9 origin
o$ git pus
git: 'pus' is not a git command. See 'git --help'.

The most similar commands are
        push
        pull
o$ git push
fatal: The current branch main has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin main

o$ git push
fatal: The current branch main has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin main

o$ git push --set-upstream origin main
To 9.k9w.org:/home/kevin/git-repos/instructions.git
 ! [rejected]        main -> main (non-fast-forward)
error: failed to push some refs to '9.k9w.org:/home/kevin/git-repos/instructions.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
o$ git pull
There is no tracking information for the current branch.
Please specify which branch you want to merge with.
See git-pull(1) for details.

    git pull <remote> <branch>

If you wish to set tracking information for this branch you can do so with:

    git branch --set-upstream-to=origin/<branch> main

o$ git pull origin main
From 9.k9w.org:/home/kevin/git-repos/instructions
 * branch            main       -> FETCH_HEAD
Updating 7a15525..6f49420
Fast-forward
 git_setup.md | 52 +++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 49 insertions(+), 3 deletions(-)
o$ git status
On branch main
nothing to commit, working tree clean
o$ 
```
