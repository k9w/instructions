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
displays correctly. But on OpenBSD, if the contents fit on one
screenfull, less filsthe rest of the screen with blanks and exits.

To fix it on OpenBSD, one option is to set core.pager to pass the correct flags
to less(1).

To find the correct flags to pass to less on OpenBSD, compare is
manpage with less on FreeBSD.

Or set core.pager to cat(1) instead of less(1) with we do here:

```
$ git config --global core.pager cat
```

Keep in mind if the output is long enough for commands such as 'git
log' that you choose to pipe it into less, you'll lose the color
highlighting Git provides.


To make a Git repo of your dotfiles, start in you home directory:

```
$ cd
```

Initialize the git repository for dotfiles. Don't worry about how to
name it that yet.

```
$ git init
```

Rename the default branch from 'master' to 'main' if you haven't
already set init.defaultBranch to it in ~/.gitconfig.

```
$ git branch -m main
```

Often times, your Git repo is in a directory containing only the files
in the project you want to track. In many cases, building or running
the project makes logs, binaries and other files you don't want to
track or don't need to clutter up other people's or other machines'
folders where your repo may now or later be cloned to.

Because your 'dotfiles' repo is in your home directory, Git will see
other files and folders there which you likely don't need or want to
track.

To prevent those files from showing in a 'git status' or be added with
'git add', make a ./.gitignore as follows.

```
# Ignore all files and directories recursively except what is added
# manually by 'git add'. Requires 'git add -f' to add a file for the
# first time to be committed and tracked.

*

```

Next add the initial list of files to be tracked.

```
$ git add -f .Xresources .cwmrc .emacs.d/init.el .gitconfig .init.ee \
.kshrc .mg .nexrc
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

Check the status, with 'git status'.

```
$ git status
$ git status | less
```
Commit what you have thus far, and print the
commands you just typed.

```
$ git commit -m 'Initial commit.'
$ git status
$ history
```

Going forward, whenever you modify an already tracked file and want to
commit it to Git, you need to manually add it to the staging area, but
without the -f flag since it's already tracked.

```
$ git add .tmux.conf
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

You could also just rename the file regularly just with mv, 'git add
-f' the new filename. 'git status' or 'git commit' would then
auto-detect the file under the old name to be removed and see the file
under the new name to be committed.

Interestingly, if you had already modified the file before renaming
it, but didn't stage it with 'git add', Git won't stage the changed
file contents when it stages the file name change. In my test, I did
that separately after committing the rename.

You can remove a tracked file from the local directory and Git will
notice it and remove it just like a renamed file above.

To remove an already-tracked file from git and from the local
directory in one command:

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
one, or some, but not all, specify the file(s) or a wildcard.

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


The distributed nature of Git allows one person to clone another's
repository, or for one to upload their own repo to a server or another
machine they can access. Git supports a number fo workflows around
this.

The examples thus far in this guide assume you started the repo above
on your own laptop. One common way to share a repo with others is to
upload it to services with web interfaces such as Github, Gitlab, and
self-hosted solutions such as Gitweb and Gitea.

First start with a method the Git creators likely originally intended
to upload a repo: via the command line to a server you can login to
with SSH (even if you end up using a protocol other than SSH to serve
the repo).

Login to the server, create a git-repos folder in your home directory
and cd to it.

```
$ cd
$ mkdir git-repos
$ cd ~/git-repos
```

Now make a folder for the dotfiles repo.

```
$ mkdir dotfiles && cd dotfiles
```

Remember, unlike most Git repos, this dotfiles repo is intended to
exist in the root of your home directory.

So why make a dotfiles folder in a sub directory of your home folder?

This is because Git requires a bare repo to be created before you can upload
yours to it: an empty directory.

First start by initializing a new repository in the current folder.

```
$ git init
Initialized empty Git repository in /home/<username>/git-repos/dotfiles/.git/
```

Then cd back up to the ~/git-repos folder.

```
$ cd ..
```

Now clone that empty repository, the folder called 'dotfiles' into a
clone-able Git repository, a new folder called 'dotfiles.git'.

```
$ git clone --bare dotfiles dotfiles.git
Cloning into bare repository 'dotfiles.git'...
warning: You appear to have cloned an empty repository.
done
```

