#!/bin/sh

: '	$Id: function.sh,v 2.6 2019/09/22 00:05:22 kevin Exp $

Initial revison is 2.1 because I had previously set test.sh to 2.x.

A simple script with a function ...
'

add_a_user() {
	USER=$1
	PASSWORD=$2
	shift; shift;
	# Having shifted twice, the rest is now comments ...
	COMMENTS=$@
	echo "Adding user $USER ..."
	echo useradd -c "$COMMENTS" $USER
	echo passwd $USER $PASSWORD
	echo "Added user $USER ($COMMENTS) with pass $PASSWORD"
}

###
# Main body of script starts here
###
echo "Start of script ..."
add_a_user bob letmein Bob Holness the presenter
add_a_user fred badpassword Fred Durst the singer
add_a_user bilko worsepassword Sgt. Bilko the role model
echo "End of script ..."

