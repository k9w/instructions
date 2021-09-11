	$Id: rcs_notes,v 1.2 2019/09/22 22:28:22 kevin Exp $

added Id keyword on 09-22-19

started 07-23-19

# check in working file and keep it locked and writable (executable?)

ci -l [file]


# put in a descriptive log message when prompted, so that you can
# recognize later what you revised in that revision

# view list of revisions and commit messages

rlog [file]


# checkout and lock the latest revision of [file] from RCS to edit or
# run [file] that's currently checked in and unlocked

co -l [file]


# check out [file] read only, (not executable?)

co [file]


# check in [file] and delete the working copy

ci [file]


# diff revisions 1.3 and 1.5

rcsdiff -r1.3 -r1.5 [file]


# if revision 1.3 is stubbornly locked even when checked in, break the
# lock 

rcs -u1.3 [file]


# to revert the working file to a previous revision 1.4, readonly

co -f1.4 [file]


# to revert to a previous revision 1.4, writable (executable?)

co -l -f1.4 [file]


# if ci complains with the message:

ci error: no lock set by ]your name]

# then you have tried to check in a file even though you did not lock
# it when you checked it out. Of course, it is too late now to do the
# checkout with locking, because another checkout would overwrite your
# modifications. Instead, invoke:

rcs -l f.c

# This command will lock the latest revision for you, unless somebody
# else got ahead of you already. In this case, you'll have to
# negotiate with that person. 

# see also the FreeBSD manpage rcsintro(1), available on the web at
#  https://www.freebsd.org/cgi/man.cgi?query=rcsintro&sektion=1&n=1
