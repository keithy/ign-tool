# groan new.sub.sh
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"
command="new"
description="create a new project/file structure from a template"
options=\
"--options|--list    # list available templates
--confirm            # not a dry run - perform action
--template=<choice>  # selection (-t=<choice>)
--<choice>           # selection (like cargo)
--go-ahead           # allow copy into existing project"
 
usage=\
"$breadcrumbs                               # --list & --help
$breadcrumbs --<template>                  # show template contents
$breadcrumbs my-project --starter          # new project using 'starter' template
$breadcrumbs my-project --t=starter        # new project using 'starter' template
$breadcrumbs --list                        # list available templates
$breadcrumbs --help                        # this message"

# --options
[[ -z ${g_config_preset_locations+x} ]] && g_config_preset_locations=("$c_dir")

extra="\nAvailable templates:\n"
for presetDir in "${g_config_preset_locations[@]}" 
do
   	for found in "$presetDir/"*.tmpl
   	do
       	title=""
       	#[[ -f "$found/.gitignore" ]] && title="$(grep -m 1 -i "^#" "$found/.gitignore")"
       	[[ -f "$found/README.md" ]] && title="$(grep -m 1 -i "^#" "$found/README.md")"
       	extra="$(printf "$extra %17s - $title" "${found##*/}")\n"
   	done
done

$SHOWHELP && g_displayHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

TEMPLATE=""
targetPath=""
templatePath=""
LIST_TEMPLATES=false
INSTALL=false
NO_TRAMPLE=true

for arg in "$@"
do
    case "$arg" in
        --options|--list)
            LIST_TEMPLATES=true
        ;;
        --go-ahead)
            NO_TRAMPLE=false
        ;;
        --t=|--te=|--tem=|--temp=|--templ=|--templa=|--templat=|--template= )
            TEMPLATE="${arg#--t*=}"
        ;; 
        --*)
            TEMPLATE="${arg#--}"
        ;;
        -*)
        # ignore other options
        ;;
        # ? in this context is a single letter wildcard 
        ?*) 
            targetPath="$arg"
            INSTALL=true
        ;;
    esac
done

$LIST_TEMPLATES && printf "$extra\n\n" && exit 0

[[ -z "$TEMPLATE" ]] && g_displayHelp && exit 0



templatePath="$TEMPLATE"
# auto-append .conf extension
[ "${templatePath##*.}" != "tmpl" ] && templatePath="${templatePath}.tmpl"

# search for template dir
if [[ ! -d "$templatePath" ]]; then
	for presetDir in "${g_config_preset_locations[@]}" 
	do
   		[[ -d "${presetDir}/${templatePath}" ]] && templatePath="${presetDir}/${templatePath}"
	done
fi

# exit if file does not exist
[[ ! -d "$templatePath" ]] && echo "$TEMPLATE not found" && exit 1

# show if the template exists and install is not requested
if [ $INSTALL == false ]; then
    echo "Showing template in: $templatePath" 1>&2  
    find "$templatePath"
    exit 0
fi

$NO_TRAMPLE && [[ -d "$targetPath" ]] && echo "$targetPath exists (--go-ahead) to populate existing directory" && exit 1

# INSTALL
r_options=""
$VERBOSE && r_options="v"

$LOUD && echo "${bold}Creating new project using:${reset} $TEMPLATE"
$LOUD && echo "rsync -rLtO${r_options}" "$templatePath" "$targetPath"
$DRYRUN && echo "${dim}dryrun:  --confirm required to proceed${reset}"

$CONFIRM && rsync "-rLtO${r_options}"  "$templatePath/" "$targetPath"
$CONFIRM && echo "Created $targetPath"

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."