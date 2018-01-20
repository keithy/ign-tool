echo "Help commands - $scriptName <command>"
echo

preamble="$scriptName.help.commands.preamble.txt"
postscript="$scriptName.help.commands.postfix.txt"

if [ -e $preamble ]; then
	cat $preamble
fi

METADATAONLY=true

target="$scriptName.*.cmd.sh"
 	
for loc in ${locations[@]}
do
	for found in $loc/$target
	do
		if [[ -e "$found" ]]; then
			if $DEBUG; then
				echo "found #$count : $found"
			fi
			
			source $found
						
			printf "%-17s" $command
			echo "$description"
			
		fi
	done
done

echo

for loc in ${locations[@]}
do
	for found in $loc/$target
	do
		if [ -e "$found" ]; then
			if $DEBUG; then
				echo "found #$count : $found"
			fi
			
			source $found
						
			echo "$command $usage"
			
		fi
	done
done

if [ -e $postscript ]; then
	cat $postscript
fi

echo

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."