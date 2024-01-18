

started 09-26-19

CVS uses keyword substitution. I'm waiting on adding it here until I
learn if Subversion has a different strategy.

https://subversion.apache.org/quick-start
Setting up a local repository 

~/.subversion already existed and has client configuration files. Make
a separate directory for a local repository.

mkdir ~/.svnrepos

### I stopped here. I have renamed cvs paths to not conflict with SVN
paths. Do I want to rename .svnprepos to k9w-svn ? ###

svnadmin create ~/.svnrepos/learn-svn

svn mkdir -m "Create directory structure." \
  file://$HOME/.svnrepos/MyRepo/trunk \
  file://$HOME/.svnrepos/MyRepo/branches \
  file://$HOME/.svnrepos/MyRepo/tags

Create a parent directory .svnrepos where you will place your SVN repositories:
mkdir -p ~/.svnrepos

Create a new repository MyRepo under .svnrepos:
svnadmin create ~/.svnrepos/learn-svn

Create a recommended project layout in the new repository:
svn mkdir -m "Create directory structure." \
	file://$HOME/.svnrepos/learn-svn/trunk \
	file://$HOME/.svnrepos/learn-svn/branches \
	file://$HOME/.svnrepos/learn-svn/tags

Change directory to ~/bin/learn-svn where your unversioned project is
located:

cd $HOME/bin/learn-svn

Convert the current directory into a working copy of the trunk/ in the
repository:
svn checkout file://$HOME/.svnrepos/learn-svn/trunk ./

Schedule your project's files to be added to the repository:
svn add --force ./

Commit the project's files:
svn commit -m "Initial import."

Update your working copy:
svn update


--------
09-28

RCS and CVS use per-file version numbers. SVN uses repository-wide
version numbers.

According to svnbook.red-bean.com, CVS store binary files such as pdf
and docx as whole revisions of binary files. SVN can examine binary
files better and can store revisions more space-efficiently on the
server as binary diffs, whereas CVS needs to store an entire copy of
each revision of a binary file in its repository.

Therefore SVN is better for pdf, docx, sound, pictures, videos, compiled
code, and any binary data who's versions should be tracked.

Here I created learn-svn project (like a CVS module) in my k9w-svn
repository. No specials repo files are in the root of k9w-svn.
svnadmin create ~/k9w-svn/learn-svn

Then I descended into learn-svn and created the recommended
subdirectories 'trunk', 'branches', and 'tags'.
cd ~/k9w-svn/learn-svn
svn mkdir -m "Make trunk directory" file:///home/kevin/k9w-svn/learn-svn/trunk
Committing transaction...
Committed revision 1.
svn mkdir -m "Make branches and tags directories" \
	file://$HOME/k9w-svn/learn-svn/branches \
	file://$HOME/k9w-svn/learn-svn/tags
Committing transaction...
Committed revision 2.

Next, I import files into ~/k9w-svn/learn-svn from ~/bin/learn-cvs. I
don't need to track www.shellscript.sh because I'm done with that
project. Any further work I do on that I can keep doing in CVS. I want
to use SVN for regular expressions, find, grep, awk, and sed, and
perhaps other tools if I need that long to learn SVN. So I hand-picked
some files from learn-cvs and copied them into ~/src/learn-svn as a
temporary location for the import. Here is how I imported those files
into the SVN repository.

I copied selected files from learn-cvs into learn-svn. Then I converted
that directory into a working copy of the repo.
svn checkout file://$HOME/k9w-svn/learn-svn/trunk ./
Checked out revision 2.

This created the .svn directory in the working copy directory.

Then I added the files and told SVN to track them.
svn add --force ./
A         learning_path
A         my-regex
A         svn_notes
A         find-grep-awk-sed

Lastly, I committed the initial import to the repo.
svn commit -m "Initial import of select files from learn-cvs"
Adding         find-grep-awk-sed
Adding         learning_path
Adding         my-regex
Adding         svn_notes
Transmitting file data ....done
Committing transaction...
Committed revision 3.


--------
09-30

To properly track file rename, move, copy, or delete, regular shell
commands won't preserve the change history properly in Subversion.
Instead, use svn move OLD NEW:
svn move find-locate-xargs find-locate


--------
10-04

The following command compares the current working copy with the
pristine copy in .svn most recently checked out from the repository.
This is a local compare and does not contact the remote repository.

svn diff svn_notes

To compare two past revisions in the repository,

cvs diff -r 2.2 -r 2.3 find-grep-awk-sed

svn diff -r 3:5 svn_notes

To compare a revision with the one right before it, say revs 4 and 3:
svn diff -c 4 svn_notes

svn annotate -r 3 svn_notes
svn ann svn_notes
svn list -v file:///home/kevin/k9w-svn/learn-svn/trunk
svn list -vR file:///home/kevin/k9w-svn/learn-svn/trunk

To revert to an older snapshot of the reponsitory, say revision 7:
svn update -r 7

svn export is like svn checkout. It makes a new working copy but does
not make a .svn directory.

cd [some directory other than the already-existing working copy]
svn export file:///home/kevin/k9w-svn/learn-svn/trunk trunk

Same, but export an older version (current revision is 11):
svn export file:///home/kevin/k9w-svn/learn-svn/trunk@10 trunk-10

