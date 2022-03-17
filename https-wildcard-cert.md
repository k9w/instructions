# 03-17-22

I have k9w.org and several subdomains registered with DNSimple. I want
a wildcard TLS certificate to use with all of the subdomains. I use
each subdomain on a different VPS server, or possibly on Linux
containers or FreeBSD jails in the future.

To initially get and then periodically renew the cert, I use:

Certificate Authority: https://letsencrypt.org/docs
Domain Registrar: https://developer.dnsimple.com
Application to speak to both services' APIs and get the cert:
https://github.com/go-acme/lego

Challenge type: dns-01

I already have a non-wildcard cert for capernaumtech.com with the
http-01 challenge. Since it's not wildcard, I can only use it on one
server.

https://api.dnsimple.com/v2

```
$ curl -u 'EMAIL:PASSWORD' -H 'Content-Type: application/json' https://api.dnsimple.com/v2/whoami
```

The example above uses http basic authentication, with
email:password. Lego intentionally does not support that. It supports
OAuth2 Tokens, like GitHub Personal Access Tokens.

DNSimple supports an account token or user token. I use the account
token.

```
$ curl -H 'Authorization: Bearer OAUTH-TOKEN' https://api.dnsimple.com/v2/whoami
```

That is a GET request. With my OAuth token in place in the command
above, the API answers the GET request as follows. 

```
{
  "data": {
    "user": null,
	"account": {
	  "id": 83837,
	  "email": "kevin.williams.edu@gmail.com",
	  "plan_identifier": "professional-v2-monthly",
	  "created_at":"2018-08-27T12:10:23Z",
	  "updated_at":"2022-01-02T19:34:35Z"
	}
  }
}
```

This pattern should be all I need for Letsencrypt, unless a POST
request is required and used.

