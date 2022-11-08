# Using a chroot on OpenBSD

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

Initial setup of the chroot:
<https://eradman.com/posts/chroot-builds.html>

I only used base, comp, and man, not game or any of the x sets.

I put mine at /build/b0

Change root into it.

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
