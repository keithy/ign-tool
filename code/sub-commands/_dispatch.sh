# This dispatcher is looking for the chosen sub-command (in this directory)
# It was invoked from the context of a top level command whose <cmd>.locations.sh
# specified this as the dispatcher.
#
# This approach supports partial matching of subcommands

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

#note $subcommand requested may be partial and $scriptSubcommand is the matched result 
target="${subcommand}*.sub.*"
exact="${subcommand}.sub.*"

commandFileList+=("$commandFile")

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
    scriptSubcommand="${scriptName%%.cmd.*}"
    scriptSubcommand="${scriptSubcommand%%.sub.*}"
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
    breadcrumbsList+=("$breadcrumbs")

    return
done

$LOUD && echo "Not Found: $breadcrumbs sub-command: '$subcommand'."
exit 1