Merge Conflicts

For projects in Git cloned among multiple people, or multiple machines
of yours, or even multiple folders on the same machine, it is best
practice to 'git pull' before making any changes, then to 'git add .',
'git commit', and 'git push'.

A common merge conflict for me has been when I forgot to 'git pull'
before making a local change until after it's added and committed. Git
reports the merge conflict when I try to push.

Here's how it starts when we don't first 'git pull'.

```
$ vi <newfilename>
$ git add .
$ git commit
$ git push
<error and unable to push due to conflict with remote>
```

Here is how to resolve this merge conflict.

First, look at the commit history with 'git log' to locate the local
repo's current commit, called HEAD, and the last good commit, usually
the one right before.

```
$ git log
```

Revert the local repository to the last good commit with 'git checkout'
and the first seven (7) characters of the commit ID.

```
$ git checkout ef9b02b
```

Git now says the repo is in a detached state, not attached to a branch
at all. We can see that with 'git branch'.

```
$ git branch
```

Next merge this detached branch into the main branch.

```
$ git merge main
```

Now you can delete the temporary branch.


This next step might be optional. I'll find out with more practice.
Pull the latest changes from the remote into this detached HEAD state.

```
$ git pull
```

Now make this detached HEAD into a new branch. Switching to it may be
optional. I'll find out with more practice.

```
$ git branch mergeConflict
$ git switch mergeConflict
```

```
$ git switch main
$ git pull confirm commit message
```

```
$ git merge mergeConflict
```

That's it; your local repo is now up to date with the remote and now
with your local changes too.

Finally, push your merged changes to the remote.

```
$ git push
```


--------


Below is the raw output of how this actually played out for me, with
hostnames, usernames, and author info redacted.

```
$ pwd
/home/<username>/instructions
```

I should have done 'git pull' at this point. But because I didn't,
this merge conflict happened.

I made a new file, added it and committed it to the local repo.

```
$ vi freebsdInstallDigitalOcean.md
$ git status
On branch main
Your branch is up to date with 'origin/main'.

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        freebsdInstallDigitalOcean.md

nothing added to commit but untracked files present (use "git add" to track)
$ git add .
$ git commit
[main 1ff0c29] Add attempted install of FreeBSD on Digital Ocean.
 1 file changed, 35 insertions(+)
 create mode 100644 freebsdInstallDigitalOcean.md
$ 
```

When I went to push my changes to the remote, the push failed because
of a merge conflict. The remote had newer changes than my previous
local commit history showed.

If the remote had no newer changes then a 'git pull' would not have been necessary. But it's always a good idea to run 'git pull' before making any lcoal changes, just in case.

This time, the push failed because the remote had newer changes than my previous local commit.

```
$ git push
To example.com:/home/<username>/git-repos/instructions.git
 ! [rejected]        main -> main (fetch first)
error: failed to push some refs to 'example.com:/home/<username>/git-repos/instructions.git'
hint: Updates were rejected because the remote contains work that you do
hint: not have locally. This is usually caused by another repository pushing
hint: to the same ref. You may want to first integrate the remote changes
hint: (e.g., 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
$ 
```

Before we can fix the merge conflict and push the local changes
successfully to the remote server, we need to find the last good
commit by commit ID.

(For berevity, I've trimmed all but the three most recent commits from
the output below.)


```
$ git log
commit 1ff0c29a6f93fc2e44f2cb4216ad2b9ad5821314 (HEAD -> main)
Author: Firstname Lastname <address@hidden>
Date:   Sat Apr 16 21:46:22 2022 -0700

    Add attempted install of FreeBSD on Digital Ocean.

commit ef9b02b2a100b558a2dd664539d5473e8e2cd929 (origin/main)
Author: Firstname Lastname <address@hidden>
Date:   Thu Mar 31 22:23:48 2022 -0700

    Fix example1.com listening on * to just listen on example1.com

commit 77ac47d9f3320538c65991f89a635c45df30b938
Author: Firstname Lastname <address@hidden>
Date:   Wed Mar 30 22:01:15 2022 -0700

    Add how to renew the certs with cron.

<snip>
$ 
```