Now on the origin, on your local laptop where you first started this
repo, setup the remote to the server path you just setup.

```
$ git remote add origin <server>:/home/<username>/git-repos/dotfiles.git
$ git remote -v
origin  <server>:/home/<username>/git-repos/dotfiles.git (fetch)
origin  <server>:/home/<username>/git-repos/dotfiles.git (push)
```

And push to the server.

```
$ git push origin
Enumerating objects: 36, done.
Counting objects: 100% (36/36), done.
Delta compression using up to 2 threads
Compressing objects: 100% (34/34), done.
Writing objects: 100% (36/36), 6.25 KiB | 533.00 KiB/s, done.
Total 36 (delta 9), reused 0 (delta 0), pack-reused 0
To <server>:/home/<username>/git-repos/dotfiles.git
 * [new branch]      main -> main
$
```
The 'git push' command defaults to a target called 'origin'. We chose
that name 'origin' when setting up the remote with 'git remote' so
that we can leave off the word 'origin' and justspecify the command as
'git push'.

```
$ git push
```

<br>
# Branching


One of Git's killer features is the ability to have branches, forked
tracks of development. Do an internet search for 'git branching' for a
good visual on what it looks like to really get the concept.

Typically, organizations and open source projects use branches to have
a 'produciton' default branch called 'master', 'main', or similar, and
a 'testing' branch, and perhaps a 'hotfix' branch to develop and test
security and usability patches to the current production release.

This dotfiles repo affords a different opportunity for branches: for
each machine to have its own exact configuration, but for them all to
share a limited subset of configuration in common.

The common bits would require 'git merge' operations on an ongoing
basis to sync changes from one branch to another.

We will explore those concepts with examples in this section.

I plan to use dotfiles for all my local machines and cloud VMs. So
here I rename the local branch from 'main' to 'openbsd-thinkpad'.

```
$ git branch -m openbsd-thinkpad
$ git push
Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
To <server>:/home/<username>/git-repos/dotfiles.git
 * [new branch]      openbsd-thinkpad -> openbsd-thinkpad
$
```

It turns out this renamed the 'main' branch to 'openbsd-thinkpad' only
on the local repo. The 'git push' pushed 'openbsd-thinkpad' as a new
branch to the remote server. It left the 'main' branch on the server
and did not rename or replace it. We will come back to that.

On the server where we made 'dotfiles.git' earlier, we could clone it
into your home folder there with.

```
9$ cd ~
9$ git clone git-repos/dotfiles.git .
```

Notice the inclusion of the dot (.) at the end of the command
above. That tells Git to clone the repo into the current directory,
instead of the default behavior of making a directory called
'dotfiles' and putting the cloned repo there.


On another laptop with the same user, home directory name, and ssh key
for the server, to clone the instructions repo, here's what it does:

```
$ git clone <server>:~/git-repos/dotfiles.git .
Cloning into '.'...
remote: Enumerating objects: 41, done.
remote: Counting objects: 100% (41/41), done.
remote: Compressing objects: 100% (39/39), done.
remote: Total 41 (delta 12), reused 0 (delta 0), pack-reused 
Receiving objects: 100% (41/41), 6.83 KiB | 6.83 MiB/s, done.
Resolving deltas: 100% (12/12), done.
```

If I wanted to clone another repo called 'instructions' in the normal
fashion of making a new folder called 'instructions':

```
$ git clone <server>:~/git-repos/instructions.git
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
$ git clone <server>:~/git-repos/dotfiles.git .
fatal: destination path '.' already exists and is not an empty directory.
```

Instead, leave off the trailing dot and let git clone into a new
directory called 'dotfiles'.

```
$ git clone <server>:~/git-repos/dotfiles.git
Cloning into 'dotfiles'...
remote: Enumerating objects: 36, done.
remote: Counting objects: 100% (36/36), done.
remote: Compressing objects: 100% (34/34), done.
remote: Total 36 (delta 9), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (36/36), 6.25 KiB | 6.25 MiB/s, done.
Resolving deltas: 100% (9/9), done.
```

