# A sub-sub-command invocation
#
# by Keith Hodges 2018
#
# We provide meta data for this context and pass it on to dispatch-subcommand.sh
 
command="help"
description="show topical help"
usage="usage:
$breadcrumbsStr <command|topic>
$breadcrumbsStr topics
$breadcrumbsStr commands
$breadcrumbsStr --help      #this text"

$SHOWHELP && printf "$scriptName $commonOptions\n\n"
$SHOWHELP && printf "$breadcrumbsStr - $description\n\n$usage\n\n"
$METADATAONLY && return 

printf "here"