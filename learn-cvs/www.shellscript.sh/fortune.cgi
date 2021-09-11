#!/bin/sh

#	$Id: fortune.cgi,v 2.2 2019/09/22 00:05:22 kevin Exp $

echo "Content-type: text/html"
echo
echo "<html> <head> <title>Fortune Cookie</title> </head>"


oIFS=$IFS
IFS="&"
echo $QUERY_STRING|sed s/"%2F"/"\/"/g |sed s/"\%23"/"#"/g>
/tmp/cookie.$$
. /tmp/cookie.$$
rm /tmp/cookie.$$
IFS=$oIFS

cat - << EOFHTML
<body text="$textcolour" bgcolor="$bgcolor"> <center> <h1>Fortune
Cookie</H1> </center> 
<BR>
<PRE>
EOFHTML


PARM=" "
echo -n "Reading "

if [ "$cookiels" = "long" ]
then
	PARM="-l" 
	echo -n "long "
	ckls=">"
fi

if [ "$cookiels" = "short" ]
then
	PARM="-s" 
	echo -n "short "
	ckls="<"
fi

if [ "$cookiels" = "both" ]; then
	echo -n "all "
fi

	if [ "$cookiels" != "both" ]; then
		PARM="-n ${cookielength} ${PARM}"
		echo -n "(${ckls} ${cookielength} character) "
	fi

if [ -n "${usegivenfile}" ]; then
	PARM="${givenfile} ${PARM}"
	echo -n "cookies from ${givenfile} ..."
else
	PARM="${cookiedirectory} ${PARM}"
	#echo -n "all cookies in ${cookiedirectory} ..."
	echo -n "cookies..."
fi
echo
echo "$ /usr/games/fortune $PARM"
echo "<HR> <BR> <BR> <BR>"

/usr/games/fortune ${PARM}
echo "</pre>"

cat -- << EOFHTML

<BR> <BR> <BR> <HR>
<a href="/cgi-bin/cookie.cgi">Choose new settings for cookie</a>
</body>
</html>

EOFHTML

