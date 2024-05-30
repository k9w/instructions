#!/bin/sh

#	$Id: for.sh,v 1.10 2019/09/22 00:05:22 kevin Exp $

for runlevel in 0 1 2 3 4 5 6 S ; do
	mkdir rc${runlevel}.d
done

