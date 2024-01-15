# Lighttpd webserver on OpenBSD

This guide describes how to install and configure
[Lighttpd](https://lighttpd.net) on [OpenBSD](https://openbsd.org).


## Installation

Install the lighttpd webserver.

```
# pkg_add lighttpd
```

For now, go with the basic edition, not ldap or mysql flavors.


# Configure basic http

Backup the original configuration before making changes. That way you
can fully undo your changes later.

```
$ cd /etc
# cp lighttpd.conf lighttpd.conf.orig
```

Edit the main configuration file.

```
# vi lighttpd.conf
```

For hosting just one site, change server.document-root from `htdocs/`
to the complete filesystem path for `example.com/`.

```
server.document-root        = "/var/www/example.com"
```

Save the file.

You can check it's config for errors. You need to specify the config
file when testing the config.

```
$ lighttpd -tf /etc/lighttpd.conf
Syntax OK
```

Enable and start lighttpd.

```
# rcctl enable lighttpd
# rcctl start lighttpd
```


The problem I have is it only displays 403 Forbidden, because Lighttpd
starts as root to bind to ports 80 and 443, and then drops root
privileges and runs as _lighttpd user and group per the default config.

It does not successfully have permissions to access
/var/www/example.com, or even to write to its log files to show errors
at /var/www/log, even after I set the ownership to match the lighttpd
groupd.

Maybe add _lighttpd user to daemon group and enable g+w on /var/www?

I need to ask for assistance on this. But for now, I'll move on to
Caddy.


See also:
- Manpage: lighttpd(8)
- Local documentation in text format: /usr/local/share/doc/lighttpd
- [Online documentation at
lighttpd.net](https://redmine.lighttpd.net/projects/lighttpd/wiki)
