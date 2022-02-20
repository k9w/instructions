# started 11-30-2021 - updated 02-20-2022

Install MySQL Community Server. (Use 'dnf' for Fedora-based distros.)

```
# dnf install community-mysql-server
```

https://idroot.us/install-mysql-fedora-35/

Add the service to the firewall so that other services on the local
host system can see it.

```
# firewall-cmd --permanent --add-service=mysql
success
# firewall-cmd --reload
success
```

Start and enable the MySQL systemd service.

```
# systemctl start mysqld
# systemctl enable mysqld
```

Now initialize the new database.

```
# mysql_secure_installation

Securing the MySQL server deployment.

Connecting to MySQL using a blank password.

VALIDATE PASSWORD COMPONENT can be used to test passwords
and improve security. It checks the strength of password
and allows the users to set only those passwords which are
secure enough. Would you like to setup VALIDATE PASSWORD component?

Press y|Y for Yes, any other key for No: n
Please set the password for root here.

New password: 

Re-enter new password: 
By default, a MySQL installation has an anonymous user,
allowing anyone to log into MySQL without having to have
a user account created for them. This is intended only for
testing, and to make the installation go a bit smoother.
You should remove them before moving into a production
environment.

Remove anonymous users? (Press y|Y for Yes, any other key for No) : y
Success.


Normally, root should only be allowed to connect from
'localhost'. This ensures that someone cannot guess at
the root password from the network.

Disallow root login remotely? (Press y|Y for Yes, any other key for No) : y
Success.

By default, MySQL comes with a database named 'test' that
anyone can access. This is also intended only for testing,
and should be removed before moving into a production
environment.


Remove test database and access to it? (Press y|Y for Yes, any other key for No) : y
 - Dropping test database...
Success.

 - Removing privileges on test database...
Success.

Reloading the privilege tables will ensure that all changes
made so far will take effect immediately.

Reload privilege tables now? (Press y|Y for Yes, any other key for No) : y
Success.

All done!
# 
```

Now setup a regular user for MySQL Workbench to use and grant it all privileges.
https://www.digitalocean.com/community/tutorials/how-to-create-a-new-user-and-grant-permissions-in-mysql

```
# mysql -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 10
Server version: 8.0.27 Source distribution

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> select user from mysql.user;
+------------------+
| user             |
+------------------+
| mysql.infoschema |
| mysql.session    |
| mysql.sys        |
| root             |
+------------------+
4 rows in set (0.00 sec)

mysql> create user 'mysql'@'localhost' identified by 'epicodus';
Query OK, 0 rows affected (0.13 sec)

mysql> grant all privileges on * . * to 'mysql'@'localhost';
Query OK, 0 rows affected (0.08 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.04 sec)

mysql> exit
Bye
#
```


# Install MySQL Workbench


Install MySQL Workbench as a SNAP, one of the universal Linux
packaging formats. Two others are Flatpak and AppImage.

First, install snapd.

```
# dnf install snapd
```

Then search for and install MySQL Workbench.

```
$ snap find mysql-workbench
# snap install mysql-workbench-community
```

https://snapcraft.io/mysql-workbench-community
https://snapcraft.io/docs/permission-requests




# Troubleshooting


If you get stuck and need to start fresh, delete the database by
removing all files recursively from /var/lib/mysql. It might ask for
confirmation on a file or two.

```
# rm -rf /var/lib/mysql/*
rm: remove regular file '/var/lib/mysql/ib_buffer_pool'? y
# ls -al /var/lib/mysql
total 0
drwxr-xr-x. 1 mysql mysql   0 Jan 23 13:44 .
drwxr-xr-x. 1 root  root  806 Jan 12 00:22 ..
#
```




If MySQL fails to install because MariaDB or another database package
is installed and using the 'mysql' command name, you'll need to
determine what's requiring it and remove it.

Here's how to do that on Fedora.

https://dnf.readthedocs.io/en/latest/command_ref.html

```
$ dnf history userinstalled | grep mariadb
```

https://docs.fedoraproject.org/en-US/Fedora_Draft_Documentation/0.1/html/RPM_Guide/ch05s02.html

DNF chapter 5.2 Checking for Dependencies

First, list the capabilities, each package provides.

```
$ rpm -q --provides mariadb-connector-c
$ rpm -q --provides mariadb-embedded
$ rpm -q --provides mariadb-server
```

Then, find out what other (currently installed?) packages require each
of those packages.

```
$ rpm -q --whatrequires mariadb-connector-c
mariadb-10.5.13-1.fc35.x86_64
$ rpm -q --whatrequires mariadb-embedded
no package requires mariadb-embedded
$ rpm -q --whatrequires mariadb-server
no package requires mariadb-server
$ rpm -q --whatrequires mariadb
no package requires mariadb
```

In my example above, mariadb requires mariadb-connector-c. mariadb
does not require any other package or cabability. Your system may
differ.


Here's how to remove MariaDB.

Delete all databases managed by MariaDB.

```
# rm -rf /var/lib/mysql/*
```

Verify it's gone by trying and getting a failed login.

```
$ mysql -u root -p
Enter password:
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock' (2)
```

Stop and disable the mariadb systemd service.

```
# systemctl stop mariadb
# systemctl disable mariadb
```

We can keep the firewall rule in place since MariaDB shares the same
binary 'mysql' as the MySQL.

Remove the packages and their dependencies.

```
# dnf remove mariadb mariadb-embedded mariadb-connector-c
```

Now try installing community-mysql-server again.
