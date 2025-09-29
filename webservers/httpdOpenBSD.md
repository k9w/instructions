# OpenBSD's httpd webserver

[OpenBSD](https://openbsd.org)'s
[httpd](https://man.openbsd.org/httpd) is a lightweight webserver
application similar to [Apache](httpdApache.md),
[Nginx](httpdNginx.md), [Caddy](httpdCaddy.md),
[Lighttpd](httpdLighttpd.md) and others.

## Starting and Stopping

Check if httpd is already running.

```
# rcctl check httpd
httpd(ok)
```

Enable and start httpd.

```
# rcctl enable httpd
# rcctl start httpd
httpd(ok)
```

Reload httpd to apply new configuration from httpd.conf.

```
# rcctl reload httpd
httpd(ok)
```

Restart httpd entirely.

```
$ doas rcctl restart httpd
httpd(ok)
httpd(ok)
```

Stop and disable httpd.

```
# rcctl stop httpd
httpd(ok)
# rcctl disable httpd
```

## Configuration

### Localhost or IP address only

OpenBSD httpd requires
[/etc/httpd.conf](https://man.openbsd.org/httpd.conf) to exist and
contain at least one server \{\} block and listen address.

Listen for requests to any address or name on network interface `vio0`
on http port 80 and serve content from default root folder
`/var/www/htdocs`.

```
server "vio0" {
        listen on * port 80
}
```

Listen only on local loopback IP address `127.0.0.1` on http port 80
with folder `/` in the www chroot, which is `/var/www`.

```
server 127.0.0.1 {
        listen on * port 80
        root '/'
}
```

### Set a test page

The default www root `/var/www/htdocs` is read and execute by group
`daemon` and writable by root.

Add your user to the `daemon` group.

```
# usermod -G daemon username
```

Logout standard user and back in to apply the group membership.

Add write permission to `daemon` group for `/var/www/htdocs`.

```
# chmod -R 775 /var/www/htdocs
```

Add an index file with any text. No HTML is needed for this
simple test.

```
$ echo Test > /var/www/htdocs/index.html
```

If httpd is already running, there's no need to reload it.

Navigate to the IP address in your browser to see the test page.


### Production setup with DNS and TLS

Login to your domain registrar or DNS provider and point an A record for your
domain the correct IP address. Set a separate A record for each
subdomain you want covered by TLS later.

Example configs for `httpd.conf` and `acme-client.conf` are available
at `/etc/examples`.

Serve & listen on domain name `example.com` port 80 with root folder
`/var/www/example.com`.

```
server 'example.com' {
	    listen on 'example.com' port 80
		root '/example.com'
}
```

(The examples in the rest of this guide assume you have set the
permissions for `/var/www/example.com` like described above for
`/var/www/htdocs` and populated a test `index.html`.)


06-20-2025 - This works. But it's not clear to me how to quickly
remove the web serving even with commenting out all httpd.conf and
stopping the service. Removing the A record worked.


This example has three websites:
- example.com
- foobar.org
- www.foobar.org

The port 80 server block for each site redirects to a port 443 block
right below it.


```
$ cat /etc/httpd.conf
server "example.com" {
        listen on "example.com" port 80
        root "/example.com"
        location "/.well-known/acme-challenge/*" {
                root "/acme"
                request strip 2
        }
        location * {
                block return 302 "https://$HTTP_HOST$REQUEST_URI"
        }
}

server "example.com" {
        listen on "example.com" tls port 443
        root "/example.com"
        tls {
                certificate "/etc/ssl/example.com.crt"
                key "/etc/ssl/private/example.com.key"
        }
}

server "foobar.org" {
        listen on "foobar.org" port 80
        alias "www.foobar.org"
        root "/foobar.org"
        location "/.well-known/acme-challenge/*" {
                root "/acme"
                request strip 2
        }
        location * {
                block return 302 "https://$HTTP_HOST$REQUEST_URI"
        }
}

server "foobar.org" {
        listen on "foobar.org" tls port 443
        root "/foobar.org"
        tls {
                certificate "/etc/ssl/foobar.org.crt"
                key "/etc/ssl/private/foobar.org.key"
        }
}
```

## acme-client to fetch TLS certificates for https

OpenBSD uses [acme-client](https://man.openbsd.org/acme-client) to
fetch TLS certificates for secure https. It is configured with
[acme-client.conf](https://man.openbsd.org/acme-client.conf).

acme-client and https are generally not required for local web
development on your own machine or internal network. This guide for
acme-client only addresses typical setup for an internet-facing
webserver.

### Configuration

You can copy and adapt the example config file for acme-client to your
needs..

```
# cp /etc/example/acme-client.conf /etc
```

The production example below fetches TLS certificates for the domains
listed in httpd.conf earlier in this guide. acme-client only supports
the http-01 challenge, not the dns-01 challenge for a wildcard
certificate. So a unique cert is needed for each domain and each
subdomain.

```
$ cat /etc/acme-client.conf
authority letsencrypt {
        api url "https://acme-v02.api.letsencrypt.org/directory"
        account key "/etc/acme/letsencrypt-privkey.pem" ecdsa
}

domain example.com {
        domain key "/etc/ssl/private/example.com.key" ecdsa
        domain certificate "/etc/ssl/example.com.crt"
        sign with letsencrypt
}

domain foobar.org {
        alternative names { www.foobar.org }
        domain key "/etc/ssl/private/foobar.org.key" ecdsa
        domain certificate "/etc/ssl/foobar.org.crt"
        sign with letsencrypt
}
```

### Getting the cert for the first time


The acme protocol used by Let's Encrypt and other providers requires
the website to be reachable with standard http as part of validating
the domain belongs to you to issue a TLS certificate to you.

Make a simple index.html file and put it into /var/www and the folder
for each website, such as /var/www/example.com.

Standard http won't work as is because our port 80 server block in
httpd.conf redirects to https, which won't work yet before we get the
cert.

For each port 80 server block in httpd.conf, comment out the location
block redirecting to https 443.

```
#	location * {
#		block return 302 "https://$HTTP_HOST$REQUEST_URI"
#	}
```

Reload httpd for it to re-read its config.

```
# rcctl reload httpd
```

Test each website with standard http.

http://example.com

If each site loads successfully, you're ready to try fetching the TLS
certificate from the iussuer.

```
# acme-client -v example.com
```

-v is optional and gives verbose detail like below, which shows a
successfull first-time registration.

```
acme-client: https://acme-v02.api.letsencrypt.org/directory: directories
acme-client: acme-v02.api.letsencrypt.org: DNS: 172.65.32.248
acme-client: dochngreq: https://acme-v02.api.letsencrypt.org/acme/authz-v3/160169565936
acme-client: challenge, token: HbDBXzzBCHABm0E4r34nkOddY-Z25OM1elibl_9f4Dc, uri: https://acme-v02.api.letsencrypt.org/acme/chall-v3/160169565936/1vDAqg, status: 0
acme-client: /var/www/acme/HbDBXzzBCHABm0E4r34nkOddY-Z25OM1elibl_9f4Dc: created
acme-client: dochngreq: https://acme-v02.api.letsencrypt.org/acme/authz-v3/160169565946
acme-client: challenge, token: nGVVQrZo37-w9yqlNRw5YbuI6DZNQV_jKCmSu8A1Xn0, uri: https://acme-v02.api.letsencrypt.org/acme/chall-v3/160169565946/o4rZDQ, status: 0
acme-client: /var/www/acme/nGVVQrZo37-w9yqlNRw5YbuI6DZNQV_jKCmSu8A1Xn0: created
acme-client: https://acme-v02.api.letsencrypt.org/acme/chall-v3/160169565936/1vDAqg: challenge
acme-client: https://acme-v02.api.letsencrypt.org/acme/chall-v3/160169565946/o4rZDQ: challenge
acme-client: order.status 1
acme-client: https://acme-v02.api.letsencrypt.org/acme/finalize/119176435/130997223986: certificate
acme-client: order.status 3
acme-client: https://acme-v02.api.letsencrypt.org/acme/cert/042629603e4e38b7833d1ec06b9f96f422f5: certificate
acme-client: /etc/ssl/example.com.crt: created
```

If you have problems, see the Troubleshooting section below.

### Automate the cert renewal with cron

Make a script to fetch or renew the certs with acme-client, and then
reload httpd.

```
# cat /root/bin/tls-renew.sh
#!/bin/sh

for i in \
  example.com \
  foobar.org 
#  barbaz.org 
do acme-client -vv "$i";
done

rcctl reload httpd
```

Make it executable.

```
# chmod 744 /root/bin/tls-renew.sh
```

Run the script weekly with cron.

```
$ cat /etc/weekly.local
/root/bin/tls-renew.sh
```

## Web content folder

OpenBSD, other BSDs, and Linux generally put web content in
/var/www. Put each website into its own subfolder, even if you host
only one site, and title the folder after the website domain name.

### Optionally allow write to web folder by non-root user

Web content for example.com would be at /var/www/example.com.

If you want to write files to /var/www as a regular user without root
or doas, change the permissions for each website subfolder to allow
it.

Check the default owner, group and their permissions for /var/www.

```
$ ls -al /var
drwxr-xr-x  10 root  daemon     512 Oct 10 07:41 www
```

The group and others cannot write to /var/www, only root.

Add group write permission g+w to the existing permissions.

```
$ pwd
/var/www
# chmod -R g+w ./example.com
```

Add your user to the daemon group.

```
# usermod -G daemon <user>
```

Next, set default set-user-id and set-group-id, and umask.


## Backup and restore site content, config, and cert

Here is how to move the site, cert, and private key, from one server
to another, with $siteName equaling your domain, such as k9w.org

Here is the list of folders to backup.

/etc/acme/*
/etc/acme-client.conf
/etc/httpd.conf
/etc/monthly.local
/etc/ssl/$siteName.fullchain.pem
/etc/ssl/private/$siteName.key
/var/www/example.com/*

First, use doas or root to copy all the files and folders above to a
backup folder in your home directory.

Make a backup folder.

```
$ pwd
/home/<user>
$ mkdir backup-$siteName && cd backup-$siteName
$ mkdir -p etc/ssl
$ mkdir -p var/www
```

Use doas or root to copy all the files. Replace $siteName below with your domain name, or set it as a variable.

```
# export siteName=<your-site-name>
# echo $siteName
# cp -r /etc/{acme,acme-client.conf,httpd.conf,monthly.local} etc
# cp -r /etc/ssl/{$siteName.fullchain.pem,private} etc/ssl
# cp -r /var/www/$siteName var/www
```

Change the owner of the .pem private key files in etc/acme from root
to your username. Otherwise, they will not be copied in the following
steps. (We'll reset or double-check the permissions and owner:group
later.)

```
# chown -R <user> etc/acme
```

Let's assume you'll copy the site files from the old server to the new
server by sftp-ing the backup folder from the old server to your
laptop, and then sftp the folder up to the new server.

```
$ sftp <old-server>
sftp> get -r <backup-folder>
sftp> exit
$ sftp <new-server>
sftp> put -r <backup-folder>
sftp> exit
```

At this point, it's a good idea to delete the backup folder on the old
server. This is because we left the .pem private keys in an unsecured
state by switching their owner from root to your user account for the
copying. Now that the copying is done, the backup folder should be
deleted. If something goes wrong and you need to copy it again, you
can use the copy stored on your local laptop (and back that up
somewhere secured if you like).

Now on the new server, we need to fix the permissions and owner:group.

For etc, the correct permissions likely were preserved. The
owner:group needs to be changed back to root:wheel for all of etc's
files and folders. (Note that some files and folders in /etc have
group names of 'operator' or 'bin'. Be sure to change only the files
in this etc directory and not all the files in your production /etc
folder.)

```
$ cd ~/<backup-folder>
# chown -R root:wheel etc/*
```

If permissions were not preserved, set acme folder to:
drwx------ (700)
And the .pem private key files in it to:
-rw------- (600)

```
# chmod 700 etc/acme
# chmod 600 etc/acme/*
```

For the rest of these files in etc, set the permissions to:
-rw-r--r-- (644)

```
# chmod 644 etc/{acme-client.conf,httpd.conf,monthly.local}
```

For var, only the www folder and all files and folders in it should
have owner:group of root:daemon, not the var folder itself or any
other folders not in www.

```
$ cd ~/<backup-folder>
# chown -R root:daemon var/www
```

If permissions were not preserved, set var/www recursively to:
drwxr-xr-x (755)
And the site files/folders in $siteName (not the site folder itself)
to not executable:
-rw-r--r-- (644)

```
# chmod -R 755 var/www
# chmod -R 644 var/www/$siteName/*
```

Next steps are to copy the files into place.

```
# cp -R etc/* /etc
# cp -R var/* /var
```

(continue working here)
comment out the redirect from 80 to 443, so that you can test with ip address
:port80.


Start the webserver and acme-client services.

```
# rcctl check {httpd,acme-client}
# rcctl enable {httpd,acme-client}
# rcctl start {httpd,acme-client}
```

If successfull, revert httpd.conf to restore the 443 redirect. Go to
your DNS provider and switch that domain name from the old server IP
address to the new one.

Run acme-client to get the fresh cert. That way you don't have to wait
until the next time cron runs it from /etc/monthly.local.

```
# acme-client $siteName
```

Wait for the TTL (usually one hour) and confirm the site loads with
https in the browser.


```
$ cat /etc/httpd.conf
```

```
server "example.com" {
	listen on "example.com" port 80
	root "/example.com"
	location "/.well-known/acme-challenge/*" {
		root "/acme"
		request strip 2
	}
	location * {
		block return 302 "https://$HTTP_HOST$REQUEST_URI"
	}
}

server "example.com" {
	listen on "example.com" tls port 443
	root "/example.com"
	tls {
		certificate "/etc/ssl/example.com.crt"
		key "/etc/ssl/private/example.com.key"
	}
}
```


```
$ cat /etc/acme-client.conf
```

```
authority letsencrypt {
	api url "https://acme-v02.api.letsencrypt.org/directory"
	account key "/etc/acme/letsencrypt-privkey.pem"
}

domain example.com {
	alternative names { www.example.com }
	domain key "/etc/ssl/private/example.com.key" ecdsa
	domain certificate "/etc/ssl/example.com.crt"
	sign with letsencrypt
}
```

Enable httpd to auto-start at boot time. Without it enabled, you'd
also have to specify the -f flag to manually start it too.

```
# rcctl enable httpd
```

Manually run httpd with debugging to see why it won't start.

```
# httpd -d
```

## Troubleshooting

### After successful staging, fetching the real cert fails

In Firefox, that successfully redirected example.com to
https://example.com.

But Firefox threw error code: SEC_ERROR_UNKNOWN_ISSUER

I examined the certificate in the browser and found it complained
because it was issued by letsencrypt-staging, not letsencrypt.

This means I am next ready to generate the cert in production.

----

In /etc/acme-client.conf, I changed this:

-	sign with letsencrypt-staging
+	sign with letsencrypt

Re-ran acme-client:

```
# acme-client example.com
```

And re-loaded httpd:

```
# rcctl restart httpd
```

But I still got the same error in Firefox and Chromium.

Next thing to check are the .pem files in /etc/ssl and its private directory.

The timestamp on example.com.fullchain.pem is from 45 minutes
ago when I generated the staging cert.

Perhaps it will be sufficient to remove the .pem files and rerun
acme-client. Or I might need to revoke the staging cert.

For now, I disabled and stopped httpd until I come back to it.

Next step it to replace the staging cert with a production cert.

Renamed the TLS cert file in /etc/ssl and restarted httpd.

```
# mv example.com.fullchain.pem example.com.fullchain.pem-staging 
# rcctl restart httpd
```

Reloaded the page in the browser. The error changed from invalid cert
to site cannot be reached. This is good because it means httpd cannot
find the cert, which means we can then make the new cert in its place.

Regenerated the cert, for production this time, and restarted httpd.

```
# acme-client example.com
# rcctl restart httpd
```

And now the page loads properly with TLS.


## See Also

[Let's Encrypt on OpenBSD](https://blog.lambda.cx/posts/letsencrypt-on-openbsd)

[acme-client does not support wildcard certificates.](https://serverfault.com/questions/1040803/acquiring-a-wildcard-certificate-from-lets-encrypt-via-acme-client1)
* <https://www.reddit.com/r/openbsd/comments/l2ovm5/wildcard_lets_encrypt_certificates>

[Web content folder permissions](https://serverfault.com/questions/6895/whats-the-best-way-of-handling-permissions-for-apache-2s-user-www-data-in-var)

