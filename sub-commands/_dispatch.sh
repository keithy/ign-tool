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

#######
#These functions implement the format/policy of each command script for this folder
#######
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
      destPath="${scriptDir%/*}/${destCommand}/${destCommand:-$commandName}"
      destSubcommandName="${scriptName#*.cmd.}"  # keep everything after .cmd.

    fi
  fi
}

# Recursively scan the subcommands for those that call the dispatcher of a contained command
# find_commands populates two arrays
# commandFileList= each element is a sub-command file (e.g. helper)
# breadcrumbsList= each element is a list of subcommands that reaches the above command

function find_commands()
{
  local commandFile="$1"
  local crumbs="$2"

  commandFileList+=("$commandFile")
  crumbsList+=("$crumbs")

  local scriptDir
  local scriptPath

  readLocations "$commandFile"

  for scriptDir in "${locations[@]}"
  do
    for scriptPath in "$scriptDir"/*.sub.*.cmd.*
    do
      parseScriptPath "$scriptPath"

      if [ -n "scriptSubcommand" ]; then
        if ! [[ "$destSubcommandName" == *.sub.* ]]; then #this subcommand invokes a dispatcher
          crumbs="$2 $scriptSubcommand"
          find_commands "$destPath" "$crumbs"
        fi
      fi
    done
  done
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
      [[ "$scriptSubcommand" == _* ]] || breadcrumbs="$breadcrumbs $scriptSubcommand"
      executeScriptPath "$scriptPath"
      $METADATAONLY && return || exit 
  done
fi

if [ ${#list[@]} -gt 1 ]; then
    $LOUD && echo "Multiple options exist for requested '${subcommand}' (${list[@]})"
    exit 1
fi

#not found scenario, continue to next dispatcher


