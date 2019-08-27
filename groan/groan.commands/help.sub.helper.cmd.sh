# A sub-command invocation
#
# by Keith Hodges 2018
#
# Subcommands like 'help.sub.helper.cmd.sh' - a script name like this is a mapping
#  interpreted as the "<help> sub-command in the parent (groan) command's list,
#  is implemented by the <helper> command contained in the parent (groan) folder
#  
#  Mapped sub-commands all have identical implementation, taking parameters from their own name
#
#  theScriptName is obtained from the script file name
#  it looks for commands in a folder with the same name 
#  ../$name/commands

scriptName="${BASH_SOURCE##*/}"
scriptDir="${BASH_SOURCE%/*}"
scriptSubcommand="${scriptName%%.*}" # should be the same as $subcommand

implementingCommand="${scriptName%.cmd.sh}"
implementingCommand="${implementingCommand#*.sub.}"
implementingCommandDir="${scriptDir%/*}/$implementingCommand"

$DEBUG && echo "scriptName: $scriptName"
$DEBUG && echo "implementingCommandDir: $implementingCommandDir"

readLocations "$implementingCommandDir" "$implementingCommand" 
readConfig 

shiftArgsIntoNext
subcommand="$next"
[ -z "$subcommand" ] && subcommand="$defaultSubcommand"
breadcrumbs+=($subcommand)

$DEBUG && echo "$scriptSubcommand($implementingCommand) sub-command: '$subcommand' args(${#args[@]}): ${args[@]:+${args[@]}}"

### dispatch
for loc in "${locations[@]}"
do 
	if [ -f "$loc/_${scriptSubcommand}_dispatch.sh" ]; then
		source "$loc/_${scriptSubcommand}_dispatch.sh"
	else 
#		source "$loc/$defaultDispatch"
        :
	fi
done

$LOUD && echo "Warning: ${breadcrumbs[*]// /|} $command : command  not found"
exit 1

# "This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
# Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed
# subject to the same license."

