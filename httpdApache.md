04-11-22

Install the apache webserver. The commands and file paths assume
you use OpenBSD.

```
# pkg_add apache-httpd
```

One of the files this installs is /var/www/htdocs/index.html with 'It
works!'

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

Optionally, remove all the comments, that aren't commented out code, so
that you can read the file better. You can refer to the .orig to read
the comments when needed.


## Enable basic http before https

Edit httpd2.conf.

```
# mg httpd2.conf
```

Comment out the DocumentRoot and the <Directory "/var/www/htdocs"> block.

We'll specify them both for each site later in httpd-vhosts.conf.

Uncomment the Include line for httpd-vhosts.conf.

Save the file and exit.

Throughout this setup, and for later review, you can compare the
differences in your file from the original using the diff(1) command.
It is best practice to specify the original file as the first argument
to diff, and your modified file second. That way, the differences on
the left (<) are the original, and the differences on the right (>)
are your changes.

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

Add your own `<VirtualHost>` block containing a `<Directory>` block
with the same options you commented out from httpd2.conf. Also add a
redirect statement for https and comment it out for now.

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

We'll uncomment the redirect later, after we generate our TLS
certificate for https.

Save and exit httpd-vhosts.conf.

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

## Enable and start Apache

```
# rcctl enable apache2
# rcctl start apache2
```


## Generate your TLS certificate

OpenBSD's built-in acme-client requires a location directive in nginx
and OpenBSD's httpd for '.well-known/acme-challenge' in order to
generate the TLS certificate. Apache allows hidden directories by
default and does not need such an explicit directive.



## Enable https

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



In ```/etc/apache2/extra/httpd-ssl.conf```

Comment out SSLSessionCache. (It gave me an error with it active.)
```
#SSLSessionCache        "shmcb:/var/www/logs/ssl_scache(512000)"
```

Set SSLCertificateFile and KeyFile to the location of your wildcard
certificae files.

```
SSLCertificateFile "/etc/ssl/example.com.crt"
```

```
SSLCertificateKeyFile "/etc/ssl/private/example.com.key"
```


Start the server.

```
# apachectl start
```

Note that starting apache with doas does not let it see into
/etc/ssl/private and the certificate key therein. It needs to be started
as root, not with doas.

The page should display now.

Reference:
https://httpd.apache.org/docs/2.4/mod/quickreference.html
https://httpd.apache.org/docs/2.4/ssl/ssl_howto.html
https://community.letsencrypt.org/t/recommended-apache-config/58294/2
