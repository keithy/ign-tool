# dispatcher for commands
# handles the default empty case

# no command provided default to subcommmand help --help
if [[ "$command" = "" ]]; then
	command="help"
	SHOWHELP=true
	METADATAONLY=true
fi

selfLocation="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
$DEBUG && echo "dispatch-command location: $selfLocation"

target="${command}*.cmd.*"
exact="${command}.cmd.*"

count=0
previous=""
for dispatchLocation in ${dispatchLocations[@]} 
do
	[[ "$previous" == "$dispatchLocation" ]] && continue
	previous="$dispatchLocation"
	
	$DEBUG && echo "Looking for $target in: $dispatchLocation"

	# if an exact match is available - upgrade the target to prioritise the exact match
	for found in $dispatchLocation/$exact
	do
		target=$exact
	done

	for found in $dispatchLocation/$target
	do
		count=$((count + 1))	
		$DEBUG && echo "Found #$count : $found"
	done

	if [ $count -gt 1 ]; then
		$LOUD && echo "Warning: Command '$command' is ambiguous (use --debug for more info)"
		exit
	fi

	arg_str="${args[@]:+${args[@]}}" # needed bash<=4.1 when set -u is on
	
	for found in $dispatchLocation/$target
	do
		case ${found##*.} in
			sh)
				$DEBUG && echo "Running source: $found $arg_str"
				source "$found" "${args[@]:+${args[@]}}"
				exit 0
			;;
			exec)
				$DEBUG && echo "Running exec: $found $arg_str"
				exec "$found" "${args[@]:+${args[@]}}"
				exit 0
			;;
			*)
				$DEBUG && echo "Extracting metadata from: $found"
				$DEBUG && sed -n 's|^#m# \(.*\)$|\1|p' "$found"
				
				#evaluate meta-data first
				eval "$(sed -n 's|^#m# \(.*\)$|\1|p' $found)"
				
				$DEBUG && echo "Running eval: $found $arg_str"				
				eval "$found" "${args[@]:+${args[@]}}"
			    exit 0
			;;
		esac
		exit
	done
done

$LOUD && echo "Warning: $scriptName sub-command $command not found"
exit 1

