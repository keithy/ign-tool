# A generic sub-command invocation that invokes a nested command e.g. groan help -> groan/helper
#
# by Keith Hodges 2018
#
# The idea is that sub-commands that map to nested commands have identical code (i.e. this file)
# taking parameters from their own name
#
# Sub-commands like 'help.sub.helper.cmd._dispatch.sh' are invoked based upon their prefix <cmd>.sub.*
# 
# This script is then responsible for interpreting useful parameters embedded in its own name.
# Other scripts may provide alternative parameterizations and interpretations.
#
# In this case the sub-command in the parent command's list, is implemented by the .sub.<helper>.cmd
# command contained in the parent folder, whose target script is provided within <helper>.commands 
# The target script may be either
# 1) a specific sub-command
# 2) a g_dispatcher, selecting the sub-sub-command based upon the next argument
# 3) any other bespoke script or g_dispatcher

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"
$DEBUG && echo "s_name: ${bold}$s_name${reset}"

g_readLocations "$s_dest_path"

g_shiftArgsIntoNext

c_sub_cmd="${next:-$g_default_subcommand}" # if no argument get the default (set in g_locations.sh)

$DEBUG && echo "$s_sub_cmd($s_dest_cmd $s_dest_subcmd_name) args(${#args[@]}): ${args[@]:+${args[@]}}"

# given the argument look for commands that match
for s_dir in "${g_locations[@]}"
do
  if [ -f "$s_dir/$s_dest_subcmd_name" ]; then
    source "$s_dir/$s_dest_subcmd_name"
    $METADATAONLY && return
  fi
done

$LOUD && echo "Not Found: $breadcrumbs ${bold}$c_sub_cmd${reset}"
# "This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
# Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed
# subject to the same license."

