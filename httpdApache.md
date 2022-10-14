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

It's a good idea to backup the original files, so that you can go back
to a default clean-install. For example:

```
$ cd /etc/apache2
# cp httpd2.conf httpd2.conf.orig
```

## Enable basic http before https

Edit httpd2.conf.

```
# mg httpd2.conf
```

Find the line starting with DocumentRoot using Ctrl-s or manually.
Commnet out the whole line. We'll specify the DocumentRoot in
extra/httpd-vhosts.conf.

From:
```
DocumentRoot "/var/www/htdocs"
```

To:
```
#DocumentRoot "/var/www/htdocs"
```

On the very next line, change the Directory from "/var/www/htdocs" to
"/var/www/example.com".

From:
```
<Directory "/var/www/htdocs">
```

To:
```
<Directory "/var/www/example.com">
```

Find the Include line for httpd-vhosts.conf. Uncomment the line.

From:
```
#Include /etc/apache2/extra/httpd-vhosts.conf
```

To:
```
Include /etc/apache2/extra/httpd-vhosts.conf
```

Save the file and exit. Your changes from the .orig should look like this.

```
$ diff httpd2.conf.orig httpd2.conf
248,249c248,249
< DocumentRoot "/var/www/htdocs"
< <Directory "/var/www/htdocs">
---
> #DocumentRoot "/var/www/htdocs"
> <Directory "/var/www/example.com">
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


Replace the two <VitualHost> blocks:
```
<VirtualHost *:80>
    ServerAdmin webmaster@dummy-host.example.com
    DocumentRoot "/var/www/docs/dummy-host.example.com"
    ServerName dummy-host.example.com
    ServerAlias www.dummy-host.example.com
    ErrorLog "logs/dummy-host.example.com-error_log"
    CustomLog "logs/dummy-host.example.com-access_log" common
</VirtualHost>

<VirtualHost *:80>
    ServerAdmin webmaster@dummy-host2.example.com
    DocumentRoot "/var/www/docs/dummy-host2.example.com"
    ServerName dummy-host2.example.com
    ErrorLog "logs/dummy-host2.example.com-error_log"
    CustomLog "logs/dummy-host2.example.com-access_log" common
</VirtualHost>
```

With this:
```
<VirtualHost *:80>
    DocumentRoot "/var/www/example.com"
    ServerName example.com
#    Redirect / https://example.com
</VirtualHost>
```

We'll uncomment the redirect later, after we generate our TLS
certificate for https.

Save and exit httpd-vhosts.conf.

Here are the changes we made compared to httpd-vhosts.conf.orig.

```
$ diff httpd-vhosts.conf.orig httpd-vhosts.conf
24,29c24,26
<     ServerAdmin webmaster@dummy-host.example.com
<     DocumentRoot "/var/www/docs/dummy-host.example.com"
<     ServerName dummy-host.example.com
<     ServerAlias www.dummy-host.example.com
<     ErrorLog "logs/dummy-host.example.com-error_log"
<     CustomLog "logs/dummy-host.example.com-access_log" common
---
>     DocumentRoot "/var/www/example.com"
>     ServerName example.com
> #    Redirect / https://example.com
31,41d27
< 
< <VirtualHost *:80>
<     ServerAdmin webmaster@dummy-host2.example.com
<     DocumentRoot "/var/www/docs/dummy-host2.example.com"
<     ServerName dummy-host2.example.com
<     ErrorLog "logs/dummy-host2.example.com-error_log"
<     CustomLog "logs/dummy-host2.example.com-access_log" common
< </VirtualHost>
```

the config files and test the configuration.

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

OpenBSD's built-in acme-client requires a location directive for
'.well-known/acme-challenge' in order to generate the TLS certificate.



Next steps here?
<https://www.phcomp.co.uk/Tutorials/Web-Technologies/Configure-Apache-for-Lets-Encrypt-challenge-response.html>



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
