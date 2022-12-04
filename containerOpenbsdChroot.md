# Containerizing apps with chroot on OpenBSD

## Introduction

Modern web and server application deployments predominently use
containers to run app components:

- Securely: Isolate with only the access and permissions necessary to
  function.

- Efficiently: Scale up and down and only pay for resources used.

- Conveniently: Run apps developed for an obsolete, obscure, or just a
  different environment from the host environment, or just for
  convenience and repeatability even if it's built for the same
  environment as the host.

Some notable tools for this include:

- [Zones](https://illumos.org/docs/about/features/#native-zones) on
  [illumos](https://illumos.org)

- [Jails](https://docs.freebsd.org/en/books/handbook/jails) and
  [Docker on FreeBSD](https://wiki.freebsd.org/Docker)

- [Podman](https://podman.io), [Docker](https://www.docker.com) and
  [Kubernetes](https://kubernetes.io) on Linux

[OpenBSD](https://openbsd.org) doesn't currently have container
environments at that scale. But it does have
[chroot(8)](https://man.openbsd.org/chroot), which those tools were
modeled after.

## Limitations

The [chroot(2)](https://man.openbsd.org/chroot.2) system call only
restricts filesystem access. Any operation that deals with the kernel
and not the filesystem, such as listing or configuring network
interfaces, performed in the chroot affects the host environment as if
there was no chroot. Using [pfctl(8)](https://man.openbsd.org/pfctl)
to load an alternate [pf.conf(5)](https://man.openbsd.org/pf.conf.5)
inside the chroot would override any firewall rules defined on the
host.

Other kernel operations by root equally
apply. [ifconfig(8)](https://man.openbsd.org/ifconfig),
[df(1)](https://man.openbsd.org/df),
[rcctl(8)](https://man.openbsd.org/rcctl) and any command that deals
directly with the kernel (even read-only as a regular user), has full
access to everything as in the host system.

OpenBSD has other security mechanisms for related areas:

- [Pledge(2)](https://man.openbsd.org/pledge): A process defines a
  list of intended capabilities. If the process tries to do anything
  else, the kernel kills it.

- [Unveil(2)](https://man.openbsd.org/unveil): A process starts in a
  chroot-like environment with only a subset of the host filesystem
  visible. Unveil selectively reveals more of the filesystem to the
  process if conditions are met.

## Use Case

One great use of a basic chroot is to build software, where a build
script can pull in any dependencies needed to complete its job. The
completed binary can be copied from the chroot to the host environment
and function identically if the same shared libraries are in host and
chroot.

The packages and ports systems, and other userspace software builds
such as from [Github](https://github.com), often use files and
directories that are not shared in the kernel with the host system.

So for example, you can install [Git](https://git-scm.com) and
[Go](https://go.dev) from packages, clone a go application from source
on Github, and build it using the go compiler in the chroot, check its
library dependencies with ldd, copy the binary to ~/bin or
/usr/local/bin on the host, verify it works, and delete the chroot, or
keep the chroot for the next time you want to build the updated
application from source.

## How to build the chroot

### Partition mount requirements

Building software on OpenBSD often requires certain filesystem
[mount(8)](https://man.openbsd.org/mount) 
flags to be present, and others to be absent.

Specifically, an OpenBSD chroot needs to:

- Allow a process to ask that memory be made writable and executable
  and therefore should have `wxallowed`.

- Interpret character and block devices in /dev and therefore should
  not have `nodev`.

- Allow [set-user-identifier and
  set-group-identifier](https://man.openbsd.org/setuid) bits to be set
  and therefore should not have `nosuid`.

[/etc/fstab](https://man.openbsd.org/fstab) shows the OpenBSD
partitions on the system and the mount flags used with them.

If you use the default partition layout of OpenBSD, it's recommended
you make a new partition mapped to /build dedicated just to chroot
environments.

The easiest way to do this is at the beginning when first installing
OpenBSD.

If however you use one single partition for your entire OpenBSD
install (not recommended), ensure it has those flags set or not set
accordingly.

Here is my fstab entry. 

```
$ cat /etc/fstab
245f04ba1667c1de.a / ffs rw,wxallowed,noatime 1 1
```

### Make the chroot folder

In my /build, I call my first chroot 'b0'.

```
# mkdir -p /build/b0
```

### Fetch file sets for the chroot

#### Which sets to install?

Stock OpenBSD comes as a base system, a core group of files mainly
developed in the OpenBSD project's own source code repository [with
documented third-party
additions](https://www.openbsd.org/faq/faq1.html#WhatIs). This base
system consists of [sets of
files](https://www.openbsd.org/faq/faq4.html#FilesNeeded).

 The complete OpenBSD installation is broken up into a number of file sets:

```
bsd             The kernel (required)
bsd.mp 	        The multi-processor kernel (only on some platforms)
bsd.rd          The ramdisk kernel
base72.tgz 	    The base system (required)
comp72.tgz 	    The compiler collection, headers and libraries
man72.tgz 	    Manual pages
game72.tgz 	    Text-based games
xbase72.tgz 	Base libraries and utilities for X11 (requires xshare72.tgz)
xfont72.tgz 	Fonts used by X11
xserv72.tgz 	X11's X servers
xshare72.tgz 	X11's man pages, locale settings and includes
```

A chroot doesn't need any of the bsd kernel sets. The chroot
environment is managed by the kernel and, in OpenBSD's case, has full
access to the kernel's facilities as covered above.

Technically, you could put some files and a fully-standalone
executable into the chroot and call it good if it does not depend on
any shared libraries or standard utility commands. But that is usually
not very useful.

For most use cases, you'll want a full OpenBSD environment with all
the commands, libraries, character devices, etc, that you'd have on
the host. However, if you don't plan to use the BSD games or run an
app in the chroot that depends on X11 or any of its facilities, you
can safely exclude those sets and save disk space and attack surface
(though the X11 facilities are regularly audited by the OpenBSD
developers and are reasonably safe).

Therefore, in this guide, I install base, comp and man into the chroot.

```
base72.tgz 	    The base system (required)
comp72.tgz 	    The compiler collection, headers and libraries
man72.tgz 	    Manual pages
```

#### What set versions to install?

Only install set versions that match your host. From OpenBSD's
[flavors](https://www.openbsd.org/faq/faq5.html#Flavors), the project
supports the three following versions at any given time:

- **-current** - The most recent snapshot from the current branch - built
  and published every few hours or days depending on the hardware
  platform and the stage of the release cycle.
  
- **Latest -release** - The most recent release
  ([7.3](https://www.openbsd.org/73.html)).

- **Last prior -release** - The release right before that
  ([7.2](https://www.openbsd.org/72.html)).

Current is what the OpenBSD developers generally run on their
production machines, including their servers and laptops, and is
therefore the best tested with the latest software and firmware in
base, ports, and packages.

Releases come out every 6 months, generally in May and October. Each
release receives security and reliability updates for [1 year for the
base system](https://www.openbsd.org/faq/faq10.html#Patches), and for
[6 months for third-party packages and
ports](https://www.openbsd.org/faq/ports/ports.html#PortsSecurity).

***The sets installed in the chroot must not be newer than the kernel
running on the host.***

- If you run release on the host, use sets from that same release in
the chroot.

- If you run a snapshot on the host from OpenBSD's current branch,
only install sets in the chroot that match the version on the host or
older.


Download the sets on the host:

```
$ cd ~/Downloads
$ ftp https://cdn.openbsd.org/pub/OpenBSD/snapshots/amd64/{base,comp,man}73.tgz
```

Uncompress the tar'ed gzip'ed sets into your chroot directory,
/build/b0 in my case, with the following tar(1) flags.

`-C` - Specify the destination directory.

`-x` - Extract files from the archive.

`-z` - (Un)compress files with gzip(1).

`-p` - Preserve user/group owner, other file attributes.

`-h` - Follow symbolic links.

`-f` - Specify the archive (tgz file) to read from, in our case.

Options x through f can be combined together:

```
$ pwd
~/Downloads
# tar -C /build/b0 -xzphf {base,comp,man}73.tgz
```

### Configure and activate the container

These steps performed manually below are likely the same ones
performed by the OpenBSD installer. Some of the steps are necessary
for the container to function at all like an OpenBSD system, others
are essential if you want it to match the host, such as having the
same user account and home folder.

#### Populate the device files in /dev

Run the [MAKEDEV(8)](https://man.openbsd.org/MAKEDEV) script (related
to the [makedev(3)](https://man.openbsd.org/makedev) system call). The
script is located at /dev and applies to the current working
directory. So you must CD to it first.

```
$ cd /build/b0/dev
# ./MAKEDEV all
```

#### Populate user accounts and home folder

This is important even if you'll only start out with just a root
account. Copying the files from your host will add a user account with
the same name and password as your host.

Set the accounts, passwords, and user groups by copying these three
files from /etc on the host to /etc in the chroot.

[master.passwd(5)](https://man.openbsd.org/master.passwd) - Contains
the encrypted password and account info for all accounts, readable
only by root.

[passwd(5)](https://man.openbsd.org/passwd.5) - Generated from
master.passwd by [pwd_mkdb(8)](https://man.openbsd.org/pwd_mkdb) with
the class, change, and expire fields removed and the password replaced
by an asterisk (*), readable by all users.

[group(5)](https://man.openbsd.org/group.5) - group permissions file

```
# cp /etc/{master.passwd,passwd,group} /build/b0/etc
```

Add the home folder for your user account and any other users you
want, and set the permissions accordingly.

```
# mkdir -p /build/b0/home/<username>
# chown <username>:<groupname> /build/b0/home/<username>
```

#### Add package path and resolv.conf

Since the chroot interacts with the same kernel as the host, copy the
following two files from /etc on the host to /etc in the chroot.

[installurl(5)](https://man.openbsd.org/installurl) - Contains the
package mirror location, usually
<https://cdn.openbsd.org/pub/OpenBSD>.

[resolv.conf(5)](https://man.openbsd.org/resolv.conf) - Contains the
[DNS
nameservers](https://kinsta.com/knowledgebase/what-is-a-nameserver) to
use.

```
# cp /etc/{installurl,resolv.conf} /build/b0/etc
```


### Add any files before entering the chroot

I added my ~/.tmux.conf from the host, which sets the tmux prefix key
from the default Ctrl-B to ` (backtick).


### Change root into it

```
# cd /build/b0
# chroot -u <regular-user> .
```

From the host, the chroot inherits the HOME and USER variables of the
root or doas user that executed the chroot command.

cd to the your regular user directory, set HOME and USER, and start a
tmux session.
```
$ cd /home/<regular-user>
$ export HOME=/home/<regular-user>
$ export USER=<regular-user>
$ tmux
```

# After entering the chroot, customize the prompt

So that I can tell when I'm in a chroot, I modified my prompt to show
the current working directory.

```
$ echo 'export ENV=~/.kshrc' >> ~/.profile
$ echo "export PS1='b0:\w \$ '" >> ~/.kshrc
```

So if the prompt in the host system is:

```
b$
```

The prompt in the chroot, when in the home directory would be:

```
b0:~ $ 
```

If you change directory to /home/<regular-user>/bin, the prompt
reflects the changed directory.

```
b0:~/bin $ 
```

You can install 


## See also

* [Building Software on OpenBSD in a chroot](https://eradman.com/posts/chroot-builds.html)
* [Creating a Chroot in OpenBSD](https://www.tubsta.com/2020/01/creating-a-chroot-in-openbsd)
* [chroot(8)](https://man.openbsd.org/chroot) - Userspace command
* [chroot(2)](https://man.openbsd.org/chroot.2) - Kernel system call
