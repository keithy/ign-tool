# run all commands collecting metadata
METADATAONLY=true

target="*.cmd.*"

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
		if [ -f "$found" ]; then

			$DEBUG && echo "Found #$count : $found"
			
			if [[ "$found" = *".sh" ]]; then
				$DEBUG && echo "Sourcing for metadata: $found"
				source $found
				
			else
				$DEBUG && echo "Evaluating magic comments for metadata in: $found"
				$DEBUG && echo $(sed -n 's|^#m# \(.*\)$|\1|p' $found)
				
				eval "$(sed -n 's|^#m# \(.*\)$|\1|p' $found)"
			fi
			
			printf "%-30s" "$breadcrumbs $command"
			echo "$description"					
			printf "\n$usage\n\n"	
		fi
	done
done

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."