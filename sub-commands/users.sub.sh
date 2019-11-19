# groan users.sub.sh
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="users"
description="create a new user"
options=\
"--list                     # list users names
--show                     # show users entries
--add                      # add userPath entry
   [ --gid <id> ]          # with uid
   [ --system <bool> ]     # system user
--delete                   # remove userPath entry
--groups=<primary,other..> # with users
--uid=<id>                 # with userPath id
--system=[true|false]      # with system flag - set/remove
--password_hash <hash>     # with <sha-256>/<sha-512>/false/0
--password			       # enter at prompt"

usage=\
"$breadcrumbs                             # --show
$breadcrumbs users --list                # list users names
$breadcrumbs users --show                # show users entries
$breadcrumbs users bob                   # show a user's entry
$breadcrumbs userPath bob --add --uid: 1001  # add a userPath with id"

$SHOWHELP && executeHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

# default config
[[ -z ${workspace+x} ]] && workspace="$workingDir/input"
[[ -z ${output+x} ]]    && USETMP=true || USETMP=false 
$USETMP || output="${output%.json}"

LIST=false
SHOW=true
DELETE=false
ADD_ENTRY=false
ENTER_PASSWORD=false
GET_ID=false
GET_NAME=false
GET_PASSWORD=false
a_name=""
an_id=""
a_system=""
a_password=""
for arg in "$@"
do
	$GET_ID && an_id="$arg" && GET_ID=false && continue
	$GET_PASSWORD && a_password="$arg" && GET_PASSWORD=false && continue
    case "$arg" in
        --list|-l)
            LIST=true
            SHOW=false
        ;;
        --show|-s)
            SHOW=true
            LIST=false
        ;;
        --delete)
        	DELETE=true
        	SHOW=false
        	LIST=false
        ;;
        --add)
        	ADD_ENTRY=true
        	SHOW=false
        ;;
        --uid=*|-u=*)
			an_id="${arg#--u*=}"
			SHOW=false	
        ;;
        --uid|-u)
			GET_ID=true
			SHOW=false	
        ;;
        --password_hash|--hash)
			GET_PASSWORD=true
			SHOW=false	
        ;;
        --password|-p)
			ENTER_PASSWORD=true
			SHOW=false	
        ;;
        --system|--system=true|--system=1)
			a_system=true
			SHOW=false
        ;;
        --system=false|--system=0)
			a_system=false
			SHOW=false	
        ;;
        -*)
        # ignore other options
        ;;
        # ? in this context is a single letter wildcard 
        ?*)
	        a_name="$arg"
	        SHOW=false   
        ;;
    esac
done

# FIND AND SHOW
FOUND=false	
for userPath in "$workspace"/passwd/groups/*.yaml
do
 	userFile="${userPath##*/}"
 	userName="${userFile%.yaml}"

	$LIST && echo $userName
	
	if $SHOW; then
		content=$(cat "$group"); 
		[[ "${content: -1}" == "\n" ]] && NL='' || NL=$'\n' 
		echo "${bold}$userFile${reset}"
	    echo "$content$NL"
	fi
	
	[[ "$userName" == "$a_name" ]] && FOUND=true && break
done

$SHOW && [[ -z ${groupPath+x} ]] && echo "none defined"
$SHOW || $LIST && exit # Finished SHOW action

$FOUND && $DELETE && mv "$userPath" $trash && echo "Moved $userFile to $trash" && exit 0

if ! $FOUND && $ADD_ENTRY && [[ -n "$a_name" ]]; then
	userPath="$workspace/passwd/groups/${a_name}.yaml"
 	userFile="${userPath##*/}"
 	userName="${userFile%.yaml}"
 	FOUND=true
 	
	printf "passwd.groups[+]:\n  name: ${a_name}\n" > "$userPath" 
fi

$LOUD && ! $FOUND && echo "$a_name - not found" && exit 0

#idiomatic verifies an_id is numeric
if [[ -n "$an_id" && "$an_id" -eq "$an_id" ]]; then
	sed -i -e '/gid:.*/d' "$userPath"
	[[ "$an_id" -ne 0 ]] && printf "  gid: ${an_id}\n" >> "$userPath" 
fi

if [[ -n "$a_system" ]]; then
	sed -i -e '/system:.*/d' "$userPath"
	$a_system && printf "  system: true\n" >> "$userPath" 
fi

$ENTER_PASSWORD && a_password=$(python -c "from passlib.hash import sha512_crypt; import getpass; print sha512_crypt.encrypt(getpass.getpass())")

#a_password 
if [[ -n "$a_password" ]]; then
	sed -i -e '/password_hash:.*/d' "$userPath"
	
	if [[ "${a_password:0:1}" == "$" && ${#a_password} -gt 40 ]]; then
		printf "  password_hash: ${a_password}\n" >> "$userPath"
	fi
fi

$LOUD && $FOUND && echo "${bold}${userFile}${reset}" && cat "$userPath"
	
exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
