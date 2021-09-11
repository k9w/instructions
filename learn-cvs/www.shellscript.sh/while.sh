#!/bin/sh

#	$Id: while.sh,v 1.8 2019/09/22 00:05:22 kevin Exp $

while read f ; do
	case $f in 
		hello)		echo English	;;
		howdy)		echo American	;;
		gday)		echo Australian	;;
		bonjour)	echo French	;;
		"guten tag")	echo German	;;
		*)		echo Unknown Language: $f
			;;
	esac
done < myfile

# The section below is a multi-line comment.

: '
After I completed this exercise from shellscript.sh I appended the
contents of myfile here for archiving in RCS and deleted the working
file.

hello
howdy
gday
bonjour
guten tag
balony sandwich
'

