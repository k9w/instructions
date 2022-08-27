08-24-2022

I want to run several apps on OpenBSD at once, like jails on FreeBSD or
containers on Linux.

Have relayd listen on ports 80 and 443 for all URLs. Redirect 80 to 443 
and have relayd handle all TLS. Then pass each fqdn to its webserver.

rcctl can actually run multiple daemons of the same application, two
OpenBSD httpd servers for example. But you can also use nginx, apache,
and lighttpd.

I checked for the following ports in /etc/services and they are free.

2080 2443 httpd, first instance
3080 3443 httpd, second instance
4080 4443 nginx, first instance
5080 5443 nginx, second instance
6080 6443 apache, first instance
7080 7443 apache, second instance
8080 8443 lighttpd, first instance
9080 9443 lighttpd, second instance

The 443 likely won't be needed on each server since relayd is taking 
care of TLS.

Each webserver can, of course, serve multiple websites and URLs based
on the fqdn in the packet header.

