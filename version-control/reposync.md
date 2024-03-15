## Host a reposync server

[reposync](https://github.com/sthen/reposync) is a client-side shell
script to fetch and update a CVS repository to allow CVS commands to
be run against the local machine, rather than reaching across the
internet. This removes one bottle-neck to speed with CVS.

On the server, create user `anoncvs`, which is used by reposync to
connect from the client to the server.

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



In `sshd_config` allow anoncvs to login without authentication.

```
Match User anoncvs
PermitEmptyPasswords yes
		AllowTcpForwarding no
		AllowAgentForwarding no
		X11Forwarding no
		PermitTTY no
```

You will need `/etc/rsyncd.conf` to allow `/cvs` and to start `rsync --daemon`.


## See Also

<https://daulton.ca/2018/10/openbsd-create-private-mirror>

<https://linuxconfig.org/how-to-setup-the-rsync-daemon-on-linux>

<https://www.upguard.com/blog/secure-rsync>

<https://www.cyberciti.biz/tips/howto-linux-shell-restricting-access.html>

<https://www.baeldung.com/linux/create-non-login-user>

