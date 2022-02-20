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
# 12-30-2021

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
# 01-23-2022

In case you have an existing MariaDB/MySQL database, delete it and start fresh. Remove all data from /var/lib/mysql. It might ask for confirmation on a file or two.

Warning: All previous MariaDB/MySQL data on that machine will be lost!

```
# rm -r /var/lib/mysql/*
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


<p>
# 02-19

Today Discord failed to launch because an update is available. I had
installed it from DNF in RPM Fusion. That older version is still listed
there. So today I added the Flathub repo for Flatpak. Flatpak came
pre-installed on Fedora.

https://docs.flatpak.org/en/latest/getting-started.html

I searched for and installed the flatpak of Discord in Plasma Discover.
It launched successfully. So I removed the DNF version of Discord and rebooted.

I had also previously installed Postman from their site. Today I
installed its Flatpak, tested it successfully, and removed the website
install.


I had previously setup most of these tools, including for C#. But today
while going throught the C# pre-work, I found dotnet 6 from the Fedora
repos gives errors for the code samples in the lessons. I'll look to
switch to dotnet 5.

First remove the previously installed dotnet 6.

```
# dnf remove dotnet-script dotnet
```

Then follow the instructions for Dotnet SDK 5 at:
https://docs.microsoft.com/en-us/dotnet/core/install/linux-fedora#install-net-5

```
# dnf install dotnet-sdk-5.0
Last metadata expiration check: 3:46:10 ago on Sat 19 Feb 2022 10:30:09
AM PST.
Package dotnet-sdk-5.0-5.0.206-1.fc35.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
$ dotnet --version
5.0.206
```

The 'dnf remove' command removed every dependency for Dotnet 6. But the
'dnf install' command above shows dotnet-sdk-5.0 was already loaded on
my Fedora install.

Dotnet-script was also still installed. In learnhowtoprogram.com's test
instruction, calling the variable 'hello' just using the word 'hello'
didn't work.

```
$ dotnet-script
> string hello = "Hello world!";
> hello;
(1,1): error CS0201: Only assignment, call, increment, decrement, await,
and new object expressions can be used as a statement
>
Ctrl-C
$
```

This worked instead.
https://github.com/filipw/dotnet-script#usage

```
> Console.WriteLine(hello);
Hello world!
>
```

MariaDB was installed and conflicts with MySQL, which is required by
Epicodus for C$. I thought MariaDB was required by some Fedora system
service and therefore I couldn't swap it out for MySQL. I emailed
Epicodus' Brook Kullberg (pronouns they/them). Brooke asked me to try
some SQL statements in Workkbench and on the command line. I was able
to create a database on the command line and connect to it in MySQL
Workbench.

I kept running into syntax errors when setting up a table in that
database per Brooke's instructions (in my edu email). So I checked
again if MariaDB was installed by me, according to DNF, and could be
safely removed.

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

mariadb requires mariadb-connector-c. mariadb does not require any
other package or cabability.


Here's how to remove MariaDB.

Delete all databases managed by MariaDB.

```
# rm -r /var/lib/mysql/*
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


Next, search for and install community-mysql-server.

```
# dnf search mysql-server
# dnf install community-mysql-server
```

Setup the MySQL server.

```
# mysql_secure_installation
```

Start and enable the MySQL systemd service.

```
# systemctl start mysqld
# systemctl enable mysqld
```

mysql.service not found. Need to investigate and also ensure the
firewall rule is still correct.


```
# mysql_secure_installation 

Securing the MySQL server deployment.

Enter password for user root: 
Error: Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock' (2)
```

```
# systemctl status mysqld
× mysqld.service - MySQL 8.0 database server
     Loaded: loaded (/usr/lib/systemd/system/mysqld.service; disabled; vendor preset: disabled)
     Active: failed (Result: exit-code) since Sat 2022-02-19 19:41:41 PST; 26min ago
    Process: 2538 ExecStartPre=/usr/libexec/mysql-check-socket (code=exited, status=0/SUCCESS)
    Process: 2560 ExecStartPre=/usr/libexec/mysql-prepare-db-dir mysqld.service (code=exited, status=0/SUCCESS)
    Process: 2594 ExecStart=/usr/libexec/mysqld --basedir=/usr (code=exited, status=1/FAILURE)
    Process: 2596 ExecStopPost=/usr/libexec/mysql-wait-stop (code=exited, status=0/SUCCESS)
   Main PID: 2594 (code=exited, status=1/FAILURE)
     Status: "Server startup in progress"
      Error: 22 (Invalid argument)
        CPU: 480ms

Feb 19 19:41:40 flap systemd[1]: Starting MySQL 8.0 database server...
Feb 19 19:41:41 flap systemd[1]: mysqld.service: Main process exited, code=exited, status=1/FAILURE
Feb 19 19:41:41 flap systemd[1]: mysqld.service: Failed with result 'exit-code'.
Feb 19 19:41:41 flap systemd[1]: Failed to start MySQL 8.0 database server.
```

Then, even though I didn't change anything, it started working.


```
# systemctl start mysqld
# systemctl enable mysqld
Created symlink /etc/systemd/system/multi-user.target.wants/mysqld.service → /usr/lib/systemd/system/mysqld.service.
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
