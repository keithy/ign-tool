source $loc/_dispatch.sh

target="${command}*.cmd.*"
exact="${command}.cmd.*"

$DEBUG && echo "Looking for $target in: $loc"

# if an exact match is available - upgrade the target to prioritise the exact match
for found in $loc/$exact
do
	target=$exact
done

count=0
for found in $loc/$target
do
	count=$((count + 1))
	$DEBUG && echo "Found #$count : $found"
done

if [ $count -gt 1 ]; then
	$LOUD && echo "Warning: Command '$command' is ambiguous (use --debug for more info)"
	exit
fi

subcommandsLocation="$loc"

for found in $loc/$target
do
	# Passing In: $found $arg_str
	executeScript
	exit 1
done