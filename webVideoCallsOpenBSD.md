12-01-2022

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

