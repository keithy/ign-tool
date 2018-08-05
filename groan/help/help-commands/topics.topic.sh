echo "Help topics - $scriptName <topic>"
echo

preamble="topics.pre-script.md"
postscript="topics.post-script.md"

if [ -f $preamble ]; then
	${markdownViewerUtility%% *} ${markdownViewerUtility#* } $preamble
fi

METADATAONLY=true

target="*.topic.*"

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
			topic=${topic##*/}
			
			printf "$breadcrumbs %-17s\n" $topic
			
		fi
	done
done

if [ -f $preamble ]; then
	${markdownViewerUtility%% *} ${markdownViewerUtility#* } $postscript
fi

echo

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."