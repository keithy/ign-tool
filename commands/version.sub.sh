# groan version.sub.sh
#
# by Keithy 2019
#

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="version"
description="returns version tagged in git and the short hash"
usage="usage:
$breadcrumbs version"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

c_file_list=()
crumbsList=()
g_findCommands "${g_file}" "${g_name}"

# get the cached version, the git version, use cache if git not working, if changed write cache
function get_version()
{
  local dir="$1"
  local cached=$(cat "$dir/.version" 2> /dev/null ) || true
  local version=$(cd "$dir"; git describe --long --tags --dirty --always 2> /dev/null ) || true
  version="${version:-$cached}"
  [[ "$version" == "cached" ]] || echo "$version" > "$dir/.version" || true
  
  [ -n "$version" ] && printf "%s:${bold}${dim}%16s${reset} ${bold}%s${reset}\n" "${version}" "(${dir##*/})" "${2:-}"
}

# get the version of this sub-command's command (i.e. groan)

get_version $(dirname "${BASH_SOURCE%/*}")

for i in "${!c_file_list[@]}"
do
  g_readLocations "${c_file_list[i]}"

  get_version "${c_file_list[i]%/*}" "${crumbsList[i]}"
  
done
 
exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."