# groan configure.sub.sh
#
# by Keith Hodges 2010
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="configure"
description="select or edit configuration file"
usage="usage:
$breadcrumbs configure --show        # default behaviour
$breadcrumbs configure --options     # list available options
$breadcrumbs configure --local       # view local config
$breadcrumbs configure --local --install someones.conf # view file
$breadcrumbs configure --help        # this message"

$SHOWHELP && executeHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

file=""
configureName=""
configOption=""
SHOWCONFIG=true
EDITCONFIG=false
SHOWOPTIONS=false		    
LISTTEMPLATES=false
INSTALL=false
GETFILE=false

for arg in "$@"
do
    case "$arg" in
        --current|--show)
            SHOWCONFIG=true
        ;;
        --edit)
            EDITCONFIG=true
            SHOWCONFIG=false
        ;;
        --options)
            SHOWOPTIONS=true
            SHOWCONFIG=true
        ;;
        --install)
            INSTALL=true
            SHOWCONFIG=false
        ;;
        --*)
            configOption="$arg"
            SHOWCONFIG=true
        ;;
        -*)
        # ignore other options
        ;;
        # ? in this context is a single letter wildcard 
        ?*) 
            configureName="$arg"
        ;;
    esac
done
 
if [ -n "$configureName" ]; then
  SHOWCONFIG=false
fi

# --options

if $SHOWOPTIONS; then
    printf "\nAvailable options:\n"
    for i in "${!configOptions[@]}"
    do
            j=$(( $i + 1 ))
            printf "  %d) %s\t[ %s ]\n" $j ${configOptions[$i]} ${configFileLocations[$i]}
    done

    printf "\nAvailable .conf files:\n"

    for found in "$commandDir/"*.conf
    do
        echo "    ${found##*/} (preset)"
    done
    
    if [ "$PWD" != "$commandDir" ]; then
        for found in *.conf
        do
            echo "    $found"
        done
    fi
    echo
    echo "Current setting:"
fi

# --show currently selected configuration file contents
if $SHOWCONFIG; then
    for i in "${!configOptions[@]}"
    do
        if [ -f ${configFileLocations[$i]} ]; then
            echo "${configOptions[$i]} config found: ${configFileLocations[$i]}" 1>&2
            $SHOWOPTIONS || cat "${configFileLocations[$i]}"
            return 0
        fi
    done
    echo "No configuration file found"
    return 1
fi

# --edit currently selected configuration file contents
if $EDITCONFIG; then
    for i in "${!configOptions[@]}"
    do
        if [ -f ${configFileLocations[$i]} ]; then
            $EDITOR "${configFileLocations[$i]}"
            return 0
        fi
    done
    echo "No configuration file found"
    return 1
fi
 
# auto-append .conf extension
[ "${configureName##*.}" != "conf" ] && configureName="${configureName}.conf"

# exit if file does not exist
[ ! -f "$configureName" ] && echo "$configureName not found" && exit 1

# show if the file exists and install is not requested
if [ $INSTALL == false ]; then
    echo "Showing configuration in: $configureName" 1>&2  
    cat "$configureName"
    exit 0
fi

# INSTALL

if [ -z "$configOption" ]; then
    echo "Provide an install location option for $configureName: (${configOptions[@]})"
    exit 1
fi

# INSTALL GO AHEAD

for i in "${!configOptions[@]}"
do
  [ "$configOption" == "${configOptions[$i]}" ] && break
done
 
$LOUD && echo "cp" "$configureName" "${configFileLocations[$i]}"
$DRYRUN && echo "dryrun:  --confirm required to proceed"

$CONFIRM && cp  "$configureName" "${configFileLocations[$i]}"
$CONFIRM && echo "$configureName installed as $configOption configuration"

exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."