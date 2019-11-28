# ign - filesystems 
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="filesystems"

# THE EMPTY FORM TEMPLATE

theForm="storage.filesystems[+]:
  path:
  device:
  format:
# wipe_filesystem:
# label:
# uuid:
# options:
"

source "$s_dir/include.sh"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

# READ FROM A DATA RECORD
declare -A Y
declare -A options
list=""
#initialize defaults
if $FOUND; then
	while IFS=$'\n' read -r line
	do
		# remove leading whitespace
		line="${line#"${line%%[![:space:]]*}"}"
		case "$line" in      
			options:*)
			   list="options"
			;;
			*-*)
			   [[ "$list" == "options" ]] && options["${line##*- }"]=1
			;;
			*:*)
				Y[${line%:*}]="${line#*: }"
			;;
		esac
	done < "$thePath"
else
 #add entry
	:
 # $ADD_ENTRY && name="$theName"
fi

# CHANGE DATA

for arg in "$@"
do 
  case "$arg" in
    options+=*)
	   options["${arg#*+=}"]=1
	;;
    options-=*)
	   unset -v "options['${arg#*-=}']"
	;;
    *=*)
	   Y["${arg%=*}"]="${arg#*=}"
	;;
  esac
done

# UPDATE RECORD
													yaml="storage.filesystems[+]:\n"
													yaml="$yaml  path: ${Y[path]:-}\n"
													yaml="$yaml  device: ${Y[device]:-}\n"
													yaml="$yaml  format: ${Y[format]:-}\n"
[[ "${Y[wipe_filesystem]:-false}" == "true" ]]	&&  yaml="$yaml  wipe_filesystem: ${Y[wipe_filesystem]}\n"
[[ -n "${Y[label]:-}" ]]						&&  yaml="$yaml  label: ${Y[label]}\n"
[[ -n "${Y[uuid]:-}" ]]							&&  yaml="$yaml  uuid: ${Y[uuid]}\n"

[[ "${options[@]}" != "" ]]						&&  yaml="$yaml  options:\n" 
for option in "${!options[@]}"; 				do	yaml="$yaml  - ${option}\n" ; done 

printf "$yaml" > "$thePath"

$VERBOSE && echo "${bold}${theFile}${reset}" && cat "$thePath" && exit 0
$LOUD && echo "${bold}${theFile}${reset}" && grep -v '^#' "$thePath"
	
exit 0

#This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
