# grow.help.cmd.sh
#
# by Keith Hodges 2010
#
# General Help On Commands

# may have been invoked with a partial name
# so set the full command name
command="help"

description="show topical help"
commonOptions="common options:
--help    | -h | -?  Usage help for a command
--quiet   | -q       Quiet mode - say nothing
--verbose | -V       Verbose
--debug   | -d | -D  Debug - tell all
"

usage="usage:
$scriptName help <command|topic>
$scriptName help topics
$scriptName help commands
$scriptName help --help      #this text"

$SHOWHELP && printf "$command - $description\n\n$scriptName $commonOptions\n$usage"
$METADATAONLY && return 

helpRequest=""
for arg in $@
do
	case $arg in
    	--all | -a)
	   	VERBOSE=true
		;;
		*)
		if [[ "$helpRequest" = "" ]]; then
		   helpRequest=$arg
		fi
	    ;;
	esac
done

$DEBUG && echo "Help request: $helpRequest"

#check user has given us a file reference
if [[ "$helpRequest" = "" ]]; then
	printf "$scriptName $commonOptions\n$usage\nPlease give me a help topic\n"
	exit 1
fi

helpFile=""
target="$scriptName.help.$helpRequest*.topic.*"

previous=""
for loc in ${locations[@]} ; do

	[[ "$previous" == "$loc" ]] && break
	previous="$loc"
	
	$DEBUG && echo "looking in: $loc"

	for found in $loc/$target; do
		if [ -f "$found" ]; then
			$DEBUG && echo "found: $found"
			helpFile="$found"
			break
		fi
	done

	if [[ "$helpFile" = "" ]]; then
		$LOUD && echo "Warning: help for '$helpRequest' not found"
		exit 1
	fi
done

case ${helpFile##*.} in
    	txt | text)
		   	cat $helpFile
		   	echo  
		;;
	  	sh)
		   	source $helpFile
	    ;;
	    *)
		   	eval $helpFile
	    ;;
esac

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."