Script started on 2021-02-03 06:23:31+00:00
$ pwd
/home/kevin
$ svnadmin create dotfiles
$ su
Password: 
# mv dotfiles /home
# exit
$ mkdir test
$ cd test
$ svn import . file:///home/dotfiles -m ""
$ cd ..
$ rmdir test
$ svn checkout file:///home/dotfiles .
Checked out revision 0.
$ mkdir instructions
$ svn add configuration
A         configuration
$ svn commit -m "Added file configuration as first commit."
Adding         configuration
Transmitting file data .done
Committing transaction...
Committed revision 1.
$ svn list file:///home/dotfiles
configuration
$ svn log file:///home/dotfiles
------------------------------------------------------------------------
r1 | kevin | 2021-02-03 06:31:03 +0000 (Wed, 03 Feb 2021) | 1 line

Added file configuration as first commit.
------------------------------------------------------------------------
$ svn log configuration
------------------------------------------------------------------------
r1 | kevin | 2021-02-03 06:31:03 +0000 (Wed, 03 Feb 2021) | 1 line

Added file configuration as first commit.
------------------------------------------------------------------------
$ svn diff configuration
Index: configuration
===================================================================
--- configuration	(revision 1)
+++ configuration	(working copy)
@@ -11,3 +11,5 @@
 
 dnf install subversion

+This is new data.
+
$ svn status configuration
M       configuration
$ svn revert configuration
Reverted 'configuration'
$ svn add --depth=empty .ssh
A         .ssh
$ svn add .ssh/authorized_keys
A         .ssh/authorized_keys
$ svn status
?       .bash_history
?       .bash_logout
?       .bash_profile
?       .bashrc
A       .ssh
A       .ssh/authorized_keys
?       .ssh/id_ed25519.pub
?       .subversion
?       .viminfo
?       instructions
$ svn diff
Index: .ssh/authorized_keys
===================================================================
--- .ssh/authorized_keys	(nonexistent)
+++ .ssh/authorized_keys	(working copy)
@@ -0,0 +1 @@
+ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINPCvLA5gGqSDzIBB2GtBlpuyMSTELVzkzTHwl3OL5rE kevin@OpenBSD63.vultr.com
$ svn log configuration
------------------------------------------------------------------------
r1 | kevin | 2021-02-03 06:31:03 +0000 (Wed, 03 Feb 2021) | 1 line

Added file configuration as first commit.
------------------------------------------------------------------------
$ svn commit -m "Added .ssh and .ssh/authorized_keys."
Adding         .ssh
Adding         .ssh/authorized_keys
Transmitting file data .done
Committing transaction...
Committed revision 2.

$ su
Password: 
# cd ..
# svnadmin create conf
# mkdir test
# cd test
# mkdir root etc usr var
# svn import root file:///home/conf -m ""
# svn import etc file:///home/conf -m ""
# svn import usr file:///home/conf -m ""
# svn import var file:///home/conf -m ""
# svn import foo file:///home/conf -m ""
vn: E000002: Can't stat '/home/test/foo': No such file or directory
# cd ..
# rm -rf test
# cd /
# svn checkout file:///home/conf etc
Checked out revision 0.
# svn checkout file:///home/conf etc
Checked out revision 0.
# svn checkout file:///home/conf etc
Checked out revision 0.
# svn checkout file:///home/conf etc
Checked out revision 0.
# ls -al /var/.svn
drwxr-xr-x.  4 root root 4096 Feb  4 04:54 .svn
# cd /etc
# svn add --depth=empty ssh
A         ssh
# cd ssh
# svn add sshd_config
A         sshd_config
# cd ..
# svn add sudoers
A         sudoers
# cd /var
# svn add --depth=empty spool
A         spool
# svn add --depth=empty cron
A         cron

No root crontab file existed yet. So I did not add it yet.

# cd /var
# svn commit -m "Added cron directory."
Adding         spool
Adding         spool/cron
Committing transaction...
Committed revision 1.
# cd /etc
# svn commit -m "Added sshd_config and sudoers."
Adding         ssh
Adding         ssh/sshd_config
Adding         sudoers
Transmitting file data ..done
Committing transaction...
Committed revision 2.
# exit
$ cd
$ svn add instructions
A         instructions
A         instructions/svn_setup
$ svn commit -m "Added instrucitons folder and svn_setup."
Adding         instructions
Adding         instructions/svn_setup
Transmitting file data .done
Committing transaction...
Committed revision 3.
$ svn list -R file:///home/dotfiles
.ssh/
.ssh/authorized_keys
configuration
instructions/
instructions/svn_setup
$ svn diff
Index: instructions/svn_setup
===================================================================
--- instructions/svn_setup	(revision 3)
+++ instructions/svn_setup	(working copy)
@@ -143,8 +143,23 @@
 Transmitting file data ..done
 Committing transaction...
 Committed revision 2.
+# exit
+$ cd
+$ svn add instructions
+A         instructions
+A         instructions/svn_setup
+$ svn commit -m "Added instrucitons folder and svn_setup."
+Adding         instructions
+Adding         instructions/svn_setup
+Transmitting file data .done
+Committing transaction...
+Committed revision 3.
+$ svn list -R file:///home/dotfiles
+.ssh/
+.ssh/authorized_keys
+configuration
+instructions/
+instructions/svn_setup
+$
 
 
-
-
-
$ svn commit -m "Added more to svn_setup."
Sending        svn_setup
Transmitting file data .done
Committing transaction...
Committed revision 4.
$

