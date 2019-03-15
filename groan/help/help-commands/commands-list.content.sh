# grow help list-commands.cmd.sh
#
# by Keith Hodges 2018

METADATAONLY=true
target="*.sub.*"

list=()

readLocations $commandDir

list+=("${locations[@]}")

previous=""
for loc in ${locations[@]} ; do

	[[ "$previous" == "$loc" ]] && continue
	previous="$loc"
	
	$DEBUG && echo "Looking for $target in: $loc"
		
	len=$(( ${#scriptDir} - ${#scriptName} ))
	breadcrumbs=${loc:$len:1000}
	breadcrumbs=${breadcrumbs%/*}
	breadcrumbs=${breadcrumbs//\// }
	
	for found in $loc/$target
	do
		if [[ -f "$found" ]]; then
			
			if [[ "$found" = *".sh" ]]; then
				$DEBUG && echo "Sourcing for metadata: $found"
				source $found
			else
				$DEBUG && echo "Evaluating magic comments for metadata in: $found"
				$DEBUG && echo $(sed -n 's|^#m# \(.*\)$|\1|p' $found)
				eval "$(sed -n 's|^#m# \(.*\)$|\1|p' $found)"
			fi
			
			$DEBUG && echo "ScriptDir: $scriptDir"
			$DEBUG && echo "Location: $loc"		
						
			printf "%-30s" "$breadcrumbs $command"
			echo "$description"
		fi
	done
done

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."