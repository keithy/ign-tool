# ign - files 
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="files"

# THE EMPTY FORM TEMPLATE

theForm="storage.files[+]:
  path:
# overwrite:
# contents:
#   compression:
#   source:
#   inline:
#   verification:
#     hash:
# mode:
# user:
#   name:
#   id:
# group:
#   name:
#   id:
"

source "$s_dir/include.sh"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

# READ FROM A DATA RECORD
declare -A Y
Y[contents]=""
ACTION=""
TAB="      "
#initialize defaults
if $FOUND; then
	while IFS=$'\n' read -r line
	do
		line_no_ws="${line#"${line%%[![:space:]]*}"}"
		case "${line_no_ws}" in
			inline:\ \|)
				ACTION="contents"
				Y[contents]=""
				continue
			;;
			user:*)
				ACTION="user"
			;;        
			group:*)
				ACTION="group"
			;;
			id:*)
				Y["${ACTION}.id"]="${line##*id: }"
			;;
			name:*)
				Y["${ACTION}.name"]="${line##*name: }" 
			;;
			*:\ *)
				ACTION=""
				Y["${line_no_ws%%:*}"]="${line_no_ws#*:\ }"
			;;
		esac
		[[ "$ACTION" == "contents" ]] && Y[contents]="${Y[contents]}${line}${NL}"
	done < "$thePath"
else
 #add entry
	:
 # $ADD_ENTRY && name="$theName"
fi

# CHANGE DATA

a_contents=""
EDIT_CONTENTS=false
AUTOHASH=false
for arg in "$@"
do 
  case "$arg" in
    --edit-contents|--edit-inline)
		EDIT_CONTENTS=true
    ;;
    --hash)
		AUTOHASH=true
		Y[contents]=""
		a_contents=""
    ;;
    contents_file=*|inline_file=*|contents.inline_file=*)
		a_contents=$(<"${arg#*_file=}")
		Y[source]="" # source/contents are mutually exclusive
    ;;
    contents=|inline=|contents.inline=)
		Y[contents]=""
		a_contents=""
    ;;
    contents=*|inline=*|contents.inline=*)
		a_contents="${arg#*=}"
		Y[source]="" # source/contents are mutually exclusive
    ;;
    contents.compression=*|compression=*)
    	Y[contents]="" # source/contents are mutually exclusive
    	a_contents=""
		Y[compression]="${arg#*=}"
    ;;
    contents.source=*|source=*)
    	Y[contents]="" # source/contents are mutually exclusive
    	a_contents=""
		Y[source]="${arg#*=}"
    ;;
	contents.verification.hash=*|verification.hash=*|hash=*)
		Y[contents]="" # source/contents are mutually exclusive
		a_contents=""
		Y[hash]="${arg#*=}"
    ;;
    *=*)
	   Y["${arg%=*}"]="${arg#*=}"
	;;
  esac
done

if $EDIT_CONTENTS; then
	tmpfile=$(mktemp)
	while IFS=$'\n' read -r line; do
		printf "%s\n" "${line//$TAB/}" >> "$tmpfile"  
	done <<< "${Y[contents]}"
	$EDITOR "$tmpfile"
	a_contents="$(<"$tmpfile")"
fi

if [[ -n "$a_contents" ]]; then
	a_contents="${a_contents//\\n/$NL}"
	Y[contents]=""
	buf=""
	while IFS=$'\n' read -r line; do
		[[ -z "$line" ]] && buf="$buf$NL" || buf="$buf$TAB$line$NL"
	done <<< "$a_contents"
	Y[contents]="${buf}"
	Y[source]=""
fi

if $AUTOHASH; then
	Y[hash]="sha512-$(curl -sSL "${Y[source]}" | shasum -a 512)X"
	Y[hash]="${Y[hash]%%\ *}"
fi
 
# UPDATE RECORD
contentsMedley="${Y[contents]:-}${Y[compression]:-}${Y[source]:-}${Y[hash]:-}"

													yaml="storage.files[+]:\n"
													yaml="$yaml  path: ${Y[path]:-}\n"
[[ "${Y[overwrite]:-false}" == "true" ]]		&&  yaml="$yaml  overwrite: ${Y[overwrite]}\n"

[[ -n "$contentsMedley" ]]						&&  yaml="$yaml  contents:\n"
[[ -n "${Y[compression]:-}" ]] 					&&  yaml="$yaml    compression: ${Y[compression]}\n"
[[ -n "${Y[source]:-}" ]] 						&&  yaml="$yaml    source: ${Y[source]}\n"
[[ -n "${Y[contents]:-}" ]]						&&  yaml="$yaml    inline: |\n"
[[ -n "${Y[contents]:-}" ]]						&&  yaml="$yaml${Y[contents]}"
[[ -n "${Y[hash]:-}" ]]							&&  yaml="$yaml    verification:\n"
[[ -n "${Y[hash]:-}" ]]							&&  yaml="$yaml      hash: ${Y[hash]}\n"

[[ -n "${Y[mode]:-}" ]]							&&  yaml="$yaml  mode: ${Y[mode]:-}\n"
[[ -n "${Y[user.id]:-}${Y[user.name]:-}" ]] 	&&  yaml="$yaml  user:\n"
[[ -n "${Y[user.id]:-}" ]] 						&&  yaml="$yaml    id: ${Y[user.id]}\n"
[[ -n "${Y[user.name]:-}" ]] 					&&  yaml="$yaml    name: ${Y[user.name]}\n"
[[ -n "${Y[group.id]:-}${Y[group.name]:-}" ]] 	&&  yaml="$yaml  group:\n"
[[ -n "${Y[group.id]:-}" ]] 					&&  yaml="$yaml    id: ${Y[group.id]}\n"
[[ -n "${Y[group.name]:-}" ]] 					&&  yaml="$yaml    name: ${Y[group.name]}\n"

# OUTPUT												
printf "$yaml" > "$thePath"

# DISPLAY

$DDEBUG && echo ">${bold}${theFile}${reset}" && printf "$yaml" && exit 0
$VERBOSE && echo "${bold}${theFile}${reset}" && cat "$thePath" && exit 0
$LOUD && echo "${bold}${theFile}${reset}" && grep -v '^#' "$thePath"
	
exit 0

#This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
