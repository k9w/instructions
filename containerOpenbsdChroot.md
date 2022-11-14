# Containerizing apps with chroot on OpenBSD

Modern web and server application deployments predominently use
containers to run app components:

- securely - Isolate with only the access and permissions necessary to
  function.


- efficiently - Scale up and down and only pay for resources used.

- conveniently - Run apps developed for a different, obsolete, or
  obscure environment from the host environment, or just for
  convenience and repeatability even if it's built for the same
  environment as the host.

Some notable tools for this include:

- [https://illumos.org/docs/about/features/#native-zones](zones) on
  [https://illumos.org](illumos)

- [https://docs.freebsd.org/en/books/handbook/jails](jails) and
  [https://wiki.freebsd.org/Docker](Docker on FreeBSD)

- [https://www.docker.com](Docker) and
  [https://kubernetes.io](Kubernetes) on Linux

OpenBSD doesn't currently have container environments at that
scale. But it does have chroot, which those containers were modeled
after.

OpenBSD chroots are best for building software, and lack security
features of FreeBSD jails and Linux containers to justify running apps
in chroots.

ifconfig, df, rcctl and any command that deals directly with the
kernel (even read-only as a regular user), has full access to
everything as in the host system.

However, the packages and ports systems, and other userspace software
builds use files and directories that ar not usually shared in the
kernel with the host system.

So for example, you can install git and go from packages, clone a go
application from source on Github, and build it using the go compiler
in the chroot, check its library dependencies with ldd, copy the
binary to ~/bin or /usr/local/bin on the host, verify it works, and
delete the chroot, or keep the chroot for the next time you want to
update build the updated application from source.

## Build the chroot

### Partition mount requirements

Building software on OpenBSD often requires certain filesystem
[https://man.openbsd.org/mount](mount(8)) 
flags to be present, and others to be absent.

Specifically, an OpenBSD chroot needs to:

- Allow processes to ask for memory to be made writable and
executable and therefore should have `wxallowed`.

- Interpret character and block devices in /dev and
therefore should not have `nodev`.

- Allow set-user-identifier and set-group-identifier bits to
be set and therefore should not have `nosuid`.

`/etc/fstab` shows the OpenBSD partitions on the system and the mount
flags used with them.

If you use the default partition layout of OpenBSD, it's recommended
you make a new partition mapped to /build dedicated just to chroot environments.

If however you use one single partition for your entire OpenBSD
install, not recommended, ensure it has those flags set or not set
accordingly.

Here is my fstab entry. 

```
$ cat /etc/fstab
245f04ba1667c1de.a / ffs rw,wxallowed,noatime 1 1
```

### Make the chroot folder

### Fetch install sets for the chroot

I only used base, comp, and man, not game or any of the x sets.

I put mine at /build/b0

### Add any files or customizations

Customize the prompt.

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