The first step to fix the merge conflict is to revert the local repo
to the last good state, synchronized with the remote, based on commit
ID. So we'll checkout the commit with (origin/main) next to it,
referencing just the first seven (7) characters of the commit ID.

```
$ git checkout ef9b02b
Note: switching to 'ef9b02b'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -c with the switch command. Example:

  git switch -c <new-branch-name>

Or undo this operation with:

  git switch -

Turn off this advice by setting config variable advice.detachedHead to false

HEAD is now at ef9b02b Fix example1.com listening on * to just listen on example1.com
$ 
```

The currently-selected content of the local repo, called HEAD, is now
in the state before the conflicting change, which was:
'vi freebsdInstallDigitalOcean.md'

One way to resolve this merge conflict is to rewrite the local commit
history with 'git rebase'.

A better way is to merge the two divertent commit histories together:
the commit history of the local repo and that of the remote upstream.

Merging the divergent histories is what this guide shows.

The output of 'git checkout ef9b02b' above says HEAD is in a detached state. This means it's not connected to any branch at all.

```
$ git branch
* (HEAD detached at ef9b02b)
  main
$ 
```

'main' is the only branch known to the local repo.

(The remote, or other cloned copies elsewhere might have more
branches. But we've not merged them in prior to this merge
conflict. So they don't matter right now.)

Now that HEAD is detached from main and reverted to the last state matching a commit on the remote (synchronized) let's pull any later changes from the remote.

```
$ git pull
remote: Enumerating objects: 13, done.
remote: Counting objects: 100% (13/13), done.
remote: Compressing objects: 100% (12/12), done.
remote: Total 12 (delta 6), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (12/12), 1.86 KiB | 40.00 KiB/s, done.
From example.com:/home/<username>/git-repos/instructions
   ef9b02b..0756823  main       -> origin/main
You are not currently on a branch.
Please specify which branch you want to merge with.
See git-pull(1) for details.

    git pull <remote> <branch>

$ 
```

HEAD is now up to date with the remote, but still detatched from the
local 'main' branch.

```
$ git status
HEAD detached at ef9b02b
nothing to commit, working tree clean
$ 
```

Next, make a new branch from this detached HEAD. I called mine
'mergeConflict'.

```
$ git branch mergeConflict
```

The new branch is created from HEAD. But HEAD is still detached.

```
$ git branch
* (HEAD detached at ef9b02b)
  main
  mergeConflict
```

New branch 'mergeConflict' is now a copy of the detached HEAD.

Next, switch to the 'main' branch.

```
$ git switch main
Switched to branch 'main'
Your branch and 'origin/main' have diverged,
and have 1 and 4 different commits each, respectively.
  (use "git pull" to merge the remote branch into yours)
```

Now when checking the branches, we see HEAD is now on the 'main'
branch, indicated by the asterisk (*). 'main' has a clean commit
history with the upstream remote up until our merge conflict
started. We also see new branch 'mergeConflict', which has the new
commit we made without first pulling changes from the remote.

```
$ git branch
* main
  mergeConflict
```

Now we pull changes into 'main' from the upstream remote. Because we
now have a divergent branch, Git will ask for a commit message to make
a merge commit in order to pull in the changes from the upstream
remote.

```
$ git pull
```

This invokes the default text editor with the following commit message
pre-filled in:

```
Merge branch 'main' of example.com:/home/<username>/git-repos/instructions
```

Accept the commit message, or modify it. then save and close the
editor to finalize the merge commit, and the 'git pull'. Here is the
output:

```
hint: Pulling without specifying how to reconcile divergent branches is
hint: discouraged. You can squelch this message by running one of the following
hint: commands sometime before your next pull:
hint:
hint:   git config pull.rebase false  # merge (the default strategy)
hint:   git config pull.rebase true   # rebase
hint:   git config pull.ff only       # fast-forward only
hint:
hint: You can replace "git config" with "git config --global" to set a default
hint: preference for all repositories. You can also pass --rebase, --no-rebase,
hint: or --ff-only on the command line to override the configured
default per
hint: invocation.
Merge made by the 'recursive' strategy.
 httpdApache.md                                   | 36 +++++++++++++++++++++++++
 httpdNginx.md                                    | 39 ++++++++++++++++++++++++++++
 migrateSiteOpenbsdHttpd-01.md => httpdOpenBSD.md |  0
 3 files changed, 75 insertions(+)
 create mode 100644 httpdApache.md
 create mode 100644 httpdNginx.md
 rename migrateSiteOpenbsdHttpd-01.md => httpdOpenBSD.md (100%)
```

Now that we have the latest changes pulled into 'main' from the remote, let's merge the changes from 'mergeConflict' branch into the 'main' branch.

```
$ git switch mergeConflict
Switched to branch 'mergeConflict'
```

Here we see the difference betwee the branch we're on ('mergeConflict'
denoted by the minus (-)), and the branch specified to 'git diff'
('main' denoted by the plus (+)).)

