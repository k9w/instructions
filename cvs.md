	$Id: cvs_notes,v 1.11 2019/09/28 23:03:14 kevin Exp $

originally started 08-29-19

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
