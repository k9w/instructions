
started 04-10-2021

SSH logins are more secure using an SSH key than with just a password.
For access by you, a human (not automation), it is most secure to set a
password to unlock and use the SSH key. That way, no one may use the key
without knowing the password.

An SSH key is actually a key pair: 

- A private key stored securely on your local device.

- And a public key stored on a server or other remote location you want
to access, or even in a container, chroot-ed environment, or virtual
machine running locally on your device.

(Search the web for how to generate an SSH key pair and add the public
key to your remote location's SSH authorized_keys file.)

Protect your private SSH key. If it is stolen or leaked, any resource
that trusts your private key cannot tell you apart from the person or bot
trying to use your private key.

Here are some best practices to protect your private key or limit the
damage if it's stolen:

- Encrypt either your entire OS install when not booted, including your
private SSH key; or at least encrypt the folder containing your private
key. (Search the web for 'full disk encryption' for details.)

- Use a different SSH key pair for each local device, and operating
system, you want to SSH from. If your laptop has two solid state drives,
with OpenBSD and FreeBSD for example, use a separate SSH key pair for
each OS install.

If your device is stolen while the disk or folder containing your
private key is not in use and encrypted (such as when your laptop is
powered off), the thief only gets encrypted cyphertext he cannot readily
use, not your decrypted private SSH key.

If your local OS is compromized remotely while booted up and the private
key is already decrypted, you can revoke that key just for that OS
install without affecting your private key on other devices or OS
installs.

A password on your private SSH key is your last line of defense against
an attacker using it to access your resources. The attacker can crack
your password with time; but that time gives you a chance to discover it
was stolen and revoke the public key before the attacker cracks the
private key's password.

The main way to revoke an SSH key is to remove its public key from the
authorized_keys file on all your servers. (A more advanced method is to
use an SSH certificate instead of an SSH key. But we won't cover that
yet.)

Now that we've established why to use a password for your private key,
let's look at how to not have to type the password every time the key is
used. (If you use it for Git, for example, it could be several times per
hour.)

To avoid typing the password every time the key is used, it can be
stored in an ssh-agent, unlocked once with a password, and then used
repeatedly for password-less, but secured, SSH operations.

(For automated SSH access, this wouldn't work. You'd need to type in the
password when the automated service first needs it, which isn't
automated at all. Or you'd need to store the SSH key password in plain
text in a script, or use a passwordless SSH key. We'll cover how to
handle that separately.)

Some desktop environments use keyrings or auto-launch the ssh-agent and
prompt for the password on initial login.

We will first look at how to use the ssh-agent from scratch, where none
of that is setup in advance. Our example uses OpenBSD and ksh, works
with or without X (or Wayland on Linux) and works across the graphical
environment and all local tty terminals.


if [ SSH_AUTH_SOCK != $(find /tmp -name agent*) ]; then
	export SSH_AUTH_SOCK=$(find /tmp -name agent*)
fi

Launch the agent from a console login shell, not in X or Wayland.

$ ssh-agent /bin/ksh

Or

$ eval `ssh-agent -s`

Or

$ ssh-agent $SHELL

Then type `ssh-add` and on the next line type the key password when
prompted.

$ ssh-add
Enter passphrase for /home/kevin/.ssh/id_ed25519:
Identity added: /home/kevin/.ssh/id_ed25519 (kevin@OpenBSD63.vultr.com)
$ 

When using X or Wayland, consult the proper setting to activate the
graphical ssh-agent which will prompt for the key password if it finds
a key in ~/.ssh.

To kill the currently running ssh-agent without shutdown, reboot, or
logging out of the original login shell:

$ ssh-agent -D

Or

$ ssh-agent -k

In some cases the agent had spawned a subshell. One exit command would
not log you out. But a second exit would.

In other cases, the agent did not appear to spawn a subshell, as
evidenced by a single exit command causing a full logout.


--------


One change to make is to no longer use the same private key from all
my laptops, but to generate a different keypair for each laptop, and
perhaps each OS install if multi-booting or re-installing the OS.

Backup these keys offline, such as a USB drive or printout in an
OCR-friendly font.

----

Disalbe passwords in SSH server. Set both of these keywords in
sshd_config to no.

ChallengeResponseAuthentication no
PasswordAuthentication no


--------


How to manually SSH from one server to another, not automated


You don't need to store your private key on the server. If you're
manually logged into one server from your laptop with ssh key and
ssh-agent running, you can use Agent Forwarding to SSH from one server
to another, for instance to SFTP files between hosts.

Find the agent ID locally:
$ echo $SSH_AUTH_SOCK
/tmp/ssh-jYaU6spT5WqA/agent.74875

If your server root account is compromised (some other way than
stealing/cracking ssh key), the attacker can access your laptop
ssh-agent socket and SSH into other servers of yours without providing
the key passphrase. Only allow agent forwarding on machines you
control and have properly secured.

To enable agent forwarding:

On the first server you SSH into:
sshd_config:

AllowAgentForwarding yes

You can actually disable it globally, but then use a match rule to
only allow certain users or addresses to forward their agents.

On your laptop:
ssh_config:

ForwardAgent yes


--------


How to safely automate SSH connections between servers.

If the X or Wayland session starts an ssh-agent, it should have a socket
file in /tmp and that value should be set in $SSH_AUTH_SOCK. If the
agent dies, or was never started, or loses its socket, place this in
.kshrc or .bashrc.

```
SSH_AUTH_SOCK=$(find /tmp -name agent*)
```


