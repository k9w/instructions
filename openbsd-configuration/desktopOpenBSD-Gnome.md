# Gnome Desktop on OpenBSD

Gnome is a popular desktop environment available for OpenBSD. It
features a pleasing asthetic and encourages a consistent configuration
over customizability.

## Installation

Install the gnome-extras package.

```
# pkg_add gnome-extras
```

View the package readme.

```
$ less /usr/local/share/doc/pkg-readmes/gnome
```

Disable OpenBSD's default graphical login desktop manager xenodm.
```
# rcctl disable xenodm
```

Enable services for Gnome, including it's login desktop manager gdm.

```
# rcctl enable multicast messagebus avahi_daemon gdm
```

Reboot into the new setup.

```
# reboot
```

If you don't want to reboot, you can switch to a tty with Ctrl Alt F2
and stop and start the daemons by hand easily. There's no rc.d script
for multicast, which will error the rest of the services if you try to
start it with them. Leave it off.

```
# rcctl stop xenodm
# rcctl start messagebus avahi_daemon gdm
```

## Switch from Gnome to another DE

To switch from Gnome to any other DE or WM which doesn't need GDM, 
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

