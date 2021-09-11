#!/bin/sh

#	$Id: var.sh,v 1.6 2019/09/22 00:05:22 kevin Exp $

echo "What is your name?"
read USER_NAME
echo "Hello $USER_NAME"
echo "I will create you a file called ${USER_NAME}_file"
touch "${USER_NAME}_file"

