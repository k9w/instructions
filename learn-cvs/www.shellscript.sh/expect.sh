#!/bin/sh

: '	 $Id: expect.sh,v 2.3 2019/09/22 00:05:22 kevin Exp $

Adapted from: shellscript.sh/expect.html

Synopsis:
expect.sh | telnet > file1

'

host=127.0.0.1
port=23
file=file1
MAX_WAITS=5

echo open ${host} ${port}

while read l; do
	c=`echo ${l} | cut -c1`
	if [ "${c}" = "E" ]; then
		expected=`echo ${l} | cut -d" " -f2-`
		delay=`echo ${l} | cut -d" " -f1 | cut -c2-`
		if [ -z "${delay}" ]; then
			sleep ${delay}
		fi
		res=1
		i=0
		while [ "${res}" -ne "0" ]; do
			tail -1 "${file}" 2> /dev/null | grep "${expected}" > /dev/null
			res=$?
			sleep $i
			i=`expr $i + 1`
			if [ "${i}" -gt "${MAX_WAITS}" ]; then
				echo "ERROR: Waiting for ${expected}" >> ${file}
				exit 1
			fi
		done
	else
		echo ${l} | cut -d" " -f2-
	fi
done < expect.txt
