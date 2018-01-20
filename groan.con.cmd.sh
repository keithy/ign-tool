# grow.conf.sh
#
# by Keith Hodges 2010
#
# A Dummy

command="con"
description="dummy (test for duplication)"
usage="usage:
$scriptName conf --help
"

if $SHOWHELP; then
	echo "$command - $description\n\n$usage"
fi
if $METADATAONLY; then
	return
fi

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."