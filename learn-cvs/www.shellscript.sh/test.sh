#!/bin/sh

: '	$Id: test.sh,v 2.12 2019/09/22 00:05:22 kevin Exp $

# From : ' to ' is a multi-line comment.

X=$((RANDOM % 2048))
echo $X
'

# If X is less than zero
if [ "$X" -lt "0" ]; then
	echo "X is less than zero"
fi

# If X is greater than zero
if [ "$X" -gt "0" ]; then
	echo "X is more than zero"
fi

# If X is less than or equal to zero
[ "$X" -le "0" ] && \
	echo "X is less than or equal to zero"

# If X is greater than or equal to zero
[ "$X" -ge "0" ] && \
	echo "X is more than or equal to zero"

# If X is exactly equal to zero
[ "$X" = "0" ] && \
	echo "X is the string or number \"0\""

# True if X equals "hello"
[ "$X" = "hello" ] && \
	echo "X matches the string \"hello\""

# True if X does not equal exactly "hello"
[ "$X" != "hello" ] && \
	echo "X is not the string \"hello\""

# True if X has a value that is longer than zero characters
[ -n "$X" ] && \
	echo "X is of nonzero length"

# True if X matches a regular file on the local filesystem
[ -f "$X" ] && \
	echo "X is the path of a real file" || \
	echo "No such file: $X"

# True if X is a file and is executable
[ -x "$X" ] && \
	echo "X is the path of an executable file"

# True if X is a file that has been modified more recently than /etc/passwd
[ "$X" -nt "/etc/passwd" ] && \
	echo "X is a file which is newer than /etc/passwd"
