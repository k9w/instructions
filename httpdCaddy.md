Make an OpenBSD chroot and change root into it. 

Then follow caddy's Install from Source instructions at <https://caddyserver.com>.

Check the compiled binary for library dependencies, search the host
systems for those same libraries, create ~/bin and add it to PATH. Copy
caddy executable from chroot to the host ~/bin.

caddy run

I had curl installed already as dependency from another package. I don't
yet know how to do this with OpenBSD's ftp.

curl localhost:2019/config

caddy stop
caddy start
