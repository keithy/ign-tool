# ign plugs.sub.sh
#
# by Keith Hodges 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="plugs"
description="manage ignition plugs"
options=\
"--find              # find available plugs
--pull              # download available plugs"

usage=\
"$breadcrumbs             # --list && --find
$breadcrumbs             # print first three keys found
$breadcrumbs             # print first three keys used"

theForm="## No fixed form
passwd.users[+]:
systemd.units[+]:
storage.files[+]:
"

# default config
[[ -z ${libraries+x} ]] && libraries=("$c_dir/plugs" "$g_working_dir/plugs")
[[ -z ${repo_directory+x} ]] && repo_directory="$c_dir/repos"
[[ -z ${workspace+x} ]] && workspace="$g_working_dir/input"
[[ ! -f "$g_config_file" || ! -d "$workspace" ]] \
	&& echo "Config not found or not within an ign project directory" && exit 1

function installed_plugs () {
	installed=""
	i=65 #A - using alphabetic index
	plug_names=()
	for plug in "${workspace}/${command}/"*
	do
		row=$(printf "\x$(printf %x $i)")
		plug_file="${plug##*/}"
		plug_name="${plug_file%.yaml}"

		installed="$installed\n${row}) $plug_name"
		
		if [[ "${plugs_minus:-}," == *",$row,"* || "${plugs_minus:-}," == *",${plug_name},"* ]];
		then
			rm "$plug"
			installed="$installed ${bold}-> removed${reset}"
		else
			plug_names+=("$plug_name")
		fi	
		
		i=$(( $i + 1 ))
	done
}

installed_plugs
help_postscript="${bold}installed:${reset}\n${installed}"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

plugs_add=""
plugs_minus=""
FIND_PLUGS=true
LIST_PLUGS=true
PULL_PLUGS=false
for arg in "$@"
do
    case "$arg" in
        --find)
            FIND_PLUGS=true
        ;;
        --list)
        	LIST_PLUGS=true
        	FIND_PLUGS=false
        ;;
        --download|--down|--pull)
            PULL_PLUGS=true
        ;;

        +*)
        # ignore other options
        plugs_add="${plugs_add},${arg#+}"
        ;;
        -*)
        plugs_minus="${plugs_minus},${arg#-}"
        # ignore other options
        ;;
        # ? in this context is a single letter wildcard 
        ?*) 
        ;;
    esac
done

installed_plugs

if $PULL_PLUGS; then
	for repo in "${repositories[@]}"; do
		repo_name="${repo##*/}"
		repo_name="${repo_name%.git}"
		repo_local="${repo_directory}/${repo_name}"
		[[ -d "${repo_local}" ]] \
			&& git -C "${repo_local}" pull \
			|| git clone "${repo}" "${repo_local}"
	done
fi

$LIST_PLUGS && printf "${bold}installed:${reset}${installed}\n\n"

# YAML

plugs=()
for library in "${libraries[@]}"; do
	for plug in "${library}"/*.yaml; do
		plugs+=("${plug}")
	done
done

# MARKDOWN

for plug in $(grep -lr '```yaml' "$repo_directory")
do
	plugs+=("${plug}")
done

i=1
plug_dir=""
for plug in "${plugs[@]}"
do
	$FIND_PLUGS && [[ "$plug_dir" != "${plug%/*}" ]] \
		&& plug_dir="${plug%/*}" && echo "${bold}available:${reset} ${plug_dir}" 
	plug_file="${plug##*/}"
	plug_name="${plug_file%.*}"
	$FIND_PLUGS && [[ "$NL${plug_names[*]}$NL" == *"$NL${plug_name}$NL"* ]] && printf "${dim}" 
	$FIND_PLUGS && printf "$i) ${plug_name}${reset}"			

	if [[ "${plugs_add}," == *",$i,"* || "${plugs_add}," == *",${plug_name},"* ]];
	then
		case "${plug_file##*.}" in
			yaml)
				cp "$plug" "${workspace}/${command}"
			;;
			md)
				awk '/```yaml/,/```$/ { if(/```/) next; print }' "$plug" > "${workspace}/${command}/${plug_name}.yaml"
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
