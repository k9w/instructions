started 10-1-19

awk is a text processing language

it searches for a pattern, and takes an action if a match is found.

pattern {action}; pattern {action}
pattern {action}

fields of a line are denoted as $1, $2, etc. the whole line is $0

awk programs have many of the same characteristics as shell scripts:

conditionals: if, for, while, do, break, continue, print, return, next,
nextfile, delete, exit.

Examples from awk(1):
EXAMPLES
     Print lines longer than 72 characters:

           length($0) > 72

     Print first two fields in opposite order:

           { print $2, $1 }

     Same, with input fields separated by comma and/or blanks and tabs:

           BEGIN { FS = ",[ \t]*|[ \t]+" }
                 { print $2, $1 }

     Add up first column, print sum and average:

           { s += $1 }
           END { print "sum is", s, " average is", s/NR }

     Print all lines between start/stop pairs:

           /start/, /stop/

     Simulate echo(1):

           BEGIN { # Simulate echo(1)
                   for (i = 1; i < ARGC; i++) printf "%s ", ARGV[i]
                   printf "\n"
                   exit }

     Print an error message to standard error:

           { print "error!" > "/dev/stderr" }

--------
Need to work through each of the above examples.

Open /etc/passwd for reading to awk. Set the field delimiter from
default of <space> to colon `:'. Print the 5th field, which is the
account description.
awk < /etc/passwd -F : '{ print $5 }'


fahrenheit-to-celsius calculator
awk '{ print ($1-32)*(5/9) }'

echo 89 F | awk '{ print ($1-32)*(5/9) }'
31.6667 C 


celsius-to-fahrenheit calculator
awk '{ print ($1*(9/5))+32 }'

echo 32 C | awk '{ print ($1*(9/5))+32 }'
89.6 F

I added the C and F units to the answers. In the commands, including the
units does no change the result because the number is the 1st  argument 
$1, whereas the unit C or F is the 2nd argument $2.


String concatenation is accomplished simply by writing two string
expressions next to each other. '+' is always addition. Thus

        echo 5 4 | awk '{ print $1 + $2 }'

prints 9, while

        echo 5 4 | awk '{ print $1 $2 }'

prints 54. Note that

        echo 5 4 | awk '{ print $1, $2 }'

prints "5 4".

For a set of numbers, print the average. 
echo 1 2 3 3 4 3 2 3 | \
awk '{ tot=0; for (i=1; i<=NF; i++) tot += ; print tot/NF; }'

Print the same set of numbers, but strip off the first column, the first
number.
echo 1 2 3 3 4 3 2 3 | \
awk '{ for (i=2; i<=NF; i++) printf "%s ", $i; printf "\n"; }'

Look for some awk programs.
find /usr/src | grep awk

One good one is:
/usr/src/distrib/miniroot/list2sh.awk

Another one, which has the awk shebang line, is:
/usr/src/sys/dev/sdmmc/devlist2h.awk

Here is some new text.
BEGIN { FS=","
	print "Produce to pick up from the store:" }

# For lines with a third field equaling an integer greater than 1,
# print the second word.
$3>1 { print $2 }

# For lines containing 'dairy', print the second field.
/dairy/ { print $2 }

END { print "--------" }
dairy,milk, 1
produce,bananas, 5
dairy,cheese, 1
produce,spinach, 1
produce,apples, 6
meat,salmon, 1
grocery,coffee, 1
