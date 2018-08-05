echo "Help commands - $scriptName <command>"
echo

preamble="help.commands.pre-script.md"
postscript="help.commands.post-script.md"

if [ -f $preamble ]; then
	${markdownViewerUtility%% *} ${markdownViewerUtility#* } $preamble
fi

# run all commands collecting metadata
METADATAONLY=true

target="*.cmd.*"

previous=""
for loc in ${locations[@]} ; do

	[[ "$previous" == "$loc" ]] && continue
	previous="$loc"
	
	$DEBUG && echo "Looking for $target in: $loc"

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
								
			printf "%-17s" $command
			echo "$description"
		fi
	done
done

echo

previous=""
for loc in ${locations[@]} ; do

	[[ "$previous" == "$loc" ]] && continue
	previous="$loc"

	$DEBUG && echo "Looking for $target in: $loc"
	
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
								
			printf "$command $usage\n\n"	
		fi
	done
done

if [ -f $postscript ]; then
		   	${markdownViewerUtility%% *} ${markdownViewerUtility#* } $postscript
fi

echo

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."