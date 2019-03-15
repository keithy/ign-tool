# The default dispatcher, is looking for the chosen sub-command (in this directory)
# It was invoked from the context of a top level command whose config.locations
# specified this file as the default dispatcher.
#
# Alternative dispatchers may be defined for invocation from sub-command contexts
# e.g. groan help topics
# The help sub-command invokes the dispatcher: _help_dispatch.sh

target="${command}*.sub.*"
exact="${command}.sub.*"

$DEBUG && echo "Looking for $target in: $loc"

# if an exact match is available - upgrade the target to prioritize the exact match
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
	# Passing In: $found $arg_str $subcommandsLocation
	executeScript
	exit 1
done