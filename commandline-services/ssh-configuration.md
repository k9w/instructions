# SSH Configuration

## Test if ssh server is running

Test from client if sshd is running on server.

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

Check the server and client config using `-G`. Optionally pipe it into
`less` in case it over-fills your screen.

```
$ sshd -G | less
```

The ssh client requires a hostname specified for the `-G` flag to
work. This is not obvious from the `ssh_config` manpage.

```
$ ssh -G * | less
```

You can also check specific settings with the `-Q` flag.

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
# cp sshd_config sshd_config.test
```

Similarly for client config changes, copy `ssh_config` to a new file and
modify the new file before committing the change to production.

```
# cp ssh_config ssh_config.test
```

While it is possible to run multiple ssh daemons using OS init
services (such as `rcctl`, `service`, or `systemctl`), this guide uses
sshd directly on the command line for testing.

Note that sshd requires execution with an absolute path in some cases.

You can find the absolute path of `sshd` with the `which` command.

```
$ which sshd
/usr/sbin/sshd
```

That is how you call `sshd` when an absolute path is required:

```
$ /usr/sbin/sshd
```

Invoking the `ssh` client does not require specifying its absolute
path.

Use `-f` for `sshd` or `-F` for `ssh` to specify a non-default
configuration file name. `sshd` can test config files without
absoloute path and without running as root by specifying:

- The `-G` flag to show all options, default and those changed in this config
file. 

- The `-t` flag to check for syntax errors. The default config in
  `/etc/ssh` is fine.

Pipe it into `less` for readability.

Show the server config.

```
$ sshd -f sshd_config.test -G | less
```

Show the client config.

```
$ ssh -F ssh_config -G o | less
```

If I chose `*` as the hostname, the result picks the first filename in
the current folder. I chose `o` arbitrarily to avoid that.

To test an error with `-t`, I intentionally misspelled `no` as `noo`
for `KbdInteractiveAuthentication` to see what would happen.

```
$ sshd -f sshd_config.new -t
sshd_config.new line 59: unsupported option "noo".
```

Next, to test your config, by running the server daemon on an
alternate port, and connecting to it from the client on that same
alternate port.

Use these safeguards to prevent a bad config locking you out of your
server:

- On your ssh client, keep an ssh session open using the original port
  and configuration. (Restarting sshd only affects new connections,
  not existing ones.)
- Test the sshd config using an alternate config file name and port
  number.

It's also helpful to use a terminal multiplexer (session saver) such
as `tmux` or `screen`. This lets you, for example, leave an sshd
instance running in the foreground after you disconnect from the
server.

Use `-p` to specify the alternate port.

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

# My changes to ssh server and client

Here are changes I made to both the server and the client.

Here I choose all variations of ED25519:

- Regular key
- Certificate
- MFA-backed key
- MFA-backed certificate

```
HostBasedAcceptedAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com

HostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com

PubKeyAcceptedAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com

IdentityFile ~/.ssh/id_ed25519

CASignatureAlgorithms ssh-ed25519,sk-ssh-ed25519@openssh.com
```

This disallows all other hostkey algorithms.

I have left the following variables at default because I do not
understand which algorithms are better than others. See
`ssh_config(5)` for default values.

- Ciphers
- KexAlgorithms
- MACs


## My ssh server-only changes

Here is the full unified diff. I will explain server-only changs after.

```
$ diff -u sshd_config.orig sshd_config 
--- sshd_config.orig    Wed Jul 10 15:46:42 2024
+++ sshd_config       Thu Aug 22 18:41:43 2024
@@ -15,8 +15,14 @@
 
 #HostKey /etc/ssh/ssh_host_rsa_key
 #HostKey /etc/ssh/ssh_host_ecdsa_key
-#HostKey /etc/ssh/ssh_host_ed25519_key
+HostKey /etc/ssh/ssh_host_ed25519_key
 
+HostBasedAcceptedAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com
+
+HostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com
+
+PubKeyAcceptedAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com
+
 # Ciphers and keying
 #RekeyLimit default none
 
@@ -52,11 +58,11 @@
 #IgnoreRhosts yes
 
 # To disable tunneled clear text passwords, change to no here!
-#PasswordAuthentication yes
+PasswordAuthentication no
 #PermitEmptyPasswords no
 
 # Change to no to disable s/key passwords
-#KbdInteractiveAuthentication yes
+KbdInteractiveAuthentication no
 
 #AllowAgentForwarding yes
 #AllowTcpForwarding yes
```

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


### Check Available & Configured HostKeyAlgorithms

Check what algorithms `sshd` supports for keyword HostKeyAlgorithms:

```
$ ssh -Q hostkeyalgorithms
```

From the client, check what algorithms are currently configured for
keyword HostKeyAlgorithms on the server.

```
$ ssh -G k9w.org | grep hostkeyalgorithms | tr ',' '\n'
```

### Set which HostKeyAlgorithms to Accept

In `sshd_config`, perhaps right below the HostKey entry, add
HostKeyAlgorithms with the algorithms you want to use.



## My ssh client config changes

```

```

## Generate new hostkeys

I have not yet tested setting HostKeyAlgorithms as specified above.

Delete the current hostkeys from `/etc/ssh` named `ssh_host

```
$ ssh-keygen -A
```

