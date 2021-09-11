#!/bin/sh

: '	$Id: trap.sh,v 2.3 2019/09/22 00:05:22 kevin Exp $

Adapted from: shellscript.sh/trap.html

trap tells how the script should handle signals from the shell, such
as Ctrl-C for signal 2 to SIGINT, to quit and return to the parent
shell. If the script does not have a method to catch and process these
signals on its own, the shells default methods are imposed on the
script. Trap.sh is a good example of how to give the script that
addditional choice or leeway.

v2.2 prints the value of X at 1 and increments it up by 1 per second.
Then for the first two times I type Ctrl-C to quit, it doesn't quit but
instead increments X up by 500 and then resumes counting up by one. On
the third time, it says I'll quit and quits.
 
'

trap 'increment' 2

increment() {
	echo "Caught SIGINT ..."
	X=`expr ${X} + 500`
	if [ "${X}" -gt "2000" ]; then
		echo "Okay, I'll quit ..."
		exit 1
	fi
}

### main script

X=0
while : ; do
	echo "X=$X"
	X=`expr ${X} + 1`
	sleep 1
done

