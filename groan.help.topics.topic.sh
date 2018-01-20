echo "Help topics - $scriptName help <topic>"
echo

preamble="$scriptName.help.topics-preamble.txt"
postscript="$scriptName.help.topics-postfix.txt"

if [ -e $preamble ]; then
	cat $preamble
fi

METADATAONLY=true

target="$scriptName.help.*.topic.*"

for loc in ${locations[@]}
do
	for found in $loc/$target
	do
		if [[ -e "$found" ]]; then
			if $DEBUG; then
				echo "found #$count : $found"
			fi
			
			topic=${found%.*}
			topic=${topic%.*}
			topic=${topic##*.}
			
			printf "%-17s\n" $topic
			
		fi
	done
done

if [ -e $postscript ]; then
	cat $postscript
fi

echo

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."