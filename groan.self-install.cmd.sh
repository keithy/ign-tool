# grow.self-install.sh
#
# by Keith Hodges 2010
#

command="self-install"
description="install in system"
usage="usage:
$scriptName self-install --link 
$scriptName self-install <dest */bin directory> --link
$scriptName self-install --unlink  
"

if $SHOWHELP; then
	echo "$command - $description\n\n$usage"
fi
if $METADATAONLY; then
	return
fi

what="none"
for arg in $@
do
	case $arg in
    	--link)
	   	what="link"
		;;
    	--unlink)
	   	what="unlink"
		;;
	  	--full)
	   	what="full"
	    ;;	 
	esac
done

if [ "$what" = "unlink" ]; then
	theInstalledLink=`which "$scriptName"`
	if [ -z "$theInstalledLink" ]; then
		echo "$scriptFile appears not to be installed"
		return
	fi
	if [ ! -L "$theInstalledLink" ]; then
		echo "Not a link: $theInstalledLink - leaving well alone"
		return
	fi
	theInstalled=`readlink -n $theInstalledLink`
	if [ "$theInstalled" != "$scriptFile" ]; then
		echo "This link does not point to me: $theInstalledLink - leaving well alone"
		return
	fi
	rm "$theInstalledLink"
	echo "Removed installed symbolic link $theInstalledLink"
	return
fi

#user giving us a destination
destDir=$1

if [[ -z $destDir || "${destDir:0:1}" = "-" ]]; then
	
	destDir="/usr/local/bin"

	#no destination specified
	if $LOUD; then
		echo "No destination specified, using: $destDir"
	fi
		
	if [ "$searchablePath" = "${searchablePath/:$destDir:/:}" ]; then
		echo "Your PATH does not include $destDir, please specify an explicit path."
		return
	fi
	
fi

if [ $what = "none" ]; then
	if $LOUD; then
		echo "No option specified, \n\n$usage"
		return
	fi
fi

if [ $what = "link" ]; then
	ln -s "$scriptFile" "$destDir/$scriptName" 
	echo "Installed symbolic link from $destDir/$scriptName to $scriptFile"
fi

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."