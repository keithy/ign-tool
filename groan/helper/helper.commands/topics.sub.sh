# groan help topics.sub.sh
#
# by Keith Hodges 2019

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="$scriptSubcommand"
description="list available commands"
#since help doesn't exec anything many common options don't apply
commonOptions="--theme=light    # alternate theme"
usage="$breadcrumbs    # list commands"

$SHOWHELP && executeHelp
$METADATAONLY && return

function list_topics()
{
  commandFile="$1"
  crumbs="$2"
 
  readLocations "$commandFile"

  for scriptDir in ${locations[@]} ; do
    local first=true
    for topicPath in $scriptDir/*.topic.{md,html,txt}
    do
      $first && printf "${dim}${commandFileList[i]##*/} topics:${reset}\n"

      if [[ -f "$topicPath" ]]; then
        topicFile="${topicPath##*/}"
        topicName="${topicFile%%.topic.*}"
        breadcrumbs="$2"
        
        echo "$breadcrumbs topic ${bold}$topicName${reset}"         
      fi
      first=false
    done
  done
}

commandFileList=()
crumbsList=()
find_commands "$rootCommandFile" ${rootCommandFile##*/}


TOPIC="${1:-}"

if [ -z "$TOPIC" ]; then
  for i in "${!commandFileList[@]}"
  do
    list_topics "${commandFileList[i]}" "${crumbsList[i]}"
  done
  
  echo

  exit 0
fi

if [ -n "$TOPIC" ]; then
  for i in "${!commandFileList[@]}"
  do
    readLocations "${commandFileList[i]}"

    for scriptDir in ${locations[@]} ; do
  
      target="${TOPIC}*.topic.*"

      # if an exact match is available - upgrade the target to prioritize the exact match
      for topicPath in "$scriptDir/$TOPIC.topic."*
      do
          target="$TOPIC.topic.*"
      done

      for topicPath in $scriptDir/$target
       do

         if [[ -f "$topicPath" ]]; then
           topicFile="${topicPath##*/}"
           topicName="${topicFile%%.topic.md}"
           breadcrumbs="${crumbsList[i]}"

           echo "$breadcrumbs $command $topicName"
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
  done
  exit 0
fi

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."
