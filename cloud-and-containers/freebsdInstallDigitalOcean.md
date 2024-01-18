04-17-2022 San Francisco on Digital Ocean
https://marcocetica.com/posts/openbsd_digitalocean

Differences from those instructions:
 - You can download and dd an install larger than OpenBSD's miniroot,
including FreeBSD mini-memstick.img.
 - After dd'ing the image and rebooting, go to the droplet's access tab
and launch the recovery console, rather than the regular console.
 - FreeBSD installer gets error: geom: gpart vtbd0 file exists.
Fix found at: https://github.com/helloSystem/ISO/issues/200
At bottom of page:

----

Need to test with running /sbin/gpart destroy -F adaX before invoking
the installer. After having tried without, all we get is

/sbin/gpart destroy -F adaX
gpart: Device busy

After rebooting:

sudo umount -f /dev/ada2*
sudo /sbin/gpart destroy -F adaX
# Run Installer

----

For this case on Digital Ocean, it is the first partition of vtdb0.

```
# gpart destroy -F vtdb0
```
It did not work. I cancelled the VM.

