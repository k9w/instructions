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

For the following file:

```
main.c
```

RCS tracks it in a repo file called:

```
main.c,v
```

RCS supports two general workflows:
- Lock the file for editing.
- Just check in changes and don't worry about locking.

## Basic Usage 

Create a file, main.c for example. Add content and save it.

Check in the file to RCS and let RCS lock the file from further
editing.

```
$ ci main.c
main.c,v  <--  main.c
enter description, terminated with single '.' or end of file:
NOTE: This is NOT the log message!
>> 
```

Check in a working file and keep it locked and writable (executable?).

```
$ ci -l main.c
```

Put in a descriptive log message when prompted, so that you can
recognize later what you revised in that revision.

View list of revisions and commit messages.

```
$ rlog main.c
```

Checkout and lock the latest revision of [file] from RCS to edit or
run [file] that's currently checked in and unlocked.

```
$ co -l main.c
```

Check out [file] read only, (not executable?).

```
$ co main.c
```

Check in [file] and delete the working copy

```
$ ci main.c
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
