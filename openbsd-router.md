installed 03-30-19

Files I touched to conifigure this router are in these directories:
etc
home
root
var

./etc:
boot.conf
dhcpd.conf
hostname.bridge0
hostname.em0
hostname.em1
hostname.em2
hostname.em3
hostname.vether0
monthly.local
pf.conf
rc.conf.local
sysctl.conf

./home:
.mg
.nexrc
.ssh/authorized_keys
configuration

./root:
.mg
.nexrc
pkg_add-u.sh

./var/cron/tabs:
root

./var/unbound/etc:
unbound.conf


<p>
# 07-24

system installed a couple months ago

Today I created /etc/daily.local to sysupgrade instead of openbsd-upgrade.sh


<p>
# 07-28

Switched to weekly.local to save writes on SSD


<p>
# 10-05

added -s to sysupgrade in weekly.local so that it would continue to
retrieve snapshots when 6.6-beta changes to 6.6 (release) and stops
trying to retrieve snapshots by default. Adding -s to sysupgrade fixes
that behavior. 


<p>
# 12-31-2019

Changed hostname from 'apu' to 'router'. Will take effect on next reboot.
Switched 'sysupgrade -s' from weekly.local to monthly.local


<p>
# 01-11-2020

To reload the PF ruleset after modifying the config file:

pfctl -ef /etc/pf.conf

--
Changed timezone from America/Los_Angeles to UTC; the change took
affect cleanly without a reboot; tmux did not update with the new time
until I closed all sessions. It's good to go now.


<p>
# 02-02-2020

Added pkg_add-u.sh to crontab to auto-update packages after sysupgrade.


<p>
# 02-14

Moved install from APU2 with 3 ports to APU4 with 4 ports.


<p>
# 02-26

Configured dhcpd and unbound for reserved IP for nas and local DNS for
router and nas.

dig worked right away.

I had to dhclient iwm0 on t440 to get local DNS to start working.


Need to update openbsd-router and openbsd-nas with latest
configuration.  Then install FreeBSD on nas.


--------
02-29

 - configured all interfaces on a bridge
 - configured unbound
 - reconfigured pf.conf and added comments

Need to investigate switch interface instead of bridge.


<p>
# 04-01

Decided to keep using bridge rather than switch.
Discovered /etc/monthly.local failed to sysupgrade because tmux -d
needs to be 'tmux new -d'. The failure was logged in
/var/log/monthly.out.

I updated /etc/monthly.local from 'tmux -d' to 'tmux new -d' and,
rather than waiting another month to sysupgrade, scheduled it with:

at -f /etc/monthly.local 1pm tomorrow

which will run at thu apr 2 1300 UTC 2020


<p>
# 04-05

Finally checked this file into RCS for version control.

Today I found nas on APU2 is a minute behind on time. So I added
'listen on *' to ntpd.conf. Now the router ntpd daemon listens for ntp
requests from hosts on the LAN, including nas.


<p>
# 05-18

Setup NFS. Added /etc/exports. Documented it in nfs-server-client-config.


<p>
# 08-13

Activated doas.conf for wheel members without password and with users
own environment variables.

permit nopass :wheel

Used existing file and RCS file (,v) from openbsd-laptop.


<p>
# 08-19-2020

Successfully enrolled all pf.conf history files (pf.conf.old, etc)
into RCS. Cleaned up formatting, comments, and whitespace on pf.conf.


<p>
# 08-19-2021

Uploaded new authorized_keys file for different public ssh keys for
each client.

Uploaded ~/.tmux.conf to replace default prefix Ctrl-b with backtick `.

/etc/ssh/sshd_config, disabled PasswordAuthentication and
ChallengeResponseAuthentication.

Corrected the local time which had drifted ahead by almost 10 minutes.

```
# date 2223
```

Sysupgrade is not working, but gives the error:

```
sysupgrade: invalid signing key
```

Trying to upgrade from: 6.8-current #254 Fri Jan 1 2021
To 6.9-current #180 or higher, Aug 20 2021 or later

/etc/signify didn't have openbsd-70-*

Copying the ones from 9.k9w.org did not work, because it's a release?

Does -current use a different set of keys?

Compare the keys with those of a.k9w.org


<p>
# 08-22

Renamed /etc/signify to /etc/signify.bak.d

Copied /etc/signify from a.k9w.org to router. A had a snapshot from
08-14-21. But sysupgrade still gave the same error, even after
deleting the directory /home/_sysupgrade.


<p>
# 08-23

Renamed configuration to configuration-router.md.

/usr/sbin/sysupgrade was on the same Oct 22 2020 version as 6.9-current.
I deduced that the shell script might not be able to upgrade more than 6
months in one jump unless it was to a release.

So I chose to upgrade from 6.8-current Jan 1 2021 to 6.9-release. Syspatched
to the Aug 10 2021 kernel.

Sysmerge selected root's crontab and unbound.conf. I selected merge
current and new version, manually renamed my current copies to *.bak,
and the new ones sysmerge installed were blank. So I deleted them and
renamed *.bak back to their original names. Running sysmerge again
returned already completed.

Hopefully my automatic snapshot upgrades in /etc/monthly.local will resume
as usual on September 1st 22:30 Pacific.

Before the upgrade from 6.8-current, unbound wasn't resolving router and
nas to their IP addresses. That did not change with the upgrade. Need to
fix it.


<p>
# 08-24

To reduce disk overwrites and preserve the life of the SSD, I chose to
not keep up with -current and instead to stick with -release.

Moved monthly.local from /etc to ~.

```
# mv /etc/monthly.local /home/kevin
```

Also moved root's crontab from /var/cron/tabs to /home/kevin.


<p>
# 10-15-2021

Upgraded from 6.9-release to 7.0-release.


<p>
# 06-05-2022

Removed this file from RCS and deleted the RCS file. Renamed this
file's extension from .d to .md. Converted the rest of the date
timestamps to markdown format.

Starting within the last month, on a fresh boot, the router no longer
routes traffic to or from wifi connected devices. Once I initiate a
ping to any wifi-connected client, it starts passing traffic.

Need to either re-examine the PF rules and new router install
instructions to see what to change in my setup, or need to re-install
OpenBSD on the router and start from scratch.


