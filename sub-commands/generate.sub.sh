# ign generate.sub.sh
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="generate"
description="generate ignition file"
options=\
"--script             # show unprocessed input script
--vars               # list variables in the script
--yaml               # yaml final
--json               # validated json output
--verbose            # (all of the above)
--confirm            # not a dry run - deploy"
 
usage=\
"$breadcrumbs --verbose  # show all steps in generation
$breadcrumbs --confirm  # generate and deploy ignition file"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

# default config
[[ -z ${output+x} 	 ]] && USETMP=true || USETMP=false 
[[ -z ${libraries+x} ]] && libraries=("$g_working_dir/plugs" "$c_dir/plugs")
[[ -z ${workspace+x} ]] && workspace="$g_working_dir/input"
[[ -z ${header+x}    ]] && header="$workspace/00-header.yaml"
[[ ! -f "$g_config_file" || ! -d "$workspace" ]] \
	&& echo "Config not found or not within an ign project directory" && exit 1

command -v fcct >/dev/null 2>&1 || { echo "Missing dependency for generating ignition - fcct" ; exit 1 ; }
command -v yq >/dev/null 2>&1 || { echo "Missing dependency for composing yaml - yq" ; exit 1 ; } 

$USETMP || output_name="${output%.json}"

GENERATE=true
VIEW_HEADER="$VERBOSE"
VIEW_SCRIPT="$VERBOSE"
LIST_VARIABLES="$VERBOSE"
VIEW_YAML="$VERBOSE"
VIEW_JSON="$VERBOSE"
FCCT_PRETTY="-pretty"
FCCT_STRICT="-strict"
GET_INPUT=false
input_file=""

for arg in "$@"
do
	$GET_INPUT && input_file="$arg" && GET_INPUT=false && continue
    case "$arg" in
        --input|-input)
            GET_INPUT=true
            continue
        ;;
        --header)
            VIEW_HEADER=true
        ;;
        --script)
            VIEW_SCRIPT=true
        ;;
        --yaml)
            VIEW_YAML=true
        ;;
        --json|-j)
            VIEW_JSON=true
        ;;
        --ugly|--minimised|--min|--no-pretty)
            FCCT_PRETTY=""
        ;;
        --no-strict)
            FCCT_STRICT=""
        ;;
        --variables|--vars)
            LIST_VARIABLES=true
        ;;
        -*)
        # ignore other options
        ;;
        # ? in this context is a single letter wildcard 
        ?*) 
        ;;
    esac
done

# Three input options
# A - Start with named input file
# B - Build upon a standard header
# C - Read input from pipe
if [[ -n "$input_file" ]]; then #A
 	input=$(cat "$input_file")
elif [ -t 0 ]; then #B
	input=$(cat "$header")
else #C
	input=$(cat) #read from stdin
fi

$VIEW_HEADER && printf "${bold}header:${reset}\n$input\n"

# Collate the input script
$USETMP && script_file=$(mktemp) || script_file="${output_name}.src" && $DDEBUG && echo "script: ${script_file}" 
cp /dev/null "${script_file}"

find "${workspace}" -mindepth 2 -name "*.yaml" -type f -exec grep -v '^##' {} \; -exec echo \; > "${script_file}"

script="$(cat "$script_file")"
if $VIEW_SCRIPT; then

	printf "${bold}script:${reset}\n%s" "$script"
 
fi

if $LIST_VARIABLES; then

	printf "${bold}vars required:${reset}\n"
	
	envsubst --variables "$input"
	envsubst --variables "$(cat "$script_file")" 
		
	printf "${bold}values provided:${reset}\n" 
	for env in "${g_working_dir}/"*.env; do

  		case "$g_PLATFORM" in
  			*linux-gnu)
  				printf "%s\n" $(grep -v '^#' "$env" | xargs -d '\n')
			;;
			*darwin*)
  				printf "%s\n"  $(grep -v '^#' "$env" | xargs -0)
			;;
  		esac
	done
	$VERBOSE && "$g_file" ssh --export || "$g_file" ssh

fi

# EXPORT variables so envsubst can use them

case "$g_PLATFORM" in
	*linux-gnu)
		export $("$g_file" ssh -q --export | xargs -0)
	;;
	*darwin*)
		export $("$g_file" ssh -q --export | xargs -0)
	;;
esac

for env in "${g_working_dir}/"*.env; do

  case "$g_PLATFORM" in
  	*linux-gnu)
  		export $(grep -v '^#' "$env" | xargs -0)
	;;
	*darwin*)
  		export $(grep -v '^#' "$env" | xargs -0)
	;;
  esac
done

# Generate YAML
$USETMP && yaml_file=$(mktemp) || yaml_file="${output_name}.yaml" && $DDEBUG && echo "yaml: ${yaml_file}"
cp /dev/null "$yaml_file"

if [[ -z "$script" || "$script" =~ ^\ +$ ]]; then #script is empty
	echo "$input" | envsubst > "$yaml_file";
else
	echo "$input" | yq w -s "$script_file" - | envsubst > "$yaml_file"
fi
  
if $VIEW_YAML; then	
	printf "${bold}yaml:${reset}\n"
	cat "$yaml_file"

fi

# Generate JSON
$USETMP && json_file=$(mktemp) || json_file="${output_name}.json" && $DDEBUG && echo "json: $json_file"
cp /dev/null "$json_file"

fcct $FCCT_PRETTY $FCCT_STRICT -input "$yaml_file" -output "$json_file"

if $VIEW_JSON; then
	printf "${bold}json:${reset}\n"
	cat "$json_file"
fi

# Deployment is --confirm(ed)
$CONFIRM || printf "\nadd ${dim}--confirm${reset} to deploy to: $deploy_target\n" >&2
$CONFIRM || exit 0

$LOUD && echo cp "$json_file" "$deploy_target"
cp "$json_file" "$deploy_target"

exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
