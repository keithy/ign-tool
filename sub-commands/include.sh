# ign - implements common functions of various commands 
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

description="edit $command"
options=\
"--list                      # list record names
--show                      # show records
--form                      # show the record form
--add                       # add named record
--delete                    # remove named record"

usage=\
"$breadcrumbs                              # --show
$breadcrumbs $command --list                 # list names
$breadcrumbs $command --show                 # show files
$breadcrumbs $command hug --edit             # edit file
$breadcrumbs $command hug --add              # add record
$breadcrumbs $command key=value              # add field
$breadcrumbs $command --help                 # this message"

# Pretty print the form
form=$(echo "$theForm" | sed -e "s/^ \(.*\):/ ${bold}\1:${reset}/" \
  					         -e "s/^#\(.*\):/ ${dim}\1:${reset}/" )
      
extra="\n${bold}form:${reset}\n$form"

$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

# default config
[[ -z ${workspace+x} ]] && workspace="$g_working_dir/input"
[[ ! -f "$g_config_file" || ! -d "$workspace" ]] \
	&& echo "Config not found or not within an ign project directory" && exit 1

SHOW=true #default
LIST=false
SHOW_FORM=false
DELETE_ENTRY=false
ADD_ENTRY=false
EDIT_ENTRY=false
a_name=""
 
for arg in "$@"
do
	[[ $arg == "--"* ]] && SHOW=false
    case "$arg" in
        --show|-s)
            SHOW=true
            LIST=false
    	;;
        --list|-l)
            LIST=true
        ;;
        --form)
            SHOW_FORM=true
        ;;
        --edit|-e|-E)
            EDIT_ENTRY=true
        ;;
        --delete)
        	DELETE_ENTRY=true
        ;;
        --add)
        	ADD_ENTRY=true
        ;;
        -*|*=*)
        # ignore other options
        ;;
        # ? in this context is a single letter wildcard 
        ?*)
	        a_name="$arg"
	        SHOW=false
        ;;
    esac
done

# FIND LIST||SHOW
FOUND=false	
for thePath in "$workspace"/$command/*.yaml
do
 	theFile="${thePath##*/}"
 	theName="${theFile%.yaml}"
	$DEBUG && echo "thePath: $thePath" "theFile: $theFile" "theName: $theName"

	$LIST && echo $theName
	
	if $SHOW; then
		content=$(grep -v '^#' "$thePath"); 
		[[ "${content: -1}" == "\n" ]] && NL='' || NL=$'\n' 
		echo "${bold}$theFile${reset}"
	    echo "$content$NL"
	fi
	
	[[ "$theName" == "$a_name" ]] && FOUND=true && break
done


$SHOW_FORM && printf "$form\n" && exit 0
$SHOW && [[ -z ${thePath+x} ]] && echo "none defined"
$SHOW || $LIST && exit # Finished SHOW action
$FOUND && $EDIT_ENTRY && $EDITOR "$thePath" && exit 0
$FOUND && $DELETE_ENTRY && mv "$thePath" "$trash/$theFile" && echo "Moved $theFile to $trash" && exit 0
$DELETE_ENTRY && echo "not found" && exit 1

if ! $FOUND; then
	! $ADD_ENTRY && echo "${a_name} - not found" && exit 1
	thePath="$workspace/$command/${a_name}.yaml"
	theFile="${thePath##*/}"
	theName="${a_name}"
fi

$VERBOSE && echo "Result> ${dim}${thePath%/*}/${reset}${reset}$theFile${reset} (${bold}$theName${reset})"

: 

#This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
