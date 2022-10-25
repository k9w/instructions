# Nginx webserver on OpenBSD

This guide describes how to install and configure
[Nginx](https://nginx.org) on [OpenBSD](https://openbsd.org).

## Installation & configuration files

Install nginx from packages.

```
# pkg_add nginx
```

The package added html/{50x.html,index.html} to /var/www. It did not add
anything to htdocs. But nginx.conf's root defaults to htdocs.

This guide assumes your site lives at `/var/www/example.com`

Edit the main configuration file.

```
# vi /etc/nginx/nginx.conf
```

In the http block, in the first server block, change server_name from
localhost to your domain name, and the root from htdocs to your site
complete folder path.

If you use Let's Encrypt or another ACME protocol TLS provider, add a
location block here for the [http-01
challenge](https://letsencrypt.org/docs/challenge-types).

Add a redirect to https and comment it out for now.

Before:
```
	server_name	localhost;
	root		/var/www/htdocs;
```

After:
```
        server_name	example.com;
        root		/var/www/example.com;

	location /.well-known/acme-challenge/ {
	    rewrite ^/.well-known/acme-challenge/(.*) /$1 break;
	    root /acme;
	}

#	return 301 https://example.com;
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
(Firefox complains about no https; but Chrome should load the page fine.)

Next, we need to configure https and generate a TLS certificate. Here we
use Let's Encrypt and OpenBSD's acme-client.

The 'well-known' location block we added above is required by
acme-client. Other acme TLS tools such as Lego and Certbot might also
require this.

Let's Encrypt only requires the location block for production 'sign
with letsencrypt', not staging 'sign with letsencrypt-staging'.

Additionally, multiple domain names on the same IP need to be specified
differently.

Leave the whole https port 443 server block commented out for now.

The 'ssl' on/off directive is deprecated. Remove it and add it to the
'listen' directive.

Before:
```
	listen		443;
...
	ssl		on;
```

After:
````
	listen		443 ssl;
```

Like port 80, change its server_name from localhost to example.com and
root from htdocs to example.com.

Set the location of your TLS cert and key.

```
	ssl_certificate		/etc/ssl/example.com.crt;
	ssl_certificate_key	/etc/ssl/private/example.com.key;
```

It's also a good idea to set the 'ssl_protocols' directive to enable TLSv1.3.

```
	ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
```

Save the file, reload nignx. If it works, try issuing the tls cert. If
that works, uncomment the redirect and https server block. Reload nginx.

Uncomment the example server block for port 443 and the redirect line in
http port 80.

After editing the configuration file, reload or restart nginx to apply
the changes.

```
# rcctl reload nginx
# rcctl restart nginx
```

## Summary of changes

Here is a diff of the changes made with the original nginx.conf on the
left and the production version on the right.

```
$ diff nginx.conf.orig nginx.conf
45,46c45,46
<         server_name  localhost;
<         root         /var/www/htdocs;
---
>         server_name  example.com;
>         root         /var/www/example.com;
47a48,54
> 	location /.well-known/acme-challenge/ {
> 	    rewrite ^/.well-known/acme-challenge/(.*) /$1 break;
> 	    root /acme;
> 	}
> 
> #	return 301 https://example.com;
> 
107,110c114,117
<     #server {
<     #    listen       443;
<     #    server_name  localhost;
<     #    root         /var/www/htdocs;
---
>     server {
>         listen       443 ssl;
>         server_name  example.com;
>         root         /var/www/example.com;
112,114c119,120
<     #    ssl                  on;
<     #    ssl_certificate      /etc/ssl/server.crt;
<     #    ssl_certificate_key  /etc/ssl/private/server.key;
---
>         ssl_certificate      /etc/ssl/example.com.crt;
>         ssl_certificate_key  /etc/ssl/private/example.com.key;
116,117c122
<     #    ssl_session_timeout  5m;
<     #    ssl_session_cache    shared:SSL:1m;
---
> 	ssl_protocols	     TLSv1.1 TLSv1.2 TLSv1.3;
119,121c124,125
<     #    ssl_ciphers  HIGH:!aNULL:!MD5:!RC4;
<     #    ssl_prefer_server_ciphers   on;
<     #}
---
>         ssl_session_timeout  5m;
>         ssl_session_cache    shared:SSL:1m;
122a127,130
>         ssl_ciphers  HIGH:!aNULL:!MD5:!RC4;
>         ssl_prefer_server_ciphers   on;
>     }
> 
123a132,168
> 
> #    server {
> #        listen       80;
> #        listen       [::]:80;
> #        server_name  b.metabytesblog.com;
> #        root         /var/www/b.metabytesblog.com;
> 
> #	location /.well-known/acme-challenge/ {
> #	    rewrite ^/.well-known/acme-challenge/(.*) /$1 break;
> #	    root /acme;
> #	}
> 
> #	return 301 https://b.metabytesblog.com;
> 
> #        error_page   500 502 503 504  /50x.html;
> #        location = /50x.html {
> #            root  /var/www/htdocs;
> #        }
> 
> #    }
> 
> #    server {
> #        listen       443 ssl;
> #        server_name  b.metabytesblog.com;
> #        root         /var/www/b.metabytesblog.com;
> 
> #        ssl_certificate      /etc/ssl/b.metabytesblog.com.crt;
> #        ssl_certificate_key  /etc/ssl/private/b.metabytesblog.com.key;
> 
> #	ssl_protocols	     TLSv1.1 TLSv1.2 TLSv1.3;
> 
> #        ssl_session_timeout  5m;
> #        ssl_session_cache    shared:SSL:1m;
> 
> #        ssl_ciphers  HIGH:!aNULL:!MD5:!RC4;
> #        ssl_prefer_server_ciphers   on;
> #    }
```

## See also

<https://dataswamp.org/~solene/2019-07-04-nginx-acme.html>
<https://stackoverflow.com/questions/69318127/nginx-2-different-domains-on-one-server>
<https://nginx.org/en/docs/http/request_processing.html>
<https://www.openbsdhandbook.com/services/webserver/nginx>
<https://nginx.org/en/docs>
<https://nginx.org/en/docs/beginners_guide.html>
<https://nginx.org/en/docs/http/server_names.html>
<https://www.hostiserver.com/community/articles/how-to-redirect-301-in-apache-and-ngninx>

