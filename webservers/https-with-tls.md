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


If you host two sites, you might get this error.

In Firefox:

```

Warning: Potential Security Risk Ahead

Firefox detected a potential security threat and did not continue to a.k9w.org. If you visit this site, attackers could try to steal information like your passwords, emails, or credit card details.

What can you do about it?

The issue is most likely with the website, and there is nothing you can do to resolve it. You can notify the website’s administrator about the problem.

Learn more…

Websites prove their identity via certificates. Firefox does not trust this site because it uses a certificate that is not valid for a.k9w.org. The certificate is only valid for k9w.org.
 
Error code: SSL_ERROR_BAD_CERT_DOMAIN
 
View Certificate

```

In Chrome:

```
Your connection is not private
Attackers might be trying to steal your information from a.k9w.org (for example, passwords, messages, or credit cards). Learn more
NET::ERR_CERT_COMMON_NAME_INVALID
To get Chrome’s highest level of security, turn on enhanced protection
This server could not prove that it is a.k9w.org; its security certificate is from k9w.org. This may be caused by a misconfiguration or an attacker intercepting your connection.

Proceed to a.k9w.org (unsafe)
```

Double-check `/etc/acme-client.conf`.

If that doesn't fix it....

It resolved itself a day later when I checked from a different browser
and different computer.
