# 11-30-2021

Install MySQL Community Server.

```
# dnf install community-mysql-server
```

Fails because MariaDB Server is already installed and MySQL cannot be
installed along side it (unless they are separated using Containers)
because they share the same shell commands. MariaDB will work with
MySQL Workbench.

<https://mariadb.com/products/skysql/docs/clients/third-party/mysql-workbench>

MySQL Workbench is not in the Fedora repositories and therefore not
installable with DNF. For Linux, don't install it from the MySQL
website either because the version 8.0.27 requires SSL. MariaDB
shipped with Fedora does not have SSL compiled in. This is likely
because it's assumed another app, such as a web server on the same
machine, would sit between the database and outside internet traffic
and handle SSL itself.

<https://dev.mysql.com/downloads/workbench/?os=src>

You would also have to install dependencies manually. And we don't want to deal with that.

Instead, install MySQL Workbench as a SNAP Package.


<p>
# 12-30

Start, enable, and check mariadb systemd service.

```
# systemctl start mariadb
# systemctl enable mariadb
$ systemctl status mariadb
```


Install MySQL Workbench as a SNAP. (It's not on Flathub as a Flatpak,
which is another universal package format).

```
# dnf install snapd
```

```
$ snap find mysql-workbench
```

It has 8.0.25. Should I just downgrade to .26 and not use snap?

Install the snap. Then remove the manually installed RPM.

```
# snap install mysql-workbench-community
```

https://snapcraft.io/mysql-workbench-community
https://snapcraft.io/docs/permission-requests


<p>
# 01-23

In case you have an existing MariaDB/MySQL database, delete it and start fresh. Remove all data from /var/lib/mysql. It might ask for confirmation on a file or two.

Warning: All previous MariaDB/MySQL data on that machine will be lost!

```
# rm /var/lib/mysql/*
rm: remove regular file '/var/lib/mysql/ib_buffer_pool'? y
# ls -al /var/lib/mysql
total 0
drwxr-xr-x. 1 mysql mysql   0 Jan 23 13:44 .
drwxr-xr-x. 1 root  root  806 Jan 12 00:22 ..
#
```

Start the mariadb service in systemd; and add the service to the
firewall so that other local services on the host can see it.

```
# systemctl enable mariadb
# systemctl start mariadb
Add the service to the firewall so that other services on the local
host system can see it.
# firewall-cmd --permanent --add-service=mysql
success
# firewall-cmd --reload
success
```

Now initialize the new database.


```
# mysql_secure_installation

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none): 
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] n
 ... skipping.

You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n] y
New password: 
Re-enter new password: 
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
#
```

Log back into the database and view existing users.

```
# mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 17
Server version: 10.5.13-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> SELECT User FROM mysql.user;
+-------------+
| User        |
+-------------+
| mariadb.sys |
| mysql       |
| root        |
+-------------+
3 rows in set (0.002 sec)

MariaDB [(none)]>
```

Here, set the password for existing user 'mysql' to 'epicodus' to match the setup at learnhowtoprogram.com.

This is the account we will use in MySQL Workbench since the workbench app does not run as root and therefore cannot access the MySQL root account. Additional privileges can be granted to the 'mysql' user later as needed.

```
MariaDB [(none)]> SET PASSWORD FOR 'mysql'@'localhost' = PASSWORD('epicodus');
Query OK, 0 rows affected (0.042 sec)

MariaDB [(none)]> exit
Bye
#
```

Now try logging in as user mysql from a standard Linux shell account.

```
$ mysql -u mysql -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 18
Server version: 10.5.13-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> exit
Bye
$
```

And finally, try logging in to 'mysql' user in MySQL Workbench. Screenshots attached.

