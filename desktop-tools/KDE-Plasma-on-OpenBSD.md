document started 04-22-2024

Installed kde-plasma-extras and followed package readme at
`/usr/share/docs/pkg-readmes/kde-plasma`.

Issues:

Dark mode from system settings does not work correctly. It usually does
not apply to the body of the system settings window. When it does apply,
the text remains the original dark color and is unreadable on the dark
background. 

Konsole terminal cannot be fully full-screened. The scroll bar cannot be
removed. The top menu bar cannot be fully hidden in full screen mode.
Adding or removing menu bar components does not usually apply. The left
side items on the top menu bar cannot be added back once removed.

Alt-tab to switch apps does not work at all.

When docked to multiple monitors, the super key to open the applications
menu does not work at all.

System Settings > Display Configuration - Does not correctly identify or
adjust placement, identification, or display of multiple monitors. The
external screens sometimes go black and only show the mouse if moved
across them. One of the monitors did not even show the mouse moving
across. ArandR still worked to arrange the monitors.

When connected to multiple monitors, the Task Manager (bottom bar) shows
bigger than when only the laptop screen is connected. And the pinned app
icons are smashed together and overlap. And when opening the application
menu with the mouse, the menu itself opens on a different monitor than
the bottom bar and is also too big for the screen.

When disconnected from external monitors, the built-in display does not
fully revert to sole-display settings. This happens in cwm and any
desktop environment which does not take special care to update the
display configuration when external monitors are connected or
disconnected. Plasma should have special settings to handle this. But it
does not work as intended.

When I sysupgraded to the May 10th snapshot, updated all packages,
followed the pkg-readme from scratch and rebooted, the task bar and
start menu showed bad font colors on a transparently absent
background, which was un-readable against the default plasma
wallpaper. It would no longer apply any appearance setting I changed,
would not let me move the windows around, or let me unhide the window
menus or show the minimize, maximize, or exit buttons of each window.

I have not yet uninistalled and re-installed kde-plasma-extras and all
its dependencies.