Then copy the files into your intended directory after ensuring it
won't overwrite anything you want to keep. If necessary, move or
rename files which would have been overwritten by the repo files.

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
<server>:~/git-repos/instructions.git and where the local repo on
openbsd-laptop had fallen behind <server> after I had cloned from 9
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
To <server>:/home/<username>/git-repos/instructions.git
 ! [rejected]        main -> main (non-fast-forward)
error: failed to push some refs to '<server>:/home/<username>/git-repos/instructions.git'
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
From <server>:/home/<username>/git-repos/instructions
 * branch            main       -> FETCH_HEAD
Updating 7a15525..6f49420
Fast-forward
 git_setup.md | 52 +++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 49 insertions(+), 3 deletions(-)
o$ git status
On branch main
nothing to commit, working tree clean
o$ 

o$ git status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   git_setup.md

no changes added to commit (use "git add" and/or "git commit -a")
o$ git add git_setup.md
nstead of "git push 9", and resolved a merge conflict.'
           <
[main c548e11] Added info on how to rename a remote to more easily do
"git push" instead of "git push 9", and resolved a merge conflict.
 1 file changed, 66 insertions(+), 1 deletion(-)
o$ git push
fatal: The current branch main has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin main

o$ git push --set-upstream origin main
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 2 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 1.33 KiB | 340.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
To <server>:/home/<username>/git-repos/instructions.git
   6f49420..c548e11  main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
o$
```

In the 'dotfiles' repo, I had originally called the first, default
branch 'main' I decided to change that to 'openbsd-thinkpad' and then to
'openbsd-laptop'.

To view all branch names, both local and remote:

```
$ git branch -a
```

To delete the branch 'openbsd-thinkpad':

```
$ git push origin --delete openbsd-thinkpad
 - [deleted]         openbsd-thinkpad
```

I found 'git branch -a' still listed openbsd-thinkpad.

https://stackoverflow.com/questions/35941566/git-says-remote-ref-does-not-exist-when-i-delete-remote-branch

Here is how to update the local list of branches, including the list of
remote branches, after the branch openbsd-thinkpad has been removed
from the remote:

```
$ git fetch --prune
From <server>:~/git-repos/dotfiles
 - [deleted]         (none)     -> origin/openbsd-thinkpad
$ git branch -a
* fedora-laptop
  remotes/origin/HEAD -> origin/main
  remotes/origin/fedora-laptop
  remotes/origin/main
  remotes/origin/openbsd-laptop
```

I upgraded OpenBSD on 9.k9w.org from 6.9 to 7.0. The 9 in 9.k9w.org
referred to the 9 in 6.9. So I renamed its hostname from 9 to r (r is
for 'release'), and changed its FQDN in at my DNS provider from
9.k9w.org to r.k9w.org.

The ./.git/config file still points to 9.k9w.org. Here is how to
update the URL to the new address. Note, everything after the r in
r.k9w.org is the same as before.

```
$ git remote set-url origin r.k9w.org:/home/kevin/git-repos/dotfiles.git
```

Next, compare the main and openbsd-laptop branches. The main branch is
not on my laptop; the openbsd-laptop branch is. But main is
still on the origin site. Here's how to compare them.

```
$ git diff openbsd-laptop..remotes/origin/main
```

Here's how to compare the remote main branch with the remote
openbsd-lapotp branch.

```
$ git diff remotes/origin/fedora-laptop..remotes/origin/main
```

We don't see any differences, which is good. However, we do see
differences between fedora-laptop and openbsd-laptop, which is also
good.

```
$ git diff remotes/origin/fedora-laptop..remotes/origin/openbsd-laptop
```

For my purposes, I don't need a master or main branch for the dotfiles
repo because I would use OpenBSD and Fedora equally.

Later, I will explore how to selectively merge changes between them,
and among any further branches made in the future, while also keeping
the differences I want between/among each branch for each laptop, OS
install, and possibly on cloud-servers too.

Here's how to delete the main branch on the origin.

First change the upstream from main to openbsd-laptop

```
$ git push --set-upstream origin openbsd-laptop
```

Check it with:

```
$ git branch -a
```

Then delete the old branch:

```
$ git push origin --delete bad-branch-name
```

However, I'm not sure if I'll need the main branch later. I'm leaving
it for now, even if it falls out of date.

