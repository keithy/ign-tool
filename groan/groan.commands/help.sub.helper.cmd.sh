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

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

commandName="${scriptName%.cmd.sh}"
commandName="${commandName#*.sub.}"
commandDir="${scriptDir%/*}/$commandName"

$DEBUG && echo "scriptName: ${bold}$scriptName${reset}"
$DEBUG && echo "commandDir: $commandDir"

readLocations 

shiftArgsIntoNext
subcommand="$next"
[ -z "$subcommand" ] && subcommand="$defaultSubcommand" 

$DEBUG && echo "$scriptSubcommand($commandName) sub-command: '$subcommand' args(${#args[@]}): ${args[@]:+${args[@]}}"

# if no argument get the default for this command
# given the argument look for commands that match
for scriptDir in "${locations[@]}"
do

    if [ -f "$scriptDir/$defaultDispatch" ]; then
        source "$scriptDir/$defaultDispatch"
    fi
done

# So no commands match the argument...


### dispatch
#for scriptDir in "${locations[@]}"
#do
#	if [ -f "$scriptDir/_${scriptSubcommand}_dispatch.sh" ]; then
#            source "$scriptDir/_${scriptSubcommand}_dispatch.sh"
#	fi
#done

$LOUD && echo "Not Found: ${bold}${breadcrumbs}${reset} sub-command '${bold}${subcommand}${reset}'."
 
exit 1

# "This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
# Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed
# subject to the same license."

