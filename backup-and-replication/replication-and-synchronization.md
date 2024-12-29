# Replication & Synchronization

Replication is not a backup because it only synchronizes data from the
source to the destination, without necessarily keeping any version or
change history. This means if you discover you need a previous version
of your data, replication will not help because it (usually) only
keeps the latest version.

This guide focuses on Rsync and Openrsync.

## Rsync

### Usage examples

Say you already have a static website on your server. You make some
updates to your copy on your local computer. Use rsync to upload it to
the server.

```
rsync -avzP ./site example.com:/~
```

Then on the server, copy the site into /var/www/example.com. Note the
`-a` flag needs to be re-evaluated, since it will try to change the
owner and group in `/var/www` to match that in `$HOME` which won't be
allowed and is not what we want.

```
rsync -avzP ~/site/ /var/www/example.com/site
```

Since `-a` corresponds to `-rlptgoD`, remove the following flags since
we are not allowed to modify them in `/var/www`. We cannot preserve:

- `-p` - permissions
- `-t` - modification times
- `-g` - group ownership
- `-o` - user ownership


```
$ rsync -rlDvzP ~/site/ /var/www/example.com/site
```

### Daemon to speed up file comparisons

rsyncd

## Openrsync

[openrsync(1)](https://man.openbsd.org/openrsync) is an
[ISC-licensed](https://en.wikipedia.org/wiki/ISC_license)
implementation of the [rsync](https://rsync.samba.org) protocol for
[OpenBSD](https://openbsd.org).


### Usage examples


Copy a generated static website from the build directory to the
webserver directory on the same local machine to preview without help
of a live server by the site generator.

```
$ openrsync -rtv ~/src/mkdocs/site/ /var/www/example.com
```

The slash (/) at the end of the source (site/) is required to copy
just the folder content (example.com/"files"). Otherwise the source
folder (site) with its content would be copied into the destination
folder (example.com/site/"files").

Copy the site folder from the local webserver folder to the same
folder on the remote webhost, if rsync is installed or aliased at the
destination.

```
$ openrsync -av /var/www/example.com/ webserver.com:/var/www/example.com
```

If only openrsync is available at the destination and if it has not
been aliased to 'rsync', the openrsync binary must be specified
manually.

```
$ openrsync -av --rsync-path=/usr/bin/openrsync /var/www/example.com/ webserver.com:/var/www/example.com
```

Download from a remote source to a local destination, the current
working directory.

```
$ openrsync -av --rsync-path=/usr/bin/openrsync hostname:~/src/rcs-tracked-files/ .
```

Openrsync is suitable for replicating or synchronizing files. But it
alone is not suitable for backups, because it does not keep versions
or immutability. Proper backup and restore tools would be Tarsnap,
Borg, Rclone, Restic, and others.


### Daemon to speedup file comparisons

Copy files to a destination host which has rsync installed and the
daemon running. Use the daemon by specifying two colons after the
remote hostname, instead of just one colon.

```
$ openrsync -av /var/www/example.com/ webserver.com::/var/www/example.com
```

Or you can remove the colons and use 'rsync://' instead.

```
$ openrsync -av /var/www/example.com/ rsync://webserver.com/var/www/example.com
```

If the remote daemon is not running, here is how to start it while
ssh'ed into the remote machine.

(To be continued.)

## See Also

### Rsync

<https://rsync.samba.org>

<https://devhints.io/rsync>

<https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories>

### Openrsync

<https://man.openbsd.org/openrsync>

<https://www.openrsync.org>

<https://github.com/kristapsdz/openrsync>

<https://github.com/openbsd/src/tree/master/usr.bin/rsync>


