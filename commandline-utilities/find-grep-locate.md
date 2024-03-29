# Find files and text strings in them


--------
FIND command


find uses shell-style pattern matching, or wildcards, documented in
glob(7)

find file1 and file2

```
$ cd /home/kevin/learn/www.shellscript.sh
$ mkdir sdir
$ cd sdir
$ touch file1 file2
$ cd ../..
$ pwd
/home/kevin/learn

$ find . -name file*
./www.shellscript.sh/sdir/file1
./www.shellscript.sh/sdir/file2

$ find ~/bin/learn/www.shellscript.sh/sdir -name file* -delete
$ find ./www.shellscript.sh -name sdir -delete
```

Match a file* case-insensitive.

```
$ find . -iname file*
```

Delete sdir and file1 and file2 in that directory.

```
$ find . -name sdir -delete
```

Match any path that matches pattern, in glob(7), similar to -name and
-iname. Forward slashes / are treated as normal characters and do not
need to be escaped.

```
$ find . -path pattern
```

For example, to search /usr/ports for all files and directories with 
*emacs* in the name.

```
$ cd /usr/ports
$ find . -name *emacs*
./editors/emacs
./editors/uemacs
./editors/xemacs21
./editors/xemacs21-sumo
./inputmethods/anthy/pkg/DESCR-emacs
./inputmethods/anthy/pkg/PLIST-emacs
./lang/apl/patches/patch-src_emacs_mode_TcpListener_cc
./lang/apl/patches/patch-src_emacs_mode_UnixSocketListener_cc
./mail/mailest/files/dot.emacs
./textproc/p5-Text-Autoformat/files/dot.emacs
```

If we use -path instead of -name, find returns a far larger list of
every item in any directory with emacs in the name (not listed here
because it's too long).

```
$ find . -path *emacs*
```

Match files with exact permisssions.

```
$ find . -perm 644
```

Match files with at least these permisssions or more permissive (higher
numbers).

```
$ find . -perm -644
```

For all files and directories with permission 755, change their
permissions to 775.

```
$ find . -perm 755 -exec chmod 775 {} \;
```

Search ~ for files or folders containing *learn* at least 3 directories 
deep, and at most 5 directories deep.

```
$ find . -mindepth 3 -maxdepth 5 -path *learn*
```

This returns a bunch of results in my cvs and svn repos (too long to
list here). These results are not found by the next command.

Search ~ for files or folders containing *learn* at least 7 directories
deep, and at most 10 directories deep.

```
$ cd /home/kevin
$ find . -mindepth 7 -maxdepth 10 -path *learn*
./cvs-head/ports/math/py-scikit-learn/pkg/CVS/Root
./cvs-head/ports/math/py-scikit-learn/pkg/CVS/Repository
./cvs-head/ports/math/py-scikit-learn/pkg/CVS/Entries
./cvs-head/ports/x11/kde-applications/artikulate/patches/patch-liblearnerprofile_src_CMakeLists_txt
```

This did not work as intended. Instead, find and delete the files
first; then find and delete the directory.

List all files not modified in the last 290 days.

```
$ find . -mtime 290
```

List files modified less than 1000 minutes ago but more than 10
minutes ago.

```
$ find . -mmin -1000 -mmin +10
```

List files modified less than 1000 dayss ago but more than 10 days
ago.

```
$ find . -mtime -1000 -mtime +10
```

List all empty files in the system, ignoring permission denied errors.

```
$ find / -type f -empty 2> /dev/null
```

Same but find all empty directories.

```
$ find / -type d -empty 2> /dev/null
```

Same but find all types of files and directories.

```
$ find / -empty 2> /dev/null
```

Find all regular files and grep for dnssec; print each file name
matched and the line of text matched. the semicolon ; must be escaped by
a backslash \ so that the shell does not interpret it, but passes it
over to the find command.

```
$ find /usr/src/usr.sbin -type f -exec grep -H 'dnssec' {} \;
$ find . -exec grep OpenBSD {} \;
```

similar to -exec. But find asks for confirmation before running utiilty
such as grep.

```
$ find . -ok
```

Match all files bigger than 99999 512-byte blocks in size.

```
$ find / -size +99999 2> /dev/null
```

Locate and remove all .core files in the current directory, not sub
directories. Ending the command in + instead of ; causes exec to pass
sets of results to rm, instead of executing rm for each match found. I
use maxdepth of 1 because my home folder has a ports tree that might
have .core files that I don't want to delete.  find . -name *.core
-maxdepth 1 -exec rm {} +


OPERATORS

Find calls the above flags 'primaries'. They may be combined using the
following 'operators'. ( ) ! are special shell characters and must be
escaped with \.

```
( expression )   <- typed as \( expression \)

! expression  <- typed as \! expression
-not expression

expression -a expression
expression -and expression
expression expression

expression -o expression
expression -or expression
```

Match files /usr/src ending in .digit but skip /usr/src/gnu. find(1)
says -o is an OR operator. But here it does not appear to be an OR
operator. Find returns no results with -o left out. Need to
investigate and ask a friend for clarification.

```
$ find /usr/src -path /usr/src/gnu -prune -o -name \*.[0-9]
```


--------
LOCATE command

OpenBSD updates the locate database weekly. This week, 9-30-19, emacs
was updated from 26.1 to 26.3. Locate found 26.1 in its results from
the last time the database was rebuilt. It is much faster than find.

