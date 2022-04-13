04-13-22

https://www.openbsdhandbook.com/services/webserver/nginx
https://nginx.org/en/docs

Install nginx from packages.

```
# pkg_add nginx
```

The main configuration file is at:

```
/etc/nginx/nginx.conf
```

In the http block, in the server block, change server_name from
localhost to your domain name or IP address.

The package added html/{50x.html,index.html} to /var/www. It did not add
anything to htdocs. But nginx.conf's root defaults to htdocs.

Copy or symlink the files from html to htdocs, or make your own index.html.

Enable nginx to start on each boot.

```
# rcctl enable nginx
# rcctl start nginx
```

On a browser on your local computer, navigate to the domain name or IP
address with standard http: http://example.com

Https confguration is next...

