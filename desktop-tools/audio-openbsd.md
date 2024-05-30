# USB and audio jack headsets with OpenBSD

https://www.openbsd.org/faq/faq13.html


```
# rcctl set sndiod flags -f rsnd/0 -F rsnd/1
# rcctl restart sndiod
# rcctl reload sndiod
```

It may be necessary to reload the Firefox tab playing the audio so
that it shows up as app/firefox0.level in sndioctl.

sndioctl
mixerctl
audioctl

When resuming from suspend, unplug and replug the USB headset and reload
sndiod.

