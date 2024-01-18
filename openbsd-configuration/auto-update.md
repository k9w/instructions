started 10-07-19

This file starts out as a specification for how to apply un-attended
updates to OpenBSD-current fully automatically. Once specified, it
will be coded as a shell script, or modification to an incumbent shell
scipt such as /usr/sbin/sysupgrade, and/or what ever other direction
this project takes. Then, before making the script executable, the 
specification will be converted to a comment, or removed entirely.

Step 1

The issue: A few weeks after changing from 6.6-current to 6.7-beta, it
will change to 6.7 for a week or two before the actual release. The
problem is that sysupgrade, fw_update, and pkg_add default to fetching
sets, firmware, and packages for the version they are on now. If that
changes from a snapshot to a release candidate, it won't update to the
next release candidate or snapshot, only the following release when it
comes out 6 months later, 6.8 in this example. 

Here is where and why fw_update is instructed to run on the next reboot.
It needs to always download from the snapshots folder and not look for a
release directory that does not exist yet.

/usr/src/distrib/miniroot/install.sub:
# Ensure that fw_update is run on reboot.
echo "/usr/sbin/fw_update -v" >>/mnt/etc/rc.firsttime

One solution: alias the options in /etc/profile to always fetch for a
snapshot even when this happens. Don't use ~/.profile, because the
root shell won't execute that when running sysupgrade or
/etc/rc.firsttime later.

Step 2

Find out how sysupgrade calls install.sub to call fw_update. See if
any changes are needed.

In the sysupgrade script, add pkg_add to /etc/rc.firsttime. I have
observed that rc.firsttime is called, and needs to finish, before boot
completes and the login prompt appears, probably before sshd starts
too. 

This can affect when I or monitoring or configuration management
services such as Ansile can login and verify successfull updates and
functioning, or (for me logging in) to just use the system if it's a
laptop.

**Need to check /etc/rc to verify.**

In situations such as servers where the packages should really be
updated before starting any /usr/local services from packages, it
might be okay to delay allowing logins until this is done.

If however login should be allowed as soon as possible, then pkg_add
should be called in rc.firsttime with the at(1) command.

Either the package services can start normally and pkg_add can run in
the background (services might not restart and actually start using the
newly-updated or patched executables).

Or the services should also be delayed from starting until pkg_add is done.

