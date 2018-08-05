# dispatcher for helper

helpRequest=$command
$DEBUG && echo "Help request: '$helpRequest'"
	
#check user has given us a file reference
if [[ "$helpRequest" = "" ]]; then
	printf "$scriptName $commonOptions\n\n$usage\n\nPlease give me a help topic\n"
	exit 1
fi

helpFile=""
target="$helpRequest*.topic.*"
exact="$helpRequest.topic.*"

previous=""

for loc in ${dispatchLocations[@]}
do
	$DEBUG && echo "Looking for $target in: $loc"

	[[ "$previous" == "$loc" ]] && continue
	previous="$loc"
	
	$DEBUG && echo "Looking for $target in: $loc"

	# if an exact match is available - upgrade the target to prioritise the exact match
	for found in $loc/$exact
	do
		target=$exact
	done
	
	for found in $loc/$target
	do
		if [ -f "$found" ]; then
			$DEBUG && echo "Found: $found"
			helpFile="$found"
			continue 2
		fi
	done
done

if [[ "$helpFile" = "" ]]; then
	$LOUD && echo "Warning: help for '$helpRequest' not found"
	exit 1
fi
	
case ${helpFile##*.} in
    	txt | text)
			$DEBUG && echo "Viewing txt: $found"
		   	cat $helpFile
		   	echo
		;;
	    md)
			$DEBUG && echo "Using $markdownViewerUtility to display markdown: $found"
		   	${markdownViewerUtility%% *} ${markdownViewerUtility#* } $helpFile
	    ;;
	  	sh)
			$DEBUG && echo "Running source: $found"
		   	source $helpFile
	    ;;
	    *)
			$DEBUG && echo "Running eval: $found"
		   	eval $helpFile
	    ;;
esac

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."