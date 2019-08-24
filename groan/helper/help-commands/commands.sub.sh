# groan help -commands.cmd.sh
#
# by Keith Hodges 2018

command="commands"
description="list available commands"
usage="usage:
$breadcrumbs $command"

$SHOWHELP && printf "$command - $description\n\n$scriptName $commonOptions\n\n$usage\n"
$METADATAONLY && return 

commandOrientation "${BASH_SOURCE}"
$DEBUG && commandOrientationDebug

echo "Help list - commands"
echo

 
$DEBUG && echo " Sourcing: $thisScriptDir/list-commands.content.sh"
source $thisScriptDir/list-commands.content.sh

 

echo

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."