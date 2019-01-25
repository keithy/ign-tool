# sub-sub-commands invocation
#
# by Keith Hodges 2018
#
# pass on to subcommand dispatch-command.sh

subcommandsLocation="${commandsLocation%/*}/$command/commands"
dispatchLocations=( "$subcommandsLocation" )
locations+=("$subcommandsLocation")

$DEBUG && echo "Breadcrumbs: $breadcrumbs"
$DEBUG && echo "This command: $command"
$DEBUG && echo "Args: ${args[*]:-}"

newSubcommand=${args[0]:-}
args=("${args[@]:1}")

if [ "$newSubcommand" = "" ]; then
	$SHOWHELP && printf "$command - $description\n\n$scriptName $commonOptions\n\n$usage\n"
	$METADATAONLY && return 
fi

$DEBUG && echo "New sub-command: $newSubcommand"
$DEBUG && echo "Args: ${args[*]:-}"
$DEBUG && echo "Sourcing:  $subcommandsLocation/dispatch-command.sh"

command="$newSubcommand"
source "$subcommandsLocation/dispatch-command.sh"
