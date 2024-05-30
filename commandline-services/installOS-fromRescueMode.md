10-23-22 

Adapted from:
<https://marcocetica.com/posts/openbsd_digitalocean>
<https://wiki.archlinux.org/title/Chroot>

Example: racknerd, switch from AlmaLinux8 to OpenBSD.

Boot to Debian 9 rescue mode and login.

Use curl to download the img file, and dd to write it to the main
partition.

Since rescue mode doesn't have curl, ftp, or wget, mount the full
install which does have curl.

```
# mount /dev/vda1 /mnt
```

Running curl at `/mnt/usr/bin/curl` fails due to missing libraries. The
rescue mode shell is looking for them in the rescue mode root, whereas
they are in the main system partition mounted to /mnt.

To fix, chroot into /mnt.

```
# mount /mnt
```

Download the installer (to the chroot / is fine).

```
# curl -o https://cdn.openbsd.org/pub/OpenBSD/snapshots/amd64/miniroot73.img
```

Exit the chroot and return to the rescue mode filesystem.

```
# exit
```

Copy the installer out of /mnt to the rescue mode filesystem.

```
# cp /mnt/miniroot73.img .
```

Unmount the vda1 partition.

```
# umount /mnt
```

Overwrite the existing Linux installation with the OpenBSD installer.

```
# dd if=miniroot73.img of=/dev/vda bs-512k
11+1 records in
11+1 records out
5832704 bytes (5.8 MB, 5.6 MiB) copied, 0.0255728 s, 228 MB/s
```

Reboot back into normal mode and return to the cloud console.

Run the OpenBSD installer.

