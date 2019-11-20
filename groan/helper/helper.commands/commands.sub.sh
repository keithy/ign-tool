# groan help commands.sub.sh
#
# by Keith Hodges 2019

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="commands"
description="full list of commands"
#since help doesn't exec anything many common options don't apply
commonOptions="--theme=light    # alternate theme"
usage="$breadcrumbs    # list commands"

$SHOWHELP && executeHelp
$METADATAONLY && return

function list_subcommands()
{
  commandFile="$1"
  crumbs="$2"
 
  readLocations "$commandFile"

  for scriptDir in ${locations[@]} ; do

	# Display the default sub-command at the top of  the list (without its breadcrumb)
    #if ! [[ "$defaultSubcommand" == _* ]] ; then    
     for scriptPath in $scriptDir/$defaultSubcommand.sub.*
      do
        parseScriptPath "$scriptPath"
        $DEBUG && echo "Parsed: …${scriptDir##*/}${dim}/${reset}$scriptName (${scriptSubcommand:-no subcommand})" 
        METADATAONLY=true
        executeScriptPath "$scriptPath"  

        printf "%-45s" "$crumbs"
        echo "$description"
      done
    #fi

	# Display the subcommands (with breadcrumb)
    for scriptPath in $scriptDir/[^_]*.sub.*
    do
      parseScriptPath "$scriptPath"

      $DEBUG && echo "Parsed: …${scriptDir##*/}${dim}/${reset}$scriptName (${scriptSubcommand:-no subcommand})" 

      if [[ -n "$scriptSubcommand" ]] && [[ "$destSubcommandName" == *.sub.* ]]; then
         
        crumbs="$2 $scriptSubcommand"

        METADATAONLY=true
        printf "%-45s" "$crumbs"
        executeScriptPath "$scriptPath"  

        echo "$description"
      fi
    done
  done
}

commandFileList=()
crumbsList=()
find_commands "$rootCommandFile" ${rootCommandFile##*/}

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