# Install and Configure Wordpress on OpenBSD

This guide shows you how to install and configure Wordpress on
OpenBSD.


## Install Dependencies

[Wordpress.org](https://wordpress.org) lists their required,
recommended, and optional dependencies in the [Server Environment](
https://make.wordpress.org/hosting/handbook/server-environment)
section of their [Hosting
Handbook](https://make.wordpress.org/hosting/handbook).

### PHP Version

OpenBSD offers multiple versions of PHP.

```
$ pkg_info -I php | cut -d" " -f1
```

On 7.2-release:
```
php-7.4.32p0
php-7.4.33
php-8.0.24p0
php-8.0.25
php-8.0.26
php-8.1.11p0
php-8.1.12
php-8.1.13
```

On 7.2-current (Dec 13 2022 snapshot):
```
php-7.4.33
php-8.0.26
php-8.1.13
php-8.2.0p0
```

If you find any PHP extensionsrecommended by Wordpress, are not tied to
the latest PHP version in -current, they likely won't be updated until
shortly before the next OpenBSD release.

Examples.

In this case, you'll have best support for Wordpress features by using
the latest version of PHP offered for the most recent OpenBSD release.

So in our case of 7.2-release, let's go with PHP 8.1.

```
# pkg_add php ....
```

### Extensions to PHP

From <https://www.openbsdhandbook.com/howto/wordpress>:
- php-cgi
- fcgi

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
  a library in the same vein as [fileinfo}(https://fileinfo.com) to
  identify the type of a file. (no openbsd package)

- [php-imagick](https://www.php.net/manual/en/book.imagick.php) is a
  native PHP extension to create or modify images using the
  ImageMagick API. OpenBSD package:
  [pecl81-imagick](https://openports.pl/path/graphics/pecl-imagick,php81)

- openssl 3.0 for php 8.1 (will it work with libressl?) ?

- pcre or pcre2 ?

- php-zip

#### Recommended

- memcached or libmemcached
- opache (requires libcurl)
- redis (if using Redis)

#### Optional

- bc - arbitrary precision math
- php-filter
- image, libgd, php-gd (if imagick is not installed)
- iconv
- intl
- simplexml
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
# pkg_add mariadb_server
# rcctl enable mysqld
# rcctl start mysqld
# rcctl check mysqld
# mysql_install_db
# mysql_secure_installation
# vi /etc/my/cnf
```

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
MariaDB [(none)]> CREATE DATABASE sampledb;
```

Create a new standard user with a strong password.

```
MariaDB [(none)]> CREATE USER 'user2'@'localhost' IDENTIFIED BY 'STRONG-PASSWORD';
```

Grant the user full permissions to the sample database.

```
MariaDB [(none)]> use sampledb; 
MariaDB [sampledb]> GRANT ALL PRIVILEGES ON sampledb.* TO
'user2'@'localhost';
```

Reload the privileges.

```
MariaDB [sampledb]> FLUSH PRIVILEGES;
```

Exit the console.

```
MariaDB [sampledb]> EXIT 
```

Log in to the MySQL console again, this time as a standard user.

```
# mysql -u user2 -p

Check the current databases accessible by the user.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| sampledb           |
+--------------------+
2 rows in set (0.002 sec)
Exit the console.
MariaDB [(none)]> EXIT
```

## Setup PHP to talk with Webserver and Database

```
# pkg_add php-mysqli php-pdo_mysql
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

[paste my own screensho]

o limit potential attacks on your WordPress server, you can install security plugins such as Wordfence or Sucuri to limit password guesses and access to the wp-login page.

Also, delete the WordPress installation script to limit any duplicate installations.

```
# rm /var/www/htdocs/wp-admin/install.php
```

## See also

<https://wordpress.org/support/article/creating-database-for-wordpress/#using-the-mysql-client>

First install and configure MariaDB.
<https://www.vultr.com/docs/how-to-install-mariadb-on-openbsd-7>

Then install and configure PHP and Wordpress.
<https://www.vultr.com/docs/how-to-run-wordpress-on-openbsd-7-0-with-apache-httpd-d>

