04-11-22

Install the apache webserver. The commands and file paths assume
you use OpenBSD.

```
# pkg_add apache-httpd
```

One of the files this installs is /var/www/htdocs/index.html with 'It
works!'


Let's assume you already have an A record at your DNS provider for
example.com pointing to your server's IP address and that Apache has
permission from the operating system kernel and cloud provider to
listen on ports 80 and 443.

In ```/etc/apache2/httpd2.conf```, uncomment the following lines.

To enable https:
```
LoadModule ssl_module /usr/local/lib/apache2/mod_ssl.so
```

To enable redirecting http to https.
```
LoadModule rewrite_module /usr/local/lib/apache2/mod_rewrite.so
```

This included file will hold the http port 80 configuration.
```
Include /etc/apache2/extra/httpd-vhosts.conf
```

This included file will hold the https port 443 configuration.
```
Include /etc/apache2/extra/httpd-ssl.conf
```


In ```/etc/apache2/extra/httpd-vhosts.conf```, replace the two
<VitualHost> blocks with this:

```
<VirtualHost *:80>
    DocumentRoot "/var/www/htdocs"
    ServerName example.com
    Redirect / https://example.com
</VirtualHost>
```


In ```/etc/apache2/extra/httpd-ssl.conf```

Comment out SSLSessionCache. (It gave me an error with it active.)
```
#SSLSessionCache        "shmcb:/var/www/logs/ssl_scache(512000)"
```

Set SSLCertificateFile and KeyFile to the location of your wildcard
certificae files.

```
SSLCertificateFile "/etc/ssl/_.example.com.crt"
```

```
SSLCertificateKeyFile "/etc/ssl/private/_.example.com.key"
```


Start the server.

```
# apachectl start
```

The page should display now.

Reference:
https://httpd.apache.org/docs/2.4/mod/quickreference.html
https://httpd.apache.org/docs/2.4/ssl/ssl_howto.html
https://community.letsencrypt.org/t/recommended-apache-config/58294/2
