#!/bin/sh

: '	$Id: cvs-ports-src-xenocara.sh,v 2.2 2019/11/04 07:11:55 kevin Exp $

If there is a log file from last time, delete it.

For each directory:
/usr/{ports,src,xencara}

do cvs -q up -Pd

Save the output to a log file in ~/cvs-head/log

'

LOG=~/cvs-head/log

if [ -e $LOG ]; then
	rm $LOG
fi

cd /usr

for d in ports src xenocara; do
	cd "$d" && cvs -q up -Pd >> $LOG 2>&1 &
done
