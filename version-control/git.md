# Git

[Git](https://git-scm.com) is a [distributed version control
system](https://en.wikipedia.org/wiki/Distributed_version_control)
used to manage source code, coniguration files, documentation, etc.

Because Git is widely documented elsewhere, this guide shows my
understanding and common usage of the system, including on
[OpenBSD](https://openbsd.org).

## Global user settings

My `git config` setup is tracked in:

```
~/.gitconfig
~/.gitignore
~/.priv/gitconfig
```

### .gitconfig

```
[include]
	path = ~/.priv/gitconfig

[core]
	excludesfile = /home/kevin/.gitignore
#	pager = less
#	editor = emacsclient -a mg

# Normalize line endings across Windows, Linux, etc.
#	autocrlf = input

[init]
	defaultBranch = main

# Inserted automatically by 'gh auth login'.
[credential "https://github.com"]
	helper = 
	helper = !/usr/local/bin/gh auth git-credential
```


### .gitignore

```
# Ignore all files and directories recursively.

# Whitelist new files:
# 'git add -f <filenames>'

# Stage any changed files:
# 'git add .'

*
```

### .priv/gitconfig

```
# private info Git configuration file

[user]
	name = Firstname Lastname
	email = name@example.com
```


## Start a new repository

This example uses a static website with one file already.

```
$ cd ~/src/example.com
```

Create the git repository in this folder.

```
$ git init
```

Next add the initial list of files to be tracked.

```
$ git add -f index.html
```

Check what Git now tracks in this repo.

```
$ git status
```
Commit what you have thus far.

```
$ git commit -m 'Initial commit.'
```

See details of what already-tracked files have been modified since
they were last staged:

```
$ git diff
```

Show how currently-staged files differ from the latest commit.

```
$ git diff --staged
```

Re-add any modified files to staging.

```
$ git add .
```

Show files currently tracked by git in the default main branch.

```
$ git ls-tree -r main
```

To rename an already-tracked file:

```
$ git mv test-file test-file1
```

Remove an already-tracked file from git and from the local
directory in one command.

```
$ git rm test-file1
```

Remove an already-tracked file from Git but keep the local file:

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

<br>
## Cloning

On the server where we made 'dotfiles.git' earlier, we could clone it
into my home folder on the same server.

```
$ cd ~
$ git clone git-repos/dotfiles.git .
```

Notice the inclusion of the dot (.) at the end of the command
above. That tells Git to clone the repo into the current directory,
instead of the default behavior of making a directory called
'dotfiles' and putting the cloned repo there.


Here's how to clone the repo onto another laptop without a remote
already specified. Note the use of ~ because the server has my same
home directory name /home/<user>.

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
fashion of making a new folder called 'instructions' and spell out the
full directory path on the server:

```
$ git clone <server>:/home/<user>/git-repos/instructions.git
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
$ cp dotfiles/* .
```

Be sure to clone from a bare repo, instrucitons.git, rather than the
regular repo, instructions. Here are details of the error I got and
how to fix it.

<https://stackoverflow.com/questions/44809486/why-am-i-not-able-to-push-from-a-local-repository-to-a-remote-repository-given>


If you want to have a central repo for a repo you'll have cloned
several places, any one of the clones can serve that purpose, ideally
one on an accessible server.

For example, ~/instructions/ could be a git repo and also serve as the
central repo all others clone from, pull from, and push to. But you
could instead clone ~/instructions/ to an alternate location with
--bare and use that as the central repo, or the preferred remote for
all clones.

```
$ pwd
~/test-repo
$ touch test
$ git init
$ git add .
$ git commit -m 'Initial commit.'
$ git remote add origin ~/git-repos/test-repo
```

Now setup the empty folder for that repo.

```
$ cd ~/git-repos
$ ls test-repo
$ git clone --bare ~/test-repo
Cloning into bare repository 'my-setup.git'...
done.
$ ls
test-repo.git
```

~/test-repo is the original repo, and we've cloned it to a new bare
repo ~/git-repos/test-repo.git. The --bare option to 'git clone'
appended .git to the new folder name.

To first time each clone, even the original one, pushes to a remote,
'git push' needs an additional option.

```
$ cd ~/test-repo
$ ls test
test
$ cat test
$ echo "hello" > test
## git add and commit here ##
$ git push --set-upstream origin main
```

From now on, you can just do 'git push' from that clone of the repo.


If you have a similar project folder on another host and want to use
this repo for it and keep the data for both, do this on the other host.

We need a --bare repo as the central repo - if we plan to use the same
'main' branch in all clones.

```
$ git clone r.k9w.org:~/git-repos/my-setup.git
$ mv flap.md my-setup/
$ cd my-setup/
$ git add .
$ git commit -m "Add fedora-laptop file."
$ git push
$ ls
flap.md  r.md
```

<br>
## Remotes


List any existing remotes for the current repo.

```
$ git remote -v
```

The distributed nature of Git allows one person to clone another's
repository, or for one to upload their own repo to a server or another
machine they can access. Git supports a number of workflows around
this.

The examples thus far in this guide assume you started the repo above
on your own laptop. One common way to share a repo with others is to
upload it to services with web interfaces such as Github, Gitlab, and
self-hosted solutions such as Gitweb and Gitea.

Let's first start with a method the Git creators likely originally
intended to upload a repo: via the command line to a server you can
login to with SSH (even if you end up using a protocol other than SSH
to serve the repo).

Login to the server, create a git-repos folder in your home directory
and cd to it.

On server:

```
$ mkdir my_project.git
$ cd my_project.git
$ git --bare init -b main
```

On client:

Start the local repository.

```
$ mkdir my_project && cd my_project
$ git init
```

Add files with contents. Then add to git and commit.

```
$ git add -f <first files>
$ git commit -m "Initial commit"
```

Add the first remote and push to it.

```
$ git remote add origin youruser@yourserver.com:/path/to/my_project.git
$ git push --set-upstream origin main
```


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

If you want to add Github as an origin, create an empty repo with that
name on your Github profile.

<https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository>
<https://github.com/new>


Then set the url with [git-remote(1)](https://git-scm.com/docs/git-remote).

```
$ git remote set-url --add --push origin git://original/repo.git
$ git remote set-url --add --push origin git://another/repo.git
```

```
$ git remote set-url --add --push github https://github.com/k9w/instructions.git
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
that we can leave off the word 'origin' and just specify the command
as 'git push'.

```
$ git push
```

If have 'origin' as a self-hosted remote on your server, you could add
your new blank repo on github as a remote called 'github'.

Before you push, be sure your local repo has all branches up to date.

Then push.

```
$ git push github --all
```


<br>
## Branching


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

To switch HEAD and select another branch:

```
$ git checkout <other-branch-name>
```

Or:

```
$ git switch <other-branch-name>
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
$ git merge
fatal: No remote for the current branch.
$ git merge 9
merge: 9 - not something we can merge
$ git remote rename 9 origin
$ git push
fatal: The current branch main has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin main

$ git push --set-upstream origin main
To <server>:/home/<username>/git-repos/instructions.git
 ! [rejected]        main -> main (non-fast-forward)
error: failed to push some refs to '<server>:/home/<username>/git-repos/instructions.git'
hint: Updates were rejected because the tip of your current branch is behind
hint: its remote counterpart. Integrate the remote changes (e.g.
hint: 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
$ git pull
There is no tracking information for the current branch.
Please specify which branch you want to merge with.
See git-pull(1) for details.

    git pull <remote> <branch>

If you wish to set tracking information for this branch you can do so with:

    git branch --set-upstream-to=origin/<branch> main

$ git pull origin main
From <server>:/home/<username>/git-repos/instructions
 * branch            main       -> FETCH_HEAD
Updating 7a15525..6f49420
Fast-forward
 git_setup.md | 52 +++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 49 insertions(+), 3 deletions(-)
o$ git status
On branch main
nothing to commit, working tree clean
$ 

$ git status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   git_setup.md

no changes added to commit (use "git add" and/or "git commit -a")
$ git add git_setup.md
nstead of "git push 9", and resolved a merge conflict.'
           <
[main c548e11] Added info on how to rename a remote to more easily do
"git push" instead of "git push 9", and resolved a merge conflict.
 1 file changed, 66 insertions(+), 1 deletion(-)
o$ git push
fatal: The current branch main has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin main

$ git push --set-upstream origin main
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 2 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 1.33 KiB | 340.00 KiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
To <server>:/home/<username>/git-repos/instructions.git
   6f49420..c548e11  main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
$
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
$ git push origin --delete <bad-branch-name>
```

However, I'm not sure if I'll need the main branch later. I'm leaving
it for now, even if it falls out of date.

Here's how to update the remote on fedora-laptop from 9.k9w.org to
r.k9w.org.

```
$ git remote set-url origin r.k9w.org:~/git-repos/dotfiles.git
```

If the local branch does not show all remote branches, a shortcut way
to fix it is to rename the local repo, clone a new repo copy from the
remote origin, verify it looks good and shows all the remote branches,
and delete the original local repo.


If you find git is not ignoring .*.swp temp files from vim or *~
auto-save files from Emacs, have git re-assign the ~/.gitignore as the
default excludes file. 

```
$ git config --global core.excludesfile ~/.gitignore
```


To revert to a previous commit, locate the commit ID you want first
with:

```
$ git log
```

Then revert or change the repository to the state it was in at that
commit with the checkout command. The switch command doesn't work here
because it expects a branch, not a commit ID.

```
$ git checkout 844cc47
```

If you make changes and want to commit them, follow the instructions to
make a new branch with 'switch -c <new-branch-name>'. Then you can merge
that new branch into the main branch.

If instead you decide to not make changes and to go back to the most
recent commit, you can use either the checkout or switch command.

```
$ git checkout -
```

```
$ git switch -
```

Delete local branch.

```
$ git branch -d <old-branch-name>
```

Delete remote branch.

```
$ git push -d origin <old-branch-name>
```

Delete a remote branch that only exists in local repo cache.

```
$ git fetch origin --prune
```


<br>
## Stashing changes

If you changed files in a local repo without first running 'git pull',
you can stash away those changes, do the git pull, then apply them
back and commit and push.

```
$ git stash
$ git pull
$ git stash apply
$ git add .
$ git commit
$ git push
```

<br>
## See Also


<https://stackoverflow.com/questions/2337281/how-do-i-do-an-initial-push-to-a-remote-repository-with-git>

<https://stackoverflow.com/questions/30590083/how-do-i-rename-both-a-git-local-and-remote-branch-name#30590238>

<https://stackoverflow.com/questions/35941566/git-says-remote-ref-does-not-exist-when-i-delete-remote-branch>



Git merge conflict:

```
$ git merge --no-ff
$ git pull
$ git push
```


