started 07-10-22

FreeBSD containerizes apps using
[Jails](https://docs.freebsd.org/en/books/handbook/jails), similar to
Linux containers such as Podman and Docker. 

Why containerize an application or process?
* Protect other apps, services, and the host system from accidental or
  intentional interference or harm from the containerized app via 
  security breach, upstream bug, or simple misconfiguration.
* Run many instances of the app, or type of app, on the host system -
  even where security and resource contention are solved - to allow the
  app to serve requests from the outside world. For example, Apache,
  Nginx, Caddy and other web servers could all serve requests incoming
  to the host on the same port 80 and 443, but to their own URLs.

A jail builds on the concept of a
[chroot(2)](https://www.freebsd.org/cgi/man.cgi?query=chroot&sektion=2),
or change root environment, made by the root user with the
[chroot(8)](https://www.freebsd.org/cgi/man.cgi?query=chroot&sektion=8)
command.

## How a chroot works on OpenBSD and FreeBSD

Make a chrooted user account with its own home directory. We will use
that directory for the chrooted environment. You don't need to set a 
password for the user.

```
# useradd -m chrootedUser
```

As a regular user (not the chrootedUser), write a shell script that
echoes a sentense. Don't bother setting the file owner. Just turn on
the execute bit for all users. We'll use this script later.

```
$ cd
$ echo 'echo "This is a test script inside a chrooted space."' > test.sh
$ chmod +x test.sh
```

Give the chroot environment basic commands, such as pwd, ls, echo, and
the shell executed in the environment when you change root in a bit.

```
# cp -R /bin /home/chrootedUser
```

Give the chroot environment other commands too, such as whoami, and
grep. For /usr/bin, you need to create the usr folder first.

```
# mkdir /home/chrootedUser/usr
# cp -R /usr/bin /home/chrootedUser/usr
```

Give it some networking commands too, such as ping and ifconfig.

```
# cp -R /sbin /home/chrootedUser
```

Change root to that user in that directory.

```
# chroot -u chrootedUser /home/chrootedUser
```

For this exercise, ignore errors about tty and job control.

```
$ whoami
Abort trap
```

The 'Abort trap' error means something else in OpenBSD prevents the
chrooted user from executing usr/bin/whoami. That's okay for this
exercise. It demonstrates the 'whoami' command is there and would
work, unlike an absent or fake command.

```
$ asdf
/bin/ksh: asdf: not found
```

Echo a sentense and print the working directory.
```
$ echo 'This is a sentense.'
This is a sentense.
$ pwd
/
```

The sentense printed. Note the working directory is / because the
change root environment cannot see any of the file system outside the
chrooted directory.

Now it's time to use the shell script we made earlier. Exit out of the
chroot, copy in the file, change the file's owner to the chroot user,
re-enter the chroot, and run the script. That should work.

```
$ exit
$ cd
# cp test.sh /home/chrootedUser
# chown chrootedUser /home/chrootedUser/test.sh
# chroot -u chrootedUser /home/chrootedUser
$ ls
bin     sbin    test.sh usr
$ ./test.sh
This is a test in a chrooted environment.
```

Try editing test.sh with vi. It should fail with the 'Abort trap'
error.

```
$ vi test.sh
Abort trap
```

Try editing it with the ed line editor. It should fail unless you
added a tmp directory, which we didn't.

```
$ ed test.sh
/tmp/ed.EuOKuNiJ2S: No such file or directory
```

Add a tmp folder and run ed again.

```
$ mkdir tmp
$ ed test.sh
[1] + Stopped (tty input)  ed test.sh
```

It worked. But the chroot stopped ed without killing it, for the same
reason we don't have job control in the chroot (won't have full job
control).

The chroot can append to its own file and view it.

```
$ echo 'echo "This is a second line."' >> test.sh
$ cat test.sh
echo "This is a test in a chrooted environment."
echo "This is a second line."
```

It can make a copy of the file in the chroot root directory. It can make
a new folder in the root directory, as we saw above with tmp. But it
cannot make a new file, not even in the sub-folder we created. It can
delete folders it made.

```
$ cp test.sh Test.sh
$ mkdir testDir
$ touch testFile
Abort trap
$ cd testDir
$ ls
$ touch test
Abort trap
$ cd ..
$ rmdir testDir
```

This feels pretty restricted. Ping does not even work.

```
$ ping www.google.com
ping: socket: Permission denied
```

However on OpenBSD, ifconfig works in chroot and reveals the host IP
address, which is not something you usually want a sandboxed app to have
access to.

```
$ ifconfig
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 32768
        index 3 priority 0 llprio 3
	groups: lo
        inet6 ::1 prefixlen 128
        inet6 fe80::1%lo0 prefixlen 64 scopeid 0x3
        inet 127.0.0.1 netmask 0xff000000
vio0: flags=808843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST,AUTOCONF4> mtu 1500
        lladdr 56:00:04:10:66:53
        index 1 priority 0 llprio 3
	groups: egress
        media: Ethernet autoselect
        status: active
        inet xxx.xxx.xxx.xxx netmask 0xfffffe00 broadcast xxx.xxx.xxx.255
enc0: flags=0<>
        index 2 priority 0 llprio 3
        groups: enc
        status: active
pflog0: flags=141<UP,RUNNING,PROMISC> mtu 33136
        index 4 priority 0 llprio 3
        groups: pflog
```

When you're done with this test, exit out of the chroot. Delete the
chroot test user and its home folder.

```
$ exit
# userdel -r chrootedUser
```

This works on OpenBSD. Need to test it on FreeBSD and Linux.

A
[jail(8)](https://www.freebsd.org/cgi/man.cgi?query=jail&sektion=8&format=html)
can be 'complete', 'service', or 'linux'.


