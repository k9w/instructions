started 04-13-21

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

# cp /etc/example/acme-client.conf /etc
# cp /etc/example/httpd.conf /etc


--------


Here is what I changed from the acme-client.conf example:

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



Here is what I changed from the httpd.conf example:

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


--------


I made a simple index.html file and put it into /var/www/capernaumtech.com

Then, to test out regular http, I skiped acme-client and enabled httpd.

# rcctl enable httpd
# rcctl start httpd

It did not work because httpd.conf had the 302 redirect to https. I
commented out the redirect block in httpd.conf:

#	location * {
#		block return 302 "https://$HTTP_HOST$REQUEST_URI"
#	}

Restarted httpd:

# rcctl restart httpd

And http://capernaumtech.com loaded successfully.


Then, with sign with letsencrypt-staging, I ran the acme client to
generate the cert:

# acme-client capernaumtech.com

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

# acme-client capernaumtech.com

And re-loaded httpd:

# rcctl restart httpd

But I still got the same error in Firefox and Chromium.

Next thing to check are the .pem files in /etc/ssl and its private directory.

The timestamp on capernaumtech.com.fullchain.pem is from 45 minutes
ago when I generated the staging cert.

Perhaps it will be sufficient to remove the .pem files and rerun
acme-client. Or I might need to revoke the staging cert.

For now, I disabled and stopped httpd until I come back to it.


--------
04-14

Next step it to replace the staging cert with a production cert.

Renamed the TLS cert file in /etc/ssl and restarted httpd.

# mv capernaumtech.com.fullchain.pem capernaumtech.com.fullchain.pem-staging 
# rcctl restart httpd

Reloaded the page in the browser. The error changed from invalid cert
to site cannot be reached. This is good because it means httpd cannot
find the cert, which means we can then make the new cert in its place.

Regenerated the cert, for production this time, and restarted httpd.

# acme-client capernaumtech.com
# rcctl restart httpd

And now the page loads properly with TLS.

----

Then, automate the renewal of the cert weekly in cron.

Root's crontab runs /etc/weekly at 03:30 UTC every Saturday.
/etc/weekly runs /etc/weekly.local which is where we add the following lines.

# Renew the TLS cert for capernaumtech.com and restart httpd.
acme-client capernaumtech.com && rcctl restart httpd

----

Then, change the website root from /var/www/htdocs to
/var/www/capernaumtech.com.

# cd /var/www
# mkdir capernaumtech.com
# mv htdocs/index.html capernaumtech.com/                      
# rcctl restart httpd

----

Next, set owner:group, default set-user-id and set-group-id, and set
file and directory permissions and umask.
https://serverfault.com/questions/6895/whats-the-best-way-of-handling-permissions-for-apache-2s-user-www-data-in-var

Here is the default in /var/www:
drwxr-xr-x   2 root  daemon  512 Apr 14 03:42 capernaumtech.com

Add group write permission g+w to the existing permissions.

$ pwd
/var/www
# chmod -R g+w ./capernaumtech.com

Add your user to the daemon group.

# usermod -G daemon kevin


--------
04-16

Crista suggested the site name metabytes.com, which is taken. But
metabytesblog.com was free. So I registered it and copyed my setup for
capernaumtech.com to it and will later generate the TLS cert.

$ cd /var/www
# cp -R capernaumtech.com metabytesblog.com

capernaumtech.com/index.html had group write. But
metabytesblog.com/index.html did not have group write.

So I changed the default permissions:
# chmod 2775 /var/www/metabytesblog.com

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

