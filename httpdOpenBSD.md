# 04-13-2021

Host a website on OpenBSD's httpd webserver and configure a TLS
certificate for https on it with acme-client, both in the base system.


First site is static files with OpenBSD httpd, acme-client, and
ideally a wildcard certificate.

Some notes found at:
https://blog.lambda.cx/posts/letsencrypt-on-openbsd

Currently, acme-client does not support wildcard certificates.
https://serverfault.com/questions/1040803/acquiring-a-wildcard-certificate-from-lets-encrypt-via-acme-client1
https://www.reddit.com/r/openbsd/comments/l2ovm5/wildcard_lets_encrypt_certificates

I intend to use k9w.org with a wildcard certificate for use across
several servers. I will save *.k9w.org for my second website and use
certbot to get and manage the Lets Encrypt wildcard certificate.

But for this first website using OpenBSD httpd and acme-client, I will
use capernaumtech.com and no subdomains, unless the non-wildcard cert
works with subdomains anyway.

Copy example conf files for acme-client and httpd.

```
# cp /etc/example/acme-client.conf /etc
# cp /etc/example/httpd.conf /etc
```

--------


Here is what I changed from the acme-client.conf example:

```
$ diff -u ./examples/acme-client.conf acme-client.conf  
--- ./examples/acme-client.conf Sat Mar 20 06:20:35 2021
+++ acme-client.conf    Tue Apr 13 05:07:22 2021
@@ -14,18 +14,18 @@
 authority buypass {
        api url "https://api.buypass.com/acme/directory"
        account key "/etc/acme/buypass-privkey.pem"
-       contact "mailto:me@example.com"
+       contact "mailto:kevin@k9w.org"
 }
 
 authority buypass-test {
        api url "https://api.test4.buypass.no/acme/directory"
        account key "/etc/acme/buypass-test-privkey.pem"
-       contact "mailto:me@example.com"
+       contact "mailto:kevin@k9w.org"
 }
 
-domain example.com {
-       alternative names { secure.example.com }
-       domain key "/etc/ssl/private/example.com.key"
-       domain full chain certificate "/etc/ssl/example.com.fullchain.pem"
-       sign with letsencrypt
+domain capernaumtech.com {
+       alternative names { www.capernaumtech.com
test.capernaumtech.com }
+       domain key "/etc/ssl/private/capernaumtech.com.key"
+       domain full chain certificate "/etc/ssl/capernaumtech.com.fullchain.pem"
+       sign with letsencrypt-staging
 }
```


Here is what I changed from the httpd.conf example:

```
$ diff -u ./examples/httpd.conf httpd.conf              
--- ./examples/httpd.conf       Sat Mar 20 06:20:35 2021
+++ httpd.conf  Tue Apr 13 05:36:56 2021
@@ -1,6 +1,6 @@
 # $OpenBSD: httpd.conf,v 1.22 2020/11/04 10:34:18 denis Exp $
 
-server "example.com" {
+server "capernaumtech.com" {
	listen on * port 80
	location "/.well-known/acme-challenge/*" {
		root "/acme"
@@ -11,11 +11,11 @@
	}
 }
 
-server "example.com" {
+server "capernaumtech.com" {
	listen on * tls port 443
	tls {
-		certificate "/etc/ssl/example.com.fullchain.pem"
-		key "/etc/ssl/private/example.com.key"
+		certificate "/etc/ssl/capernaumtech.com.fullchain.pem"
+		key "/etc/ssl/private/capernaumtech.com.key"
	}
	location "/pub/*" {
		directory auto index
```

--------


I made a simple index.html file and put it into /var/www/capernaumtech.com

Then, to test out regular http, I skiped acme-client and enabled httpd.

```
# rcctl enable httpd
# rcctl start httpd
```

It did not work because httpd.conf had the 302 redirect to https. I
commented out the redirect block in httpd.conf:

```
#	location * {
#		block return 302 "https://$HTTP_HOST$REQUEST_URI"
#	}
```

Restarted httpd:

```
# rcctl restart httpd
```

And http://capernaumtech.com loaded successfully.


Then, with sign with letsencrypt-staging, I ran the acme client to
generate the cert:

```
# acme-client capernaumtech.com
```

