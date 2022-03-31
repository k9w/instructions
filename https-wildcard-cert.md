# 03-17-22

I have example.com and several subdomains registered with DNSimple. I want
a wildcard TLS certificate to use with all of the subdomains. I use
each subdomain on a different VPS server and eventually on Linux
containers and FreeBSD jails too.

To initially get and then periodically renew the wildcard cert, I use:

Certificate Authority: https://letsencrypt.org/docs
Domain Registrar: https://developer.dnsimple.com
Application to speak to both services' APIs and get the cert:
https://github.com/go-acme/lego

Challenge type: dns-01

I already have a non-wildcard cert for example1.com with the
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
	  "email": "address@hidden",
	  "plan_identifier": "professional-v2-monthly",
	  "created_at":"2018-08-27T12:10:23Z",
	  "updated_at":"2022-01-02T19:34:35Z"
	}
  }
}
```

This pattern should be all I need for Letsencrypt, unless a POST
request is required and used.


<p>
# 03-27

I got an API token and tried it with lego for all subdomains of example.com.

```
$ DNSIMPLE_OAUTH_TOKEN=******************************** lego --email address@hidden --dns dnsimple --domains *.example.com run
2022/03/27 22:09:32 No key found for account address@hidden. Generating a P256 key.
2022/03/27 22:09:32 Saved key to /home/kevin/.lego/accounts/acme-v02.api.letsencrypt.org/address@hidden/keys/address@hidden.key
2022/03/27 22:09:32 Please review the TOS at https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf
Do you accept the TOS? Y/n
y
2022/03/27 22:10:05 [INFO] acme: Registering account for address@hidden
!!!! HEADS UP !!!!

Your account credentials have been saved in your Let's Encrypt
configuration directory at "/home/kevin/.lego/accounts".

You should make a secure backup of this folder now. This
configuration directory will also contain certificates and
private keys obtained from Let's Encrypt so making regular
backups of this folder is ideal.
2022/03/27 22:10:05 [INFO] [*.example.com] acme: Obtaining bundled SAN certificate
2022/03/27 22:10:05 [INFO] [*.example.com] AuthURL: https://acme-v02.api.letsencrypt.org/acme/authz-v3/92107296710
2022/03/27 22:10:05 [INFO] [*.example.com] acme: use dns-01 solver
2022/03/27 22:10:05 [INFO] [*.example.com] acme: Preparing to solve DNS-01
2022/03/27 22:10:06 [INFO] [*.example.com] acme: Trying to solve DNS-01
2022/03/27 22:10:06 [INFO] [*.example.com] acme: Checking DNS record propagation using [23.239.24.5:53 72.14.179.5:53 72.14.188.5:53]
2022/03/27 22:10:08 [INFO] Wait for propagation [timeout: 1m0s, interval: 2s]
2022/03/27 22:10:11 [INFO] [*.example.com] acme: Cleaning DNS-01 challenge
2022/03/27 22:10:12 [INFO] Deactivating auth: https://acme-v02.api.letsencrypt.org/acme/authz-v3/92107296710
2022/03/27 22:10:12 Could not obtain certificates:
        error: one or more domains had a problem:
[*.example.com] acme: error: 400 :: urn:ietf:params:acme:error:dns :: DNS problem: NXDOMAIN looking up TXT for _acme-challenge.example.com - check that a DNS record exists for this domain
$ 
```

It did not work. So I tried it again as just example.com, not *.example.com, and it worked.

```
$ DNSIMPLE_OAUTH_TOKEN=******************************** lego --email address@hidden --dns dnsimple --domains example.com run   
2022/03/27 22:31:36 [INFO] [example.com] acme: Obtaining bundled SAN certificate
2022/03/27 22:31:37 [INFO] [example.com] AuthURL: https://acme-v02.api.letsencrypt.org/acme/authz-v3/92113096290
2022/03/27 22:31:37 [INFO] [example.com] acme: Could not find solver for: tls-alpn-01
2022/03/27 22:31:37 [INFO] [example.com] acme: Could not find solver for: http-01
2022/03/27 22:31:37 [INFO] [example.com] acme: use dns-01 solver
2022/03/27 22:31:37 [INFO] [example.com] acme: Preparing to solve DNS-01
2022/03/27 22:31:37 [INFO] [example.com] acme: Trying to solve DNS-01
2022/03/27 22:31:37 [INFO] [example.com] acme: Checking DNS record propagation using [23.239.24.5:53 72.14.179.5:53 72.14.188.5:53]
2022/03/27 22:31:39 [INFO] Wait for propagation [timeout: 1m0s, interval: 2s]
2022/03/27 22:31:43 [INFO] [example.com] The server validated our request
2022/03/27 22:31:43 [INFO] [example.com] acme: Cleaning DNS-01 challenge
2022/03/27 22:31:44 [INFO] [example.com] acme: Validations succeeded; requesting certificates
2022/03/27 22:31:44 [INFO] [example.com] Server responded with a certificate.
$ 
```

This generated files in ~/.lego/certificates

example.com.crt        example.com.issuer.crt example.com.json      example.com.key

Copy example.com.crt to /etc/ssl. Copy example.com.key to /etc/ssl/private

Once I find out how to use the certificate on multiple servers, I need
to add that same command to /etc/monthly.local with 'renew' instead of
'run'.

http://c.example.com worked as before. https://c.example.com failed to load
the page because the cert was for example1.com. I commented out
the code blocks for example1.com in /etc/httpd.conf and then
Firefox recognized the example.com cert. It said it was not valid for
c.example.com, only for example.com. I added an A record for example.com and
confirmed that worked.

So I listed the example.com certificate, revoked, it, and ran lego this
time for *.example.com. Strangely, *.example.com was the first method I tried
last week, and it failed. But today, it worked; likely because I had
already made the cert for just example.com.

```
$ DNSIMPLE_OAUTH_TOKEN=******************************** lego --email address@hidden --dns dnsimple --domains example.com list
Found the following certs:
  Certificate Name: example.com
    Domains: example.com
    Expiry Date: 2022-06-25 21:31:43 +0000 UTC
    Certificate Path: /home/kevin/.lego/certificates/example.com.crt

