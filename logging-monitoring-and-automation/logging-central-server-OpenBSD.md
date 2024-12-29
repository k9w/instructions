# Central Server Logging with OpenBSD

Collect logs with [syslogd(8)](https://man.openbsd.org/syslogd) on each
member server, as well as with `syslogd -S` for TLS mode on the central
log server. Logs are rotated on all servers with
[newsyslog(8)](https://man.openbsd.org/newsyslog).

## syslogd

[syslogd(8)](https://man.openbsd.org/syslogd)

## newsyslog

[newsyslog(8)](https://man.openbsd.org/newsyslog)

## Certificate management and configuration files

`/etc/syslog.conf`

`/etc/newsyslog.conf`

`/etc/ssl`

## Setup from scratch

- Should you use a public Certificate Authority? Or a private CA?

- Configure the PF firewall to only allow messages from authenticated hosts

- Archive logs and compress them

- How to search through logs, compressed or not

- Storage quota: choose what old logs to offload to a storage or backup host or to delete

## See Also

- <https://www.openbsd.org/papers/eurobsdcon2017-syslog-slides.pdf>

- [Run classic syslog on Linux rather than
journalctl](https://github.com/troglobit/sysklogd)

- [Syslogd on FreeBSD and
OpenBSD](https://flylib.com/books/en/1.275.1.101/1/)

