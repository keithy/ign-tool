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
GET_FILEPATH=false
a_name=""
a_password=""
a_file=""
a_contents=""
keys=()
values=()
keys_del=()
values_del=()
keys_add=()
values_add=()
for arg in "$@"
do
	[[ $arg == "--"* ]] && SHOW=false
	$GET_FILEPATH && a_file="$arg" && GET_FILEPATH=false && continue
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
        	DELETE=true
        ;;
        --add)
        	ADD_ENTRY=true
        ;;
        contents_file=*|inline_file=*)
			keys+=("${arg%%_file=*}")
			values+=("|")
			a_file="${arg##*_file=}"
        ;;
        --file)
        ;;
        --password|-p)
			ENTER_PASSWORD=true
        ;;
        contents=*|inline=*)
        	keys+=("${arg%%=*}")
    		values+=("|")
        	a_contents="${arg##*=}"
		;;
        *-=*)
   			keys_del+=("${arg%%-=*}")
			values_del+=("${arg#*-=}")
        ;;
        *+=*)
   			keys_del+=("${arg%%+=*}")
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
		content=$(grep -v '^#' "$thePath"); 
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
	[[ ! -f "${forms}/$command.yaml" ]] && echo "Missing form:" "${forms}/$command.yaml"
	cp "${forms}/$command.yaml" "$thePath"
 	FOUND=true
 	
 	sed -i.bak -e "s/name:.*/name: ${a_name}/" "$thePath"
fi

$LOUD && ! $FOUND && echo "$a_name - not found" && exit 0

$ENTER_PASSWORD && \
	keys+=("password_hash") && \
	values+=($(python -c "from passlib.hash import sha512_crypt; \
			import getpass; print sha512_crypt.encrypt(getpass.getpass())"))

# Keys and value pairs: key=value (-z value re-comments key)
for i in "${!keys[@]}"
do
  keyA="${keys[i]%%.*}"
  keyB="${keys[i]##*.}"
  value="${values[i]}"

  $DEBUG && echo "$keyA.$keyB='$value' ($a_file) [$a_contents]"
  
	cp "$thePath" "$thePath".bak
	awk -v keyA="$keyA" \
		-v keyB="$keyB" \
		-v valA="$value" \
		-v inlineFile="$a_file" \
		-v inlineContents="$a_contents" \
		-f- "$thePath".bak > "$thePath" <<- 'EOD'
		BEGIN {
			look="key";
			if ( keyA == keyB ) look="value";
		    value=valA
		}
		{
			#print look > "/dev/stderr"
			# 0 - looking for a matching key - if found ensure that line is uncommented
			if ( look == "key" && match($0, keyA ) ) {
				sub(/^#/," ");
				print;
				look="value";
				next;
			}
			# 1 - looking for a matching keyB
			if ( look == "value" && match($0, keyB ) ) {
				look="finish";
				 
				match($0, /[# ]( *)/, spaces)

			    if (inlineContents=="" && inlineFile=="" && valA=="|") value=""
				comment=" "
				if ( value == "" ) { comment="#" }
				printf( "%s%s%s: %s\n", comment, spaces[1], keyB, value);

				if ( valA == "|" ) {
			   		# read the given file 
					if ( inlineContents != "") { 
						split(inlineContents, lines, "\n")
						for (i in lines) {
							printf( "    %s\n" , lines[i] )
						}
						printf( "\n" );
					} else if ( inlineFile != "") { 
						while ((getline < inlineFile) > 0) print "   ", $0;
					} 
					look="contents-read-already"
				}
				next;
			}	
			# 2 - line ending with | marks the start of an inline content area
			if ( $0 ~ /\|$/ ) look="contents";
			# 3 - an empty line marks the end of an inline content area
			if (look !="finish" && $0 ~ /^[\s\t\r]*$/) { printf( "\n" ); look="finish"; next };
			
			if ( look=="contents-read-already" ) next;
			
			# finish - copy out non-empty lines
			if ( ! /^[ \s\t\r]*$/ ) { print }
		}
		END { }
	EOD
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
  if [[ -n "$value" ]]; then #array add entry
	NL=$'\n'
	sed -i.bak -e "s~[ #]\( *\)${key}:.*~ \1${key}:\\${NL} \1- ${value}~g" "$thePath"				
  fi
done

$VERBOSE && $FOUND && echo "${bold}${theFile}${reset}" && cat "$thePath" && exit 0

$LOUD && $FOUND && echo "${bold}${theFile}${reset}" && grep -v '^#' "$thePath"
	
exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
