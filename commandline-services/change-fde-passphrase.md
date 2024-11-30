## OpenBSD

Here is how to change the Full Drive Encryption passphrase with bioctl.

```
# bioctl -P /dev/rsd1c
```


## FreeBSD

Here is how to change the Full Drive Encryption passphrase with GELI.

```
# geli setkey -v -j ~/old-passphrase -J ~/new-passphrase /dev/ada0p3
```

