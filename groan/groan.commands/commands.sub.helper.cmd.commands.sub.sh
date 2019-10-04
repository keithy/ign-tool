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
# 2) a dispatcher, selecting the sub-sub-command based upon the next argument
# 3) any other bespoke script or dispatcher

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"
$DEBUG && echo "scriptName: ${bold}$scriptName${reset}"

readLocations "$destPath"

shiftArgsIntoNext
subcommand="$next"
[ -z "$subcommand" ] && subcommand="$defaultSubcommand" 

$DEBUG && echo "$scriptSubcommand($destCommand $destSubcommandName) args(${#args[@]}): ${args[@]:+${args[@]}}"

# if no argument get the default for this command
# given the argument look for commands that match
for scriptDir in "${locations[@]}"
do
  if [ -f "$scriptDir/$destSubcommandName" ]; then
    source "$scriptDir/$destSubcommandName"
  fi
done

# "This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
# Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed
# subject to the same license."

