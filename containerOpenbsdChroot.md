# Containerizing apps with chroot on OpenBSD

## TL;DR

```
$ cat /etc/fstab
245f04ba1667c1de.a / ffs rw,wxallowed,noatime 1 1
# mkdir -p /build/b0
# sysmerge -k
$ cd /home/_sysupgrade
# for f in *.tgz; do tar -C /build/b0 -xzphf "$f"; done
$ /etc/doas.conf
# Default rule from wheel group members.
permit nopass :wheel

# Permit without password and set variables when <username> runs chroot cmd.
permit nopass setenv { LOGNAME=<username> HOME=/home/<username> USER=<username> \
PATH=/home/<username>/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin:/usr/games \
} <username> cmd chroot
$ cd /build/b0/dev
# ./MAKEDEV all
# cp /etc/{master.passwd,passwd,group,resolv.conf,installurl,doas.conf} /build/b0/etc
# mkdir -p /build/b0/home/<username>
# chown <username>:<groupname> /build/b0/home/<username>
$ cd /build/b0/home/<username>
$ cp ~/.{cshrc,cvsrc,login,mailrc,mg,nexrc,profile,tmux.conf} .
$ echo 'export ENV=~/.kshrc' >> ./.profile
$ echo "export PS1='b0:\w \$ '" >> ./.kshrc
$ cd /build/b0
# chroot -u <username> .
$ tmux
# pwd_mkdb /etc/master.passwd
# ldocnfig /usr/local/lib
# sysmerge
```

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

