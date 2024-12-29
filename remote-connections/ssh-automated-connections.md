# Restricting SSH Connections for Automation

Before following this guide, you should implement public key
authentication, and ideally verification and rotation.

This setup is required to secure SSH connections for automated tasks
such as backups and configuration management.

Otherwise you would need to use passwordless and keyless (completely
open and unsecured) SSH access for scripts.
