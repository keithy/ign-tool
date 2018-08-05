# grow help list-commands.cmd.sh
#
# by Keith Hodges 2018

command="usage"
description="report available commands' usage"
usage="usage:
$breadcrumbs $command"

$SHOWHELP && printf "$command - $description\n\n$scriptName $commonOptions\n\n$usage\n"
$METADATAONLY && return 

echo "Help list-commands-usage - $scriptName <command>"
echo

preamble="usage.pre-script.md"
postscript="usage.post-script.md"

if [ -f $preamble ]; then
	${markdownViewerUtility%% *} ${markdownViewerUtility#* } $preamble
fi

source $dispatchLocation/list-commands-usage.content.sh

if [ -f $postscript ]; then
		   	${markdownViewerUtility%% *} ${markdownViewerUtility#* } $postscript
fi

echo

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."