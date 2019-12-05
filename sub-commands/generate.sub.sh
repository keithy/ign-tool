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

$USETMP || output="${output%.json}"

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
$USETMP && script=$(mktemp) || script="$output.src" && $DDEBUG && echo "script: $script" 
cp /dev/null "$script"

find "${workspace}" -mindepth 2 -name "*.yaml" -type f -exec grep -v '^##' {} \; -exec echo \; > "$script" 
$VIEW_SCRIPT && printf "${bold}script:${reset}\n" && cat "$script"

# Generate YAML
$USETMP && yaml=$(mktemp) || yaml="$output.yaml" && $DDEBUG && echo "yaml: $yaml"
echo "$input" > "$yaml"

YQ_HAPPY=false
echo "$input" | yq w -s "$script" - 2&> /dev/null && YQ_HAPPY=true

if $LIST_VARIABLES; then
	$YQ_HAPPY && echo "$input" | yq w -s "$script" - > "$yaml"
	printf "${bold}vars:${reset}\n" && envsubst --variables "$(cat "$yaml")"
fi

$VIEW_YAML && printf "${bold}yaml:${reset}\n"
$YQ_HAPPY && echo "$input" | yq w -s "$script" - | envsubst > "$yaml"
$YQ_HAPPY || echo "$input" | envsubst > "$yaml"
$VIEW_YAML && cat $yaml

# Generate JSON
$USETMP && json=$(mktemp) || json="$output.json" && $DDEBUG && echo "json: $json"
cp /dev/null "$json"

$VIEW_JSON && $VERBOSE && printf "${bold}json:${reset}\n"
fcct $FCCT_PRETTY $FCCT_STRICT -input "$yaml" -output "$json"
$CONFIRM || cat "$json"

# Deployment is --confirm(ed)
$CONFIRM || printf "\nadd ${dim}--confirm${reset} to deploy to: $deploy_target\n" >&2
$CONFIRM || exit 0

$LOUD && echo cp $json "$deploy_target"
cp $json "$deploy_target"

exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
