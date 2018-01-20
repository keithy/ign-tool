# grow.configure.sh
#
# by Keith Hodges 2010
#
#
command="configure"
description="select configuration file"
usage="usage:
$scriptName configure someones.conf #view file
$scriptName configure someones.conf --local
$scriptName configure someones.conf --user
$scriptName configure someones.conf --global
$scriptName configure someones.conf --list
$scriptName configure --help  
"

if $SHOWHELP; then
	echo "$command - $description\n\n$usage"
fi
if $METADATAONLY; then
	return
fi

destDir=""
destDesc=""
list=false
for arg in $@
do
	case $arg in
	  --local | --here)
	    	destDir="$workingDir"
			destDesc="working directory: $workingDir"
	    ;;
	  --user)
	    	destDir="$HOME"
			destDesc="users home directory: $destDir"
	    ;;
	  --global)
	    	destDir="$scriptDir"
			destDesc="$scriptName installation in: $destDir"
	    ;;
	  --list)
	  	list=true
	    ;;
	esac
done

if $list; then
	for loc in ${locations[@]}
	do
		for found in $loc/*.conf
		do 
			echo "$found"
		done
	done
	return 1
fi

if $LOUD; then
	echo "configuring $destDesc"
fi

#check user has given us a file reference
configureName=$1
if [[ -z "$configureName" || "${configureName:0:1}" = "-" ]]; then
	echo "Using Configuration: $configFile\n"
	cat "$configFile"
	exit 1
fi


#append the extension if it is not present
if [ ${configureName##*.} != "conf" ]; then
 configureName="$configureName.conf"
fi

#if the file referenced by name we have been given exists, then use it.
if [ -e "$configureName" ]; then
	configureFile="$configureName"
	if $DEBUG; then
		echo "using configuration file given: $configureFile"
	fi
else

	for loc in ${locations[@]}
	do
		for found in $loc/$configureName
		do 
			if [ -e "$found" ]; then
				if $DEBUG; then
					echo "found: $found"
				fi
				configureFile="$found"
				break 2
			fi
		done
	done
fi

if [ -e $configureFile ]; then

	if [ -z "$destDir" ]; then
		cat "$configureFile"
		return 0
	fi
	
	cp $configureFile "$destDir/.$scriptName.conf"
	if $LOUD; then
		echo "copied $configureFile to $destDir/.$scriptName.conf"
		if $VERBOSE; then
			cat "$configureFile"
		fi
	fi
else
	if $LOUD; then
		echo "Warning: $configureFile not found"
	fi
fi

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."