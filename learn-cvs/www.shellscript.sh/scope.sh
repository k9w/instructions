#!/bin/sh

: '	$Id: scope.sh,v 2.5 2019/09/22 00:05:22 kevin Exp $

This script demonstrates how the positional parameters can be one set
of values when the script is executed, and they can be set to another
set of values by the time the script exits.

Compared to r2.2, this revision of the script ignores any positional
parameters passed to it.
./scope.sh a b c

Produces no different result than:
./scope.sh	# called with no positional parameters

'

myfunc() {
	echo "\$1 is $1"
	echo "\$2 is $2"
	# cannot change $1 - we'd have to say:
	# 1="Goodbye Cruel"
	# which is not a valid syntax. However, we can
	# change $a:
	a="Goodbye Cruel"
}

### Main script starts here 

a=Hello
b=World
myfunc $a $b
echo "a is $a"
echo "b is $b"