Other kernel operations by root equally apply.
[ifconfig(8)](https://man.openbsd.org/ifconfig),
vv[df(1)](https://man.openbsd.org/df),
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

So for example, you can:

- Install [Git](https://git-scm.com) and [Go](https://go.dev) from
  packages

- Clone a Go application from source on Github

- Build it using the Go compiler in the chroot

- Check its library dependencies with ldd

- Copy the binary to ~/bin or /usr/local/bin on the host

- Verify the compiled binary works

- Delete the chroot, or keep the chroot for the next time you want to
  build the updated application from source

## How to build the chroot

### Partition mount requirements

Building software on OpenBSD often requires certain filesystem
[mount(8)](https://man.openbsd.org/mount) flags to be present, and
others to be absent.

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
you make a new partition mapped to `/build` dedicated just to chroot
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

In my `/build`, I call my first chroot `b0`.

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

Or, if you're running current and are ready to upgrade to a new
snapshot, save the downloaded sets with the -k flag to sysmerge.

```
# sysmerge -k
```

Then after the reboot, you can use the sets saved to
`/home/_sysupgrade`.

Uncompress the tar'ed gzip'ed sets into your chroot directory,
/build/b0 in my case, with the following
[tar(1)](https://man.openbsd.org/tar) flags.

- `-C` - Specify the destination directory.

- `-x` - Extract files from the archive.

- `-z` - (Un)compress files with gzip(1).

- `-p` - Preserve user/group owner, other file attributes.

- `-h` - Follow symbolic links.

- `-f` - Specify the archive (tgz file) to read from, in our case.

Options x through f can be combined together.

Untaring multiple archives in one command usually returns the error:

```
tar: WARNING! These patterns were not matched:
comp73.tgz
man73.tgz
```

Instead, [wrap the tar command in a shell for
loop](https://www.cyberciti.biz/faq/how-to-extract-multiple-tar-ball-tar-gz-files-in-directory-on-linux-or-unix).

The first time the for loop runs, `$f` equals `base73.tgz`. The second
time, the for loop runs `$f` equals `comp72.tgz`. The for loop keeps
running until it finds no more files in the current directory matching
`*.tgz`.

```
$ cd /home/_sysupgrade
# for f in *.tgz; do tar -C /build/b0 -xzphf "$f"; done
```

If you prefer to untar one archive at a time, this is how it looks:

```
# tar -C /build/b0 -xzphf base73.tgz
# tar -C /build/b0 -xzphf comp73.tgz
# tar -C /build/b0 -xzphf man73.tgz
...
```

### Set doas on the host to maintain default environment for chroot

OpenBSD by default uses [doas(1)](https://man.openbsd.org/doas)
instead of [sudo](https://www.sudo.ws). It normally sets environmental
variables `$LOGNAME`, `$HOME`, `$USER`, and `$PATH` to the target user
(root), which is not what we want for chroot.

For most commands, I set
[doas.conf(5)](https://man.openbsd.org/doas.conf) to allow wheel group
members to execute any command without password.

```
$ /etc/doas.conf
permit nopass :wheel
```

Here we make a special rule for `<username>` running `chroot` to set
those four variables back to the default for `<username>`. Place the
rule below the defautl rule above in `doas.conf`.

```
$ /etc/doas.conf
# Default rule from wheel group members.
permit nopass :wheel

# Permit without password and set variables when <username> runs chroot cmd.
permit nopass setenv { LOGNAME=<username> HOME=/home/<username> USER=<username> \
PATH=/home/<username>/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin:/usr/games \
} <username> cmd chroot
```

### Populate the device files in /dev

Run the [MAKEDEV(8)](https://man.openbsd.org/MAKEDEV) script (related
to the [makedev(3)](https://man.openbsd.org/makedev) system call). The
script is located at [/dev](https://man.openbsd.org/hier) and applies
to the current working directory. So you must CD to it first.

```
$ cd /build/b0/dev
# ./MAKEDEV all
```

### Add /etc files

This is important even if you'll only start out with just a root
account. Copying the files from your host will add a user account with
the same name and password as your host.

Set the accounts, passwords, user groups, default gateway, package
download path, and doas permission by copying these `/etc` files from
the host to the chroot.

- [master.passwd(5)](https://man.openbsd.org/master.passwd) - Contains
the encrypted password and account info for all accounts, readable
only by root.

- [passwd(5)](https://man.openbsd.org/passwd.5) - Generated from
master.passwd by [pwd_mkdb(8)](https://man.openbsd.org/pwd_mkdb) with
the class, change, and expire fields removed and the password replaced
by an asterisk (*), readable by all users.

- [group(5)](https://man.openbsd.org/group.5) - group permissions file

- [resolv.conf(5)](https://man.openbsd.org/resolv.conf) - Contains the
[DNS
nameservers](https://kinsta.com/knowledgebase/what-is-a-nameserver) to
use.

- [installurl(5)](https://man.openbsd.org/installurl) - Contains the
package mirror location, usually
<https://cdn.openbsd.org/pub/OpenBSD>.

- [doas.conf(5)](https://man.openbsd.org/doas.conf) - Specifies your
  regular user can run commands as root using
  [doas(1)](https://man.openbsd.org/doas).

```
# cp /etc/{master.passwd,passwd,group,resolv.conf,installurl,doas.conf} /build/b0/etc
```

### Add home folder for regular user

Add the home folder for your user account and any other users you
want, and set the user owner and group owner permissions accordingly.

```
# mkdir -p /build/b0/home/<username>
# chown <username>:<groupname> /build/b0/home/<username>
```

### Add dotfiles

Home folders on most all versions of Linux and the BSDs contain
'dotfiles', hidden files whose names start with a dot (.), such as
`.profile`. On the host they are added by the Linux or *BSD
installer.

Dotfiles are not added into the chroot by sets or any other automatic
method thus far (except for `/root` with
[sysmerge(8)](https://man.openbsd.org/sysmerge) covered below). You
need dotfiles to set things such as environment variables including
`$PATH`, which tells the shell where to find any non-[builtin shell
commands](https://man.openbsd.org/sh#BUILTINS), such as `/bin`,
`/sbin`, `/usr/bin`, `/usr/sbin`, etc.

#### Standard OpenBSD dotfiles

- `.Xdefaults` - Not needed unless running X.
  
- `.cshrc` - Startup file executed each time
  [csh(1)](https://man.openbsd.org/csh) is invoked, not just on
  initial login. If you only use
  [ksh(1)](https://man.openbsd.org/ksh), you don't need it.
  
- `.cvsrc` - Customization file for
  [cvs(1)](https://man.openbsd.org/cvs). If you don't use cvs, you
  don't need it.
  
- `.login` - Startup file executed upon login if the user shell is set
  to csh(1), not needed if you only use ksh(1). You can check what
  your default shell is with
  [userinfo(8)](https://man.openbsd.org/userinfo).
  
- `.mailrc` - Statup file for the
  [mail(1)](https://man.openbsd.org/mail) utility. Not needed if you
  don't read email using mail(1).
  
- `.profile` - Startup file executed upon login with the default shell
  ksh(1).
  
#### Non-standard dotfiles

- `.kshrc` - We'll create or edit this file later in this guide when
  we set a custom shell prompt.

- `.mg` - Startup file for [mg(1)](https://man.openbsd.org/mg) to set
  line wrap at 72 characters, etc.

- `.nexrc` - Startup file for [vi(1)](https://man.openbsd.org/vi), to
  set line wrap, etc.

- `.ssh` - This directory is almost certainly not needed unless you
  plan to [ssh(1)](https://man.openbsd.org/ssh) from this host (and
  from inside this chroot) to another host, since you don't ssh
  directly into the chroot from another host. You login to the host
  first, and then change root into this chroot. Therefore, you might
  or might not need this folder in the chroot.

- `.tmux.conf` - Startup file for
  [tmux(1)](https://man.openbsd.org/tmux), to change defaults such as
  setting the prefix key from Ctrl-B to ` (backtick). (We'll demo that
  in a section below.)

- If you have other dotfiles on your host for
  [Emacs](https://www.gnu.org/software/emacs),
  [Vim](https://www.vim.org/), [NeoVim](https://neovim.io/), etc and
  want to use them in the chroot, you'll need to copy those dotfiles
  and install the packages into the chroot that use them.

#### Copy needed dotfiles into the chroot

Copy `.profile` and other desired dotfiles from your host home
directory to your user folder in the chroot. 

Notice the copy below does not need root or
[doas(1)](https://man.openbsd.org/doas) because we earlier changed the
owner and group to `<username>` so that our regular user can write to
it, even before we change root into the chroot environmentt.

```
$ cd /build/b0/home/<username>
```

You can copy just .profile.
```
$ cp /home/<username>/.profile .
```

Or you can copy most of the dotfiles listed above.

```
$ cp ~/.{cshrc,cvsrc,login,mailrc,mg,nexrc,profile,tmux.conf} .
```

#### Set a different prompt

One way to remind yourself you're in a chroot is to set a prompt
different from your host, for example, to show the current working
directory.

First tell `./.profile` to execute `./.kshrc` if it detects it.

```
$ cd /build/b0/home/<username>
$ echo 'export ENV=~/.kshrc' >> ./.profile
```

Then set PS1 in `./.kshrc`.

`b0` is the name we chose for the chroot environment.

The colon `:` is a nice delimiter.

`\w` means 'the current working directory, as reported by
[pwd(1)](https://man.openbsd.org/pwd).

The space ` `  is interpreted literally.

`\$` prints a literal `$`.

We include a space ` `  after the `$`.

```
$ echo "export PS1='b0:\w \$ '" >> ./.kshrc
```

So if the prompt in the host system is:

```
b$
```

The prompt in the chroot, when in the home directory would be:

```
b0:~ $ 
```

If you change directory to `/home/<username>/bin`, the prompt reflects
the changed directory.

```
b0:~/bin $ 
```

#### Change tmux prefix key

I added my ~/.tmux.conf from the host, which sets the tmux prefix key
from the default Ctrl-B to ` (backtick).

## Change root into your new chroot environment

```
$ cd /build/b0
# chroot -u <username> .
```

To test the custom prompt, launch a tmux session.

```
$ tmux
```

## First time setup in the chroot

Build the password database from `/etc/master.passwd` with
[pwd_mkdb(8)](https://man.openbsd.org/pwd_mkdb).

```
# pwd_mkdb /etc/master.passwd
```

Refresh the shared library cache with
[ldconfig(8)](https://man.openbsd.org/ldconfig).

```
# ldocnfig /usr/local/lib
```

Populate `/etc` with [sysmerge(8)](https://man.openbsd.org/sysmerge).

```
# sysmerge
```

## Caveats

### HOME and USER

If you don't set a `doas.conf` rule for chroot that sets those
variables, the chroot inherits the HOME and USER variables of the root
or doas user that executed the chroot command.

To set them manually6 (like in the host environment), you need to
export their values each time you enter the chroot (unless you save
the environment in a tmux session).

To fix, cd to the your regular user directory, set HOME and USER, and
start a tmux session.

```
$ cd /home/<username>
$ export HOME=/home/<username>
$ export USER=<username>
$ tmux
```

### .profile not sourced in chroot's first shell

One affect of this is you won't see the customized prompt you set
until you launch a subshell. The best way to do this is to launch a
tmux session. If you plan to leave the chroot running, you can save
the environment and any running processes by disconnecting from the
tmux session before exiting the chroot.

### tmux sessions in host and chroot don't know about each other

Normally if you run two tmux sessions on the same system, you can
switch between them with Ctrl-B ) (next session), or Ctrl-B (
(previous session).

tmux inside the chroot cannot see any sessions running outside the
chroot on the host because the file(s) tracking the host session(s) is
not visible to the chroot.

Likewise, tmux run on the host cannot see any sessions running inside
the chroot because tmux in the chroot tracks its sessions in a file
inside the chroot, not in the default location on the host used by the
host's tmux.

There is no fix. This is intentional.

## See also

* [Building Software on OpenBSD in a
  chroot](https://eradman.com/posts/chroot-builds.html)
* [Creating a Chroot in OpenBSD](https://www.tubsta.com/2020/01/creating-a-chroot-in-openbsd)
* [chroot(8)](https://man.openbsd.org/chroot) - Userspace command
* [chroot(2)](https://man.openbsd.org/chroot.2) - Kernel system call
