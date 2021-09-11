#!/bin/sh

#	$Id: first.sh,v 1.4 2019/09/22 00:05:22 kevin Exp $

# This is a comment!
echo Hello  World	# This is a comment, too!

: '
This is a multi-line comment. It starts after the " : ' " above; and it
ends with the next " ' ". It allows me to have more than would fit onto a
single line of text as a single comment without worrying about
managing line wrap and maintaining pound signs (#) at the beginning of
each line. This saves me unnecessary editing when I edit a commented
paragraph.
'

echo "Hello 	World " 
echo "Hello * World " 
read _line
echo _line
echo "Hello" "World " 
echo Hello "    World " 
echo "Hello "*" World " 

: '
echo `hello` World	<-- this wont work, because `hello` tries to
run hello as a command. hello is not a command; so it wont work.
'

echo 'hello' world 
