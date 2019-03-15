# A sub-sub-command invocation
#
# by Keith Hodges 2018
#
#Command subcommands like 'help.sub.cmd.sh'
#  have identical implementation
#  theScriptName is obtained from the script file name
#  it looks for commands in a folder with the same name 
#  ../$name/commands

commandOrientation "${BASH_SOURCE}"

parentCommand="${thisScriptName%.cmd.sh}"
parentCommand="${parentCommand#*.sub.}"
parentDir="${subcommandsLocation%/*}/$parentCommand"

$DEBUG && commandOrientationDebug

readLocations $parentDir && readConfig

shiftArgsIntoCommand
 
# handle the default empty case
[ -z "$command" ] && command="$defaultSubSubcommand"

$DEBUG && echo "Child command: '$command' args(${#args[@]}): ${args[@]:+${args[@]}}"

### dispatch
for loc in "${locations[@]}"
do 
	if [ -f "$loc/_${thisSubcommand}_dispatch.sh" ]; then
		source "$loc/_${thisSubcommand}_dispatch.sh"
	else 
#		source "$loc/$defaultDispatch"
        :
	fi
done

$LOUD && echo "Warning: $breadcrumbsStr $command : command  not found"
exit 1

# "This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
# Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed
# subject to the same license."

