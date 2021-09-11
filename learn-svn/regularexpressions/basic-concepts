	$Id: my-regex,v 2.4 2019/09/22 22:35:33 kevin Exp $

09-13-19

This file documents my understanding of regular expressions based on
tutorials I read and ultimately on the specification for basic regular
expressions and extended regular expressions for OpenBSD described in
re_format(7).

The first tutorial I checked out was Code Camp's regular expresisons
with JavaScript at:
https://www.youtube.com/watch?v=ZfQFUJhPqMM

Next I am working my way through re_format(7) to piece it together in
this file.

--------
ERE

One or more branches:

branch|branch


In a branch: one or more pieces. A match for the first is followed by
a match for the second piece, etc.

piece


Each piece is an atom plus....

atom  plus a single  * + ? or bound

atom*  matches zero or more occurrences of atom
atom+  matches one or more occurrences of atom
atom?  matches zero or one occurrences of atom


A bound sets a custom number of times to match the atom to get a true
result. The bound consists of {} with a number, maybe a comma, and
maybe a second number. Numbers can be from 0 to 255 inclusive. The
second number must be greater than the first number. Examples:

{2}		match exactly two times
{3,}		match three or more times
{7,255}		match a sequence of 7 through 255 matches of atom

An atom can consist of:

(regex)			matching a part of the regex
()			matching the null string
[bracket regex]		(see below)
.			matching any single charater
^			matched if regex is a the beginning of a line
$			matched if regex is a the end of a line
\			to escape one of the characters ^.[$()|*+?{\
{ non-number		is not a bound; matches literally a {
{1}			is a bound, with a number
a regex may not end with a '\'

[list of characters]	matches any single character in the list
[^list of characters]	matches any single character NOT in the list
[0-9] or [A-Za-Z]	matches the range of characters inclusive
to match a ], list it first
to match a -, list it at the start or at the end
to match a range ending in -, enclose it in [. .]
with these and other exceptions using [, all special characters lose
their special meaning in a bracket expression

[.string to match.] is a collating element list of those characters
[[.ch.]]*c matches chchc
[[=characters=]] is an equivalence class, meaning
[:alnum:] is a character class for alpha-numeric characters; see manpage
[[:<:]] or [[:>:]] match the null string at start or end of a word



--------
BRE

differ from ERE:

| + ? are ordinary characters
bounds are \{ \}, { } are ordinary characters
sub expressions are with \( \), ( ) are ordinary characters
^ is ordinary except at the start of RE
$ is ordinary except at the end of RE
* is ordinary if it is at the start of RE or subexpression
\([bc]\)\1	matches bb or cc, not bc. this example is a
		back-reference; manpage BUGS says to avoid them

char		any non-special character matches itself
\char		any backslash-escaped character matches itself, except 
		{ } ( )
.		matches any single character except a newline \n
[char-class]	matches any single character in char-class
[a-z]		regular char class
[:alnum:]	literal expression to match all alpha numeric
		characters; to match -, list it first or last
[^char-class]	matches any character NOT in the char-class; otherwise
		behaves like [char-class]
^re		anchors re to the start of the line, matching it only
		if it is found at the start of a line; if specified
		alone, ^ matches itself
re$		same as above with ^re, except it anchors the re at
		the end of a line, and matches re only if re is found
		at the end of the line
[[:<:]]		match single char at start of word
[[:>:]]		match single char at end of word
\(re\)		defines sub-expression, or an re inside another re;
		sub-expressions may be nested; they are ordered
		relative to their left delimiter
re*		matches re zero or more times
\{2\}		match exactly two times
\{3,\}		match three or more times
\{7,255\}	match a sequence of 7 through 255 matches of atom

