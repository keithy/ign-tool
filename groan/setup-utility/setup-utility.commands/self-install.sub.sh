# groan.self-install.sh
#
# by Keith Hodges 2010
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="self-install"
description="install in system"
usage="usage:
$breadcrumbs self-install /usr/local/bin --link
$breadcrumbs self-install --unlink"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

ADDACTION=false
ADDLINK=false
UNLINK=false
FULLINSTALL=false
installPath="/usr/local/bin"

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
#   --full)
#	FULLINSTALL=true
#	ADDACTION=true	
#   ;;
    -*)
    # ignore other options
    ;;
    *)
        installPath="$arg"
    ;;
    esac
done

if $UNLINK; then
    theInstalledLink=$(which "$c_name")
    if [ -z "$theInstalledLink" ]; then
        echo "$c_name appears not to be installed"
        exit 1
    fi

    if [ ! -L "$theInstalledLink" ]; then
        echo "Not a link: $theInstalledLink - leaving well alone"
        exit 1
    fi

    theInstalled=$(readlink -n $theInstalledLink)
    if [ "$theInstalled" != "$c_file" ]; then
        echo "This link does not point to me: $theInstalledLink - leaving well alone"
        exit 1
    fi

    $LOUD && echo "rm $theInstalledLink"
    $DRYRUN && echo "dryrun:  --confirm required to proceed"
    $CONFIRM && rm "$theInstalledLink" && echo "Removed installed symbolic link $theInstalledLink" || echo "failed"

    exit 0
fi

if ! $ADDACTION; then
    echo "No action specified ( --link )"
    exit 1
fi

#no destination specified

if [[ "$installPath" = "" ]]; then
    echo "No destination specified, try (/usr/local/bin)"
    exit 1
fi

#user gave us a destination is it on the $PATH
searchablePath=":$PATH:"
if [ "$searchablePath" = "${searchablePath/:$installPath:/:}" ]; then
    echo "Your PATH does not include $installPath, please specify a valid path."
    exit 1
fi
	
if [[ ! -d "$installPath" ]]; then
    echo "Directory $installPath does not exist"
    exit 1
fi

if $ADDLINK; then
    $LOUD && echo "ln -s $c_file $installPath/$c_name"
    $DRYRUN && echo "dryrun: --confirm required to proceed"
    $CONFIRM && ln -s "$c_file" "$installPath/$c_name" 
    $CONFIRM && echo "Installed symbolic link from $installPath/$c_name to $c_file"
fi

exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."