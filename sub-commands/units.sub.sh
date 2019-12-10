# ign - units 
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="units"

# THE EMPTY FORM TEMPLATE

theForm="systemd.units[+]:
  name:
# enabled:
# mask:
# contents:
"

source "$s_dir/include.sh"
options="$options\n--contents_file=<filename>  # enter at prompt"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

TAB="    "
# READ FROM A DATA RECORD
declare -A Y
#initialize defaults
READ_CONTENTS=false
ACTION=false
if $FOUND; then
	while IFS=$'\n' read -r line
	do
		# remove leading whitespace
		line_no_ws="${line#"${line%%[![:space:]]*}"}"
		case "${line_no_ws}" in
			contents:\ \|)
				READ_CONTENTS=true
				Y[contents]=""
				continue
			;;
			*:\ *)
				READ_CONTENTS=false
				Y["${line_no_ws%%:*}"]="${line_no_ws#*:\ }"
			;;
		esac
		$READ_CONTENTS && Y[contents]="${Y[contents]}${line}${NL}"
	done < "$thePath"
else
 #add entry
	:
 $ADD_ENTRY && Y[name]="$theName"
fi

# CHANGE DATA
a_contents=""
EDIT_CONTENTS=false
for arg in "$@"
do 
  case "$arg" in
    --edit-contents)
		EDIT_CONTENTS=true
    ;;
    contents_file=*)
		a_contents=$(<"${arg#contents_file=}")
    ;;
    contents=)
		Y[contents]=""
    ;;
    contents=*)
		a_contents="${arg#contents=}"
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
fi

# UPDATE RECORD
													yaml="systemd.units[+]:\n"
													yaml="$yaml  name: ${Y[name]:-}\n"
[[ "${Y[enabled]:-false}" == "true" ]]			&&  yaml="$yaml  enabled: ${Y[enabled]}\n"
[[ "${Y[mask]:-false}" == "true" ]]				&&  yaml="$yaml  mask: ${Y[mask]}\n"
[[ -n "${Y[contents]:-}" ]]						&&  yaml="$yaml  contents: |\n"
[[ -n "${Y[contents]:-}" ]]						&&  yaml="$yaml${Y[contents]}"

# OUTPUT												
printf "$yaml" > "$thePath"

# DISPLAY

$DDEBUG && echo ">${bold}${theFile}${reset}" && printf "$yaml" && exit 0
$VERBOSE && echo "${bold}${theFile}${reset}" && cat "$thePath" && exit 0
$LOUD && echo "${bold}${theFile}${reset}" && grep -v '^#' "$thePath"
	
exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
