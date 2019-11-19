# groan new.sub.sh
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="groups"
description="add groups"
options=\
"--confirm            # not a dry run - perform action
--list               # list group names
--show               # show group entries"
 
usage=\
"$breadcrumbs                            # --show
$breadcrumbs group --list               # list group names
$breadcrumbs group --show               # show group files"

$SHOWHELP && executeHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

# default config
$DEBUG && echo "Viewer: $VIEWER"
[[ -z ${workspace+x} ]] && workspace="$workingDir/input"
[[ -z ${output+x} ]]    && USETMP=true || USETMP=false 
$USETMP || output="${output%.json}"

LIST=false
SHOW=true
DELETE=false
ADD_GROUP=false
a_gid=""
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
        --delete)
        	DELETE=true
        	SHOW=false
        	LIST=false
        ;;
        --gid=)
			a_gid="${arg#--gid=}"
        ;;        
        -*)
        # ignore other options
        ;;
        # ? in this context is a single letter wildcard 
        ?*)
	        ADD_GROUP=true
        	a_group="$arg"
        ;;
    esac
done

FOUND=false	
for group in "$workspace"/passwd/groups/*.yaml
do
 	groupFile="${group##*/}"
 	groupName="${groupFile%.yaml}"

	$LIST && echo $groupName
	
	if $SHOW; then
		content=$(cat "$group"); NL=$'\n'
		[[ "${content: -1}" != "\n" ]] && content="$content$NL"
		echo "${bold}$groupFile${reset}"
	    echo "$content"
	fi
	
	[[ "$groupName" == "$a_group" ]] && FOUND=true && break
done

$FOUND && $DELETE && mv "$group" $trash && echo "Moved $groupFile to $trash"

$FOUND && exit 0


if $ADD_GROUP; then

	group="$workspace/passwd/groups/${a_group}.yaml"

	printf "passwd.groups[+]:\n  name:${a_group}\n" > "$group" 
	
	#idiomatic verifies a_gid is numeric
	[[ -n "$a_gid" ]] && [[ "$a_gid" == "$a_gid" ]] && printf "  gid:${a_gid}\n" > "$group" 
fi

exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
