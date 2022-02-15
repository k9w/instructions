#!/bin/sh

: '	$Id: rename.sh,v 2.5 2019/11/04 06:37:52 kevin Exp $

This file is derived from www.shellscript.sh/functions.html at the
examples called function2.sh and function3.sh. I chose to combine them
with an if statement and name the file rename.sh, since that is what
it does.

This script calls the rename() function in the separate file
common.lib in the same working directory.

The if statement is not working out here. So my next idea (not yet
implemented) is to set a variable $FILELIST to
find . -type f | grep -o -E '\.[^\.]+$' | sort -u
Retrieved from:
https://stackoverflow.com/questions/1842254/how-can-i-find-all-of-the-distinct-file-extensions-in-a-folder-hierarchy

For now, I'm documenting my understanding of regular expressions in
the file ~/bin/learn/my-regex.

find . | grep '\.html$'

09-13 - I'm giving up on this for now and moving on with the tutorial.
function2.sh and function3.sh are good enough for now.

'

. ~/bin/learn/www.shellscript.sh/common.lib

echo $STD_MSG

if [ -e *.txt && -e *.html ]; then
	rename .txt .bak
	rename .html .html-bak
elif [ -e *.txt ]; then
	rename .txt .bak
elif [ -e *.html ]; then
	rename .html .html-bak
else
	return
fi

