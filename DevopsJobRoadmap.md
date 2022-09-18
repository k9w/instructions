9-15-2022

Have something to host, to run.
- Wife's Wordpress website
- My Hugo website
- Nextcloud or another solution for family pictures and videos
- Dendrite, Matrix, Session, or another messaging server app
- Minecraft or another game server app for wife and son

Start off running all of them together on one OpenBSD cloud Virtual
Machine (VM)
- Prefer OpenBSD's default httpd webserver
- Set OpenBSD's relayd to listen for incoming connections on ports 80
and 443, handle 443 and TLS, and proxy the secured connections on
through to httpd, and optionally Nginx, Apache and Lighttpd
- Ensure at least two apps are served together by the same webserver,
and the same instance/daemon of the webserver
- Run multiple daemons of the same webserver for at least one
application or a daemon for each application

Migrate or implement TLS for all web services
- No wildcard certs. Perfer the following tools:
- OpenBSD - acme-client
- FreeBSD - acme.sh
- Linux Lego or Certbot (not pre-containered)

Implement SSH Certificates and VPNs where it makes sense
- Run SSH Certificate Authority on a separate cloud VM server from the
production server applications. Later, you might choose to use this
server for monitoring and log collection. Or it could be separate
- Use VPN tunnels where it makes sense

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

