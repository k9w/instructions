If you get this error:

```
# acme-client -vv example.com
acme-client: /etc/ssl/private/k9w.org.key: group read/writable or world read/writable
```

You need to set /etc/ssl/private and all files as readable by owner
and no permissions for anyone else.

```
# chmod -R 400 /etc/ssl/private
```

