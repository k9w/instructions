# 09-10-21

In ~/.tmux.conf, I have my prefix key remapped from C-b to `
(backtick).

Here is how to copy text from one tmux window or pane to another.

Enter copy mode:

```
` [
```

Set the Mark to start selecting text:

```
C-SPC
```

Use the arrow keys or C-p to select the text you want.

```
C-p
```

Copy the selection with Alt-W. This also exits copy mode.

```
M-w
```

Move to the window, pane, or file you want for the copied text to go.
Then paste it with ` ].

```
` ]
```

