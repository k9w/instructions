04-11-22

Install the apache webserver. The commands and file paths assume
you use OpenBSD.

```
# pkg_add apache-httpd
```

One of the files this installs is /var/www/htdocs/index.html with 'It
works!'

Configuration is in /etc/apache2: 
- httpd2.conf
- extra/httpd-vhosts.conf
- extra/httpd-ssl.conf


## Enable basic http before https

In httpd2.conf, uncomment the following lines.
```
Include /etc/apache2/extra/httpd-vhosts.conf
```

In ```/etc/apache2/extra/httpd-vhosts.conf```, replace the two
<VitualHost> blocks with this:

```
<VirtualHost *:80>
    DocumentRoot "/var/www/example.com"
    ServerName example.com
#    Redirect / https://example.com
</VirtualHost>
```

We'll uncomment the redirect later.

Save the config files and test the configuration.

```
# httpd2 -t
Syntax OK
```


## Generate your TLS certificate



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
