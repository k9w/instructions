# Tarsnap

I had trouble running tarsnap on OpenBSD and FreeBSD with ACTS and
cron. So I am trying it here on Debian.

Started crontab for root. The system asked what editor to use. I chose
nvi. It created roots crontab at:
/var/spool/cron/crontabs/root

Scheduled the following and it worked:

```
# touch /root/test
```

Next since Tarsnap and ACTS are not in the Debian repos, I will
install tarsnap from its deb package, and acts from git.

From https://tarsnap.com/pkg-deb.html:

```
$ wget https://pkg.tarsnap.com/tarsnap-deb-packaging-key.asc

$ gpgv --keyring /usr/share/keyrings/debian-archive-keyring.gpg tarsnap-deb-packaging-key.asc
gpgv: verify signatures failed: Unexpected error
```

I chose to skip the check and add the key.

```
# apt-key add tarsnap-deb-packaging-key.asc
E: gnupg, gnupg2 and gnupg1 do not seem to be installed, but one of
them is required for this operation
```

So I installed gpg

```
# apt install gpg
```

Then apt-key add worked. Next I added the tarsnap repo to sources-list.d.

```
# echo "deb http://pkg.tarsnap.com/deb/$(lsb_release -s -c) ./" | \
tee -a /etc/apt/sources.list.d/tarsnap.list

# apt update
```

Searching for tarsnap worked and also found tarsnap-archive-keyring. I
chose to install both and git, so that I can get acts.

```
# apt install tarsnap-keyring tarsnap git
```

Next I initialized tarsnap for this system.

/etc/tarsnap.conf
 - change default key to /root/de.k9w.org.tarsnapkey
 - uncomment humanize-numbers

```
# tarsnap-keygen --keyfile /root/de.k9w.org.tarsnapkey --user
kevin@k9w.org --machine de.k9w.org
Enter tarsnap account password: 
# 
ls
CVS  de.k9w.org.tarsnapkey
# tarsnap --list-archives
Directory /usr/local/tarsnap-cache created for "--cachedir /usr/local/tarsnap-cache"
# tarsnap --list-archives
# tarsnap --print-stats
tarsnap: Error reading cache directory from /usr/local/tarsnap-cache
tarsnap: Error generating archive statistics
tarsnap: Error exit delayed from previous errors.
# ls /usr/local
bin  etc  games  include  lib  man  sbin  share  src  tarsnap-cache
# ls -al /usr/local
total 44
drwxr-xr-x 11 root root 4096 Jan 31 21:34 .
drwxr-xr-x 14 root root 4096 Jan 31 20:58 ..
drwxr-xr-x  2 root root 4096 Jul 21  2019 bin
drwxr-xr-x  2 root root 4096 Jul 21  2019 etc
drwxr-xr-x  2 root root 4096 Jul 21  2019 games
drwxr-xr-x  2 root root 4096 Jul 21  2019 include
drwxr-xr-x  4 root root 4096 Jul 21  2019 lib
lrwxrwxrwx  1 root root    9 Jul 21  2019 man -> share/man
drwxr-xr-x  2 root root 4096 Jul 21  2019 sbin
drwxr-xr-x  4 root root 4096 Jul 21  2019 share
drwxr-xr-x  2 root root 4096 Jul 21  2019 src
drwx------  2 root root 4096 Jan 31 21:34 tarsnap-cache
# pwd
/root
# ls
CVS  de.k9w.org.tarsnapkey
# du -hcs /home/kevin
116K    /home/kevin
116K    total
# du -hcs /etc
4.0M    /etc
4.0M    total
# tarsnap -cf etc /etc
tarsnap: Removing leading '/' from member names
                                       Total size  Compressed size
All archives                               2.4 MB           531 kB
  (unique data)                            2.4 MB           531 kB
This archive                               2.4 MB           531 kB

  (unique data)                            2.4 MB           531 kB

                                       [0/1439]
This archive                               2.4 MB           531 kB
New data                                   2.4 MB           531 kB
# tarsnap --print-stats
                                       Total size  Compressed size
All archives                               2.4 MB           531 kB
  (unique data)                            2.4 MB           531 kB

                                              
# tarsnap -df etc     
                                       Total size  Compressed size
All archives                                  0 B              0 B
  (unique data)                               0 B              0 B
This archive                               2.4 MB           531 kB
            
Deleted data                               2.4 MB           531 kB
# crontab -e           
crontab: installing new crontab                                     
# tarsnap --print-stats            
                                       Total size  Compressed size
All archives                                  0 B              0 B
  (unique data)                               0 B              0 B 
root@de:~# tarsnap --print-stats
                                       Total size  Compressed size
All archives                                  0 B              0 B
  (unique data)                               0 B              0 B
root@de:~# tarsnap --print-stats             
                                       Total size  Compressed size
All archives                                  0 B              0 B
  (unique data)                               0 B              0 B
root@de:~# crontab -e                        
crontab: installing new crontab                           
root@de:~# tarsnap --print-stats              
                                       Total size  Compressed size
All archives                               2.4 MB           531 kB
  (unique data)                            2.4 MB           531 kB
# exit
exit 
$ cd
$ git clone https://github.com/alexjurkiewicz/acts.git
Cloning into 'acts'...        
remote: Enumerating objects: 541, done.
remote: Total 541 (delta 0), reused 0 (delta 0), pack-reused 541
Receiving objects: 100% (541/541), 91.69 KiB | 2.70 MiB/s, done.
Resolving deltas: 100% (288/288), done.
$ ls
acts  configuration  CVS       
$ ls acts                            
acts  acts.conf.sample  contrib  LICENSE  Makefile  PACKAGING.md  README.md
$ ls /usr/local                                         
bin  etc  games  include  lib  man  sbin  share  src  tarsnap-cache
$ 

#	$Id$

.cache
.config
.mozilla
```
