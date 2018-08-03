# grow.configure.sh
#
# by Keith Hodges 2010
#
#


command="configure"
description="select configuration file"
usage="usage:
$scriptName configure --show        # default behaviour
$scriptName configure --options     # list available options
$scriptName configure someones.conf # view file
$scriptName configure someones.conf --install 1 # install at option 1
$scriptName configure --help        # this message
"

$SHOWHELP && printf "$command - $description\n\n$usage"
$METADATAONLY && return

option=""
configureName=""
SHOWCONFIG=true
SHOWOPTIONS=false		    
LISTTEMPLATES=false
INSTALL=false
GETOPTION=false

for arg in "$@"
do
	if $GETOPTION; then
		option="$arg"
		GETOPTION=false
		continue
	fi
	case $arg in
	  --show)
	  	SHOWCONFIG=true
	    ;;
	  --options)
		    SHOWOPTIONS=true
		    SHOWCONFIG=false
	    ;;
	  --install)
		    INSTALL=true
		    SHOWCONFIG=false
		    GETOPTION=true
	    ;;
	  -*)
	  # ignore other options
	  	;;
	  *)
	  	configureName="$arg"
	  	SHOWCONFIG=false
	  ;;	
	esac
done

if $SHOWCONFIG; then
	for i in "${!configOptions[@]}"
	do
		if [ -f ${configFileLocations[$i]} ]; then
			echo "${configOptions[$i]} config found: ${configFileLocations[$i]}"
			echo "["
			cat "${configFileLocations[$i]}"
			printf "\n]\n"
		fi
	done
	return 1
fi

if $SHOWOPTIONS; then
	printf "\nAvailable options:\n"
	for i in "${!configOptions[@]}"
	do
		j=$(( $i + 1 ))
		echo "  $j) ${configOptions[$i]} config : ${configFileLocations[$i]}"
	done

	printf "\nAvailable templates:\n"
	for found in *.conf
	do
		echo "    $found"
	done
	return 1
fi
 
# check for .conf extension
if [ ${configureName##*.} != "conf" ]; then
	echo "Not a recognised *.conf file"
	exit
fi

if [[ ! -f "$configureName" ]]; then
	echo "$configureName not found"
	exit
fi

# check file exists
if ! $INSTALL; then
		echo "Showing configuration in: $configureName"
		echo "["
		cat "$configureName"
		printf "\n]\n"
		exit 1
fi

# INSTALL

if [[ "$option" = "" ]]; then
	echo "Provide an option: --install <n>"
 
	for i in "${!configOptions[@]}"
	do
		j=$(( $i + 1 ))
		echo "  $j) ${configOptions[$i]}"
	done
	exit
fi

# INSTALL GO AHEAD

j=$(( $option - 1 ))

$LOUD && echo "cp"  "$configureName" "${configFileLocations[$j]}"
$DRYRUN && echo "  --confirm required to proceed"
$CONFIRM && cp  "$configureName" "${configFileLocations[$j]}"
$CONFIRM && echo "done"

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."