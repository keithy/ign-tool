# groan self-update.sh
#
# by Keith Hodges 2019
#

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="self-update"
description="Update to latest code (from git)"
usage="usage:
$breadcrumbs $command"

$SHOWHELP && executeHelp
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

$DRYRUN && echo "dryrun: --confirm required to proceed" && exit 0

git submodule update --init --recursive

exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."