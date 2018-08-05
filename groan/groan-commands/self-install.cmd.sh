# grow.self-install.sh
#
# by Keith Hodges 2010
#

command="self-install"
description="install in system"
usage="usage:
$breadcrumbs self-install /usr/local/bin --link
$breadcrumbs self-install --unlink"

$SHOWHELP && printf "$command - $description\n\n$usage\n"
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

ADDACTION=false
ADDLINK=false
UNLINK=false
FULLINSTALL=false
installPath=""

for arg in "$@"
do
	case $arg in
    	--link)
	   	 	ADDLINK=true
	   	 	ADDACTION=true
		;;
    	--unlink)
	   		UNLINK=true
		;;
#	  	--full)
#			FULLINSTALL=true
#			ADDACTION=true	
#	    ;;
	    -*)
	        # ignore other options
	  	;;
	    *)
	  		installPath="$arg"
   	    ;;
	esac
done

if $UNLINK; then
	theInstalledLink=$(which "$scriptName")
	if [ -z "$theInstalledLink" ]; then
		echo "$scriptFile appears not to be installed"
		return
	fi
	
	if [ ! -L "$theInstalledLink" ]; then
		echo "Not a link: $theInstalledLink - leaving well alone"
		return
	fi
	
	theInstalled=$(readlink -n $theInstalledLink)
	if [ "$theInstalled" != "$scriptFile" ]; then
		echo "This link does not point to me: $theInstalledLink - leaving well alone"
		return
	fi

	$LOUD && echo "rm $theInstalledLink"
	$DRYRUN && echo "  --confirm required to proceed"
	$CONFIRM && rm "$theInstalledLink"
	$CONFIRM && echo "Removed installed symbolic link $theInstalledLink"

	exit
fi

if ! $ADDACTION; then
	echo "No action specified ( --link )"
	exit
fi

#no destination specified

if [[ "$installPath" = "" ]]; then
	echo "No destination specified, try (/usr/local/bin)"
	exit
fi

#user gave us a destination is it on the $PATH

if [ "$searchablePath" = "${searchablePath/:$installPath:/:}" ]; then
	echo "Your PATH does not include $installPath, please specify a valid path."
	exit
fi
	
if [[ ! -d "$installPath" ]]; then
	echo "Directory $installPath does not exist"
	exit
fi

if $ADDLINK; then
	$LOUD && echo "ln -s $scriptFile $installPath/$scriptName"
	$DRYRUN && echo "  --confirm required to proceed"
	$CONFIRM && ln -s "$scriptFile" "$installPath/$scriptName" 
	$CONFIRM && echo "Installed symbolic link from $installPath/$scriptName to $scriptFile"
fi

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."