# grow.help.sh
#
# by Keith Hodges 2010
#
# General Help On Commands

command="help"

description="show topical help"
commonOptions="$scriptName common options:
--help    | -h | -?  Usage help for a command
--quiet   | -q       Quiet mode - say nothing
--verbose | -V       Verbose
--debug   | -d | -D  Debug - tell all
"

usage="usage:
$scriptName help <command>
$scriptName help commands
$scriptName help --help      #this text
"

if $SHOWHELP; then
	echo "$command - $description\n\n$commonOptions\n$usage"
fi
if $METADATAONLY; then
	return 
fi

for arg in $@
do
	case $arg in
    	--all | -a)
	   	VERBOSE=true
		;;
	esac
done

#check user has given us a file reference
helpRequest=$1
if [[ -z $helpRequest || "${helpRequest:0:1}" = "-" ]]; then
	echo "$scriptName $commonOptions\nPlease give me a help topic\n\n$usage"
	exit 1
fi

target="$scriptName.help.$helpRequest*.topic.*"
for loc in ${locations[@]}
do
	for found in $loc/$target
	do
		if [ -e "$found" ]; then
			if $DEBUG; then
				echo "found: $found"
			fi
			helpFile="$found"
			break 2
		fi
	done
done

if [ ! -e $helpFile ]; then
	if $LOUD; then
		echo "Warning: help for '$helpRequest' not found"
	fi
	exit 1
fi



case ${helpFile##*.} in
    	txt | text)
		   	cat $helpFile
		   	echo "\n"
		;;
	  	sh)
		   	source $helpFile
	    ;;
esac

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."