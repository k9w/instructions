# OpenBSD PF Firewall

This is the PF ruleset I have setup on my home OpenBSD router since
2019.

```
set skip on lo0
block all
match in all scrub (no-df random-id max-mss 1440)
match out on egress inet from !(egress:network) to any nat-to (egress:0)
pass out on egress
pass on vether0
pass on { em1, em2, em3 }
```

Here it is with comments.

```
# Default block policy is to drop the packet.
# set block-policy drop

# Skip the loopback interface, allowing all traffic through it.
set skip on lo0

# Block all traffic in every direction, except what is specifically
# allowed to pass in the next rules that follow. 
block all

# Narmalize incoming packets: clears the dont fragment bit, replaces the
# predictable IPv4 ID field with a random ID if the packet has not been
# fragmented, and sets the maximum segment size to 1440 bytes.
match in all scrub (no-df random-id max-mss 1440)

# Perform Network Address Translation from any interface other than
# egress to any destination reached through egress.
match out on egress inet from !(egress:network) to any nat-to (egress:0)

# Pass traffic out to the internet that originates from the router and
# from any LAN host that can reach the router.
pass out on egress

# Pass traffic between any LAN host and the router, and out to the 
# internet; between any LAN hosts connected to the same Ethernet port 
# on the router for example, connected to the same external wireless
# access point or external switch; but not between LAN hosts
# connected to different Ethernet ports on the router.
pass on vether0

# Pass traffic between LAN hosts connected to different Ethernet ports
# on the router.
pass on { em1, em2, em3 }
```

