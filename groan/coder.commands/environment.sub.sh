# grow.environment.sh
#
# by Keith Hodges 2010
#
# A Debugging tool

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="environment"
description="show script/environment variables"
usage="usage:
$breadcrumbs environment 
$breadcrumbs environment [--all|-a]
$breadcrumbs environment [--eval "expr"] - evaluate expression in script context
$breadcrumbs environment --help"

$SHOWHELP && executeHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

GETEXEC=false
what="env"
for arg in "$@"  
do
    $DEBUG && echo "Arg: $arg"
    if $GETEXEC; then
        what=$arg
        GETEXEC=false
        continue
    fi
    case $arg in
    --all | -a)
        what="set"
    ;;
    --eval | -e)
        GETEXEC=true
    ;;
    esac
done

$VERBOSE && echo $what

eval $what
printf ${reset}
exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."