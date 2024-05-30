12-01-2022

This guide explains how to configure a fresh OpenBSD install for common
laptop usage.



# Video conferencing with Firefox or Chromium

Want to use audio, video, and screensharing with Jitsi on Firefox and
Chromium for softPLUG meetings.

```
# echo kern.{audio,video}.record=1 >> /etec/sysctl.conf
# chown <username> /dev/video0
```

Enable screensharing with steps from package readme. For Firefox, that is:
`/usr/local/share/doc/pkg-readmes/firefox`


Asked today on OpenBSD matrix channel about screensharing.


k9w
How do I allow Firefox or Chromium to share my screen in video
conferencing such as Jitsi? I got the camera and microphone to work. But
openbsd kills the browser when I try to screen share. What permission do
I need to change?
qbit
you need to open up the pledges 
they are set in /etc/firefox
or /etc/chromium 
k9w
Thanks. Will do.
landry
you need to disable pledge for the main process for firefox
because it uses shmget for which there's no existing pledge
its in the FUCKI^Wfine package-readme
Screen sharing needs shmget() which isnt available when pledge() is
active, so
you will have to disable pledge for the main process.
in /usr/local/share/doc/pkg-readmes/firefox
qbit
landry: maybe the startpage should be set to the readme? :D
landry
that.. would be an idea. except that would mean adding an unveil path to
be able to open the readme :)
qbit
but you could just make it r for that one file, no? 
landry
yeah , i'll test that :)




https://www.reddit.com/r/openbsd/comments/li0fcd/disabling_pledge_in_firefox

As per /usr/local/share/doc/pkg-readmes/firefox:

To disable pledge and/or unveil support when troubleshooting, set the
corresponding pledge or unveil file in
/etc/firefox/{unveil,pledge}.{main,content,gpu} to contain
just "disable".

So it looks like you need just disable in all three files - /etc/firefox/pledge.{main,content,gpu}.



cd /etc/firefox
cp pledge.main pledge.main.bak
cp pledge.content pledge.content.bak
cp pledge.gpu pledge.gpu.bak

For each file, remove all lines and replace with 'disable' on its own
line. Commenting out the other lines wont' work.

For firefox crashing during jitsi calls, Andrew Fresh said to check that
my account is in the staff login class.

Check with:

```
# vipw
```

He also has his own launcher for firefox to set ulimits higher.


```
$ cat /home/afresh1/bin/firefox
#!/bin/sh

ulimit -n $(ulimit -Hn)
ulimit -d $(ulimit -Hd)
exec $_firefox "$@"
```

<https://github.com/michaeldexter/occambsd>

