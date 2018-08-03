echo "Help commands - $scriptName <command>"
echo

preamble="$scriptName.help.commands.preamble.txt"
postscript="$scriptName.help.commands.postscript.txt"

if [ -f $preamble ]; then
	cat $preamble
fi

METADATAONLY=true

target="$scriptName.*.cmd.*"

previous=""
for loc in ${locations[@]} ; do

	[[ "$previous" == "$loc" ]] && break
	previous="$loc"
	
	for found in $loc/$target
	do
		if [[ -f "$found" ]]; then
			$DEBUG && echo "found #$count : $found"
			
			if [[ "$found" = *".sh" ]]; then
				source $found
			else
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

	[[ "$previous" == "$loc" ]] && break
	previous="$loc"
	
	for found in $loc/$target
	do
		if [ -f "$found" ]; then

			$DEBUG && echo "found #$count : $found"
			
			if [[ "$found" = *".sh" ]]; then
				source $found
			else
				eval "$(sed -n 's|^#m# \(.*\)$|\1|p' $found)"
			fi
								
			printf "$command $usage\n\n"	
		fi
	done
done

if [ -f $postscript ]; then
	cat $postscript
fi

echo

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."