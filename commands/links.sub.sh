# ign - links 
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="links"

# THE EMPTY FORM TEMPLATE

theForm="storage.links[+]:
  path:
# overwrite:
# user:
#   name:
#   id:
# group:
#   name:
#   id:
  target:
# hard:
"

source "$s_dir/include.sh"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

# READ FROM A DATA RECORD
declare -A Y
owner=""
#initialize defaults
if $FOUND; then
	while IFS=$'\n' read -r line
	do
		# remove leading whitespace
		line="${line#"${line%%[![:space:]]*}"}"
		case "$line" in
			user:*)
			   owner="user"
			;;        
			group:*)
			   owner="group"
			;;
			id:*)
			   [[ "$owner" == "user"  ]] && Y[user.id]="${line##*id: }" 
			   [[ "$owner" == "group" ]] && Y[group.id]="${line##*id: }"
			;;
			name:*)
			   [[ "$owner" == "user" ]]  && Y[user.name]="${line##*name: }" 
			   [[ "$owner" == "group" ]] && Y[group.name]="${line##*name: }"
			;;
			*:\ *)
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
    *=*)
	   Y["${arg%=*}"]="${arg#*=}"
	;;
  esac
done

# UPDATE RECORD
													yaml="storage.links[+]:\n"
													yaml="$yaml  path: ${Y[path]:-}\n"
[[ "${Y[overwrite]:-false}" == "true" ]]		&&  yaml="$yaml  overwrite: ${Y[overwrite]}\n"
[[ -n "${Y[user.id]:-}${Y[user.name]:-}" ]] 	&&  yaml="$yaml  user:\n"
[[ -n "${Y[user.id]:-}" ]] 						&&  yaml="$yaml    id: ${Y[user.id]}\n"
[[ -n "${Y[user.name]:-}" ]] 					&&  yaml="$yaml    name: ${Y[user.name]}\n"
[[ -n "${Y[group.id]:-}${Y[group.name]:-}" ]] 	&&  yaml="$yaml  group:\n"
[[ -n "${Y[group.id]:-}" ]] 					&&  yaml="$yaml    id: ${Y[group.id]}\n"
[[ -n "${Y[group.name]:-}" ]] 					&&  yaml="$yaml    name: ${Y[group.name]}\n"
													yaml="$yaml  target: ${Y[target]:-}\n"
[[ "${Y[hard]:-false}" == "true" ]]			 	&&  yaml="$yaml  hard: ${Y[hard]}\n"

printf "$yaml" > "$thePath"

$VERBOSE && echo "${bold}${theFile}${reset}" && cat "$thePath" && exit 0
$LOUD && echo "${bold}${theFile}${reset}" && grep -v '^#' "$thePath"
	
exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
