#!/bin/sh

: '	$Id: factorial.sh,v 2.3 2019/09/22 00:05:22 kevin Exp $

This script showcases a function, factorial(), which calls itself
recursively, at the j= line below.

Through testing, I have found valid inputs are:

Valid inputs that produce number results higher than 1:
 * Positive integers from 2 to 20; 21 and up produces an error

Inputs that return 1:
 * The number zero and negative integers to infinity, not limited to 99
characters long as in the expr(1) command.
 * Any fraction that does not equal a positive integer
 * an sequense of letters and numbers, that do not start with numbers,
that does not contain a lowercase x surrounded by whitespace

Invalid inputs are:
 * Any string containing a lowercase x surrounded by whitespace
 * Fractions that equal a positive integer

 numbers 1 to 20; higher
numbers give an overflow error. The singular letter x is invalid;
because the script reads it as a variable outside the function. Any
combination of letters, numbers, and whitespace, including an x with
another character, is valid - not punctuation.

'

factorial() {
	if [ "$1" -gt "1" ]; then
		i=`expr $1 - 1`
		j=`factorial $i`
		k=`expr $1 \* $j`
		echo $k
	else
		echo 1
	fi
}

while : ; do
	echo "Enter a number:"
	read x
	factorial $x
done
