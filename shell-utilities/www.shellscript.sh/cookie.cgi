#!/bin/sh

#	$Id: cookie.cgi,v 2.2 2019/09/22 00:05:22 kevin Exp $

dir=/usr/share/games/fortunes

echo "Content-type: text/html"
echo
cat - << EOFHTML
<html> <head> <title>Fortune Cookie Loader</title> </head>
<body text=white bgcolor=black> <center> <h1>Fortune Cookie Loader</H1>
</center> 
<BR> <BR> <BR>
<form action=./fortune.cgi method=get>

From Directory:
<input type=text name=cookiedirectory value=$dir size=30c>
<HR>
Subject:
<select name=givenfile>

EOFHTML


for i in `ls -1 ${dir} | grep -v "\.dat$"`
do
	echo "<option value=${i}>${i}</option>"
done

cat - << EOFHTML

</select>
<BR>
Use only this file: 
<input type=checkbox name=usegivenfile>
<HR>
Only Long Cookies:
<input type=radio name=cookiels value=long>
<BR>
Only Short Cookies: 
<input type=radio name=cookiels value=short>
<BR>
A Short cookie is less than
<input type=text size=4c name=cookielength value=160>
characters long
<BR>
Both Long and Short Cookies: 
<input type=radio name=cookiels value=both checked>
<HR>
Text Colour: 
<select name=textcolour>

EOFHTML
for i in lightgreen green black white red yellow
do
	echo "<option value=$i>$i</option>"
done
echo "</select> <BR>Background Colour: "
echo "<select name=bgcolor>"
for i in black green white red yellow
do
	echo "<option value=$i>$i</option>"
done
echo "</select>"

cat - << EOFHTML
<HR>
<input type=submit value="Show me the Cookies!">
... or ...
<input type=reset value="Reset to Defaults">
</form>
</body>
</html>

EOFHTML

