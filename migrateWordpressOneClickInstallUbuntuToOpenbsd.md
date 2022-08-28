08-28-2022

This guide builds on:
relaydRunSeveralWebservers.md
wordpressOpenBSD.md

Backstory

In July 2020 my wife wanted a website (and still does to this day). She
is a licensed pre-K and Elementary school teacher and had been teaching
for about a year by that point. She has many ideas for parents who want
to be involved in their children's education no mater what form of
schooling they choose.

By that point in my tech journey, I knew I wanted my own website to be
static HTML and CSS and be generated from Markdown using Hugo, Jekyll,
etc. My wife does not claim to be tech-oriented. She said she did not
want to code or write any markup at all for her site. So I suggested
Wordpress.

I recommended to her she get email for that website with the site's
domain name and use that to log into Wordpress and any social media she
wanted for it. I had been wanting to get a paid email service away from
Google and use my own domain name and saw an opportunity to do that for
both of us with Protonmail.

I already had my domain name with DNSimple. So we registered a domain
name for her website and signed both of us up for the paid Protonmail
plan with custom email addresses.

Then I went to Digital Ocean and deployed a one-click install of
Wordpress on Ubuntu 18.04. 20.04 was out already; but the one-click
intall was only for 18.04.

I followed the setup instructions, ssh'ed into the server and ran the
setup script. That got the Wordpress install and admin login working.
But it failed to configure TLS with Certbot. I researched, installed the
python-certbot-apache package, and got TLS working correctly with the
domain and https.

My wife configured the look and theme of the site and published some
content. Comments were turned on and drew a lot of spam. She disabled
comments to stop the spam.

I ssh'ed in monthly to run updates and reboot.


Why migrate?

Later that year, I successfully upgraded the server from 18.04 to 20.04.
I noticed some repositories or packages were held back and not upgraded
from 18.04, MySQL specifically. I didn't look into specifically why the
one-click install author chose to hold back MySQL or what would break if
I un-excluded it. I also hadn't looked into the rest of the setup in
detail; it generally just worked.

But in August 2022, when 22.04.1 was released, do-release-upgrade

```
$ sudo apt update
Hit:1 https://repos.insights.digitalocean.com/apt/do-agent main InRelease
Hit:2 http://mirrors.digitalocean.com/ubuntu focal InRelease
Hit:3 http://mirrors.digitalocean.com/ubuntu focal-updates InRelease
Hit:4 http://mirrors.digitalocean.com/ubuntu focal-backports InRelease
Hit:5 http://security.ubuntu.com/ubuntu focal-security InRelease    
Hit:6 http://ppa.launchpad.net/ondrej/php/ubuntu focal InRelease
Reading package lists... Done
Building dependency tree       
Reading state information... Done
2 packages can be upgraded. Run 'apt list --upgradable' to see them.
$ sudo apt upgrade
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Calculating upgrade... Done
The following packages have been kept back:
  mysql-client mysql-server
0 upgraded, 0 newly installed, 0 to remove and 2 not upgraded.
$ sudo do-release-upgrade
Checking for a new Ubuntu release
Please install all available updates for your release before upgrading.
```

It looked like 'do-release-upgrade' refused to upgrade to 22.04 because
'mysql-client' and 'mysql-server' had been kept back from apt upgrading
them.

I checked apt and dpkg to see if they had been used to hold back the
packages and they hadn't.
<https://www.cyberciti.biz/faq/apt-get-hold-back-packages-command>

I need to check the MySQL documentation to see how the database format
has changed from 8.0.27 to 8.0.30.

I've always wanted to get into DevOps, which involves running many apps
(different apps, or copies of the same app) on a server or cloud service
efficiently to save money, and mostly automate it to save time.


Examine the current setup



What the result should look like

(refer again to wordpressOpenBSD.md)
Only list the migrating parts here.