In Firefox, that successfully redirected capernaumtech.com to
https://capernaumtech.com.

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
# acme-client capernaumtech.com
```

And re-loaded httpd:

```
# rcctl restart httpd
```

But I still got the same error in Firefox and Chromium.

Next thing to check are the .pem files in /etc/ssl and its private directory.

The timestamp on capernaumtech.com.fullchain.pem is from 45 minutes
ago when I generated the staging cert.

Perhaps it will be sufficient to remove the .pem files and rerun
acme-client. Or I might need to revoke the staging cert.

For now, I disabled and stopped httpd until I come back to it.


<p>
# 04-14

Next step it to replace the staging cert with a production cert.

Renamed the TLS cert file in /etc/ssl and restarted httpd.

```
# mv capernaumtech.com.fullchain.pem capernaumtech.com.fullchain.pem-staging 
# rcctl restart httpd
```

Reloaded the page in the browser. The error changed from invalid cert
to site cannot be reached. This is good because it means httpd cannot
find the cert, which means we can then make the new cert in its place.

Regenerated the cert, for production this time, and restarted httpd.

```
# acme-client capernaumtech.com
# rcctl restart httpd
```

And now the page loads properly with TLS.

----

Then, automate the renewal of the cert weekly in cron.

Root's crontab runs /etc/weekly at 03:30 UTC every Saturday.
/etc/weekly runs /etc/weekly.local which is where we add the following lines.

```
# Renew the TLS cert for capernaumtech.com and restart httpd.
acme-client capernaumtech.com && rcctl restart httpd
```

----

Then, change the website root from /var/www/htdocs to
/var/www/capernaumtech.com.

```
# cd /var/www
# mkdir capernaumtech.com
# mv htdocs/index.html capernaumtech.com/
# rcctl restart httpd
```

----

Next, set owner:group, default set-user-id and set-group-id, and set
file and directory permissions and umask.
https://serverfault.com/questions/6895/whats-the-best-way-of-handling-permissions-for-apache-2s-user-www-data-in-var

Here is the default in /var/www:
drwxr-xr-x   2 root  daemon  512 Apr 14 03:42 capernaumtech.com

Add group write permission g+w to the existing permissions.

```
$ pwd
/var/www
# chmod -R g+w ./capernaumtech.com
```

Add your user to the daemon group.

```
# usermod -G daemon kevin
```


<p>
# 04-16-2021

Crista suggested the site name metabytes.com, which is taken. But
metabytesblog.com was free. So I registered it and copyed my setup for
capernaumtech.com to it and will later generate the TLS cert.

```
$ cd /var/www
# cp -R capernaumtech.com metabytesblog.com
```

capernaumtech.com/index.html had group write. But
metabytesblog.com/index.html did not have group write.

So I changed the default permissions:

```
# chmod 2775 /var/www/metabytesblog.com
```

But the permissions are not working.

/etc/acme-client

----

Then, import the site and conf files into git.

Then setup replication with rsync, which is not a backup since it only
keeps the current copy. 

Then you can start in on learning HTML, CSS, and adding content to the site.

For now, just sync down to your laptop and then up to Github or other
location. Later, create an SSH key for automation and lock it down to a
specific git command or other method in MWL's SSH Mastery book.


<p>
# 03-17-2022

OpenBSD's acme-client only supports the http-01 challenge, not the
dns-01 challenge for a wildcard certificate.

Here is how to move the site, cert, and private key, from one server
to another, with $siteName equaling your domain, such as k9w.org

Here is the list of folders to backup.

/etc/acme/*
/etc/acme-client.conf
/etc/httpd.conf
/etc/monthly.local
/etc/ssl/$siteName.fullchain.pem
/etc/ssl/private/$siteName.key
/var/www/capernaumtech.com/*

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

(continue the re-work from here)

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
$ cat /etc/acme-clent.conf
```

```
server "metabytesblog.com" {
	listen on "metabytesblog.com" port 80
	root "/metabytesblog.com"
	location "/.well-known/acme-challenge/*" {
		root "/acme"
		request strip 2
	}
	location * {
		block return 302 "https://$HTTP_HOST$REQUEST_URI"
	}
}

server "metabytesblog.com" {
	listen on "metabytesblog.com" tls port 443
	root "/metabytesblog.com"
	tls {
		certificate "/etc/ssl/metabytesblog.com.crt"
		key "/etc/ssl/private/metabytesblog.com.key"
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

domain metabytesblog.com {
	alternative names { www.metabytesblog.com }
	domain key "/etc/ssl/private/metabytesblog.com.key" ecdsa
	domain certificate "/etc/ssl/metabytesblog.com.crt"
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



```
a$ doas acme-client -v metabytesblog.com
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
acme-client: /etc/ssl/metabytesblog.com.crt: created
```
