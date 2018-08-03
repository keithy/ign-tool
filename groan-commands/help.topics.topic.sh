echo "Help topics - $scriptName help <topic>"
echo

preamble="help.topics.pre-script.md"
postscript="help.topics.post-script.md"

if [ -f $preamble ]; then
	${markdownViewerUtility%% *} ${markdownViewerUtility#* } $preamble
fi

METADATAONLY=true

target="help.*.topic.*"

previous="" 	
for loc in ${locations[@]}
do
	[[ "$previous" == "$loc" ]] && continue
	previous="$loc"

	for found in $loc/$target
	do
	
		$DEBUG && echo "Looking for $target in: $loc"

		if [[ -f "$found" ]]; then
			$DEBUG && echo "Found topic: $found"
			
			topic=${found%.*}
			topic=${topic%.*}
			topic=${topic##*.}
			
			printf "$scriptName $command %-17s\n" $topic
			
		fi
	done
done

if [ -f $preamble ]; then
	${markdownViewerUtility%% *} ${markdownViewerUtility#* } $postscript
fi

echo

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."