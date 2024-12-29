# Automated Remote File Distribution with RDist

[rdist(1)](https://man.openbsd.org/rdist) is a configuration management
automation framework that distributes config files to remote systems.
Each remote system must be running
[rdistd(1)](https://man.openbsd.org/rdistd).

Rdist is similar to Ansible and other configuration management tools.
But it is small and does not require a full language interpreter, such
as Python, to be installed on each system. The control system runs
rdist(1); and each managed server runs rdistd(1).

rdist is included in the OpenBSD base system and is packaged for
FreeBSD, Fedora, and Ubuntu.
