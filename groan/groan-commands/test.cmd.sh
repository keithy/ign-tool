# grow.conf.sh
#
# by Keith Hodges 2010
#
# A Dummy

command="test"
description="dummy (test for duplication)"
usage="usage:
$breadcrumbs test"

$SHOWHELP && printf "$command - $description\n\n$usage\n"
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

echo "Test successful"

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."