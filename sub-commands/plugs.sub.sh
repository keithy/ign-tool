# ign plugs.sub.sh
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="$s_sub_cmd"
singular="${command%s}"
description="manage ignition $command"
options=\
"--find              # find available $command
--pull              # download available $command"

usage=\
"$breadcrumbs             # --list && --find
$breadcrumbs             # print first three keys found
$breadcrumbs             # print first three keys used"

# default config
[[ -z ${libraries+x} ]] && libraries=("$c_dir/library" "$g_working_dir/library")
[[ -z ${repo_directory+x} ]] && repo_directory="$c_dir/library"
[[ -z ${workspace+x} ]] && workspace="$g_working_dir/input"

function installed_plugs () {
	installed=""
	i=65 #A - using alphabetic index
	plug_names=()
	for plug_path in "${workspace}/${command}/"*
	do
		row=$(printf "\x$(printf %x $i)")
		plug_file="${plug_path##*/}"
		plug_name="${plug_file%.yaml}"

		installed="$installed\n${row}) $plug_name"
		
		if [[ ",${plugs_minus:-}," == *",$row,"* || "${plugs_minus:-}," == *",${plug_name},"* ]];
		then
			rm "$plug_path"
			installed="$installed ${bold}-> removed${reset}"
		else
			plug_names+=("$plug_name")
		fi	
		
		if  [[ ",${plugs:-}," == *",$row,"* || ",${plugs:-}," == *",${plug_name},"* ]]; then	
			${EDIT_PLUGS:-false} && "$EDITOR" "$plug_path"
			${SHOW_PLUGS:-false} && echo "${bold}.${plug_path:${#g_working_dir}}${reset}" && cat "$plug_path" && echo \
				&& [[ -f "$g_working_dir/$plug_name.env" ]] \
					&& echo "${bold}./${plug_name}.env${reset}" \
					&& cat "$g_working_dir/$plug_name.env" && echo
			${EDIT_VARS:-false} && "$EDITOR" "$g_working_dir/$plug_name.env"
		fi
		i=$(( $i + 1 ))
	done
}

installed_plugs
help_postscript="${bold}installed:${reset}\n${installed}"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

[[ ! -f "$g_config_file" || ! -d "$workspace" ]] \
	&& echo "Config not found or not within an ign project directory" && exit 1

plugs_add=""
plugs_minus=""
plug=""
DEFAULT=true
FIND_PLUGS=false
LIST_PLUGS=false
PULL_PLUGS=false
ADD_PLUGS=false
DELETE_PLUGS=false
EDIT_PLUGS=false
SHOW_PLUGS=false
EDIT_VARS=false

for arg in "$@"
do
    case "$arg" in
    	--list)
        	LIST_PLUGS=true
        	DEFAULT=false
        ;;
        --find)
            FIND_PLUGS=true
           	DEFAULT=false
        ;;
        --download|--down|--pull)
            PULL_PLUGS=true
        	DEFAULT=false
        ;;
        --edit)
        	EDIT_PLUGS=true
        	DEFAULT=false
        ;;
        --show|--print)
        	SHOW_PLUGS=true
        	DEFAULT=false
        ;;
        --vars)
        	EDIT_VARS=true
        	DEFAULT=false
        ;;
        --add)
        	ADD_PLUGS=true
        	DEFAULT=false
        ;;
        --rm|--remove|--delete|--del)
        	DELETE_PLUGS=true
        	DEFAULT=false
        ;;
        +*)
        plugs_add="${plugs_add},${arg#+}"
        ;;
        -*)
        plugs_minus="${plugs_minus},${arg#-}"
        ;;
        # ? in this context is a single letter wildcard 
        ?*)
        	plugs="$arg"
        ;;
    esac
done

$DEFAULT && $LOUD && { FIND_PLUGS=true ; LIST_PLUGS=true ; }
$DELETE_PLUGS && plugs_minus="$plugs_minus,${plugs}"
$ADD_PLUGS && plugs_add="$plugs_add,${plugs}"

installed_plugs

if $PULL_PLUGS; then
	for repo in "${repositories[@]}"; do
		repo_name="${repo##*/}"
		repo_name="${repo_name%.git}"
		repo_local="${repo_directory}/${repo_name}"
		\rm -rf "${repo_local}"
		git clone "${repo}" "${repo_local}"
		\rm -rf "${repo_local}/.git"
	done
fi

$LIST_PLUGS && printf "${bold}installed:${reset}${installed}\n\n"

# YAML

plugs=()
for library in "${libraries[@]}"; do
	for plug in "${library}/${singular}:"*.yaml; do
		plugs+=("${plug}")
	done
done

# MARKDOWN

for plug in $(find "$repo_directory" -name "$singular:*" -exec grep -lr '```yaml' {} \;)
do
	plugs+=("${plug}")
done

i=1
plug_dir=""
for plug in "${plugs[@]}"
do
	## Print Directory
	$FIND_PLUGS && [[ "$plug_dir" != "${plug%/*}" ]] \
		&& plug_dir="${plug%/*}" && echo "${bold}available:${reset} ${dim}${g_dir##*/}${reset}${plug_dir:${#g_dir}}" 
	plug_file="${plug##*/}"
	plug_name="${plug_file%.*}"

	## dim font for installed plugs
	$FIND_PLUGS && [[ "$NL${plug_names[*]}$NL" == *"$NL${plug_name}$NL"* ]] && printf "${dim}" 

	## Print plug name
	$FIND_PLUGS && printf "$i) ${plug_name}${reset}"			

	if [[ "${plugs_add}," == *",$i,"* || "${plugs_add}," == *",${plug_name},"* ]];
	then
		case "${plug_file##*.}" in
			yaml)
			    if [[ ! -f "${workspace}/${command}/${plug_name}.yaml" ]]; then
					cp "$plug" "${workspace}/${command}"
				fi
			;;
			env)
			    if [[ ! -f "${g_working_dir}/${plug_name}.env" ]]; then
					cp "$plug" "${g_working_dir}"
				fi
			;;
			md|rest)
				if [[ ! -f "${workspace}/${command}/${plug_name}.yaml" ]]; then
					awk '/```yaml/,/```$/ { if(/```/) next; print }' "$plug" > "${workspace}/${command}/${plug_name}.yaml"
				fi
				if [[ ! -f "${g_working_dir}/${plug_name}.env" ]]; then
				    values=$(awk '/```env/,/```$/ { if(/```/) next; print }' "$plug") 
				    [[ -n "$values" ]] && printf "%s" "$values" > "${g_working_dir}/${plug_name}.env"
				fi
			;;
		esac		
		$FIND_PLUGS || printf "$i) ${plug_name}"
		printf "%s\n" " ${bold}-> installed${reset}"
	else
		$FIND_PLUGS && printf "\n"
	fi		

	i=$(( $i + 1 ))
done


exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
