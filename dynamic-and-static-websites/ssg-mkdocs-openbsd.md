# mkdocs on OpenBSD

## Installation

Install pip, a package manager for Python.

```
# pkg_add py3-pip
```

Use pip to install mkdocs. Below, only select highights from the
command output are shown.

```
$ pip install mkdocs
```

Since we run pip as a regular user, it cannot install mkdocs or its
dependencies in the system folder for site packages
'/usr/local/lib/python3.x/site-packages' because it is only writable
by root.

```
Defaulting to user installation because normal site-packages is not writeable
```

But it can use system python packages to satisfy its dependencies and
save downloading them again to your user folder.

```
  Obtaining dependency information for mkdocs from https://files.pythonhosted.org/packages/89/58/aa3301b23966a71d7f8e55233f467b3cec94a651434e9cd9053811342539/mkdocs-1.5.3-py3-none-any.whl.metadata
  Downloading mkdocs-1.5.3-py3-none-any.whl.metadata (6.2 kB)
Requirement already satisfied: click>=7.0 in /usr/local/lib/python3.10/site-packages (from mkdocs) (8.0.4)
```

The pip wheels are built in ~/.cache.

```
  Building wheel for watchdog (pyproject.toml) ... done
  Created wheel for watchdog: filename=watchdog-3.0.0-py3-none-any.whl size=82033 sha256=9149d5f83d1a7c36c05d1196aa33a61124e91b67d6650ea513ed0948b530f123
  Stored in directory: ~/.cache/pip/wheels/b8/93/8a/150c2a3417342f49d9e24948f65d2b0f3bce50b8a522d80128
```
mkdocs is installed to ~/.local/bin, which is not in the default
command exection $PATH in OpenBSD.

```
  WARNING: The script mkdocs is installed in '~/.local/bin' which is not on PATH.
  Consider adding this directory to PATH or, if you prefer to suppress this warning, use --no-warn-script-location.
```

Add ~/.local/bin to $PATH in ~/.profile. Log out and back in, or
restart your terminal window or tmux session.

pip does not include manapages for itself or any of its packages by
default. To get manapages, install click-man (suggested by
mkdocs.org). 

```
$ pip install click-man
```

Generate manpages for pip, click-man itself, and mkdocs. On OpenBSD,
these third-party manpages for regular utilities normally live at
/usr/local/man/man1. 

```
$ click-man --target /usr/local/man/man1 {pip,click-man,mkdocs}
```

If click-man fails, use the mkdocs own webiste documentation instead.


## Organizing site content

If you're just trying out mkdocs and want to use the content with
another static site generator such as [hugo](https://gohugo.io), put
the markdown and other content in its own folder and symlink that
folder to <mkdocs-project-folder/docs. 

In this example make a symlink in the 'mkdocs-project' folder to the
'instructions' folder that holds the markdown content.

```
$ ln -s ~/src/instructions ~/src/mkdocs-project/docs
```


Once you've built your site, upload it to your server's
/var/www/example.com folder as the daemon user using openrsync. The
daemon user defaults to nologin rather than a shell. It will also need
an ssh key.

Is an ssh key still needed if the server has full rsync installed and an
rsync daemon running?


