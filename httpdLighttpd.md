# Lighttpd webserver on OpenBSD

This guide describes how to install and configure
[Lighttpd](https://lighttpd.net) on [OpenBSD](https://openbsd.org).


## Installation

Install the lighttpd webserver.

```
# pkg_add lighttpd
```

For now, go with the basic edition, not ldap or mysql flavors.


# Configuration

Edit the main configuration file.

```
# vi /etc/lighttpd.conf
```

