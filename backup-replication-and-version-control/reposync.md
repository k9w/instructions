Unlike Git and other distributed version control systems, CVS,
Subversion, and other centralized version control systems usually
don't give you the full repository and change history locally on your
machine when you checkout a copy of current, tagged release, or similar.

[reposync](https://github.com/sthen/reposync) is a client-side shell
script to fetch and update a CVS repository to allow CVS commands to
be run against the local machine, rather than reaching across the
internet. This removes one bottle-neck to speed with CVS.

## Use Reposync as a Client

### Regular Usage

Logged in as your regular user or root, su with your environmenent
intact (-m) to the `cvs` user for just
one command (-c), the reposync comnmand in single quotes: reposync
from the listed rsync mirror, to the default checkout location `/cvs`
(not specified at the end of the command).

```
# su -m cvs -c 'reposync rsync://mirror.example.org/cvs'
```

### First Time Client Setup

Install reposync from packages.

```
# pkg_add reposync
```

Add a local client user to run reposync and own the resultant folder.

```
# useradd cvs
```

install (create) the following directories (-d) with the cvs user as
owner (-o).

- `/cvs` - To hold the full CVS repository.
- `/var/db/reposync` - To hold reposync's hash of the repo, list of
  known hosts, etc.

```
# install -d -o cvs /cvs /var/db/reposync
```

After your initial download of the repository (see Regular Usage
above), you can set your `$CVSROOT` to `/cvs` and do your initial CVS
checkout of each child repository: src, ports, xenocara.

## Host a reposync server

If you have several machines, or if you want to serve the OpenBSD
repository to others, here is how to host your own Reposync mirror.


### Limit user options in SSHd

In `sshd_config` allow anoncvs to login without authentication.

```
Match User anoncvs
PermitEmptyPasswords yes
		AllowTcpForwarding no
		AllowAgentForwarding no
		X11Forwarding no
		PermitTTY no
```

### Setup rsync server user and rsync daemon

You will need `/etc/rsyncd.conf` to allow `/cvs` and to start `rsync --daemon`.

```
# /etc/rsyncd: configuration file for
rsync daemon mode

# See rsyncd.conf man page for more options.

# configuration example:

# uid = nobody
# gid = nobody
# use chroot = yes
# max connections = 4
# pid file = /var/run/rsyncd.pid
# exclude = lost+found/
# transfer logging = yes
# timeout = 900
# ignore nonreadable = yes
# dont compress   = *.gz *.tgz *.zip *.z *.Z *.rpm *.deb *.bz2

# [ftp]
#        path = /home/ftp
#        comment = ftp export area
```


### Create client user

On the server, create user `anoncvs`, which is used by reposync on the
client to connect to the server.

```
# useradd -s /sbin/nologin anoncvs
```

Note that nologin does not exist in /etc/shells.

```
anoncvs:*:32767:32767::/nonexistent:/sbin/nologin
```

Set its shell to nologin or whatever commands are needed for reposync.
Is the rsync daemon on the server run by a `rsyncd` user? What about
running as root to bind to the default priviledged port 873?


## See Also

<https://www.openbsd.org/anoncvs.html#rsync>

<https://daulton.ca/2018/10/openbsd-create-private-mirror>

<https://linuxconfig.org/how-to-setup-the-rsync-daemon-on-linux>

<https://www.upguard.com/blog/secure-rsync>

<https://www.cyberciti.biz/tips/howto-linux-shell-restricting-access.html>

<https://www.baeldung.com/linux/create-non-login-user>

Andrew said to start with how to host an rsync server.


