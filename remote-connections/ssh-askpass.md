# Unlock SSH Keys in Memory

When using an SSH key with a passphrase, if you don't use an ssh-agent,
you have to type your passphrase everytime, every ssh session, every git
push or pull, anything that uses that key.

In Linux by default, no agent is loaded. To use it manually, run these
commands in each terminal window or terminal tab before ssh'ing or
launching tmux/screen.

```
$ eval $(ssh-agent)
Agent pid 10747
$ ssh-add
Enter passphrase for /home/kevin/.ssh/id_ed25519: 
Identity added: /home/kevin/.ssh/id_ed25519 (manjaro-pinebook)
$
```

In order to use the ssh key to ssh to a server without entering the
key's passphrase, ssh-agent needs to be running and that ssh key's
identity needs to be loaded into the agent.

When launched, ssh-agent doesn't have any key identities stored in it.
To add one, use ssh-add. In order for ssh-add to add the key identity to
the ssh-agent, ssh-add needs to know what unix domain socket is used by
ssh-agent so that ssh-add can communicate with ssh-agent over that
domain socket.

When launched, ssh-agent sets the environment variable $SSH_AUTH_SOCK to
the path of its unix domain socket. When invoked, ssh-add checks that
variable for the path to the agent's domain socket.

The default socket path is in /tmp/ssh-*/agent.*. For example:

```
$ env | grep -i ssh
SSH_AUTH_SOCK=/tmp/ssh-XXXXXXDiG32Q/agent.16659
```

However:

```
$ ssh-agent
```

And:

```
$ ssh-add
```

Won't work because ssh-add won't see $SSH_AUTH_SOCK this way.

The unix shell exposes variables set
this way to the invoking process, ssh-agent, and to any child processes.
Some Linux distributions or BSDs might wrap X11 or Wayland inside
ssh-agent as a way to pass $SSH_AUTH_SOCK to them and all child
processes. For example:

```
# ssh-agent startx
```

But when launched from just one terminal in X or Wayland, or a
non-graphical tty terminal, ssh-add can
only find $SSH_AUTH_SOCK if it's called from the same terminal where
ssh-agent was launched if the agent is called this way.

```
$ eval $(ssh-agent)
```

eval passes the environment created by ssh-agent to the rest of that
parent shell, and any of its child processes, including tmux/screen, but
not to any other shells or non-shell processes (such as emacs or a file
manager which may use git).

One solution is to have each shell window find that socket and set
$SSH_AUTH_SOCK in ~/.bashrc:

```
export SSH_AUTH_SOCK=$(find /tmp 2> /dev/null | grep agent)
```

Now if you invoke ssh-add in just the first terminal window, ssh will
find the key in the agent in all subsequent terminals, not just
children of that first terminal.


journalctl

~/.bashrc

```
export SSH_AUTH_SOCK=$(find /tmp 2> /dev/null | grep agent)
```

That works for all shells, but not for other apps which could need
ssh.


Latest idea is to use DefaultEnvironment with
'man systemd-system.conf'.

<https://unix.stackexchange.com/questions/320552/set-environment-variable-for-all-services-running-under-systemd>
