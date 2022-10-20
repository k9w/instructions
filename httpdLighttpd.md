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

You can check it's config for errors.

```
$ lighttpd -t
2022-10-18 20:07:52: (server.c.1162) No configuration available. Try
using -f option.
```

This means... To fix it... 

Enable and start lighttpd.

```
# rcctl enable lighttpd
# rcctl start lighttpd
```

See also:
- Manpage: lighttpd(8)
- Local documentation in text format: /usr/local/share/doc/lighttpd
- [Online documentation at
lighttpd.net](https://redmine.lighttpd.net/projects/lighttpd/wiki)
