echo "Help topics - $scriptName help <topic>"
echo

preamble="$scriptName.help.topics-preamble.txt"
postscript="$scriptName.help.topics-postfix.txt"

if [ -e $preamble ]; then
	cat $preamble
fi

METADATAONLY=true

target="$scriptName.help.*.topic.*"

previous="" 	
for loc in ${locations[@]}
do
	[[ "$previous" == "$loc" ]] && break
	previous="$loc"

	for found in $loc/$target
	do
		if [[ -f "$found" ]]; then
			$DEBUG && echo "found #$count : $found"
			
			topic=${found%.*}
			topic=${topic%.*}
			topic=${topic##*.}
			
			printf "$scriptName $command %-17s\n" $topic
			
		fi
	done
done

if [ -e $postscript ]; then
	cat $postscript
fi

echo

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."