The diff shows the new file we made, which originally cause the merge
conflict when we committed it without first pulling in changes from
the remote.

```
$ git diff main
diff --git a/freebsdInstallDigitalOcean.md b/freebsdInstallDigitalOcean.md
deleted file mode 100644
index bb3706f..0000000
--- a/freebsdInstallDigitalOcean.md
+++ /dev/null
@@ -1,35 +0,0 @@
-04-17-2022 San Francisco on Digital Ocean
-https://marcocetica.com/posts/openbsd_digitalocean
-
-Differences from those instructions:
- - You can download and dd an install larger than OpenBSD's miniroot,
-including FreeBSD mini-memstick.img.
- - After dd'ing the image and rebooting, go to the droplet's access tab
-and launch the recovery console, rather than the regular console.
- - FreeBSD installer gets error: geom: gpart vtbd0 file exists.
-Fix found at: https://github.com/helloSystem/ISO/issues/200
-At bottom of page:
-
-----
-
-Need to test with running /sbin/gpart destroy -F adaX before invoking
-the installer. After having tried without, all we get is
-
-/sbin/gpart destroy -F adaX
-gpart: Device busy
-
-After rebooting:
-
-sudo umount -f /dev/ada2*
-sudo /sbin/gpart destroy -F adaX
-# Run Installer
-
-----
-
-For this case on Digital Ocean, it is the first partition of vtdb0.
-
-```
-# gpart destroy -F vtdb0
-```
-It did not work. I cancelled the VM.
-
diff --git a/httpdApache.md b/httpdApache.md
```

We didn't lose that commit. It's committed to branch 'mergeConflict'. HEAD is also currently on that branch.

```
$ git status
On branch mergeConflict
nothing to commit, working tree clean
$ git branch
  main
* mergeConflict
```

Next, switch to the 'main' branch; and merge the changes from branch 'mergeConflict' into 'main'.

```
$ git switch main
Switched to branch 'main'
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)
$ git merge mergeConflict
Already up to date.
```

Now it is safe to push to the remote.

```
$ git push
Enumerating objects: 7, done.
Counting objects: 100% (7/7), done.
Delta compression using up to 2 threads
Compressing objects: 100% (5/5), done.
Writing objects: 100% (5/5), 1.11 KiB | 379.00 KiB/s, done.
Total 5 (delta 2), reused 0 (delta 0), pack-reused 0
To example.com:/home/<username>/git-repos/instructions.git
   0756823..89118fe  main -> main
```

The branch 'mergeConflict' exists only on the local repo, not the
remote, because only the current branch is pushed with 'git push' by
default.

We could have pushed all branches with '--all'. But the
'mergeConflict' branch is no longer needed and can even be deleted
from the local repo.

```
$ git branch -d mergeConflict
Deleted branch mergeConflict (was ef9b02b).
```


