# This dispatcher is looking for the chosen sub-command (in this directory)
# It was invoked from the context of a top level command whose <cmd>-locations.conf
# specified this as the dispatcher.
#
# Alternative dispatchers may be defined for invocation from sub-command contexts
# e.g. groan help topics
# The help sub-command invokes the dispatcher: _help_dispatch.sh

target="${subcommand}*.sub.*"
exact="${subcommand}.sub.*"

$DEBUG && echo "Looking for $target in: $loc"

# if an exact match is available - upgrade the target to prioritize the exact match
for found in $loc/$exact
do
    target=$exact
done

list=()
for found in $loc/$target
do
    cmd=${found##*/}
    cmd=${cmd%*.sub.*}
    list+=($cmd)
    $DEBUG && echo "Found #${#list[@]} : $found"
done

if [ ${#list[@]} -gt 1 ]; then
    $LOUD && echo "Multiple options exist for requested '$subcommand' (${list[@]})"
    exit 1
fi
 
subcommandsLocation="$loc"

for found in $loc/$target
do
    executeScript "$found" "${args[@]:+${args[@]}}" # needed bash<=4.1 when set -u is on

    exit 1
done
