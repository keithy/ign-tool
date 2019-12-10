# groan configure.sub.sh
#
# by Keith Hodges 2010
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="configure"
description="select or edit configuration file"
usage="usage:
$breadcrumbs                                 # show current config file
$breadcrumbs --show                          # show current config file
$breadcrumbs --edit                          # edit current config file
$breadcrumbs --options                       # list available location options
$breadcrumbs --install=<option> <file.conf>  # install file at given location (local/user/global)
$breadcrumbs --help                          # this message"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

configureName=""
configOption=""
SHOWCONFIG=true
EDITCONFIG=false
SHOWOPTIONS=false		    
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
        --install=*)
            configOption="${arg#--install=}"
            INSTALL=true
            SHOWCONFIG=false
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
[[ -z ${g_config_preset_locations+x} ]] && g_config_preset_locations=("${g_dir}")

if $SHOWOPTIONS; then
    printf "\nAvailable options:\n"
    for i in "${!g_config_options[@]}"
    do
            j=$(( $i + 1 ))
            printf "  %d) %s\t[ %s ]\n" $j ${g_config_options[$i]} ${g_config_file_locations[$i]}
    done

    printf "\nAvailable .conf files:\n"

	for presetDir in "${g_config_preset_locations[@]}" 
	do
    	for found in "$presetDir/"*.conf
    	do
        	echo "    ${found##*/} (preset)"
    	done
    done
    
    if [ "$PWD" != "${g_dir}" ]; then
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
    for i in "${!g_config_options[@]}"
    do
        if [ -f ${g_config_file_locations[$i]} ]; then
            echo "${bold}Option:${reset} ${dim}${g_config_options[$i]}${reset} ${bold}found: ${reset}${dim}${g_config_file_locations[$i]}${reset}" 1>&2
            $SHOWOPTIONS || cat "${g_config_file_locations[$i]}"
            return 0
        fi
    done
    echo "No configuration file found"
    return 1
fi

# --edit currently selected configuration file contents
if $EDITCONFIG; then
    for i in "${!g_config_options[@]}"
    do
        if [ -f ${g_config_file_locations[$i]} ]; then
            $EDITOR "${g_config_file_locations[$i]}"
            return 0
        fi
    done
    echo "No configuration file found"
    return 1
fi
 
# auto-append .conf extension
[ "${configureName##*.}" != "conf" ] && configureName="${configureName}.conf"

# search for preset file
if [[ ! -f "$configureName" ]]; then
	for presetDir in "${g_config_preset_locations[@]}" 
	do
   		[[ -f "${presetDir}/${configureName}" ]] && configureName="${presetDir}/${configureName}"
	done
fi

# exit if file does not exist
[[ ! -f "$configureName" ]] && echo "$configureName not found" && exit 1

# show if the file exists and install is not requested
if [ $INSTALL == false ]; then
    echo "Showing configuration in: $configureName" 1>&2  
    cat "$configureName"
    exit 0
fi

# INSTALL

if [ -z "$configOption" ]; then
    echo "Provide an install location option for $configureName: (${g_config_options[@]})"
    exit 1
fi

# INSTALL GO AHEAD

for i in "${!g_config_options[@]}"
do
  [ "$configOption" == "${g_config_options[i]}" ] && break
done

$LOUD && echo "$configOption"
$LOUD && echo "cp" "$configureName" "${g_config_file_locations[i]}"
$DRYRUN && echo "dryrun:  --confirm required to proceed"

$CONFIRM && cp  "$configureName" "${g_config_file_locations[$i]}"
$CONFIRM && echo "$configureName installed as $configOption configuration"

exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."