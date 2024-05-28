## DWM on OpenBSD

Dynamic Window Manager (DWM) is a tiling window manager that also can
do monicle (fullscreen) and floating layouts as well. Its written in
only a few thousand lines of C and designed to be configured directly
in its source files for simplicity.

## Install & Setup

```
# pkg_add dwm dmenu st slock
```

I chose the scrollback variant of st.

```
$ cat ~/.xsession
exec dwm
```

## See Also

<https://suckless.org>
