04-22-2022

After the performance improvement of 7.0-release to 7.1-release, I
decided to try out Gnome 41.5, the current version in Ports. The Gnome
project had released version 42 last month. It's typical, and okay,
for the OpenBSD maintainer for Gnome to hold it back a bit.

Here's the guide I used for setup, with my own steps and additions
below.
<https://dataswamp.org/~solene/2021-05-07-openbsd-gnome.html.

```
# pkg_add gnome-extras
```

Some noteable dependencies: llvm 13, libssh2, freerdp, lua, pulseaudio,
ImageMagick, evolution, bash, gdm, samba, avahi.

useradd: Warning: home directory `/var/db/gdm' doesn't exist, and -m was
not specified

The following new rcscripts were installed: /etc/rc.d/avahi_daemon
/etc/rc.d/avahi_dnsconfd /etc/rc.d/gdm /etc/rc.d/nmbd /etc/rc.d/samba
/etc/rc.d/saned /etc/rc.d/smbd /etc/rc.d/winbindd
See rcctl(8) for details.
New and changed readme(s):
        /usr/local/share/doc/pkg-readmes/avahi
        /usr/local/share/doc/pkg-readmes/consolekit2
        /usr/local/share/doc/pkg-readmes/gamin
        /usr/local/share/doc/pkg-readmes/gnome
        /usr/local/share/doc/pkg-readmes/gtk+4
        /usr/local/share/doc/pkg-readmes/ibus
        /usr/local/share/doc/pkg-readmes/llvm
        /usr/local/share/doc/pkg-readmes/samba
        /usr/local/share/doc/pkg-readmes/sane-backends
        /usr/local/share/doc/pkg-readmes/texlive_base

From the gnome pkg-readme:

```
# rcctl enable messagebus
# rcctl enable avahi_daemon
# rcctl enable gdm
```

Comment out 'xenodm_flags from /etc/rc.conf.local.

Followed the 'Cheat sheet' section.

Add my user to the login class 'gnome'. Need to read up more on what
this does.
```
# usermod -L gnome kevin
```

Gnome runs best from GDM, not Xenodm, and also benefits from the other
services listed below.

```
# rcctl disable xenodm
# rcctl enable multicast messagebus avahi_daemon gdm
```

If you don't want to reboot, you can switch to a tty with Ctrl Alt F2
and stop and start the daemons by hand easily. There's no rc.d script
for multicast, which will error the rest of the services if you try to
start it with them. Leave it off.

```
# rcctl stop xenodm
# rcctl start messagebus avahi_daemon gdm
```

You can also switch to Gnome at the X terminal.

```
# rcctl stop xenodm && rcctl start messagebus avahi_daemon gdm
```

To switch from Gnome back to any other DE or WM which doesn't need GDM,
disable the GDM services, and enable xenodm.

```
# rcctl disable multicast messagebus avahi_daemon gdm
# rcctl enable xenodm
```

And switch to a tty to stop and start them.

```
# rcctl start xenodm
# rcctl stop messagebus avahi_daemon gdm
```

You can also switch from Gnome at the X terminal.

```
# rcctl stop messagebus avahi_daemon gdm && rcctl start xenodm
```

Gnome uses its Keyring to cache SSH keys and other credentials. I've
chosen to not use it at this time until I can learn it
better. Normally, Xenodm's confguration file /etc/X11/xenodm/Xsession
calls ssh-agent and prompts for the private key passphrase on login.

Without that Xenodm and the Gnome Keyring, you can start the agent and
load the your SSH key from any X terminal like this, ideally before
starting any tmux or screen sessons, so that they'll inherit the agent
keys.

```
$ eval $(ssh-agent)
$ ssh-add
Enter passphrase for key '/home/<username>/.ssh/id_ed25519': 
```

You can kill the agent and lock your key without logging out of X.

```
$ pkill ssh-agent
```

Current issues:

At first Gnome Terminal didn't render at all. But after a reboot it
worked.

The 14.4G SSD is now filled 10.5G to 77% capacity. With lots of apps
open, disk usage climbed to 11.6G at 85% capacity. When I deleted the
.core files and closed all but Gnome terminal, it returned to 77%.

The Gnome beep is annoying, but can be turned off in Settings.

The regular Fn-F2 or Fn-F3 Thinkpad volume controls don't work, at
least for USB devices. The Gnome volume only detects the default
built-in speakers.

The Fn screen brigitness keys work fine. But the Gnome brightness
control disappears if turned all the way down.

Suspend on lid close does not work even when turned on in Tweaks. It
also warns of its own suspend due to inactivity. But it does not suspend
on its own and I've found no place in Settings or Tweaks to configure
it.

Even though I turned off the keyboard bell in Terminal, it does not
respect that setting in Emacs and gVim. NeoVim and non-GUI Vim don't
have the bell.


When I removed Gnome, I kept the gnome custom class in /etc/login.conf.
When I reverted that file to its original version, the next time I tried
to login, it would not work. I logged in as root then tried to su to my
standard account. It said,
```
su: no such login class: gnome
```

I had set the login class with:

```
# usermod -L gnome <username>
```

To fix it, I set my regular user's login class to one of the pre-defined
classes in /etc/login.conf. It was likely previously assigned to the
'default' login class. I took this opportunity to add it to the 'staff'
login class, so that firefox and other applications could take up more
processes and memory.

It worked.

