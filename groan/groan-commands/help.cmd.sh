# A sub-sub-command invocation
#
# by Keith Hodges 2018
#
# We provide meta data for this context and pass it on to dispatch-subcommand.sh
 
command="help"
description="show topical help"
usage="usage:
$breadcrumbs $command <command|topic>
$breadcrumbs $command topics
$breadcrumbs $command commands
$breadcrumbs $command --help      #this text"

$METADATAONLY && return

source "$commandsLocation/dispatch-subcommand.sh"
#source "$selfLocation/dispatch-subcommand.sh"
