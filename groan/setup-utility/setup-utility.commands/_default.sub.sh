# groan single command list of subcommands.sub.sh
#
# by Keith Hodges 2019

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="commands"
description="list available commands"
#since help doesn't exec anything many common options don't apply
commonOptions="--theme=light    # alternate theme"
usage="$breadcrumbs    # list commands"

$SHOWHELP && executeHelp
$METADATAONLY && return

commandFileList=()
crumbsList=()
find_commands "$commandFile" "$breadcrumbs"

function list_subcommands()
{
  commandFile="$1"
  crumbs="$2"
 
  readLocations "$commandFile"

  for scriptDir in ${locations[@]} ; do

    # The default case without any subcommands (if not hidden)
    if ! [[ "$defaultSubcommand" == _* ]] ; then    
     for scriptPath in $scriptDir/$defaultSubcommand.sub.*
      do
        parseScriptPath "$scriptPath"
        $DEBUG && echo "Parsed: …${scriptDir##*/}${dim}/${reset}$scriptName (${scriptSubcommand:-no subcommand})" 
        METADATAONLY=true
        executeScriptPath "$scriptPath"  

        printf "%-45s" "$crumbs"
        echo "$description"
      done
    fi

    for scriptPath in $scriptDir/*.sub.*
    do
      parseScriptPath "$scriptPath"

      $DEBUG && echo "Parsed: …${scriptDir##*/}${dim}/${reset}$scriptName (${scriptSubcommand:-no subcommand})" 

      if [ -n "$scriptSubcommand" ]; then
        [[ "$scriptSubcommand" == _* ]] || crumbs="$2 $scriptSubcommand"

        METADATAONLY=true
        executeScriptPath "$scriptPath"  

        printf "%-45s" "$crumbs"
        echo "$description"
      fi
    done
  done
}

if $DEBUG; then # print out results of recursive search
  echo
  for i in "${!commandFileList[@]}"; do    
       printf "(%d) %-45s" $i ${crumbsList[i]}
       echo "${commandFileList[i]}"
  done
  echo
fi

for i in "${!commandFileList[@]}"
do
  displayName="${commandFileList[i]##*/}"
  echo "${bold}${displayName/-/ } commands:${reset}"

  list_subcommands "${commandFileList[i]}" "${crumbsList[i]}"
  
  echo
done

exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."