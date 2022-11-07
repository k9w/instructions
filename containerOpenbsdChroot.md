Initial setup of the chroot:
<https://eradman.com/posts/chroot-builds.html>

I only used base, comp, and man, not game or any of the x sets.

I put mine at /build/b0

Change root into it.

```
# cd /build/b0
# chroot -u <regular-user> .
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

