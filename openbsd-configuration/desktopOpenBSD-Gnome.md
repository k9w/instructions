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
# rcctl enable messagebus avahi_daemon gdm
```

They must be enabled in that order, or avahi_daemon will fail and gdm
won't work.

The package readme also says to enable multicast. But that's just a
varible, not an rc.d script.

Add user to _shutdown group to shutdown and reboot from the Gnome menu,
and anywhere else in the system, without password. Only works with
[shutdown(8)](https://man.openbsd.org/shutdown), not [halt or
reboot](https://man.openbsd.org/reboot). 

```
# usermod -G _shutdown <username>
```

Adding to the group is not in the package readme, as it's not specific
to Gnome.

Reboot into the new setup.

```
$ Shutdown -R Now
```

## Switch Between Gnome and xenodm

Switch back to xenodm on next boot.

```
# rcctl disable messagebus avahi_daeom gdm
# rcctl enable xenodm
```

Switch back to xenodm right away.

```
# rcctl stop messagebus avahi_daemon gdm
# rcctl start xenodm
```

## Caveats

### Gnome Keyring and ssh-agent

Gnome Keyring caches SSH keys and other credentials. Normally,
Xenodm's confguration file `/etc/X11/xenodm/Xsession` calls ssh-agent
and prompts for the private key passphrase on login. Gnome Keyring
starts its own ssh-agent but doesn't prompt for the key passphrase
until your first ssh attempt of the Gnome login session.

You can also manually unlock the ssh key before being prompted.

```
$ ssh-add
Enter passphrase for key '/home/<username>/.ssh/id_ed25519': 
```
Use of Gnome Keyring is not optional. I found nowhere in the settings
to disable it. When I launch Chromium, it prompts me to set a password 
for the new 'default keyring'. I chose not to and I have accepted 
dismissing the prompt each time I launch Chromium.

It can technically be disabled by renaming or moving the executables in
/usr/local/bin:

```
gnome-keyring
gnome-keyring-3
gnome-keyring-daemon
```

Only renaming the daemon was necessary to disable it. But then
ssh-agent failed to start.

I started it manually with:

```
$ eval `ssh-agent`
```

But it would not let me or my ~/.profile properly set $SSH_AUTH_SOCK,
which is required for `ssh-add` to work properly.

In the end I re-enabled gnome-keyring.

### Cannot use BitWarden from Chromium desktop icon

Chromium on OpenBSD disables WebAssembly, which is required for the
Argon2 KDF feature of the BitWarden extension, and likely the website
vault too.

Rather than launching it as `chrome`, I do `chrome--enable-wasm`. When 
launched from a terminal, it ties up the terminal until chromium
exits. Launching it from a dedicated tmux pane leaves the rest of my
terminal free for other use while chromium runs.

The .desktop file for Chromium does not include that flag. Those files
are located in:

```
/usr/local/share/applications
```

I copied `chromium-browser.desktop` to `chromium-wasm.desktop`. The
Exec function [does not
support](https://unix.stackexchange.com/questions/238565/how-to-pass-argument-in-desktop-file)
double-dash command flags, only single-dash. However, they can work
inside quotes, such as in a string for a subshell. In
chromium-wasm.desktop, I changed the Exec lines to:

```
Exec=sh -c "chrome --enable-wasm %U"
```

And for the private window:

```
Exec=sh -c "chrome --incognito --enable-wasm"
```
That still did not work. It kept launching chromium without wasm.

I only use Chromium with wasm for BitWarden. So I cannot add the icon
to my favorites menu and will continue launching it from the terminal.

