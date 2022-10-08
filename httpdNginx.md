04-13-22

https://www.openbsdhandbook.com/services/webserver/nginx
https://nginx.org/en/docs
https://nginx.org/en/docs/beginners_guide.html
https://nginx.org/en/docs/http/server_names.html
https://www.hostiserver.com/community/articles/how-to-redirect-301-in-apache-and-ngninx

Install nginx from packages.

```
# pkg_add nginx
```

The package added html/{50x.html,index.html} to /var/www. It did not add
anything to htdocs. But nginx.conf's root defaults to htdocs.

Copy or symlink the files from html to htdocs, or make your own index.html.


Edit the main configuration file at:

```
/etc/nginx/nginx.conf
```

In the http block, in the port 80 server block, change server_name from
localhost to your domain name, and the root from htdocs to your site
folder name if you want.

```
	server_name	localhost;
	root		/var/www/htdocs;
```

```
	server_name	example.com;
	root		/var/www/example.com;
```

At this point, go ahead and save the file and test out the site. 


You can test the nginx configuraiton without starting the service.

```
# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Enable nginx to start on each boot.

```
# rcctl enable nginx
# rcctl start nginx
```

At this point, the site should work with standard http, not https yet. 
(Firefox complains about no https; but chrome should load the page fine.)


Next, we need to configure https and generate a TLS certificate. Here we
use Let's Encrypte and OpenBSD's acme-client.

acme-client requires a 'well-known' location block in the webserver
config file. Other acme TLS tools such as Lego and Certbot might as
well.

Add a location block in the http server section per acme-client(1). The
example in the manpage is for OpenBSD's default httpd webserver. Here is
how it would look for nginx.conf, in the http server block, ideally
right after the 'root' path line.

```
location /.well-known/acme-challenge/  {
    rewrite ^/.well-known/acme-challenge/(.*) /$1 break;
    root /acme;
}
```

Credit to <https://dataswamp.org/~solene/2019-07-04-nginx-acme.html>







Add a line to redirect to https. (Comment it out until you setup https below.)

```
	return 301 https://example.com;
```

For https, uncomment the example server block for port 443. Change its
server name from localhost to example.com like port 80, and set the
location of your TLS cert and key.

```
	ssl_certificate		/etc/ssl/example.com.crt;
	ssl_certificate_key	/etc/ssl/private/example.com.key;
```



After editing the configuration file, reload or restart nginx to apply
the changes.

```
# rcctl reload nginx
# rcctl restart nginx
```

