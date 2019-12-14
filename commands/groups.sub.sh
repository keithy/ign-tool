# ign - groups 
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="groups"

# THE EMPTY FORM TEMPLATE

theForm="passwd.groups[+]:
  name:
# gid:
# password_hash:
# system:
"

source "$s_dir/include.sh"
options="$options\n--password                # enter at prompt"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

# READ FROM A DATA RECORD
declare -A Y
#initialize defaults
if $FOUND; then
	while IFS=$'\n' read -r line
	do
		# remove leading whitespace
		line="${line#"${line%%[![:space:]]*}"}"
		case "$line" in
			*:\ *)
				Y[${line%:*}]="${line#*: }"
			;;
		esac
	done < "$thePath"
else
 #add entry
	:
 $ADD_ENTRY && Y[name]="$theName"
fi

# CHANGE DATA
ENTER_PASSWORD=false
for arg in "$@"
do 
  case "$arg" in
	--password|-p)
		ENTER_PASSWORD=true
	;;
    *=*)
	   Y["${arg%=*}"]="${arg#*=}"
	;;
  esac
done

if $ENTER_PASSWORD; then
	Y[password_hash]=$(python -c 	"from passlib.hash import sha512_crypt; \
									 import getpass; print sha512_crypt.encrypt(getpass.getpass())")
fi

# UPDATE RECORD
													yaml="passwd.groups[+]:\n"
													yaml="$yaml  name: ${Y[name]:-}\n"
[[ -n "${Y[gid]:-}" ]]							&&  yaml="$yaml  gid: ${Y[gid]}\n"
[[ -n "${Y[password_hash]:-}" ]]				&&  yaml="$yaml  password_hash: ${Y[password_hash]}\n"
[[ "${Y[system]:-false}" == "true" ]]			&&  yaml="$yaml  system: ${Y[system]}\n"

# OUTPUT												
printf "$yaml" > "$thePath"

# DISPLAY

$VERBOSE && echo "${bold}${theFile}${reset}" && cat "$thePath" && exit 0
$LOUD && echo "${bold}${theFile}${reset}" && grep -v '^#' "$thePath"
	
exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
