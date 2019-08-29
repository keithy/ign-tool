# This dispatcher is looking for the chosen sub-command (in this directory)
# It was invoked from the context of a top level command whose <cmd>-locations.conf
# specified this as the dispatcher.
#
# Alternative dispatchers may be defined for invocation from sub-command contexts
# e.g. groan help topics
# The help sub-command invokes the dispatcher: _help_dispatch.sh

# This approach supports partial matching of subcommands

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

target="${subcommand}*.sub.*"
exact="${subcommand}.sub.*"

$DEBUG && echo "Looking for $target in: $scriptDir"

# if an exact match is available - upgrade the target to prioritize the exact match
for scriptPath in $scriptDir/$exact
do
    target=$exact
done

list=()
for scriptPath in $scriptDir/$target
do
    scriptName="${scriptPath##*/}"
    scriptSubcommand="${scriptName%*.sub.*}"
    list+=($scriptSubcommand)
    $DEBUG && echo "Found #${#list[@]} : $scriptPath"
done

if [ ${#list[@]} -gt 1 ]; then
    $LOUD && echo "Multiple options exist for requested '${subcommand}' (${list[@]})"
    exit 1
fi

for scriptPath in $scriptDir/$target
do
    executeScript "$scriptPath" "$scriptDir" "$scriptName" "$scriptSubcommand"
    exit 1
done
