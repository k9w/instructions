# Apache webserver on OpenBSD

This guide describes how to install and configure
[Apache](https://httpd.apache.org) on [OpenBSD](https://openbsd.org).


## Installation & configuration files

Install the apache webserver from packages. 

```
# pkg_add apache-httpd
```

One of the files this installs is `/var/www/htdocs/index.html` with "It
works!"

Configuration is in /etc/apache2. This guide uses:
- httpd2.conf
- extra/httpd-vhosts.conf
- extra/httpd-ssl.conf

Backup the original files, so that you can go back to a default
clean-install.

```
$ cd /etc/apache2
# cp httpd2.conf httpd2.conf.orig
```

Some people remove all the comments, that aren't commented out code,
so they can read the file better and refer to the .orig to read the
comments when needed. I left the comments in, to make the diffs
smaller. See the [diff(1)](https://man.openbsd.org/diff) command
below.


## Enable basic http before https

Edit httpd2.conf.

```
# mg httpd2.conf
```

Comment out the `DocumentRoot` and the `<Directory "/var/www/htdocs">`
block, including any uncommented lines and the closing `</Directory>` tag.

```
#DocumentRoot "/var/www/htdocs"
#<Directory "/var/www/htdocs">

...

#    Options Indexes FollowSymLinks

...

#    AllowOverride None

...

#    Require all granted
#</Directory>
```

We'll specify them for each site later in httpd-vhosts.conf.

Uncomment the `Include` line for httpd-vhosts.conf.

```
Include /etc/apache2/extra/httpd-vhosts.conf
```

Save the file and exit.

Throughout this setup, and for later review, you can compare the
differences in your file from the original using the
[diff(1)](https://man.openbsd.org/diff) command.  It is best practice
to specify the original file as the first argument to diff, and your
modified file second. That way, the differences on the left `<` are
the original, and the differences on the right `>` are your changes.

```
$ diff httpd2.conf.orig httpd2.conf 
248,249c248,249
< DocumentRoot "/var/www/htdocs"
< <Directory "/var/www/htdocs">
---
> #DocumentRoot "/var/www/htdocs"
> #<Directory "/var/www/htdocs">
262c262
<     Options Indexes FollowSymLinks
---
> #    Options Indexes FollowSymLinks
269c269
<     AllowOverride None
---
> #    AllowOverride None
274,275c274,275
<     Require all granted
< </Directory>
---
> #    Require all granted
> #</Directory>
507c507
< #Include /etc/apache2/extra/httpd-vhosts.conf
---
> Include /etc/apache2/extra/httpd-vhosts.conf
```


Next, edit extra/httpd-vhosts.conf.

```
$ cd /etc/apache2/extra
# mg httpd-vhosts.conf
```


Remove the two `<VitualHost>` blocks.

Add a `<VirtualHost>` block containing a `<Directory>` block with the
same options you commented out from httpd2.conf.

Also add a `Redirect` statement for https and comment it out for now.

```
<VirtualHost *:80>
    DocumentRoot "/var/www/example.com"
    ServerName example.com
    <Directory "/var/www/example.com">
	Options Indexes FollowSymLinks
	AllowOverride None
	Require all granted
    </Directory>
#    Redirect / https://example.com
</VirtualHost>
```

Between the `ServerName` and `<Directory>` block, add an `Alias` and a
seocnd `<Directory>` block.

The `Alias` directive specifies the `.well-known/acme-challenge` folder
to  `/var/www/acme/.well-known/acme-challenge` needed by Let's Encrypt
to issue a TLS certificate.

```
    Alias /.well-known/acme-challenge /var/www/acme/.well-known/acme-challenge
    <Directory "/var/www/acme/.well-known/acme-challenge">
	Options None
	AllowOverride None
	ForceType text/plain
	RedirectMatch 404 "^(?!/\.well-known/acme-challenge/[\w-]{43}$)"
	Require all granted
    </Directory>

```

We'll uncomment the `Redirect` later, after we generate our TLS
certificate for https.

Save and exit httpd-vhosts.conf.


[10-23-22 not working yet]



Here are the changes we made compared to httpd-vhosts.conf.orig.

```
$ diff httpd-vhosts.conf.orig httpd-vhost.conf
diff: httpd-vhost.conf: No such file or directory
b$ diff httpd-vhosts.conf.orig httpd-vhosts.conf
24,29c24,31
<     ServerAdmin webmaster@dummy-host.example.com
<     DocumentRoot "/var/www/docs/dummy-host.example.com"
<     ServerName dummy-host.example.com
<     ServerAlias www.dummy-host.example.com
<     ErrorLog "logs/dummy-host.example.com-error_log"
<     CustomLog "logs/dummy-host.example.com-access_log" common
---
>     DocumentRoot "/var/www/example.com"
>     ServerName example.com
>     <Directory "/var/www/example.com">
>       Options Indexes FollowSymLinks
>       AllowOverride None
>       Require all granted
>     </Directory>
> #    Redirect / https://example.com
31,41d32
< 
< <VirtualHost *:80>
<     ServerAdmin webmaster@dummy-host2.example.com
<     DocumentRoot "/var/www/docs/dummy-host2.example.com"
<     ServerName dummy-host2.example.com
<     ErrorLog "logs/dummy-host2.example.com-error_log"
<     CustomLog "logs/dummy-host2.example.com-access_log" common
< </VirtualHost>
```

We are ready to serve the site with basic http.

Test the configuration.

```
$ httpd2 -t
Syntax OK
```

Enable and start Apache

```
# rcctl enable apache2
# rcctl start apache2
```


## Generate your TLS certificate

OpenBSD's built-in acme-client requires a location directive in nginx
and OpenBSD's httpd for '.well-known/acme-challenge' in order to
generate the TLS certificate. Apache allows hidden directories by
default and does not need such an explicit directive.

With the setup above, generating the TLS cert should just work.

```
# acme-client -v example.com
```


## Enable https

Now that we have our TLS certificate, we need to:
- Edit httpd2.conf to Load the SSL and Rewrite modulse and Include
  extra/httpd-ssl.conf
- Edit extra/httpd-ssl.conf to point to our TLS cert and key
- Restart the apache service to load the changes

Edit httpd2.conf.

Load the ssl module to to enable https.
```
LoadModule ssl_module /usr/local/lib/apache2/mod_ssl.so
```

To enable redirecting http to https.
```
LoadModule rewrite_module /usr/local/lib/apache2/mod_rewrite.so
```

This included file will hold the https port 443 configuration.
```
Include /etc/apache2/extra/httpd-ssl.conf
```

Save the file.

Edit extra/httpd-ssl.conf.

Comment out SSLSessionCache. (It gave me an error with it active.)
```
#SSLSessionCache        "shmcb:/var/www/logs/ssl_scache(512000)"
```

Otherwise, you'll get this error.
```
$ httpd2 -t
AH00526: Syntax error on line 92 of /etc/apache2/extra/httpd-ssl.conf:
SSLSessionCache: 'shmcb' session cache not supported (known names: ).
Maybe you need to load the appropriate socache module (mod_socache_shmcb?).
```

Set SSLCertificateFile and KeyFile to the location of your wildcard
certificae files.

```
SSLCertificateFile "/etc/ssl/example.com.crt"
```

```
SSLCertificateKeyFile "/etc/ssl/private/example.com.key"
```


Restart the server.

```
# apachectl graceful
```

Here are the changes we made to extra/httpd-ssl.conf

```
$ diff httpd-ssl.conf.orig httpd-ssl.conf
92c92
< SSLSessionCache        "shmcb:/var/www/logs/ssl_scache(512000)"
---
> #SSLSessionCache        "shmcb:/var/www/logs/ssl_scache(512000)"
144c144
< SSLCertificateFile "/etc/apache2/server.crt"
---
> SSLCertificateFile "/etc/ssl/example.com.crt"
154c154
< SSLCertificateKeyFile "/etc/apache2/server.key"
---
> SSLCertificateKeyFile "/etc/ssl/private/example.com.key"
```


Note that starting apache with doas does not let it see into
/etc/ssl/private and the certificate key therein. It needs to be started
as root, not with doas.

The page should display now.


## Command invocation and a deeper look at what's installed

httpd2 and apachectl are the two main commands. I haven't referenced
apachectl because rcctl * apache2 is just a wrapper around apachectl.

```
$ which apachectl
/usr/local/sbin/apachectl
$ which apachectl2
/usr/local/sbin/apachectl2
$ ls -al /usr/local/sbin/apachectl*
-rwxr-xr-x  1 root  bin    3470 Oct  8 15:09 /usr/local/sbin/apachectl
lrwxr-xr-x  1 root  wheel     9 Oct 11 06:53 /usr/local/sbin/apachectl2
-> apachectl
$ which httpd2
/usr/local/sbin/httpd2
$ ls -al /usr/local/sbin/httpd2
-rwxr-xr-x  1 root  bin  988577 Oct  8 15:12 /usr/local/sbin/httpd2
$ rcctl ls all | grep apache
apache2
$ ls -al /etc/rc.d/apache2 
-rwxr-xr-x  1 root  bin  295 Oct  8 15:12 /etc/rc.d/apache2
$ cat /etc/rc.d/apache2
#!/bin/ksh

daemon="/usr/local/sbin/httpd2"

. /etc/rc.d/rc.subr

# mod_perl resets $0 to argv[0]
pexp=".*${daemon}.*"
rc_reload=NO

rc_start() {
        rc_exec "/usr/local/sbin/apachectl2 graceful ${daemon_flags}"
}
	
rc_stop() {
        /usr/local/sbin/apachectl2 graceful-stop ${daemon_flags}
}

rc_cmd $1
```

The package also installs other executables, and manpages for each.

You can see the full list of files installed with apache-httpd with:
```
$ pkg_info -f apache-httpd | less
```
Some highlights:

Headers and modules are installed to:
- `/usr/local/include/apache2`
- `/usr/local/lib/apache2`
- `/usr/local/share/examples/apache2` - has same files in `/etc/apache2` and more
- `/usr/local/share/doc/apache2` mirors docs site from
<https://httpd.apache.org/docs/2.4> 
- `/var/www/error`
- `/var/www/htdocs`
- `/var/www/icons`


Reference:
<https://httpd.apache.org/docs/2.4/mod/quickreference.html>
<https://httpd.apache.org/docs/2.4/ssl/ssl_howto.html>
<https://community.letsencrypt.org/t/recommended-apache-config/58294/2>
<https://doc.owncloud.com/server/next/admin_manual/installation/letsencrypt/apache.html#lets-encrypt-acme-challenge>

