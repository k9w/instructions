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

Here is another excellent pf ruleset from OpenBSD misc mailing list,
with wireguard.

<https://marc.info/?l=openbsd-misc&m=174071058028238>

```
set reassemble yes no-df

set skip on lo

WAN="vio0"

antispoof quick for $WAN
antispoof quick for wg1

# since we're dropping all packets by default, we don't need to explicitly worry
# about non-routable packets.
block drop all
match in all scrub (no-df random-id reassemble tcp)

# people like blocking ICMP, but it breaks parts of IPv4, and really breaks IPv6
# if you must, you can block echo-request and echo-reply, but it really doesn't
# gain you anything except making it harder to troubleshoot things.
pass in on any inet proto icmp from any to any
pass in on any inet6 proto icmp from any to any

# make sure you can ssh in
pass in on any proto tcp from any to self port 22

# your almost identical rule will work, but using parentheses will allow pf to
# gracefully handle interface address changes. even if you don't think it'll
# happen, i like having this. we don't need an explicit pass out for wg1, since
# that is handled below.
pass in on wg1 from (wg1:network)

# i've had issues with tcp mss detection on wireguard interfaces in the past, so
# i generally clamp the mss. ymmv; if you have issues with ssh over the
# wireguard tunnel, try this. if you don't, you can leave it out.
match out on wg1 from any to any scrub (max-mss 1380 random-id)

pass out modulate state
```

