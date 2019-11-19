# groan new.sub.sh
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="generate"
description="generate ignition file"
options=\
"--confirm            # not a dry run - perform action
--view               # see the input"
 
usage=\
"$breadcrumbs                            # --list & --help
$breadcrumbs generate --view            # generate ignition file
$breadcrumbs generate                   # generate ignition file"

$SHOWHELP && executeHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

# default config
$DEBUG && echo "Viewer: $VIEWER"
[[ -z ${libraries+x} ]] && libraries=("$workingDir/plugs" "$commandDir/plugs")
[[ -z ${workspace+x} ]] && workspace="$workingDir/input"
[[ -z ${header+x} ]]    && header="00-header.yaml"
[[ -z ${output+x} ]]    && USETMP=true || USETMP=false 
$USETMP || output="${output%.json}"

GENERATE=true
VIEW_SCRIPT=false
VIEW_YAML=false
VIEW_JSON=false
FCCT_PRETTY="-pretty"
FCCT_STRICT="-strict"

for arg in "$@"
do
    case "$arg" in
        --input|--script)
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
        -*)
        # ignore other options
        ;;
        # ? in this context is a single letter wildcard 
        ?*) 
        ;;
    esac
done

# --options
$USETMP && script=$(mktemp) || script="$output.src" && $DDEBUG && echo "script: $script" 

find "${workspace}" -name "*.yaml" -type f -exec cat {} \; -exec echo \; > $script
 
$VIEW_SCRIPT && cat $script && exit 0

$USETMP && yaml=$(mktemp) || yaml="$output.yaml" && $DDEBUG && echo "yaml: $yaml"
 
yq w -s $script "$header" > $yaml

$VIEW_YAML && cat $yaml && exit 0

$USETMP && json=$(mktemp) || json="$output.json" && $DDEBUG && echo "json: $json"

fcct $FCCT_PRETTY $FCCT_STRICT -input $yaml -output $json

$VIEW_JSON && cat $json && exit 0

# Deployment is --confirm(ed)
$CONFIRM || echo "${dim}(--confirm to deploy)${reset}"
$CONFIRM || exit 0

$LOUD && echo cp $json "$deploy_target"
cp $json "$deploy_target"

exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
