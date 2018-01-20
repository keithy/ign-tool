# grow.environment.sh
#
# by Keith Hodges 2010
#
# A Debugging tool

command="environment"
description="show script/environment variables"
usage="usage:
$scriptName environment 
$scriptName environment [--all|-a]
$scriptName environment expr [--exec]
$scriptName environment --help
"

if $SHOWHELP; then
	echo "$command - $description\n\n$usage"
fi
if $METADATAONLY; then
	return
fi

what="env"
for arg in $@
do
	case $arg in
    	--all | -a)
	   	what="set"
		;;
	  	--exec)
	   	what=$1
	    ;;
	esac
done

for each in `$what`
do
	echo $each
done


#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."