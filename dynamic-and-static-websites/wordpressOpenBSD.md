# Install and Configure Wordpress on OpenBSD

This guide shows you how to install and configure Wordpress on
OpenBSD.

### Why use Wordpress?

Wordpress is one of many dynamic website platforms that uses a
database to generate the webpage sent to the site visitor's web
browser each time the visitor requests a page.

The database itself, the database application, Wordpress itself (the
PHP files), the PHP language engine, any PHP extensions, any Wordpress
plugins - they all constitute a whole bunch of additional code and
content on the server compared to running a static website with
potentially the exact same text, pictures and other media, themes and
formatting.

A static website usually requires directly editing and publishing
HTML, CSS, JavaScript, or a frontend framework for those tools. Even
using a static site generator such as Hugo, MkDocs, or mkws.sh (which
requires none of their own code on the webserver) still requires
defining templates and writing Markdown or a similar configuration
language with a text editor and then uploading the files.

Wordpress and other dynamic website platforms such as Drupal and
Joomla give a point-and-click way to generate and manage every piece
of website content. The only typing the user needs to do for the most
part is just the sentences and other text they want to appear on the
website. Themes and colors, image and media placement, and website
layout, responsiveness and experience, even uploading files and
publishging changes - all of them are available by point-and-click.

Many less-technical users don't want to type their content in
Markdown, type any code or text to choose where on their site to place
a picture, or to choose how the site looks, or to generate the site
with 'hugo build' or upload the rendered site changes with a separate
graphical FTP client such as FileZilla.

Wordpress offers users that choice to point-and-click to accomplish
all those things.

### Why self-host Wordpress? Why not use Wix or GoDaddy?

Self-hosting is running the website on a server you control, even if
you don't own the server hardware used for it.

A practical reason to self-host is to save money. All-inclusive
services such as Wix and GoDaddy charge $10/mo or more (often with the
domain name example.com included in the monthly price).

You can get a website domain name for $15/yr in most cases at
registrars such as Namecheap, and Porkbun.

You can get server hosting at providers such as Vultr for $6/mo.

An idealistic reason to self-host is to own your data and retain more
control of it. Services such as Wix, GoDaddy, and even Wordpress.com
could have a technical problem or change their pricing or terms of
service. Your website could become unavailable for any number of
reasons.

If you have better control over your data and self-host it, you can
pickup and move to a different provider more easily if you need to.

### Why run it on OpenBSD?

For all the advantages that Linux and FreeBSD offer, OpenBSD uses much
less code in the base system to host a website, even a dynamic website
with Wordpress. It is less code for the developers to keep secure from
exploits. In some cases, it may even be lighter on server hosting
resources.

## Install Dependencies

