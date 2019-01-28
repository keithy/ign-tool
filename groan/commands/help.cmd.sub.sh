# A sub-sub-command invocation
#
# by Keith Hodges 2018
#
#Command subcommands like 'help.sub.cmd.sh'
#  have identical implementation
#  theScriptName is obtained from the script file name
#  it looks for commands in a folder with the same name 
#  ../$name/commands

thisScriptName="${BASH_SOURCE##*/}"
parentCommand="${thisScriptName%.*.*.*}"

$DEBUG && echo "This Script Name: $thisScriptName"
$DEBUG && echo "Parent command '$parentCommand' Args(${#args[@]}): ${args[@]:+${args[@]}}"

breadcrumbs+=($parentCommand)
breadcrumbsStr=${breadcrumbs[*]// /|}

$DEBUG && echo "Breadcrumbs: $breadcrumbsStr"

scriptDir="${subcommandsLocation%/*}/$parentCommand"
configLocationsFile="$scriptDir/$configLocationsFileName"

# Shift $args
command=""
params=()
for arg in "${args[@]}"
do 
    if [ -z $command ]; then
    	command="$arg"
    else
        params+=("$arg")
    fi  
done

args=("${params[@]:+${params[@]}}")
 
$DEBUG && echo "Child command: '$command' args(${#args[@]}): ${args[@]:+${args[@]}}"

if [ "$command" = "" ]; then
	command="help"
	SHOWHELP=true
	METADATAONLY=true
	$DEBUG && echo "New child command (default): $command"
fi

### read config (?)

source "$configLocationsFile"

for configFile in ${configFileLocations[@]}
do
	$DEBUG && echo "Looked for config in: $configFile"
	if [[ -f $configFile ]]; then
		$VERBOSE && echo "Reading configuration: $configFile"
		source "$configFile"
		break
	fi
done

### dispatch

dispatchLocations=("${locations[@]}")   

target="${command}*.cmd.*"
exact="${command}.cmd.*"

count=0
previous=""
for loc in ${dispatchLocations[@]} 
do
	[[ "$previous" == "$loc" ]] && continue
	previous="$loc"
	
	$DEBUG && echo "Looking for $target in: $loc"

	# if an exact match is available - upgrade the target to prioritise the exact match
	for found in $loc/$exact
	do
		target=$exact
	done

	for found in $loc/$target
	do
		count=$((count + 1))	
		$DEBUG && echo "Found #$count : $found"
	done

	if [ $count -gt 1 ]; then
		$LOUD && echo "Warning: Command '$command' is ambiguous (use --debug for more info)"
		exit
	fi

	arg_str="${args[@]:+${args[@]}}" # needed bash<=4.1 when set -u is on
	
	commandsLocation="$loc"
	
	for found in $loc/$target
	do
		case ${found##*.} in
			sh)
				$DEBUG && echo "Source: $found $arg_str"
				set -- "${args[@]:+${args[@]}}"
				source "$found"
				exit 0
			;;
			exec)
				$DEBUG && echo "Exec:: $found $arg_str"
				exec "$found" "${args[@]:+${args[@]}}"
				exit 0
			;;
			*)
				$DEBUG && echo "Extracting metadata from: $found"
				$DEBUG && sed -n 's|^#m# \(.*\)$|\1|p' "$found"
				
				#evaluate meta-data first
				eval "$(sed -n 's|^#m# \(.*\)$|\1|p' $found)"
				
				$DEBUG && echo "Eval: $found $arg_str"				
				eval "$found" "${args[@]:+${args[@]}}"
			    exit 0
			;;
		esac
		exit
	done
done

$LOUD && echo "Warning: $breadcrumbsStr $command : sub-command not found"
exit 1

# "This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
# Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed
# subject to the same license."

