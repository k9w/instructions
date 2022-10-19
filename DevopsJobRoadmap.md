9-15-2022

Serve a subdomain from a webserver app with TLS, generate the TLS
certificate (per site, not wildcard) using OpenBSD's acme-client and
Let's Encrypt to start.
- Webservers: OpenBSD's httpd, Apache, Nginx, Lighttpd, Caddy
- Acme-clients: OpenBSD's acme-client, Lego, Certbot (Apache acme?,
Nginx acme?)
- Setup each webserver one at a time to listen on standard ports,
serve a subdomain in a multi-vhost mode (able to easily add another
subdomain beside it in the config file), and obtain a Let's Encrypt
TLS certificate.
- Remove the certificate, stop that webserver, and repeat with the
next webserver
- Convert the setup for all webservers to run at once; each serve its
own subdomain and TLS certificate, on non-standard TCP ports,
1080/1443, 2080/2443, etc
- Pick one server, starting with OpenBSD's relayd to listen on standard
ports 80/443, optionally handle TLS, and proxy connections to the rest
of the webservers. Once relayd works, switch to Apache proxy, nginx,
etc. The proxy should be a separate daemon (not just worker) from the
Apache etc already running behind the proxy
- At this point, start generating TLS certs with acme-clients other
than OpenBSD's: lego, certbot, etc
- Optionally evaluate and use other proxy apps too (varnish?)
- Scale up to multiple (two) sites/subdomains per webserver daemon
(not practical with caddy?)
- Scale up to multiple (two) daemons per webserver (two Apache
daemons, two Nginx deamons, etc)
- Later when you move to FreeBSD jails, switch from OpenBSD's
acme-client to acme.sh on FreeBSD.

Setup first apps to host and server out to the internet.
- Import my wife's Wordpress website from one-click-install on Digital
Ocean. Document the migration.
- Setup a Hugo website for myself with select guides from this
Instructions repo as content.
- Setup Nextcloud to host family pictures and videos. Setup rsync to
copy content from home nas. (Address new content and integration with
Google photos later.)
- (later) Dendrite, Matrix, Session, or another messaging server app
- (later) Minecraft, Xonitoc, or another game server app

Logging, backup, monitoring

- Investigate and document syslog on OpenBSD and logs for all the apps
covered so far, including any built-in methods to back them up
remotely (push mode in syslog).
- Implement rsync pull-mode backup on another server. Test by hand
with special SSH key requiring password each time (do not use
ssh-agent).
- Implement SSH Certificates and VPNs where it makes sense
- Run SSH Certificate Authority on a separate cloud VM server from the
production server applications. Later, you might choose to use this
server for monitoring and log collection. Or it could be separate
- Use VPN tunnels where it makes sense
- Activate automated pull-mode backups with rsync.


Implement inexpensive cloud storage, and backups
- Wasabi object storage as primary data repository
 -- Use cloud block storage or local storage where object storage does not
    make sense for the primary data source
- Backblaze B2 object storage as primary backup repository
- Borgbase as secondary backup repository
- Evaluate keeping rsync.net as a third backup if the cost makes sense
- What tools to use for object storage and backup?
 -- FTP, other S3-compatible apps, borg, rsync, other rsync wrapper?

Test the backups by standing up a new VM server with all the server apps
- Document it and prep to automate it later with Ansible and Terraform

Implement monitoring, log collection, and graphing
- Monitoring: Nagios/Icinga
- Graphing: Grafana
- Find and use a good mobile app: Anag for Android; find a good app for 
iOS

Automate security and feature updates and full rebuild from backup
restore of all the above, except for the mobile apps
- Ansible:
- Terraform: 

Migrate production and management apps to containers
- Produciton apps: 
- Management apps: 
- Jails: 
- Containers: Podman and Docker for Linux
- Rearchitect management apps and automation for jails and containers.
This could include automatically rebuilding a container to apply a
security or feature update using container-compose.

Implement container orchestration
- Kubernetes for Linux
- That or a similar option for BSDs?

Dive deep into the specifics of one cloud provider
- Choose AWS or Azure
- Reimplement all of the above with a mix or strong favor toward that
provider's vendor lock in tools

Implement GitOps for all of the above, including the mobile app setup
and config, if practical
- Post everything on my Github profile in addition to my self-hosted git
repo

Prepare a talk and live or pre-recorded demo of all the above for the
PDX DevOps meetup or similar meetup

