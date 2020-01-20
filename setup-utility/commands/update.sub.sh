# groan.setup.update.sh
#
# by Keith Hodges 2019
#
$DEBUG && echo "${dim}${BASH_SOURCE[0]}${reset}"

command="update"
description="self-update ${g_name}"
usage=\
"$breadcrumbs                  # update tool data
$breadcrumbs --code --confirm # update code"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

UPDATE_CODE=false
UPDATE_DATA=true

for arg in "$@"
do
  case "$arg" in
    --code)
	    UPDATE_CODE=true
    ;;
    -*)
    # ignore other options
    ;;
    *)
	:
    ;;
  esac
done

if $UPDATE_DATA; then
	# Update any libraries from repoitories
	if [[ -n ${repositories+x} ]]; then

		repo_directory="${repo_directory:-${g_dir}/library}"
	
		for repo in "${repositories[@]}"; do
			repo_name="${repo##*/}"
			repo_name="${repo_name%.git}"
			repo_local="${repo_directory}/${repo_name}"
			\rm -rf "${repo_local}"
			git clone "${repo}" "${repo_local}"
			\rm -rf "${repo_local}/.git"

			$LOUD && echo "Data files updated (${repo_name})"
		done
	fi
fi

if $UPDATE_CODE; then
	$DRYRUN && echo "Code Update: --confirm required" && exit 0
	[[ -d "$g_dir/.git" ]] && git -C "$g_dir" pull
fi

exit 0

"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."