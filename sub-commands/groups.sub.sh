# ign - implements various commands 
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="${BASH_SOURCE##*/}"
command="${command%.sub.sh}"
description="edit $command"
options=\
"--list                    # list record names
--show                    # show records
--form                    # show the record form
--add                     # add named record
--delete                  # remove named record
--password                # enter at prompt"

usage=\
"$breadcrumbs                              # --show
$breadcrumbs $command --list                # list names
$breadcrumbs $command --show                # show files
$breadcrumbs $command hug --edit             # edit file
$breadcrumbs $command hug --add gid=1001     # add record and field
$breadcrumbs $command --help                 # this message"

# Pretty print the form
form=$(sed -e "s/^  \(.*\):/  ${bold}\1:${reset}/" \
           -e "s/^##\(.*\):/  ${dim}\1:${reset}/"  \
       "$forms/$command.yaml")

extra="\n${bold}form:${reset}\n$form"

$SHOWHELP && executeHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

# default config
[[ -z ${workspace+x} ]] && workspace="$workingDir/input"
[[ -z ${output+x} ]]    && USETMP=true || USETMP=false 
$USETMP || output="${output%.json}"

SHOW=true #default
LIST=false
SHOW_FORM=false
DELETE=false
ADD_ENTRY=false
EDIT_ENTRY=false
ENTER_PASSWORD=false
a_name=""
a_password=""
keys=()
values=()
values_del=()
keys_add=()
values_add=()
for arg in "$@"
do
    case "$arg" in
        --list|-l)
            LIST=true
            SHOW=false
        ;;
        --show|-s)
            SHOW=true
            LIST=false
        ;;
        --form)
            SHOW_FORM=true
            SHOW=false
            LIST=false
        ;;
        --edit|-e|-E)
            EDIT_ENTRY=true
            LIST=false
            SHOW=false
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
        --password|-p)
			ENTER_PASSWORD=true
			SHOW=false	
        ;;
        *-=*)
			values_del+=("${arg#*-=}")
        ;;
        *+=*)
			keys_add+=("${arg%%+=*}")
			values_del+=("${arg#*+=}")
			values_add+=("${arg#*+=}")
        ;;
        *=*)
			keys+=("${arg%%=*}")
			values+=("${arg#*=}")
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
for thePath in "$workspace"/$command/*.yaml
do
 	theFile="${thePath##*/}"
 	theName="${theFile%.yaml}"

	$LIST && echo $theName
	
	if $SHOW; then
		content=$(grep -v '^##' "$thePath"); 
		[[ "${content: -1}" == "\n" ]] && NL='' || NL=$'\n' 
		echo "${bold}$theFile${reset}"
	    echo "$content$NL"
	fi
	
	[[ "$theName" == "$a_name" ]] && FOUND=true && break
done

$SHOW_FORM && $EDIT_ENTRY && $EDITOR "$forms/$command.yaml" && exit 0

$SHOW_FORM && printf "$form\n" && exit 0

$SHOW && [[ -z ${thePath+x} ]] && echo "none defined"
$SHOW || $LIST && exit # Finished SHOW action

$FOUND && $EDIT_ENTRY && $EDITOR "$thePath" && exit 0

$FOUND && $DELETE && mv "$thePath" "$trash/$theFile" && echo "Moved $theFile to $trash" && exit 0

if ! $FOUND && $ADD_ENTRY && [[ -n "$a_name" ]]; then
	thePath="$workspace/$command/${a_name}.yaml"
 	theFile="${thePath##*/}"
 	theName="${theFile%.yaml}"

	cp "${forms}/$command.yaml" "$thePath"
 	FOUND=true
 	
 	sed -i.bak -e "s/name:.*/name: ${a_name}/" "$thePath"
fi

$LOUD && ! $FOUND && echo "$a_name - not found" && exit 0

$ENTER_PASSWORD && \
	keys+=("password_hash") && \
	values+=($(python -c "from passlib.hash import sha512_crypt; \
			import getpass; print sha512_crypt.encrypt(getpass.getpass())"))

# Keys and value pairs
for i in "${!keys[@]}"
do
  key="${keys[i]}"
  value="${values[i]}"
    $DEBUG && echo "$key=$value"
  if [[ -z "$value" ]]; then
  	  sed -i.bak "s~[ #][ #]\(.*\)${key}:.*~##\1${key}:~" "$thePath"
  else
	  sed -i.bak "s~[ #][ #]\(.*\)${key}:.*~  \1${key}: ${value}~" "$thePath"
  fi
done


#Keys and value adding to list of strings
for i in "${!values_del[@]}"; do
  sed -i.bak -e "/   *- ${values_del[i]}/d" "$thePath"
done

#Keys and value adding to list of strings
for i in "${!keys_add[@]}"; do
  key="${keys_add[i]}"
  [[ "$key" == "keys" ]] && key="ssh_authorized_keys"
  value="${values_add[i]}"
  if [[ -n "$value" ]]; then
	NL=$'\n'
	sed -i.bak -e "s~[ #][ #]\(.*\)${key}:.*~  \1${key}:\\${NL}  \1- ${value}~g" "$thePath"				
  fi
done

$VERBOSE && $FOUND && echo "${bold}${theFile}${reset}" && cat "$thePath" && exit 0

$LOUD && $FOUND && echo "${bold}${theFile}${reset}" && grep -v '^##' "$thePath"
	
exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
