# groan help topic.cmd.sh
#
# by Keith Hodges 2019

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="$scriptSubcommand"
description="display topics"
#since help doesn't exec anything many common options don't apply
commonOptions="--theme=light    # alternate theme"
usage="$breadcrumbs <topic_title>   # show topics"

$SHOWHELP && executeHelp
$METADATAONLY && return

#Options processing 
TOPIC="$1"

function search_topics()
{
  commandFile="$1"
  readLocations "$commandFile"


  for loc in ${locations[@]} ; do

    $DEBUG && echo "Looking for $target in: $loc"

    for scriptPath in $loc/*.cmd.*
    do
      scriptName="${scriptPath##*/}"        
      scriptPrefix="${scriptName%%.cmd.*}"
      if [[ "$scriptPrefix" =~ [^.].*\.sub\. ]]; then
        if [[ -f "$scriptPath" ]]; then
          scriptSubcommand="${scriptPrefix%%.sub.*}"
          breadcrumbs="$2"
        
          executeScript "$scriptPath" "$loc" "$scriptName" "$scriptSubcommand"
         
        fi
      fi
    done

    target="${TOPIC}*.topic.*"
    
    # if an exact match is available - upgrade the target to prioritize the exact match
    for scriptPath in $loc/$TOPIC.topic.*
    do
        target="$TOPIC.topic.*"
    done

    for topicPath in $loc/$target
     do
 
       if [[ -f "$topicPath" ]]; then
         topicFile="${topicPath##*/}"
         topicName="${topicFile%%.topic.md}"
         breadcrumbs="$2"

         echo "$breadcrumbs topic $topicName"
          case ${topicPath##*.} in
              txt)
                  cat "$topicPath"
                  return
              ;;
              md)
                  mdv "$topicPath"
                  return
              ;;
          esac
       fi
     done
  done
}

$DEBUG && echo "METADATAONLY=${bold}true${reset}"
METADATAONLY=true

commandFileList=("$rootCommandFile")
breadcrumbsList=(${rootCommandFile##*/})
 
until [ ${#commandFileList} -eq 0 ]
do
  firstCommandFile="${commandFileList[0]}"
  firstBreadcrumbs="${breadcrumbsList[0]}"

  if $DEBUG; then
    echo
    for i in "${!commandFileList[@]}"; do    
         printf "(%d) %-45s" $i ${breadcrumbsList[i]}
         echo "${commandFileList[i]}"
    done
    echo
  fi

  search_topics "$firstCommandFile" "$firstBreadcrumbs"

  #remove first command file from list
  old_array=("${commandFileList[@]}")
  old_bc_list=("${breadcrumbsList[@]}")
  commandFileList=()
  breadcrumbsList=()
  for i in "${!old_array[@]}"; do
    if [ "${old_array[i]}" != "$firstCommandFile" ]; then
      commandFileList+=( "${old_array[i]}" )
      breadcrumbsList+=( "${old_bc_list[i]}" )
    fi
  done
  unset old_array
  unset old_bc_list
  
  echo
done

exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."