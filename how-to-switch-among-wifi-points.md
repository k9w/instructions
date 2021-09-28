08-20-21

https://www.reddit.com/r/openbsd/comments/p8ml4g/switch_openbsd_laptop_from_preferred_wifi_to

Thanks guys. I was already using 'join SSID wpakey KEY' in
hostname.if(5) for all my SSIDs and had just switched successfully
from 'dhcp' to 'inet autoconf' to get faster boot time with
dhcpleased(8). Roaming between access points at home, at work, and on
my hotspot has continued to work well.

To the one who pointed out the manpages, I had already read through
those (even the long ifconfig(8) manpage) and still didn't get how to
switch among multiple in-range wifi's. That's why I asked in this
thread.

But you guys did point me in the right direction. Here's what I found
worked.

----

Use ifconfig(8) to find out your wifi driver. This guide assumes you
use the iwm(4) driver for Intel chipsets and have all your SSIDs in
/etc/hostname.iwm0 as described above.

Start with all the SSIDs and wpakeys in /etc/hostname.iwm0 (if you have
a wifi card supported by the iwm driver).

ifconfig will do a scan and auto-join the SSID, and channel of that
SSID, on the list (cached) which has the best signal. Then dhcpleased
will auto-obtain an IP address (much faster than dhclient). You can
check which SSID that is with:

```
# ifconfig iwm0 scan
```

In this guide, we call that SSID1. It is not necessarily the first SSID
listed in hostname.if.

You can check the IP address and additional info ifconfig doesn't tell
you with dhcpleasectl. Below includes output while connected to an iOS
hotspot.

```
# dhcpleasectl show interface iwm0
iwm0 [Bound]: 
	server: 172.20.10.1
		IP: 172.20.10.4/255.255.255.240 
	routes: 0.0.0.0/0.0.0.0 - 172.20.10.1
	   DNS: 172.20.10.1 
	 lease: 22h 57m 26s
```

To switch to another cached SSID, unjoin from the currently-connected
one.

```
# ifconfig iwm0 -join SSID1
```

ifconfig should automatically associate with the next best signal SSID
cached in hostname.if. Then dhcpleased should auto-obtain an IP address
lease for that connection.

To switch to a third in-range SSID, unjoin from the second one.

``` # ifconfig iwm0 -join SSID2 ```

If you later decide to re-join SSID1 or SSID2, you need to re-join with
the full wpakey.

``` # ifconfig iwm0 join SSID1 wpakey KEY ```

But if SSID3 has sufficient signal strength, ifconfig won't switch back
to SSID1 or 2 just because you re-cached 1's or 2's credentials. You'll
likely need to unjoin from SSID3.

``` # ifconfig iwm0 -join SSID3 ```

If it's SSID1 you want to go back to, you could just restart
/etc/netstart, which reloads the values from hostname.if afresh.

``` # sh /etc/netstart ```

----

One thing I noticed is that when I join the iOS hotspot, switch to
another SSID, and back to the hotspot later, ifconfig doesn't get the IP
address it had before, or any at all, not unless I turn off the hotspot
and back on in the iOS settings.

This issue does not occur when reconnecting to a Comcast gateway or
OpenBSD router (which sits on the LAN side of the Comcast gateway), and
to my Android hotspot. All three servers seem to readily resume the
prior dhcp lease my OpenBSD laptop had before, and (unlike the iOS
hotspot) advertise the IP info again to ifconfig and dhcpleasectl.

I remember seeing comments on undeadly.org that dhcpleased does not
record obtained leases in a file but needs to be queried by
dhcpleasectl, or (according to the manpage) through the unix socket
file.

I don't recall if dhclient also failed to re-obtain IP address info in
this case.
