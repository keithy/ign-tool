# This dispatcher is looking for the chosen sub-command (in this directory)
# It was invoked from the context of a top level command whose <cmd>.locations.sh
# specified this as the dispatcher.
#
# Features:
# Running subcommand <sub>.sub.<ext>
# Mapping subcommand to that of another command <sub>.sub.<cmd>.cmd.<cmdsub>.sub.<ext>
# Failthrough to _not_found_sub.<cmd>.cmd.<cmdsub>.sub.<ext>
# Partial matching of subcommands is supported

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

#This function implements the format/policy of each command script for this folder
function parseScriptPath()
{
  scriptPath="$1"
  scriptName="${scriptPath##*/}"
  scriptDir="${scriptPath%/*}"
  scriptSubcommand=""
  destCommand=""
  destSubcommandName=""

  #we remove everything .sub. onwards to avoid getting false matches on .sub
  local scriptRoute="${scriptName%%.cmd.*}" 

  if [[ "$scriptRoute" =~ \.sub\. ]]; then #a subcommand is defined

    if [[ -f "$scriptPath" ]]; then

      scriptSubcommand="${scriptRoute%%.sub.*}" # everything before the first .sub
      destCommand="${scriptRoute#*sub.}"  # keep everything after first .sub.
      destPath="${scriptDir%/*}/${destCommand}/${destCommand}"
      destSubcommandName="${scriptName#*.cmd.}"  # keep everything after .cmd.

    fi
  fi
}

#note $subcommand requested may be partial and $scriptSubcommand is the matched result
[ -z "$subcommand" ] && subcommand="$defaultSubcommand"

target="${subcommand}*.sub.*"
exact="${subcommand}.sub.*"

$DEBUG && echo "Looking for $target in: $scriptDir"

# if an exact match is available - upgrade the target to prioritize the exact match
for scriptPath in $scriptDir/$exact
do
    target=$exact
done

list=()
for scriptPath in $scriptDir/$target
do
    parseScriptPath "$scriptPath"

    if [ -n "$scriptSubcommand" ]; then
      list+=($scriptSubcommand)
      $DEBUG && echo "Found #${#list[@]} : $scriptPath"
    fi
done

if [ ${#list[@]} -eq 1 ]; then #One script matches
  for scriptPath in $scriptDir/$target
  do
      executeScriptPath "$scriptPath"
      return
  done
fi

if [ ${#list[@]} -gt 1 ]; then
    $LOUD && echo "Multiple options exist for requested '${subcommand}' (${list[@]})"
    exit 1
fi

if [ ${#list[@]} -eq 0 ]; then #not found scenario
  args=("$target" ${args[@]:+${args[@]}})
  for scriptPath in $scriptDir/_not_found_sub.*
  do
     scriptPath="$scriptPath"
     parseScriptPath "$scriptPath"
     executeScriptPath "$scriptPath"
     return
  done
fi

$LOUD && echo "Not Found: $breadcrumbs ${bold}$subcommand${reset}"
exit 1