[Wordpress.org](https://wordpress.org) lists their required,
recommended, and optional dependencies in the [Server Environment](
https://make.wordpress.org/hosting/handbook/server-environment)
section of their [Hosting
Handbook](https://make.wordpress.org/hosting/handbook).

```
# pkg_add php-pdo_mysql mariadb-server
```

### PHP Version

OpenBSD offers multiple versions of PHP.

```
$ pkg_info -I php | cut -d" " -f1
```

On 7.6-release:
```
php-8.1.30
php-8.1.31
php-8.2.24
php-8.2.25
php-8.2.26
php-8.2.27
php-8.3.12
php-8.3.13
php-8.3.14
php-8.3.15
```

On 7.6-current (as of Dec 21 2024):
```
php-8.2.26p0
php-8.3.14
php-8.4.1
```

If you find any PHP extensions recommended by Wordpress are not tied
to the latest PHP version in -current, they likely won't be updated
until shortly before the next OpenBSD release.

In this case, you'll have best support for Wordpress features by using
the latest version of PHP offered for the most recent OpenBSD release.

So in our case of 7.6-release, let's go with the latest version of PHP 8.3.

```
# pkg_add php ....
```

### Extensions to PHP

#### Required

WordPress needs one of these two PHP extensions in order to
communicate with its database.

- [php-mysqli](https://www.php.net/manual/en/book.mysqli.php) Is an
  extension to PHP allowing access to MySQL, MariaDB, or any database
  compatible with MySQL. The OpenBSD package is also called
  [php-mysqli](https://openports.pl/path/lang/php/8.1,-mysqli).

- [php-pdo_mysql](https://www.php.net/manual/en/ref.pdo-mysql.php) is
  a PDO driver giving PHP access to many databases, including
  MySQL-compatible ones such as MariaDB. The OpenBSD package is also
  called
  [php-pdo_mysql](https://openports.pl/path/lang/php/8.1,-pdo_mysql).

According to
[W3Schools](https://www.w3schools.com/php/php_mysql_connect.asp),
mysqli only works with MySQL, whereas PDO works with it and other
databases too.

#### Strongly Recommended

- [curl](https://curl.se) is used to download or upload data over http
  or https. OpenBSD package:
  [curl](https://openports.pl/path/net/curl).

- [php-curl](https://www.php.net/manual/en/book.curl.php) OpenBSD
  package: [php-curl](https://openports.pl/path/lang/php/8.1,-curl) ?
  (it is unclear which one they want)
  
- [libxml2](https://gitlab.gnome.org/GNOME/libxml2) is a library for
  reading XML documents. OpenBSD pakcage:
  [libxml](https://openports.pl/path/textproc/libxml)

- [php-xmlrpc](https://openbsd.app/?search=php-xmlrpc&current=on) ?
  (it is unclear which one they want)

- [libexif](https://libexif.github.io) is a library for reading
  metadata from EXIF image files from digital cameras. OpenBSD
  package: [libexif](https://openports.pl/path/graphics/libexif)

- [php-mbstring](https://www.php.net/manual/en/book.mbstring.php) is a
  library to deal with multibyte encodings. not found in openbsd packages

- [php-fileinfo](https://www.php.net/manual/en/intro.fileinfo.php) is
  a library in the same vein as [fileinfo](https://fileinfo.com) to
  identify the type of a file. (no openbsd package)

- [php-imagick](https://www.php.net/manual/en/book.imagick.php) is a
  native PHP extension to create or modify images using the
  ImageMagick API. OpenBSD package:
  [pecl81-imagick](https://openports.pl/path/graphics/pecl-imagick,php81)

- [openssl](https://www.openssl.org) 3.0 for php 8.1 (will it work
  with OpenBSD's [libressl](https://www.libressl.org)) ?

- [pcre](https://www.php.net/manual/en/book.pcre.php) Regular
  expressions modeled after Perl 5. OpenBSD package:
  [pcre](https://openports.pl/path/devel/pcre)

- [pcre2](https://github.com/PCRE2Project/pcre2) Regular expressions
  in C modeled after Perl 5. OpenBSD package:
  [pcre2](https://openports.pl/path/devel/pcre2) ?

- [php-zip](https://www.php.net/manual/en/book.zip.php) Transparently
  read or write zip archives and the files inside them. OpenBSD
  package: [php-zip](https://openports.pl/path/lang/php/8.1,-zip)

#### Recommended

- [Memcached](https://memcached.org) Caching to speed up
  database-driven applications. PHP package:
  [php-memcached](https://www.php.net/manual/en/book.memcached.php)
  OpenBSD package:
  [memcached](https://openports.pl/path/misc/memcached),
  [pecl81-memcached](https://openports.pl/path/www/pecl-memcached,php81)

- [libmemcached](https://libmemcached.org) C and C++ API library for
  Memcached. OpenBSD package:
  [libmemcached](https://openports.pl/path/devel/libmemcached)

- [opcache](https://www.php.net/manual/en/book.opcache.php) (requires
  libcurl) For pre-loading scripts when the PHP engine starts. (no
  OpenBSD package)

- [redis](https://pecl.php.net/package/redis) (if using Redis)

#### Optional

- [bc](https://www.php.net/manual/en/book.bc.php) - arbitrary
  precision math

- [filter](https://www.php.net/manual/en/book.filter.php) For securely
  filtering input.

- [image](https://www.php.net/manual/en/book.image.php), libgd, php-gd
  (if imagick is not installed)

- [iconv](https://www.php.net/manual/en/book.iconv.php) Convert
  between character sets.

- [shmop](https://www.php.net/manual/en/book.shmop.php) Allow PHP to
  manipulate shared sytem memory segments.

- [simplexml](https://www.php.net/manual/en/book.simplexml.php) to
  parse XML.

- sodium

- xmlreader

- zlib

#### For file changes, plugin updates, etc.

- php-ssh2

- php-ftp

- php-sockets

#### System Packages

- ImageMagick

- Ghost Script


### Non-PHP Dependencies

- mariadb-server 

See the webserver setup section below for which webserver package to
install.

## Setup the Webserver

## Setup the Database

```
# pkg_add mariadb-server
# rcctl enable mysqld
# mysql_install_db
# rcctl start mysqld
# mysql_secure_installation
```

If you get this error at the password prompt:

```
Enter current password for root (enter for none): 
ERROR 2002 (HY000): Can't connect to local server through socket '/var/run/mysql/mysql.sock' (2)
```

You need to do run `mysql_install_db` before you start `mysqld`.

For the secure installation, follow all the defaults and recommendations.

Edit MariaDB's configuration file.

```
# vi /etc/my.cnf
```

Uncomment the two lines under `[client-server]`.

```
[client-server]
socket=/var/run/sock/mysql.sock
port=3306
```

```
# mysql -u root -p
```

Enter the root password you set earlier.

Create a new sample database.

```
MariaDB [(none)]> CREATE DATABASE wordpressdb;
```

Create a new standard user with a strong password.
 
```
MariaDB [(none)]> CREATE USER 'wpdb-user'@'localhost' IDENTIFIED BY 'STRONG-PASSWORD';
```

Grant the user full permissions to the sample database.

```
MariaDB [(none)]> use wordpressdb; 
MariaDB [sampledb]> GRANT ALL PRIVILEGES ON wordpressdb.* TO 'wpdb-user'@'localhost';
```

Reload the privileges.

```
MariaDB [sampledb]> FLUSH PRIVILEGES;
```

Exit the console.

```
MariaDB [sampledb]> EXIT 
```

Log in to the MariaDB console again, this time as a standard user.

```
# mysql -u wpdb-user -p
```

Check the current databases accessible by the user.

```
MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| wordpressdb           |
+--------------------+
2 rows in set (0.002 sec)
Exit the console.
MariaDB [(none)]> EXIT
```


## Setup PHP to talk with Webserver and Database

```
# pkg_add php-mysqli php-pdo_mysql
```

Before you proceed with these steps, setup a static index.html
page. If you're just testing, you can use the server IP address and
not worry about DNS or TLS.

Copy the required config for PHP in '/etc'.

```
# ln -s /etc/php-8.3.sample/${ini} /etc/php-8.3
```

Enable and start the PHP service.

```
# rcctl enable php83_fpm
# rcctl start php83_fpm
```



<https://obsd.solutions/en/blog/2023/08/03/php-fpm-82-on-openbsd-73/index.html>


04-07-2025 - Continue working here.


```
# vi /var/www/htdocs/test.php
```

```
<?php
  $servername = "127.0.0.1";
  $username = "username";
  $password = "password";
  // Create connection to MariaDB
  $connection = new mysqli($servername, $username ,$password);
  // Test connection to MariaDB
  if ($connection->connect_error) {
    die("Database Connection Failed: " . $connection->connect_error);
  }
  echo "Database connected successfully. Congratulations!";
?>
```

Visit that page in your browser.

## Install Wordpress

```
# pkg_add php php-gd php-intl php-xmlrpc php-curl php-zip php-mysqli php-pdo_mysql pecl74-mcrypt pecl74-imagick
```

Enable installed modules.

```
# cp /etc/php-7.4.sample/* /etc/php-7.4/
```

Enable and Start PHP-FPM.

```
# rcctl enable php74_fpm
# rcctl start php74_fpm
```

```
# vi /etc/httpd.conf
```

```
ext_ip="*" #Enter Your Vultr IP Address here

server "default" {
        listen on $ext_ip port 80
        root "/htdocs/"
directory index "index.php"

 location "*.php*" {
            fastcgi socket "/run/php-fpm.sock"
    }

location "/posts/*" {
            fastcgi {
                    param SCRIPT_FILENAME \
                            "/htdocs/index.php"
                     socket "/run/php-fpm.sock"
            }
    }

    location "/page/*" {
            fastcgi {
                    param SCRIPT_FILENAME \
                            "/htdocs/index.php"
                    socket "/run/php-fpm.sock"
            }
    }

   location "/feed/*" {
            fastcgi {
                    param SCRIPT_FILENAME \
                            "/htdocs/index.php"
                    socket "/run/php-fpm.sock"
            }
    }

    location "/comments/feed/*" {
            fastcgi {
                    param SCRIPT_FILENAME \
                            "htdocs/index.php"
                    socket "/run/php-fpm.sock"
            }
    }

     location "/wp-json/*" {
            fastcgi {
                    param SCRIPT_FILENAME \
                            "htdocs/index.php"
                    socket "/run/php-fpm.sock"
            }
    }
}

types {
        text/css css ;
        text/html htm html ;
        text/txt txt ;
        image/gif gif ;
        image/jpeg jpg jpeg ;
        image/png png ;
        application/javascript js ;
        application/xml xml ;

}
 server "www.example.net" {
        listen on $ext_ip port 80
    }
```

```
# mkdir /var/www/etc
# cp /etc/resolv.conf /var/www/etc/.
# cp /etc/hosts /var/www/etc/.
```

```
# mysql
```

```
MariaDB [(none)]> CREATE DATABASE wpdb;
MariaDB [(none)]> CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'strongpassword';
MariaDB [(none)]> use wpdb; 
MariaDB [wpdb]> GRANT ALL PRIVILEGES ON wpdb.* TO 'wpuser'@'localhost';
MariaDB [wpdb]> FLUSH PRIVILEGES;
```

```
$ cd ~/Downloads
$ ftp -o https://wordpress.org/latest.tar.gz
$ tar -xzvf latest.tar.gz
# mv wordpress/* /var/www/htdocs
# chown -R www:www /var/www/htdocs
```

Run web installer.

```
https://your-domain
```

Click Let's Go to get started with your WordPress configuration.

Enter the Database name created earlier, a Username and associated
Password. Then, under Database Host replace localhost with 127.0.0.1
or localhost:/var/run/mysql/mysql.sock.

[paste my own screenshot]

Next, a wp-config.php file will be automatically created. Click Run the Installation to enter your first website title and administrator account details to set up WordPress.

Now, login to your WordPress dashboard, install themes, plugins and
create users necessary to develop your websites on the platform.

[paste my own screenshot]

To limit potential attacks on your WordPress server, you can install
security plugins such as Wordfence or Sucuri to limit password guesses
and access to the wp-login page.

Also, delete the WordPress installation script to limit any duplicate installations.

```
# rm /var/www/htdocs/wp-admin/install.php
```

## See also

<https://obsd.solutions/en/blog/2023/09/02/mariadb-109-on-openbsd-73-install/index.html>

<https://developer.wordpress.org/advanced-administration>

<https://developer.wordpress.org/advanced-administration/before-install>

<https://developer.wordpress.org/advanced-administration/before-install/creating-database/#using-the-mysql-client>

<https://developer.wordpress.org/advanced-administration/before-install/howto-install>

<https://developer.wordpress.org/advanced-administration/wordpress/wp-config>

<https://make.wordpress.org/hosting/handbook/server-environment>

<https://openports.pl/path/www/apache-httpd>

<https://openports.pl/path/www/nginx>

<https://openports.pl/path/lang/php/8.2>

<https://openports.pl/path/databases/mariadb,-server>

<https://gohugo.io>

<https://www.mkdocs.org>

<https://mkws.sh>

<https://www.godaddy.com/websites/website-builder/plans-and-pricing>

<https://www.wix.com/premium-purchase-plan/dynamo>

<https://jamstack.org/generators>

<https://wordpress.org/support/article/creating-database-for-wordpress/#using-the-mysql-client>

[First install and configure MariaDB.](https://www.vultr.com/docs/how-to-install-mariadb-on-openbsd-7)

[Then install and configure PHP and Wordpress.](https://www.vultr.com/docs/how-to-run-wordpress-on-openbsd-7-0-with-apache-httpd-d)

[Wordpress on OpenBSD 6.7 (released May 19, 2020) Guide updated May
2023](https://docs.ircnow.org/openbsd/wordpress)

[LowEndBox.com: Wordpress on OpenBSD,
2024](https://lowendbox.com/blog/lets-try-bsd-part-5-of-7-setting-up-nginx-wordpress-on-openbsd-almost)

