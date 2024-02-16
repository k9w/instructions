## Concurrent Versions System (CVS)

[cvs(1)](https://man.openbsd.org/cvs) is a centralized version control
system [used by the OpenBSD
project](https://cvs.afresh1.com/~andrew/o/why-cvs.html). This guide
shows how to:

* Obtain the source code and update it from upstream.
* Switch your working copy to a tag or branch.
* Compare code and content among different commits and with custom
changes, see the history of who changed what and when, etc.

It lacks default tooling to
push and pull changes between repositories, though add-on tools such
as [reposync](https://github.com/sthen/reposync) can accomplish
that. Checked out copies of a CVS tree are in a separate folder from
the repository, if not on a separate machine altogether. Synchronizing
the local working checkout of a large CVS tree with its repository can
be slow over the internet. This can be mitigated by using a local
repository mirrored from upstream.

(Use the OpenBSD website as an example repository to checkout, compare
different commits in history and to mirror the full repository.)

## Fetch the Repository

Becausing updating a cvs checkout working directory can be very slow
when its repository is remote across the internet, let's do the CVS
equivalent of a 'git clone' and fetch a copy of the full repository
using rsync and a wrapper script called reposync.


```
# pkg_add reposync
# useradd cvs
# install -d -o cvs /cvs /var/db/reposync
# chmod -R g+w /cvs /var/db/reposync
```

The one command below both fetches an initial mirror of the repository
and can be used again to update it.

```
$ doas -u cvs reposync rsync://anoncvs.spacehopper.org/cvs
```

This takes about 90 minutes on initial sync and uses about 10GB as of 2024.

```
$ du -hcs /cvs/*
224M    CVSROOT
1.8G    ports
4.2G    src
956M    www
2.4G    xenocara
9.5G    total
```

## Update the local Repository

Use the same reposync command above to update the repo.

```
$ doas -u cvs reposync rsync://anoncvs.spacehopper.org/cvs
```

A daily update takes about 5 minutes.


## Setup folders for CVS

`/usr/src` should already exist with these settings.

```
$ ls -l /usr | grep src
drwxrwxr-x   2 root   wsrc    512 Jan 17 23:23 src
```

If not, add it to the list of folders below.

In /usr, create folders for ports, xenocara, and www with the same
settings.

```
$ cd /usr
# mkdir {ports,xenocara,www}
# chgrp wsrc {ports,xenocara,www}
# chmod g+w {ports,xenocara,www}
```

Set $CVSROOT to `/cvs` in ~/.profile.

```
CVSROOT=/cvs
export CVSROOT
```

Log out and back in, or source .profile to apply the change. Check it
with `env`.

```
$ . ~/.profile
$ env | grep -i cvs
CVSROOT=/cvs
```

## Checkout each repository with CVS

Checkout from the local repo to these folders.

```
$ cd /usr
$ cvs -qd /cvs co -P {src,ports,xenocara,www}
```

Checking out all four sets of the repository concurrently (each in its
own tmux window) on my Thinkpad X220 took:

```
ports: 52 minutes
src: 44 minutes
xenocara: 28 minutes
www: 9 minutes
```

## Update the working copy from the local Repository

Later, use the update or up subcommand to cvs to update the new workin
copy.

```
$ cd /usr/src
$ cvs -d /cvs -q up -Pd
```

## Copy the local Repository to another machine

If you want the full repo on multiple machines and to not redundantly
download the full copy from the third party mirror multiple times,
create a compressed tar archive of /cvs in /var/db/reposync.

```
$ doas -u cvs tar czf /var/db/reposync/cvs-repo.tgz /cvs
$ doas -u cvs tar czvf /var/db/reposync/src-repo.tgz /cvs/src/*
```

```
$ openrsync -av --rsync-path=/usr/bin/openrsync \
hostname:/var/db/reposync/repo-archive /var/db/reposync
```

```
$ openrsync -av --rsync-path=/usr/bin/openrsync \
a.k9w.org:/var/db/reposync/checkout-archive /var/db/reposync
```

```
$ doas -u cvs tar xzf /var/db/reposync/repo-archive/www-repo.tgz -C /
```

Several files in the archive will excede the maximum file path length
for the default ustar and give the following error.

```
tar: File name too long for ustar
cvs/ports/x11/qt6/qtwebengine/patches/patch-src_3rdparty_chromium_ui_views_widget_desktop_aura_desktop_window_tree_host_platform_impl_interactive_uitest_cc,v
```

To prevent that, investigate other command options for tar, use a
different tool than tar, or count on re-syncing those files from
upstream once the archive is extracted on the destination machine.

To replicate to a server as is, create the user and folder on the
server and upload the tar archive from local to remote with openrsync.

At work on symmetrical Gigabit fiber, this took about 30 minutes to
upload 2.1GB.

```
$ openrsync -av --rsync-path=/usr/bin/openrsync /var/db/reposync/cvs-repo.tgz hostname:/var/db/reposync
Transfer starting: 1 files
cvs-repo.tgz
Transfer complete: 36 B sent, 2.073 GB read, 2.073 GB file size
```

On the server, change the tar archive owner to cvs if not already.

```
$ cd /var/db/reposync
# chown cvs cvs-repo.tgz
```

Ensure /cvs exists with proper permissions for the cvs user. Then
untar the archive into it.

```
$ cd /cvs
$ doas -u cvs tar xzf /var/db/reposync/cvs-repo.tgz
```
Extraction takes about 15 minutes.

Then run reposync to pull in the filepaths too long for tar to fit
into the tar archive, as well as any updates since the initial sync.


## Build OpenBSD Ports or Base

This seciton contains additions and clarifications to OpenBSD's [own
documentation](https://www.openbsd.org/anoncvs.html) on using CVS to
track OpenBSD code.

One detail not shared on that page is CVS is the only way to track
releases. The [Git mirror](https://github.com/openbsd) only tracks
-current. This is particularly important if you use -release and you
want to install a port such as [Tarsnap](https://tarsnap.com). Its
[OpenBSD port](https://openports.pl/path/sysutils/tarsnap)
deliberately does not have a pre-compiled package available, because
the Tarsnap author encourages users to verify the client source code,
to not blindly trust a pre-compiled package from someone else, but to
verify the code is safe for them, and then compile a package for
themselves.

### Switch from one upstream repository mirror to another

If you initially did a full checkout using
anoncvs@anoncvs1.usa.openbsd.org:/cvs and want to switch to
anoncvs@anoncvsd.spacehopper.org:/cvs, you need to change the mirror
name in ./CVS/Root and then specify it one time on the command line
next time you do cvs update.

If you just change it in ./CVS/Root and then run CVS update without
specifying the new mirror once on the command line, you might get an
error like this:

```
cvs update: move away usr.sbin/zic/zic.8; it is in the way
C usr.sbin/zic/zic.8
```

Here is how to switch the mirror to spacehopper while tracking
7.3-release.

```
$ cvs -d anoncvs@anoncvs.spacehopper.org:/cvs -q up -Pd -rOPENBSD_7_3
```


### reposync: Host your own repository mirror

https://github.com/sthen/reposync

## Host Your Own Project with CVS

(The rest of the content on this page is old and will likely be replaced.)

cd ~/k9w
cvs -d $PWD init

cd ~/bin/learn
cvs -d $OLDPWD import -m "Initial import from RCS project" learn k9w start
N learn/rcs_notes
N learn/cvs_notes
cvs import: Importing /home/kevin/k9w/learn/www.shellscript.sh
N learn/www.shellscript.sh/first.sh,v
N learn/www.shellscript.sh/for.sh,v
N learn/www.shellscript.sh/test.sh,v
N learn/www.shellscript.sh/var.sh,v
N learn/www.shellscript.sh/while.sh,v
N learn/www.shellscript.sh/test.sh

No conflicts created by this import

             
cd ..
mv learn learn.orig
cvs -qd ~/k9w checkout -P learn
U learn/cvs_notes
U learn/rcs_notes
U learn/www.shellscript.sh/first.sh,v
U learn/www.shellscript.sh/for.sh,v
U learn/www.shellscript.sh/test.sh
U learn/www.shellscript.sh/test.sh,v
U learn/www.shellscript.sh/var.sh,v
U learn/www.shellscript.sh/while.sh,v


# diff changes on cvs_notes

# incorporate RCS history into CVS where I used RCS

# diff changes on shellscript.sh examples that I tracked with RCS,
with revisions done after the import into CVS, and with the current
version in the source repository and working directory.

# continue working the tutorial at Functions

# try out and learn the rest of the CVS commands and document them here


--------
09-26


Now that I have learned and used CVS a bit, I am ready to start using
Subversion. I discovered I needed to rename my repository and working
directory to clearly show which repo and working directory is managed
by CVS, and which will be managed by SVN.

First I committed any changes left in my currently checked out copy of
~/k9w/learn. Then I renamed the repo 'k9w' and module 'learn'.

cd ~
mv k9w k9w-cvs
cd k9w-cvs
mv learn learn-cvs

Then I checked out a fresh copy of learn-cvs from ~/k9w-cvs

cd ~/bin
cvs -d ~/k9w-cvs checkout learn-cvs

Then I told cvs I was abandoning my checkout of 'learn'.

cd ~/bin/learn
cvs -d ~/k9w-cvs release

Then I deleted 'learn', now that it had been replaced by learn-cvs.

cd ~/bin
rm -r learn

That is how to rename a repo and module in CVS.

Now I can create a new SVN repo and project (like module), documented
in that project.

To revert my current checkout from Sep 28 2019 to the state it was in
on Sep 15:
cvs -d ~/k9w-cvs checkout -D "9/15/19" learn-cvs

To revert it to a month ago:
cvs -d ~/k9w-cvs checkout -D "1 month ago" learn-cvs

I tested this with a checkout of learn-cvs to ~/src instead of my main
woring copy in ~/bin. No cvs release was necessary. Checking out an
older version succesfully removed files that had been created later
with the phrase "is no longer in the repository" because it was
reverting the working copy back to a time before those files existed.

TODO:

Learn how to use `cvs checkout -j' and 'cvs update -j' to reconcile
the differences in file conflicts. If I conscientiously commit each
change I make, this problem would only come up in multi-developer
situations.

If cvs update or cvs commit reports a conflict where it could not
merge my local changes successfully with the version committed after
my latest checkout or update to this working copy, then here is how to
resolve the conflicting changes.

From error:
C conflicts occured

do
cvs update -j1.5 -j1.3 foo.c

or
cvs update -jTAG:DATE

or do
cvs update -C
this will overwrite the local copy with clean version from the repo
and save my local copy in '.#file.revision' Then merge or edit the
files by hand and then do 'cvs commit'

Need to test these todo commands.
	$Id: cvs_setup,v 1.2 2021/02/05 06:36:35 kevin Exp $

Migrate this server config files from RCS to CVS.
 
# apt install cvs
# exit
$ pwd
/home/kevin
$ cvs -d ~/dotfiles init
$ mkdir test
$ cd test
$ cvs -d ~/dotfiles import -m "" kevin dotfiles start

No conflicts created by this import

$ pwd
/home/kevin/test
$ cd
$ rmdir test
$ su
Password:
# mv dotfiles /home
# exit
$ cd /home
$ cvs -d /home/dotfiles checkout kevin

Since I had already started an RCS file for configuration, I imported
that into CVS by hand.

$ pwd
/home
$ mv kevin/configuration,v dotfiles/kevin

I ensured the Id keyword had been added to each file I want to track
and then added them to CVS.

$ cd
$ pwd
/home/kevin
$ cvs add .mg .nexrc .profile .ssh
cvs add: scheduling file `.mg' for addition
cvs add: scheduling file `.nexrc' for addition
cvs add: scheduling file `.profile' for addition
Directory /home/dotfiles/kevin/.ssh put under version control
cvs add: scheduling file `.ssh/authorized_keys' for addition
cvs add: use `cvs commit' to add these files permanently
$ cvs commit -m "added files, including importing the RCS file for configuration"

Adding the file called configuation using its rcs file did not work
correctly at first. CVS said it is in the way. So I renamed my working
copy, did cvs update to pull in the repo version, renamed the latest
one back, and committed again. And it worked.


cvs commit: Examining .
cvs commit: Examining .ssh
/home/dotfiles/kevin/.mg,v  <--  .mg
initial revision: 1.1
/home/dotfiles/kevin/.nexrc,v  <--  .nexrc
initial revision: 1.1
/home/dotfiles/kevin/.profile,v  <--  .profile
initial revision: 1.1
/home/dotfiles/kevin/.ssh/authorized_keys,v  <--  .ssh/authorized_keys
initial revision: 1.1
kevin@de:~$ cvs update
cvs update: Updating .
cvs update: move away `configuration'; it is in the way
C configuration
? .bash_history
? .bash_logout
? .bashrc
? .joe_state
? .lesshst
? .local
? .viminfo
cvs update: Updating .ssh
? .ssh/id_ed25519.pub
$ mv configuration configuration.1
kevin@de:~$ cvs update
cvs update: Updating .
U configuration
? .bash_history
? .bash_logout
? .bashrc
? .joe_state
? .lesshst
? .local
? .viminfo
? configuration.1
cvs update: Updating .ssh
? .ssh/id_ed25519.pub
$ diff configuration configuration.1
$ mv configuration configuration.2
$ mv configuration.1 configuration
kevin@de:~$ cvs commit -m "fixing confguration"
cvs commit: Examining .
cvs commit: Examining .ssh
/home/dotfiles/kevin/configuration,v  <--  configuration
new revision: 1.4; previous revision: 1.3

Then I deleted configuration.2.

Next, create the conf repo for the rest of the system, outside of
users in /home.

$ su
Password:
# pwd
/home
# cvs -d /home/conf init
# mkdir test
# cd test
# cvs -d /home/conf import -m "" root conf start

No conflicts created by this import

# cvs -d /home/conf import -m "" etc conf start

No conflicts created by this import

# cvs -d /home/conf import -m "" usr conf start

No conflicts created by this import

# cvs -d /home/conf import -m "" var conf start

No conflicts created by this import

# pwd
/home/test
# cd ..
# rmdir test
# cd /
# cvs -d /home/conf checkout root
cvs checkout: Updating root
? root/.bash_history
? root/.bashrc
? root/.joe_state
? root/.lesshst
? root/.local
? root/.mg
? root/.nexrc
? root/.profile
? root/.selected_editor
? root/.ssh
? root/.viminfo
? root/test

# cvs -d /home/conf checkout etc
cvs checkout: Updating etc

[Directory listing trimmed.]

# cvs -d /home/conf checkout usr
cvs checkout: Updating usr
? usr/bin
? usr/games
? usr/include
? usr/lib
? usr/lib32
? usr/lib64
? usr/libx32
? usr/local
? usr/sbin
? usr/share
? usr/src
# cvs -d /home/conf checkout var
cvs checkout: Updating var
? var/backups
? var/cache
? var/lib
? var/local
? var/log
? var/mail
? var/opt
? var/spool
? var/tmp

Add Id keyword to files to add in /root.

# cd /root
# nvi .mg                                 
# nvi .nexrc                 
# nvi .profile    
# cvs add .mg .nexrc .profile                             
cvs add: scheduling file `.mg' for addition
cvs add: scheduling file `.nexrc' for addition
cvs add: scheduling file `.profile' for addition
cvs add: use `cvs commit' to add these files permanently
# cd /etc
# cd ssh
# ls /etc/ssh/sshd_config*
/etc/ssh/sshd_config
/etc/ssh/sshd_config.old
/etc/ssh/sshd_config.ucf-old
# diff sshd_config sshd_config.
diff: sshd_config.: No such file or directory
# diff sshd_config sshd_config.
sshd_config.orig     sshd_config.ucf-old
# diff sshd_config sshd_config.
sshd_config.orig     sshd_config.ucf-old
# diff sshd_config sshd_config.orig
56c56
< PasswordAuthentication no
---
> #PasswordAuthentication yes
121a122,123
> PasswordAuthentication yes
> PermitRootLogin yes
# diff sshd_config sshd_config.ucf-old
32a33,35
>
> PermitRootLogin no
>
50c53
< # HostbasedAuthentication
---
> # Hostbasedauthentication
55a59,60
> #PasswordAuthentication yes
>
56a62
>
121a128,130
>
> # PasswordAuthentication yes
> # PermitRootLogin yes
# mv sshd_config sshd_config.new
# mv sshd_config.orig sshd_config
# nvi sshd_config
# cd ..
# cvs add ssh ssh/sshd_config tarsnap.conf
Directory /home/conf/etc/ssh put under version control
cvs add: scheduling file `ssh/sshd_config' for addition
cvs add: scheduling file `tarsnap.conf' for addition
cvs add: use `cvs commit' to add these files permanently
# cvs commit -m "added files from root and etc"
cvs commit: Examining .
cvs commit: Examining ssh
/home/conf/etc/tarsnap.conf,v  <--  tarsnap.conf
initial revision: 1.1
/home/conf/etc/ssh/sshd_config,v  <--  ssh/sshd_config
initial revision: 1.1
# cd ssh
# mv sshd_config sshd_config.old
# mv sshd_config.new sshd_config
# mg sshd_config
# cvs diff sshd_config
Index: sshd_config
===================================================================
RCS file: /home/conf/etc/ssh/sshd_config,v
retrieving revision 1.1
diff -r1.1 sshd_config
1c1
< #     $Id: cvs_setup,v 1.2 2021/02/05 06:36:35 kevin Exp $
---
> #     $Id: cvs_setup,v 1.2 2021/02/05 06:36:35 kevin Exp $
33c33
< #PermitRootLogin prohibit-password
---
> PermitRootLogin no
57c57
< #PasswordAuthentication yes
---
> PasswordAuthentication no
123,124d122
< PasswordAuthentication yes
< PermitRootLogin yes
# mg sshd_config
# mg sshd_config.old
# cvs commit -m "updated sshd_config"
cvs commit: Examining .
/home/conf/etc/ssh/sshd_config,v  <--  sshd_config
new revision: 1.2; previous revision: 1.1
# crontab -e
crontab: installing new crontab
# cd /var/spool/cron/
# ls
crontabs
# cd crontabs/
# ls
root  root,v

Here I chose to delete the RCS file since the history is not
significant. Better to start over and add the current crontab to CVS.

# rm root,v
# cvs add root
cvs add: No CVSROOT specified!  Please use the `-d' option
cvs [add aborted]: or set the CVSROOT environment variable.

Here, I had forgitten to add the directories spool and cron to CVS.

# cd /var
# cvs add spool spool/cron spool/cron/crontabs spool/cron/crontabs/root
Directory /home/conf/var/spool put under version control
Directory /home/conf/var/spool/cron put under version control
Directory /home/conf/var/spool/cron/crontabs put under version control
cvs add: scheduling file `spool/cron/crontabs/root' for addition
cvs add: use `cvs commit' to add this file permanently
# cvs commit -m "added root crontab"
cvs commit: Examining .
cvs commit: Examining spool
cvs commit: Examining spool/cron
cvs commit: Examining spool/cron/crontabs
/home/conf/var/spool/cron/crontabs/root,v  <--  spool/cron/crontabs/root
initial revision: 1.1
#

# exit
$ cd
$ mkdir instructions

I separated setup for cvs and tarsnap from configuration into separate
instruction files.

$ cvs add instructions/
Directory /home/dotfiles/kevin/instructions put under version control
$ cd instructions/
$ cvs add *
cvs add: cannot add special file `CVS'; skipping
cvs add: scheduling file `cvs_setup' for addition
cvs add: scheduling file `tarsnap_debian' for addition
cvs add: use `cvs commit' to add these files permanently
$ cd
$ cvs commit -m "Separated setup for cvs and tarsnap from configuration into separate files."
cvs commit: Examining .
cvs commit: Examining .ssh
cvs commit: Examining instructions
/home/dotfiles/kevin/configuration,v  <--  configuration
new revision: 1.5; previous revision: 1.4
/home/dotfiles/kevin/instructions/cvs_setup,v  <--  instructions/cvs_setup
initial revision: 1.1
/home/dotfiles/kevin/instructions/tarsnap_debian,v  <--  instructions/tarsnap_debian
initial revision: 1.1
$