c$ DNSIMPLE_OAUTH_TOKEN=******************************** lego --email address@hidden --dns dnsimple --domains example.com revoke
2022/03/31 00:54:23 Trying to revoke certificate for domain example.com
2022/03/31 00:54:23 Certificate was revoked.
2022/03/31 00:54:23 Certificate was archived for domain: example.com
c$ DNSIMPLE_OAUTH_TOKEN=QQNeuBtXBEna518dIZ61vOMLuqAEhvGf lego --email address@hidden --dns dnsimple --domains *.example.com run  
2022/03/31 00:54:46 [INFO] [*.example.com] acme: Obtaining bundled SAN certificate
2022/03/31 00:54:47 [INFO] [*.example.com] AuthURL: https://acme-v02.api.letsencrypt.org/acme/authz-v3/93170724640
2022/03/31 00:54:47 [INFO] [*.example.com] acme: use dns-01 solver
2022/03/31 00:54:47 [INFO] [*.example.com] acme: Preparing to solve DNS-01
2022/03/31 00:54:48 [INFO] [*.example.com] acme: Trying to solve DNS-01
2022/03/31 00:54:48 [INFO] [*.example.com] acme: Checking DNS record propagation using [23.239.24.5:53 72.14.179.5:53 72.14.188.5:53]
2022/03/31 00:54:50 [INFO] Wait for propagation [timeout: 1m0s, interval: 2s]
2022/03/31 00:54:58 [INFO] [*.example.com] The server validated our request
2022/03/31 00:54:58 [INFO] [*.example.com] acme: Cleaning DNS-01 challenge
2022/03/31 00:54:59 [INFO] [*.example.com] acme: Validations succeeded; requesting certificates
2022/03/31 00:55:00 [INFO] [*.example.com] Server responded with a certificate.
$
```

The prior files in ~/.lego/certificates were replaced with the following:

_.example.com.crt        _.example.com.issuer.crt _.example.com.json       _.example.com.key

Next step is to deploy .crt and .key to /etc/ssl as before, update
httpd.conf to refer to the new cert and key names, and retest.

```
# cp ~/.lego/certificates/_.example.com.crt /etc/ssl
# cp ~/.lego/certificates/_.example.com.key /etc/ssl/private
# rm /etc/ssl/{example.com.crt,private/example.com.key}
```

If that works for example.com and its subdomains, then re-enable
example1.com in /etc/httpd.conf and play with the settings until both
domains work.

Now that that works too, add the renewal commands to
/etc/monthly.local for example.com and *.example.com.

```
c$ DNSIMPLE_OAUTH_TOKEN=******************************** lego --email address@hidden --dns dnsimple --domains example.com renew

c$ DNSIMPLE_OAUTH_TOKEN=******************************** lego --email address@hidden --dns dnsimple --domains *.example.com renew
```

Your /etc/httpd.conf should look like this:

```
server "c.example.com" {
        listen on "c.example.com" port 80
         location * {
                block return 302 "https://$HTTP_HOST$REQUEST_URI"
        }
}

server "c.example.com" {
        listen on "c.example.com" tls port 443
        tls {
                certificate "/etc/ssl/_.example.com.crt"
                key "/etc/ssl/private/_.example.com.key"
        }
}

server "example.com" {
        listen on "example.com" port 80
         location * {
                block return 302 "https://$HTTP_HOST$REQUEST_URI"
        }
}

server "example.com" {
        listen on "example.com" tls port 443
        tls {
                certificate "/etc/ssl/example.com.crt"
                key "/etc/ssl/private/example.com.key"
        }
}

server "example1.com" {
        listen on * port 80
        location "/.well-known/acme-challenge/*" {
                root "/acme"
                request strip 2
        }
        location * {
                block return 302 "https://$HTTP_HOST$REQUEST_URI"
        }
}

server "example1.com" {
        listen on * tls port 443
		        tls {
                certificate "/etc/ssl/example1.com.fullchain.pem"
                key "/etc/ssl/private/example1.com.key"
        }
        location "/pub/*" {
                directory auto index
        }
        location "/.well-known/acme-challenge/*" {
                root "/acme"
                request strip 2
        }
        root "/example1.com"
```


The next step is to try this on another server with a second subdomain of example.com and with another standalone domain name, example2.com.

This second server will use the apache web server rather than
OpenBSD's httpd web server.

