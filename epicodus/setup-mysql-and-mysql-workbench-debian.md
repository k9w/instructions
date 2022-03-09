03-08-2022

https://www.how2shout.com/linux/how-to-install-mysql-8-0-server-on-debian-11-bullseye/

```
$ wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb
# apt install mysql-apt-config_*_all.deb
```

A command line window (ncurses interface) comes up offering a choice of
what to install. Choose 'MySQL Server & Cluster'.

On the next screen, select 'mysql-8.0'.

If it returns you to the same screen again, select 'OK', not 'none'.

The repository should be added now. If you want to reconfigure it in the
future:

```
# dpkg-reconfigure mysql-apt-config
```

Now, update the repos and search for community-mysql-server again.

```
# apt update
$ apt search mysql-server 
# apt install mysql-server
```

On Debian-based systems, installing packages such as this automatically
launches the database setup script, similar to running
'mysql_secure_installation' on Fedora-based systems.

Set the database root password. We used 'epicodus' as the password.
Use Legacy Authentication Method.

The installation should now be complete.

Test it with a login.

```
$ mysql -u root -p
Enter password:
```

Enter the password you chose. Here's what you should see:

```
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 8
erver version: 8.0.28 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```

That last line is the MySQL prompt, ending with the greater-than symbol
(>). You can type 'exit' to return to your regular command prompt.
