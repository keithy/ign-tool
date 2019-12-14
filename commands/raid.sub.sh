# ign - raid 
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="raid"

# THE EMPTY FORM TEMPLATE

theForm="storage.raid[+]:
  name:
  level:
  devices:
# spares:
# options:
"

source "$s_dir/include.sh"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

# READ FROM A DATA RECORD
declare -A Y
declare -A devices
declare -A options
list=""
#initialize defaults
if $FOUND; then
	while IFS=$'\n' read -r line
	do
		# remove leading whitespace
		line="${line#"${line%%[![:space:]]*}"}"
		case "$line" in
			devices:*)
			   list="devices"
			;;        
			options:*)
			   list="options"
			;;
			*:\ *)
				Y[${line%:*}]="${line#*: }"
			;;
			-\ *)
			   [[ "$list" == "devices" ]] && devices["${line##*- }"]=1
			   [[ "$list" == "options" ]] && options["${line##*- }"]=1
			;;
		esac
	done < "$thePath"
else
 #add entry
	:
 $ADD_ENTRY && Y[name]="$theName"
fi

# CHANGE DATA

for arg in "$@"
do 
  case "$arg" in
    devices+=*)
	   devices["${arg#*+=}"]=1
	;;
	devices-=*)
	   unset -v "devices['${arg#*-=}']"
	;;
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
													yaml="storage.raid[+]:\n"
													yaml="$yaml  name: ${Y[name]:-}\n"
 													yaml="$yaml  level: ${Y[level]:-}\n"

[[ "${devices[@]}" == "" ]]						&&  yaml="$yaml  devices: []\n" 
[[ "${devices[@]}" != "" ]]						&&  yaml="$yaml  devices:\n" 
for device in "${!devices[@]}"; 				do	yaml="$yaml  - ${device}\n" ; done

[[ -n "${Y[spares]:-}" ]]						&&  yaml="$yaml  spares: ${Y[spares]}\n"

[[ "${options[@]}" != "" ]]						&&  yaml="$yaml  options:\n" 
for option in "${!options[@]}"; 				do	yaml="$yaml  - ${option}\n" ; done 
	
#OUTPUT												
printf "$yaml" > "$thePath"

#DISPLAY
$VERBOSE && echo "${bold}${theFile}${reset}" && cat "$thePath" && exit 0
$LOUD && echo "${bold}${theFile}${reset}" && grep -v '^#' "$thePath"
	
exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
