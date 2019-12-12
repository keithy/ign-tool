# ign - users 
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="users"

# THE EMPTY FORM TEMPLATE

theForm="passwd.users[+]:
  name:
# password_hash:
# uid:
# gecos:
# home_dir:
# no_create_home:
# primary_group:
# groups:
# no_user_group:
# no_log_init:
# shell:
# system:
"

source "$s_dir/include.sh"
options="$options\n--password                  # enter at prompt"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

# READ FROM DATA RECORD
declare -A Y
declare -A grps
declare -A keys

list=""
if $FOUND; then
	while IFS=$'\n' read -r line
	do
		# remove leading whitespace
		line="${line#"${line%%[![:space:]]*}"}"
		case "$line" in
			groups:*)
				list="groups"
			;;
			ssh_authorized_keys:*)
				list="keys"
			;;
 			*:\ *)
				Y[${line%:*}]="${line#*: }"
			;;
			-\ *)
			   [[ "$list" == "groups" ]] && grps["${line#- }"]=1
			   [[ "$list" == "keys" ]]   && keys["${line#- }"]=1
			;;
		esac
	done < "$thePath"
else
 $ADD_ENTRY && Y[name]="$theName"
fi

# CHANGE DATA
needles=""
ENTER_PASSWORD=false
for arg in "$@"
do 
  case "$arg" in
	--password|-p)
		ENTER_PASSWORD=true
	;;
	--ssh+=*)
	   	while IFS=$'\n' read -r key; do
			keys["$key"]=1
		done < <("$g_file" ssh -q "=${arg#--ssh+=}")
	;;
	--ssh-=*)
		while IFS=$'\n' read -r key; do
			unset -v "keys['$key']"
		done < <("$g_file" ssh -q "=${arg#--ssh-=}")
	;;
    groups+=*)
	   grps["${arg#*+=}"]=1
	;;
	groups-=*)
	   unset -v "grps['${arg#*-=}']"
	;;
    ssh_authorized_keys+=*|keys+=*)
	   keys["${arg#*+=}"]=1
	;;
    ssh_authorized_keys-=*|keys-=*)
	   unset -v "keys['${arg#*-=}']"
	;;
    *=*)
	   Y["${arg%%=*}"]="${arg#*=}"
	;;
  esac
done

if $ENTER_PASSWORD; then

case "$g_PLATFORM" in
	*linux-gnu)
		Y[password_hash]=$(mkpasswd -m sha-512 --rounds=4096)
	;;
	*darwin*)
		Y[password_hash]=$(python3 -c 'from passlib.hash import sha512_crypt; import getpass ; print(sha512_crypt.hash(getpass.getpass()))')
	;;
esac


fi

# UPDATE RECORD
													yaml="passwd.users[+]:\n"
													yaml="$yaml  name: ${Y[name]:-}\n"
[[ -n "${Y[password_hash]:-}" ]]				&&  yaml="$yaml  password_hash: ${Y[password_hash]}\n"

[[ "${keys[@]}" != "" ]]						&&  yaml="$yaml  ssh_authorized_keys:\n" 
for key in "${!keys[@]}"; 						do  yaml="$yaml  - ${key}\n" ; done

[[ -n "${Y[uid]:-}" ]]							&&  yaml="$yaml  uid: ${Y[uid]}\n"
[[ -n "${Y[gecos]:-}" ]]						&&  yaml="$yaml  gecos: ${Y[gecos]}\n"
[[ -n "${Y[home_dir]:-}" ]]						&&  yaml="$yaml  home_dir: ${Y[home_dir]}\n"
[[ "${Y[no_create_home]:-false}" == "true" ]]	&&  yaml="$yaml  no_create_home: ${Y[no_create_home]}\n"
[[ -n "${Y[primary_group]:-}" ]]				&&  yaml="$yaml  primary_group: ${Y[primary_group]}\n"

[[ "${grps[@]}" != "" ]]						&&  yaml="$yaml  groups:\n" 
for group in "${!grps[@]}"; 					do  yaml="$yaml  - ${group}\n" ; done

[[ "${Y[no_user_group]:-false}" == "true" ]]	&&  yaml="$yaml  no_user_group: ${Y[no_user_group]}\n"
[[ "${Y[no_log_init]:-false}" == "true" ]]		&&  yaml="$yaml  no_log_init: ${Y[no_log_init]}\n"
[[ -n "${Y[shell]:-}" ]]						&&  yaml="$yaml  shell: ${Y[shell]}\n"
[[ "${Y[system]:-false}" == "true" ]]			&&  yaml="$yaml  system: ${Y[system]}\n"

# OUTPUT
printf "$yaml" > "$thePath"

#DISPLAY
$VERBOSE && echo "${bold}${theFile}${reset}" && cat "$thePath" && exit 0
$LOUD    && echo "${bold}${theFile}${reset}" && grep -v '^#' "$thePath"
	
exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
