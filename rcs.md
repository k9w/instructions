## Introduction

Revision Control System (RCS) is a Version Control System (VCS) that
allows users to create, maintain, compare and roll back changes to
files.

It preceeded other VCS'es Git, Got, Subversion, and CVS.

RCS repositories (repos) are centralized, not distributed. In fact RCS
has no concept of committing or checking in changes over the network.

Each RCS repository tracks just one file. The repository is named
identical to the file it tracks, with a ```,v``` suffix, including
after any other suffixes the file might have.


## Overview

Unique from the other VCS'es above, RCS uses multiple root commands,
not sub-commands:

- [ci(1)](https://man.openbsd.org/ci) - Check-in a file to RCS for
  tracking. Commit a new revision to an already-tracked file.

- [co(1)](https://man.openbsd.org/co) - Check-out a file from RCS for
  editing. Not needed if you previously checked in the file unlocked
  with ```ci -l [file]```.

- [rlog(1)](https://man.openbsd.org/rlog) - View the log of changes
  and commit messages.

- [rcs(1)](https://man.openbsd.org/rcs) - Manage an RCS repository's
  locking, revisions, log messages, branches, etc.

- [rcsdiff(1)](https://man.openbsd.org/rcsdiff) - Compare multiple
  revisions of the tracked file.

- [rcsmerge(1)](https://man.openbsd.org/rcsmerge) - Merge changes
  between revisions.

- [rcsclean(1)](https://man.openbsd.org/rcsclean) - Clean up working
  files. This means if you have a configuration file tracked by RCS
  delete the working copy while it is checked into the RCS ,v
  repository. This is usually not what you want these days if you
  actively use the configuration file in production in the same folder
  as its ,v repository.

- [ident(1)](https://man.openbsd.org/ident) - Identify the keyword
  string in RCS-tracked files.

RCS supports two general workflows:

- Lock the file for editing.

- Just check in changes and don't worry about locking.

RCS command flags and manpages use the term ```revision``` to refer to
a specific version of the tracked file. Later VCS'es call it a
```commit```. I may use the terms interchangably in this guide.


## Basic Usage 

For our example, let's write a configuration file for
[doas(1)](https://man.openbsd.org/doas), a [2-clause
BSD-licensed](https://opensource.org/license/bsd-2-clause) tool to run
commands as another user, usually privileged commands a root. Doas
incorporates much less code than [sudo](https://www.sudo.ws) which is
also [permissively-licensed](https://www.sudo.ws/about/license).

The file you want to track with RCS is called the working copy:

```
doas.conf
```

RCS will track it in a repo file called:

```
doas.conf,v
```

### Create a sample file

Using your preferred text editor, create the file doas.conf.

```
$ nano doas.conf
```

Add content such as the following.

```
#allow wheel members to doas without password and keep their
# environment variables

permit nopass :wheel
```

Any mistakes in the file content are okay for now. It's a good
opportunity to make corrections and see the changes in the commit history.

Save the file and exit the text editor.

Show the permissions and modification time of the file.

```
$ ls -al doas.conf
-rw-r--r--  1 kevin  kevin  107 Jul  3 14:18 doas.conf
```

Take note of it for later in this guide.


### Start tracking the file with RCS the default way

Check in the file to RCS with ```ci```. Leave off any command flags,
to see the default behavior.

```
$ ci doas.conf
doas.conf,v  <--  doas.conf
enter description, terminated with single '.' or end of file:
NOTE: This is NOT the log message!
>> 
```

Type ```First commit.``` Then hit Enter.

```
>> First commit.
>> 
```

Notice RCS did not exit and wants more input. After the description we
typed above, RCS said to terminate it with a single period (dot) or
end-of-file character. A '.' is easier than EOF.

Type ```.``` then hit Enter.

```
>> First commit.
>> .
initial revision: 1.1
done
```

The RCS repo has been created. Let's see what things look like.

```
$ ls -al doas.conf*
-r--r--r--  1 kevin  wheel  299 Jul  3 15:20 doas.conf,v
```

The original file ```doas.conf``` is gone. RCS created the new repo
file ```doas.conf,v``` and deleted the original working copy of the
file.


### The RCS repo file

In the next section, we will look at how to recover the original
file. But before we continue, let's look at the repo file in detail.

```
$ cat doas.conf,v

head    1.1;
access;
symbols;
locks; strict;
comment @# @;


1.1
date    2023.07.03.15.20.50;    author kevin;   state Exp;
branches;
next    ;


desc
@First commit.
@


1.1
log
@Initial revision
@
text
@#allow wheel members to doas without password and keep their
# environment variables

permit nopass :wheel
@
```

```head``` refers to the latest version on the selected branch. It is
```1.1``` in this case.

RCS defaults commit versions to 1.1 to start. There is no 1.0. The
second commit is 1.2, third is 1.3, etc.

We've only made one commit thus far. The rest of the repo file shows
us:

- The date and author of the commit. 2023, July 3rd, at 15:20.

- We have no branches yet.

- The description of the first commit: ```First commit.```

- The file contents of the first commit.


### How do we recover the original file?

Without any command flags, RCS literally checks in the file to the
repository and doesn't leave the working copy outside the repo.

Let's get the working copy back by checking it out with the ```co```
command.

```
$ co doas.conf
doas.conf,v  -->  doas.conf
revision 1.1
done
```

Now we should have both the repo file and the working copy.

```
$ ls -al doas.conf*
-r--r--r--  1 kevin  kevin  107 Jul  3 15:44 doas.conf
-r--r--r--  1 kevin  wheel  299 Jul  3 15:20 doas.conf,v
```

There are two problems here:

- ```doas.conf``` is now read-only, compared to the ```-rw-r--r--```
  permissions we had before we checked it into RCS.

- The file contents have not changed since the we saved it in the text
  editor at ```14:18```. Why does it now say last modified at
  ```15:44```?

Here's what happened:

- The file is read-only because RCS only lets a file be edited when
  it's ```locked``` to one person to edit it at a time. File locking
  is intended to disuade multiple people from editing the file at the
  same time, or the same person from editing the file in multiple
  terminals/editors. The intention is to minimize multiple sets of
  changes that could conflict with one another. When a file is
  ```unlocked```, anyone may lock it for exclusive editing
  permission. By default, ```ci``` checks in the file and clears any
  existing lock, and stores the file unlocked in the repository.

- By default, ```co``` checks out the working copy of the file by
  creating it new, which gives it a last-modified time of when you
  checked it out (15:44), not earlier when you saved it
  (14:18). Additionally, the time we checked in the file to RCS with
  ```ci``` was ```15:20```. Because ```ci``` deletes the working copy
  by default, we cannot use RCS to retrieve the file with it's
  original last-modified time of 14:18. What we can do is restore it
  with the timestamp it was checked in at 15:20.

Here's what to do:

We could manually set the new working copy of the file from read-only
to writable with [chmod(1)](https://man.openbsd.org/chmod). But it's
better to use RCS's own commands and flags to fix this.

We will see later that it's better to not check in the file the
default way we did above, which locks the file and removes the working
copy.

However since we did check it in the default way, we can make it
editable by us and restore its last-checked-in time as the
last-modified time.

The [co(1) manpage](https://man.openbsd.org/co) describes an option to
fix each of those issues:

	-l
		Retrieve the latest commit and lock it for editing.

	-M
		Set the modification date of the checked-out file to the time
		of the last commit.

RCS does not support multiple command flags behind one dash
```-lM```. They must be separated out as ```-l -M```. The sequence
does not matter in this case.

```
$ co -l -M doas.conf
doas.conf,v  -->  doas.conf
revision 1.1 (locked)
done
```

Let's take a look at what we checked-out.

```
$ ls -al doas.conf*
-rw-r--r--  1 kevin  kevin  107 Jul  3 15:20 doas.conf
-r--r--r--  1 kevin  wheel  310 Jul  3 20:10 doas.conf,v
```

doas.conf still shows the same content. But it now shows the
last-checked-in time of 15:20 rather than 15:44, which was when we
first checked it out.

### A better way

To avoid all that check-out cleanup, let's check in each new commit we
want to make by leaving the file locked for editing and intact as a
working copy outside its repo file using the following flag to
```ci```.

	-l
		Commit the current working copy and preserve it in its
		directory with unmodified edit permissions.

Here's how that works:

 - (Optionally) edit the file and make some changes. Here is how the
   file looks now. (The blank newline at the end is intentional.)

```
$ cat doas.conf
# Aallow wheel members to doas without password and keep their
# environment variables.

permit nopass :wheel

```

 - Now check-in or commit the new version with the -l flag.

```
$ ci -l doas.conf
doas.conf,v  <--  doas.conf
new revision: 1.2; previous revision: 1.1
enter log message, terminated with a single '.' or end of file:
>> Fix typos.
>> .
revision 1.2 (locked)
done
a$ ls -al doas.conf*
-rw-r--r--  1 kevin  kevin  111 Jul  3 20:39 doas.conf
-r--r--r--  1 kevin  wheel  522 Jul  3 20:39 doas.conf,v
```

It looks normal.

Let's now revisit the repo file itself and see how it changed with the
second commit.

```
head	1.2;
access;
symbols;
locks
	kevin:1.2; strict;
comment	@# @;


1.2
date	2023.07.03.20.39.17;	author kevin;	state Exp;
branches;
next	1.1;

1.1
date	2023.07.03.15.20.50;	author kevin;	state Exp;
branches;
next	;


desc
@First commit.
@


1.2
log
@Fix typos.
@
text
@# Aallow wheel members to doas without password and keep their
# environment variables.

permit nopass :wheel

@


1.1
log
@Initial revision
@
text
@d1 2
a2 2
#allow wheel members to doas without password and keep their
# environment variables
d5 1
@
```

Head is at commit 1.2 instead of the initial 1.1. That means the
latest version is 1.2.

Our user, kevin, now has a lock on commit 1.2, because we used the
```-l``` flag to ```ci``` to keep the working copy in the directory
and locked (available to kevin) for editing.

Next we see the metadata for the two commit records, sorted newest to
oldest.

- Commit 1.2: ```2023 July 3rd at 20:39```.

- Commit 1.1: ```2023 July 3rd at 15:20```.

No branches exist for either commit.

One thing we might have noticed from the first look at the repo file
above was the ```desc``` or description of the file is ```First
commit.```

We should have specified the description as something such as:

```
System configuration file for the doas security utility.
```

And last we see the two commits themselves.

The latest commit, 1.2, shows the commit log message ```Fix typos.```
as well as the full text of the file's current contents.

The previous commit, 1.1, shows a log message of ```Initial
revision``` (likely an RCS default), and only the lines that differ
from the commit directly after it.


RCS does not keep revision history of its own repo file, obviously,
because that's where it records the changes to the file it tracks. But
we can get a diff of how the repo file changed from the first to the
second commit by saving the repo file's initial contents from the
first commit earlier in this guide, paste it into a new file with
extension ```.orig``` and use
[diff(1)](https://man.openbsd.org/diff)'s ```-u``` flag to produce a
unified diff.

```
$ diff -u doas.conf,v.orig doas.conf,v
--- doas.conf,v.orig	Mon Jul  3 21:57:16 2023
+++ doas.conf,v	Mon Jul  3 20:39:17 2023
@@ -1,14 +1,20 @@
-head    1.1;
+head	1.2;
 access;
 symbols;
-locks; strict;
-comment @# @;
+locks
+	kevin:1.2; strict;
+comment	@# @;
 
 
+1.2
+date	2023.07.03.20.39.17;	author kevin;	state Exp;
+branches;
+next	1.1;
+
 1.1
-date    2023.07.03.15.20.50;    author kevin;   state Exp;
+date	2023.07.03.15.20.50;	author kevin;	state Exp;
 branches;
-next    ;
+next	;
 
 
 desc
@@ -16,14 +22,27 @@
 @
 
 
-1.1
+1.2
 log
-@Initial revision
+@Fix typos.
 @
 text
-@#allow wheel members to doas without password and keep their
-# environment variables
+@# Aallow wheel members to doas without password and keep their
+# environment variables.
 
 permit nopass :wheel
+
 @
 
+
+1.1
+log
+@Initial revision
+@
+text
+@d1 2
+a2 2
+#allow wheel members to doas without password and keep their
+# environment variables
+d5 1
+@
```


Next we will see how to update the description and the initial
commit's log message.

Here is how it looks with the bad description, before the fix.

```
$ rlog doas.conf

RCS file: doas.conf,v
Working file: doas.conf
head: 1.2
branch:
locks: strict
        kevin: 1.2
access list:
symbolic names:
keyword substitution: kv
total revisions: 2;     selected revisions: 2
description:
First commit.
----------------------------
revision 1.2    locked by: kevin;
date: 2023/07/03 20:39:17;  author: kevin;  state: Exp;  lines: +3 -2;
Fix typos.
----------------------------
revision 1.1
date: 2023/07/03 15:20:50;  author: kevin;  state: Exp;
Initial revision
=============================================================================
```

Here is the fix.

```
$ rcs -t-"System doas configuration file" -m1.1:"First commit" doas.conf
RCS file: doas.conf,v
done
```
And here is how it looks after the fix.

```
$ rlog doas.conf

RCS file: doas.conf,v
Working file: doas.conf
head: 1.2
branch:
locks: strict
        kevin: 1.2
access list:
symbolic names:
keyword substitution: kv
total revisions: 2;     selected revisions: 2
description:
System doas configuration file
----------------------------
revision 1.2    locked by: kevin;
date: 2023/07/03 20:39:17;  author: kevin;  state: Exp;  lines: +3 -2;
Fix typos.
----------------------------
revision 1.1
date: 2023/07/03 15:20:50;  author: kevin;  state: Exp;
First commit
=============================================================================
```

[continue editing here]




locks the file from further editing
until it is checked out.



Check in a working file and keep it locked and writable (executable?).

```
$ ci -l doas.conf
```

Put in a descriptive log message when prompted, so that you can
recognize later what you revised in that revision.

View list of revisions and commit messages.

```
$ rlog doas.conf
```

Checkout and lock the latest revision of [file] from RCS to edit or
run [file] that's currently checked in and unlocked.

```
$ co -l doas.conf
```

Check out [file] read only, (not executable?).

```
$ co doas.conf
```

Check in [file] and delete the working copy

```
$ ci doas.conf
```

Find the diff between revisions 1.3 and 1.5.

```
$ rcsdiff -r1.3 -r1.5 [file]
```

If revision 1.3 is stubbornly locked even when checked in, break the
lock.

```
$ rcs -u1.3 [file]
```

To revert the working file to a previous revision 1.4, readonly:

```
$ co -f1.4 [file]
```

To revert to a previous revision 1.4, writable (executable?):

```
$ co -l -f1.4 [file]
```

If ci complains with the message:

```
ci error: no lock set by [your name]
```

T hen you have tried to check in a file even though you did not lock
it when you checked it out. Of course, it is too late now to do the
checkout with locking, because another checkout would overwrite your
modifications. Instead, invoke:

```
rcs -l f.c
```

This command will lock the latest revision for you, unless somebody
else got ahead of you already. In this case, you'll have to negotiate
with that person.

See also the FreeBSD manpage rcsintro(1), available on the web at:

<https://www.freebsd.org/cgi/man.cgi?query=rcsintro&sektion=1&n=1>
