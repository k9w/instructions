# SSH Key Authentication, Verification, and Rotation

It is assumed you know how to SSH into a server with a password. Using
keys is more secure, allows for automation including system backups, and
is a requirement for ssh certificates, which simplifies management of
many SSH servers.

## Set the crypto for fewer key types to manage

ed25519 is the latest of the three key-types enabled by default on ssh.
rsa and ecdsa have longer key strings. SSH has supported ed25519 since
2014. All major BSDs and Linux distributions have supported it for quite
some time. I choose to disable rsa and ecdsa.

Manage it system-wide with crypto-policies(7), or individually for 

sshd:
HostKey /etc/ssh/ssh_host_ed25519_key

Check supported host key algorithms.

```
$ ssh -Q HostKeyAlgorithms
```

HostKeyAlgorithms ssh-ed25519, ssh-ed25519-cert-v01@openssh.com \
sk-ssh-ed25519@openssh.com, sk-ssh-ed25519-cert-v01@openssh.com

You also need to set HostKeyAlgorithms on the clent in ssh_config, so
that it won't add rsa and ecdsa keys to known_hosts if the server offers
them.


## User Key Authentication

### One Key per User per Client Host

ed25519

### Use One Key for all Client Hosts

ed25519-sk

## Limit SSH server to only accept Keys, not Passwords

/etc/ssh/sshd_config

PermitRootLogin prohibit-password (default), or no
PublicKeyAuthentication yes (default)
PasswordAuthentication no (default is yes)
KbdInteractiveAuthentication no (default is yes)

## Host Key Verification

Disable rsa and ecdsa. Use just ed25519 for simplicity and shorter
known_hosts and fingerprint files.

## Key Deployment & Rotation

Rotation must be tested on a regular basis. Deploy and test new keys
first before removing old keys.
