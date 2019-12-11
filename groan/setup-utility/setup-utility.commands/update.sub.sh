# groan.setup.update.sh
#
# by Keith Hodges 2019
#
$DEBUG && echo "${dim}${BASH_SOURCE[0]}${reset}"

command="update"
description="self-update ${g_name}"
usage="usage:
$breadcrumbs update --confirm"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

for arg in "$@"
do
  case "$arg" in

    -*)
    # ignore other options
    ;;
    *)
	:
    ;;
  esac
done

$DRYRUN && echo "dryrun: --confirm required to proceed" && exit 0

[[ -d "$g_dir/.git" ]] && git -C "$g_dir" pull

exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."