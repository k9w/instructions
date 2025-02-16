One of my FreeBSD VMs with only 10GB storage recently ran out of
space.

How to find and delete snapshots. This first way did not work.

```
$ zfs list
NAME                                           USED  AVAIL  REFER  MOUNTPOINT
zroot                                         5.24G  2.03G    96K  /zroot
zroot/ROOT                                    5.21G  2.03G    96K  none
zroot/ROOT/14.0-RELEASE-p5_2024-05-11_034439     8K  2.03G  1.73G  /
zroot/ROOT/14.0-RELEASE-p6_2024-07-03_160033     8K  2.03G  2.61G  /
zroot/ROOT/14.0-RELEASE-p8_2024-07-18_212956     8K  2.03G  3.16G  /
zroot/ROOT/14.0-RELEASE_2024-02-15_025619        8K  2.03G  1.49G  /
zroot/ROOT/14.1-RELEASE-p2_2024-08-10_033931     8K  2.03G  3.35G  /
zroot/ROOT/14.1-RELEASE-p3_2024-11-08_210548     8K  2.03G  3.34G  /
zroot/ROOT/14.1-RELEASE_2024-07-18_213402        8K  2.03G  3.26G  /
zroot/ROOT/default                            5.21G  2.03G  3.34G  /
zroot/home                                     148K  2.03G   148K  /home
zroot/tmp                                      104K  2.03G   104K  /tmp
zroot/usr                                      288K  2.03G    96K  /usr
zroot/usr/ports                                 96K  2.03G    96K  /usr/ports
zroot/usr/src                                   96K  2.03G    96K  /usr/src
zroot/var                                     18.3M  2.03G    96K  /var
zroot/var/audit                                 96K  2.03G    96K  /var/audit
zroot/var/crash                                 96K  2.03G    96K  /var/crash
zroot/var/log                                 1.32M  2.03G  1.32M  /var/log
zroot/var/mail                                16.6M  2.03G  16.6M  /var/mail
zroot/var/tmp                                   96K  2.03G    96K  /var/tmp
```

```
# zfs destroy zroot/ROOT/13.4-RELEASE-p1_2024-09-21_080458
```

That did not free up space, even afer a reboot.

```
$ zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zroot  7.50G  5.24G  2.26G        -         -    45%    69%  1.00x    ONLINE  -
```


```
$ zfs list -t all -r
NAME                                           USED  AVAIL  REFER  MOUNTPOINT
zroot                                         5.24G  2.03G    96K  /zroot
zroot/ROOT                                    5.21G  2.03G    96K  none
zroot/ROOT/14.0-RELEASE-p5_2024-05-11_034439     8K  2.03G  1.73G  /
zroot/ROOT/14.0-RELEASE-p6_2024-07-03_160033     8K  2.03G  2.61G  /
zroot/ROOT/14.0-RELEASE-p8_2024-07-18_212956     8K  2.03G  3.16G  /
zroot/ROOT/14.0-RELEASE_2024-02-15_025619        8K  2.03G  1.49G  /
zroot/ROOT/14.1-RELEASE-p2_2024-08-10_033931     8K  2.03G  3.35G  /
zroot/ROOT/14.1-RELEASE-p3_2024-11-08_210548     8K  2.03G  3.34G  /
zroot/ROOT/14.1-RELEASE_2024-07-18_213402        8K  2.03G  3.26G  /
zroot/ROOT/default                            5.21G  2.03G  3.34G  /
zroot/ROOT/default@2024-02-15-02:56:19-0       425M      -  1.49G  -
zroot/ROOT/default@2024-05-11-03:44:39-0       265M      -  1.73G  -
zroot/ROOT/default@2024-07-03-16:00:33-0      54.9M      -  2.61G  -
zroot/ROOT/default@2024-07-18-21:29:57-0      1.59M      -  3.16G  -
zroot/ROOT/default@2024-07-18-21:34:02-0      1.43M      -  3.26G  -
zroot/ROOT/default@2024-08-10-03:39:31-0      80.3M      -  3.35G  -
zroot/ROOT/default@2024-11-08-21:05:48-0      78.2M      -  3.34G  -
zroot/home                                     148K  2.03G   148K  /home
zroot/tmp                                      104K  2.03G   104K  /tmp
zroot/usr                                      288K  2.03G    96K  /usr
zroot/usr/ports                                 96K  2.03G    96K  /usr/ports
zroot/usr/src                                   96K  2.03G    96K  /usr/src
zroot/var                                     18.3M  2.03G    96K  /var
zroot/var/audit                                 96K  2.03G    96K  /var/audit
zroot/var/crash                                 96K  2.03G    96K  /var/crash
zroot/var/log                                 1.32M  2.03G  1.32M  /var/log
zroot/var/mail                                16.6M  2.03G  16.6M  /var/mail
zroot/var/tmp                                   96K  2.03G    96K  /var/tmp
```

Snapshots need to be deleted from the bottom up.

```
$ zfs list -t all -r
# zfs destroy zroot/ROOT/default@2024-09-21-08:04:58-0
```

This worked right away, after deleting the clones above that depended
on the snapshots.

This is a clone from a snapshot.

```
zroot/ROOT/14.1-RELEASE_2024-07-18_213402
```

This is the snapshot it likely refers to, based on timestamp.

```
zroot/ROOT/default@2024-07-18-21:34:02-0
```

If you try to remove the snapshot without first removing the clone:

```
# zfs destroy zroot/ROOT/default@2024-07-18-21:34:02-0
cannot destroy 'zroot/ROOT/default@2024-07-18-21:34:02-0': snapshot has dependent clones
use '-R' to destroy the following datasets:
zroot/ROOT/14.1-RELEASE_2024-07-18_213402
```

Use the -R flag instead to delete the snapshot and any clones
depending on it.

```
# zfs destroy -R zroot/ROOT/default@2024-07-18-21:34:02-0
```


How to create a pool with draid vdev.

```
$ mkdir ~/test-zfs && cd ~/test-zfs
$ dd if=/dev/zero of=disk00
```

List all the device files into a file called `drive-list`.

```
/home/kevin/test-zfs/disk00
/home/kevin/test-zfs/disk01
/home/kevin/test-zfs/disk02
/home/kevin/test-zfs/disk03
/home/kevin/test-zfs/disk04
/home/kevin/test-zfs/disk05
/home/kevin/test-zfs/disk06
/home/kevin/test-zfs/disk07
/home/kevin/test-zfs/disk08
/home/kevin/test-zfs/disk09
/home/kevin/test-zfs/disk10
/home/kevin/test-zfs/disk11
/home/kevin/test-zfs/disk12
/home/kevin/test-zfs/disk13
/home/kevin/test-zfs/disk14
```

```
# zpool create test-pool draid3:2s $(cat drive-list)
```

```
# zpool destroy test-pool
```

```
$ zpool status test-pool
```

```
$ zfs list test-pool
```


