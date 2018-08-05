# A sub-sub-command invocation
#
# by Keith Hodges 2018
#
# We provide meta data for this context and pass it on to dispatch-subcommand.sh
 
command="help"
description="show help on help"
usage="usage:
$breadcrumbs $command # prints this message

Try Jesus"
$SHOWHELP && printf "$command - $description\n\n$breadcrumbs \n$usage\n"
$METADATAONLY && return 

