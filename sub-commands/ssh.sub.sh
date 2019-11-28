# ign ssh.sub.sh
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="ssh"
description="manage ssh keys"
options=\
"--find              # find ssh public keys
--list              # list ssh keys in use"
 
usage=\
"$breadcrumbs             # --list && --find
$breadcrumbs =A,B,C      # print first three keys found
$breadcrumbs =1,2,3      # print first three keys used"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

# default config
[[ -z ${libraries+x} ]] && libraries=("$g_working_dir/plugs" "$c_dir/plugs")
[[ -z ${workspace+x} ]] && workspace="$g_working_dir/input"
[[ ! -f "$g_config_file" || ! -d "$workspace" ]] \
	&& echo "Config not found or not within an ign project directory" && exit 1


LIST_KEYS=true
FIND_KEYS=true
FIND_NEEDLE=false
needle=""
for arg in "$@"
do
    case "$arg" in
        --list)
            LIST_KEYS=true
            FIND_KEYS=false
        ;;
        --find)
            FIND_KEYS=true
            LIST_KEYS=false
        ;;
        =*) #(comma separated list)
        	FIND_NEEDLE=true
       	    LIST_KEYS=false
        	FIND_KEYS=false
        	needles="${arg#=}"
        ;;
        -*)
        # ignore other options
        ;;
        # ? in this context is a single letter wildcard 
        ?*) 
        ;;
    esac
done

if $FIND_KEYS; then
    $LOUD && echo "${bold}found:${reset}"
 	$VERBOSE && print="-print" || print=""
 	find $HOME/.. -name "*.pub" -path "*/.ssh/*" -type f -maxdepth 3 $print -exec awk \
 		'{printf "%3c) %12s %s...%s %s\n", 64 + NR, $1, substr($2, 1, 7), substr($2,length($2)-7) , $3}' \
 		{} + 2> /dev/null || true
fi

if $FIND_NEEDLE; then
    $VERBOSE && echo "${bold}needle:${reset}"
 	$VERBOSE && print="-print" || print=""
 	find $HOME/.. -name "*.pub" -path "*/.ssh/*" -type f -maxdepth 3 $print -exec awk -v "needles=,$needles," \
 		'{ key=sprintf(",%c,", NR+64 ); if ( needles ~ key  ) print $0}' \
 		{} + 2> /dev/null || true
fi

$LOUD && $LIST_KEYS && echo "${bold}list keys used:${reset}"
cd "$workspace"
i=1
for a_file in ./*/*.yaml
do
	READ_KEYS=false
	while IFS=$'\n' read -r line
	do
		# remove leading whitespace
		line_no_ws="${line#"${line%%[![:space:]]*}"}"
		case "${line_no_ws}" in
			\#*) # ignore comments
			;;
			ssh_authorized_keys:*)
				READ_KEYS=true
				continue
			;;
			*:\ *)
				READ_KEYS=false
			;;
		esac
		if $READ_KEYS; then
			$LIST_KEYS && printf "%3d) %s %s\n" "$i" "$a_file" "$line_no_ws"
			$FIND_NEEDLE && [[ ",$needles," == *",$i,"* ]] && printf "${line_no_ws#- }\n"
			i=$(( $i + 1 ))
		fi 
	done < "$a_file"
done

exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
