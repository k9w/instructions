BEGIN { FS=","
	print "Produce to pick up from the store:" }

# For lines with a third field equaling an integer greater than 1,
# print the second word.
$3>1 { print $2 }

# For lines containing 'dairy', print the second field.
/dairy/ { print $2 }

END { print "--------" }
