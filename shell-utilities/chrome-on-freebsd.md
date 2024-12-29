To install Google Chrome on FreeBSD, enable and start the 'linux'
service and install the `linux-chrome` package.

```
# pkg install linux-chrome
Cannot install package: kernel missing 64-bit Linux support
```

Need to enable and start the linux compatibility service before
package install.


```
# sysrc linux_enable="YES"
# service linux start
```
