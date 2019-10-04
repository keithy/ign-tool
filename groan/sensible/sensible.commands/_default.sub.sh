# sensible _default.sub.sh
#
# by Keithy 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="test"
description="deploy and execute on remote servers"
usage=\
"$breadcrumbs               # test ssh connections
$breadcrumbs --help        # this message"

$SHOWHELP && executeHelp
$METADATAONLY && return

 
exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."