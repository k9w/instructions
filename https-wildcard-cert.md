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


<p>
# 03-27

I got an API token and tried it with lego for all subdomains of k9w.org.


$ DNSIMPLE_OAUTH_TOKEN=******************************** lego --email kevin.williams.edu@gmail.com --dns dnsimple --domains *.k9w.org run
2022/03/27 22:09:32 No key found for account kevin.williams.edu@gmail.com. Generating a P256 key.
2022/03/27 22:09:32 Saved key to /home/kevin/.lego/accounts/acme-v02.api.letsencrypt.org/kevin.williams.edu@gmail.com/keys/kevin.williams.edu@gmail.com.key
2022/03/27 22:09:32 Please review the TOS at https://letsencrypt.org/documents/LE-SA-v1.2-November-15-2017.pdf
Do you accept the TOS? Y/n
y
2022/03/27 22:10:05 [INFO] acme: Registering account for kevin.williams.edu@gmail.com
!!!! HEADS UP !!!!

Your account credentials have been saved in your Let's Encrypt
configuration directory at "/home/kevin/.lego/accounts".

You should make a secure backup of this folder now. This
configuration directory will also contain certificates and
private keys obtained from Let's Encrypt so making regular
backups of this folder is ideal.
2022/03/27 22:10:05 [INFO] [*.k9w.org] acme: Obtaining bundled SAN certificate
2022/03/27 22:10:05 [INFO] [*.k9w.org] AuthURL: https://acme-v02.api.letsencrypt.org/acme/authz-v3/92107296710
2022/03/27 22:10:05 [INFO] [*.k9w.org] acme: use dns-01 solver
2022/03/27 22:10:05 [INFO] [*.k9w.org] acme: Preparing to solve DNS-01
2022/03/27 22:10:06 [INFO] [*.k9w.org] acme: Trying to solve DNS-01
2022/03/27 22:10:06 [INFO] [*.k9w.org] acme: Checking DNS record propagation using [23.239.24.5:53 72.14.179.5:53 72.14.188.5:53]
2022/03/27 22:10:08 [INFO] Wait for propagation [timeout: 1m0s, interval: 2s]
2022/03/27 22:10:11 [INFO] [*.k9w.org] acme: Cleaning DNS-01 challenge
2022/03/27 22:10:12 [INFO] Deactivating auth: https://acme-v02.api.letsencrypt.org/acme/authz-v3/92107296710
2022/03/27 22:10:12 Could not obtain certificates:
        error: one or more domains had a problem:
[*.k9w.org] acme: error: 400 :: urn:ietf:params:acme:error:dns :: DNS problem: NXDOMAIN looking up TXT for _acme-challenge.k9w.org - check that a DNS record exists for this domain
$ 

It did not work. So I tried it again as just k9w.org, not *.k9w.org, and it worked.

$ DNSIMPLE_OAUTH_TOKEN=******************************** lego --email kevin.williams.edu@gmail.com --dns dnsimple --domains k9w.org run   
2022/03/27 22:31:36 [INFO] [k9w.org] acme: Obtaining bundled SAN certificate
2022/03/27 22:31:37 [INFO] [k9w.org] AuthURL: https://acme-v02.api.letsencrypt.org/acme/authz-v3/92113096290
2022/03/27 22:31:37 [INFO] [k9w.org] acme: Could not find solver for: tls-alpn-01
2022/03/27 22:31:37 [INFO] [k9w.org] acme: Could not find solver for: http-01
2022/03/27 22:31:37 [INFO] [k9w.org] acme: use dns-01 solver
2022/03/27 22:31:37 [INFO] [k9w.org] acme: Preparing to solve DNS-01
2022/03/27 22:31:37 [INFO] [k9w.org] acme: Trying to solve DNS-01
2022/03/27 22:31:37 [INFO] [k9w.org] acme: Checking DNS record propagation using [23.239.24.5:53 72.14.179.5:53 72.14.188.5:53]
2022/03/27 22:31:39 [INFO] Wait for propagation [timeout: 1m0s, interval: 2s]
2022/03/27 22:31:43 [INFO] [k9w.org] The server validated our request
2022/03/27 22:31:43 [INFO] [k9w.org] acme: Cleaning DNS-01 challenge
2022/03/27 22:31:44 [INFO] [k9w.org] acme: Validations succeeded; requesting certificates
2022/03/27 22:31:44 [INFO] [k9w.org] Server responded with a certificate.
$ 

Once I find out how to use the certificate on multiple servers, I need to add that same command to /etc/monthly.local with 'renew' instead of 'run'.

First thing to check is: based on the documentation at lets encrypt, dnsimple, or lego, how do I start using that cert with k9w.org and OpenBSD httpd?
