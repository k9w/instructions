# SSH Configuration

## Test if ssh is running

### From the client

Test from client for running sshd on server.

```
$ nc -v k9w.org 22
```

### From the server

```
$ ps aux | grep sshd
```

## Check what config ssh sees

SSH reads its config not just from ssh_confg and sshd_confg, but
optionally from the operating system settings for cryptographic
algorithms, etc.

Rather than just viewing ssh_config and sshd_config, check what ssh
and sshd think their configuration is directly.

Check the server config using `-G`. Optionally pipe it into `less` in
case it over-fills your screen.

```
$ sshd -G | less
```

The ssh client manpage also lists a `-G` flag as well. But it does not
work. Use `-Q` instead with each ssh_config option you want to check.

For example, to check what ciphers the client offers or accepts:

```
$ ssh -Q ciphers
```

Key Exchange Algorithms.

```
$ ssh -Q kexalgorithms
```

Host Key Algorithms:

```
$ ssh -Q hostkeyalgorithms
```

We will see how to change these later.

## Testing changes

If you mess up your sshd config, you could lock yourself out of your
server.

Copy the unmodified sshd_config to save the original. Then make
changes on the new file for now.

```
$ pwd
/etc/ssh
# cp sshd_config sshd_config.new
```

Similarly for client config changes, copy ssh_config to a new file and
modify the new file before committing the change to production.


## My sshd changes

Limit host keys to just the latest format ed25519, not ecdsa or
rsa. The default is to use all three. I uncomment just the ed25519
line.

```
HostKey /etc/ssh/ssh_host_ed25519_key
```

Do not let root login directly, even with an SSH key. Change from
`prohibit-password` to `no`.

```
PermitRootLogin no
```

Disable Password and Keyboard Interactive Authentication.

```
PasswordAuthentication no
KbdInteractiveAuthentication no
```

Default sshd offers many old cryptographic algorithms. If ssh on all
your servers and clients is new enough, you can remove old algorithms
wit these options for sshd and the ssh client:

- Ciphers
- KexAlgorithms
- HostkeyAlgorithms

Coming up, I will cover how to change these to accept only newer and
safer algorithms.

## Test the new configuration before committing to it

First, test the config for syntax errors with the `-t` flag. Here, I
intentionally misspelled `no` as `noo` for
`KbdInteractiveAuthentication` to see what would happen.

```
# sshd -t -f sshd_config.new
sshd_config.new line 59: unsupported option "noo".
```

Next, to test your config, use these safeguards to prevent a bad
config locking you out of your server:

- On the server, use a terminal multiplexer (session saver) such as
  tmux or screen.
- On your ssh client, keep an ssh session open using the original port
  and configuration. (Restarting sshd only affects new connections,
  not existing ones.)
- Test the sshd config using an alternate config file name and
  alternate port number.

Rather than calling your OS init daemon to restart the sshd service to
apply the new configuration, start a second instance of the sshd
daemon, have it use the new config, and run on a port other than the
default 22 so as to not interfere with the current sshd config and
daemon process.

Use `-f` to specify the alternate config file, and `-p` to specify the
alternate port.

```
# /usr/sbin/sshd -f /etc/ssh/sshd_config.new -p 2022
```

Test the client by trying to connect to the server, here specifying an
alternate port as well.

```
$ /usr/bin/ssh -f /etc/ssh/ssh_config.new -p 2022
```

Next I will show how to debug the client or server process, which can
help troubleshoot config errors.

