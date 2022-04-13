04-11-22

Install the apache webserver.

```
# pkg_add apache-httpd
```

One of the files this installs is /var/www/htdocsindex.html with 'It
works!'


Assuming you already have a DNS name and port number for the server
registered, set ServerName to that in /etc/apache2/httpd2.conf. You'll
also configure TLS and port 443 later.

```
ServerName www.example.com:80
```

Start the server.

```
# apachectl start
```

The page should display now.

Next step is to use the pre-generated wildcard TLS cert to configure
https.
