#!/bin/sh

: '	$Id: exitcodes.sh,v 2.6 2019/09/22 00:05:22 kevin Exp $

A tidier approach: put the test into a separate function

The string "^${1}:" is a basic regular expression (BRE) as described in
re_format(7). Here is what it means:

 - The script is executed as 
./exitcodes.sh kevin

 - ${1} means $1, the first positional parameter according to sh(1)
SPECIAL PARAMETERS; in this case $1 is set to kevin

 - The 1 in $1 is surrounded by curly braces {}, which is required for
$10 and higher according to sh(1). In my testing, it affects if the
username is printed in the error "Sorry, cannot find" when the
username is not found

 - ^ means ${1} should only be matched if it is at the start of a
word; if the string is not the first characters of a word in
/etc/passwd, it is not a valid match for grep

 - : is similar to ^, except that a word in /etc/passwd should only be
matched if the word containing the string has no characters after it;
if the string is not the last characters of a word in /etc/passwd, it
is not a valid match for grep

 - The effect of ^ and : is that $1 is only matched if grep finds the
exact word "kevin" in /etc/passwd

'

check_errs() {
	# Function. Parameter 1 is the return code
	# Para. 2 is text to display on failure.
	if [ "${1}" -ne "0" ]; then
		echo "ERROR # ${1} : ${2}"
		# as a bonus, make our script exit with the right
		# error code.
		exit ${1}
	fi
}

### main script starts here ###

grep "^${1}:" /etc/passwd > /dev/null 2>&1

check_errs $? "User ${1} not found in /etc/passwd"

USERNAME=`grep "^${1}:" /etc/passwd | cut -d ":" -f 1`

check_errs $? "Cut returned an error"

echo "USERNAME: $USERNAME"

check_errs $? "echo returned an error - very strange!"
