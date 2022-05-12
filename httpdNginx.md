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
localhost to your domain name.

```
	server_name	localhost;
```

```
	server_name	example.com;
```

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


Enable nginx to start on each boot.

```
# rcctl enable nginx
# rcctl start nginx
```

After editing the configuration file, reload or restart nginx to apply
the changes.

```
# rcctl reload nginx
# rcctl restart nginx
```

