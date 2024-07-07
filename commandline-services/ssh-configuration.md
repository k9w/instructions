# SSH Configuration

## Test if ssh is running

Test from client for running sshd on server.

```
$ nc -v k9w.org 22
```

View the running sshd process when logged in on the server.

```
$ ps aux | grep sshd
```

## Check what config ssh sees

SSH reads its config not just from `ssh_confg` and `sshd_confg`, but
optionally from the operating system settings for cryptographic
algorithms, etc.

Rather than just viewing ssh's config files, check what ssh and sshd
think their configuration is directly.

Check the server config using `-G`. Optionally pipe it into `less` in
case it over-fills your screen.

```
$ sshd -G | less
```

The ssh client manpage also lists a `-G` flag as well. But it does not
work. Use `-Q` instead with each `ssh_config` option you want to check.

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

## Test changes & troubleshoot errors

If you mess up your sshd config, you could lock yourself out of your
server.

Copy the unmodified `sshd_config` to save the original. Then make
changes on the new file for now.

```
$ pwd
/etc/ssh
# cp sshd_config sshd_config.new
```

Similarly for client config changes, copy `ssh_config` to a new file and
modify the new file before committing the change to production.

```
# cp ssh_config ssh_config.new
```

While it is possible to run multiple ssh daemons using OS init
services (such as `rcctl`, `service`, or `systemctl`), this guide uses
sshd directly on the command line for testing.

Note that sshd requires execution with an absolute path. This won't work:

```
# sshd
```

You can find the absolute path of `sshd` with the `which` command.

```
$ which sshd
/usr/sbin/sshd
```

That is how you call `sshd`:

```
# /usr/sbin/sshd
```

Invoking the `ssh` client does not require specifying its absolute
path.

First, test the config for syntax errors with the `-t` flag, and `-f`
to specify a non-default configuration file name. Here, I
intentionally misspelled `no` as `noo` for
`KbdInteractiveAuthentication` to see what would happen.

```
# /usr/sbin/sshd -t -f sshd_config.new
sshd_config.new line 59: unsupported option "noo".
```

Next, to test your config, use these safeguards to prevent a bad
config locking you out of your server:

- On your ssh client, keep an ssh session open using the original port
  and configuration. (Restarting sshd only affects new connections,
  not existing ones.)
- Test the sshd config using an alternate config file name and port
  number.

It's also helpful to use a terminal multiplexer (session saver) such
as tmux or screen. This lets you, for example, leave an sshd instance
running in the foreground after you disconnect from the server.

Use `-f` to specify the alternate config file, and `-p` to specify the
alternate port.

```
# /usr/sbin/sshd -f sshd_config.new -p 2022
```

Test the client by trying to connect to the server on its
alternate port.

```
$ ssh -f ssh_config.new -p 2022
```

If the connection does not work, or if you want to see the connection
process in more detail, use `-d` on the server:

```
$ /usr/sbin/sshd -v -f sshd_config.new -p 2022
```

Or `-v` on the client:

```
$ ssh -v -f ssh_config.new -p 2022 k9w.org
```

You can get two more levels of detail by repeating the letter, up to
`-ddd` or `-vvv`, respectively.

Here is how they look with an alternate port and the default config,
for the server:

```
# /usr/sbin/sshd -ddd -p 2022
```

For the client:

```
$ ssh -vvv -p 2022 k9w.org
```

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


