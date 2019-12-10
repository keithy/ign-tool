# groan help topics.sub.sh
#
# by Keith Hodges 2019

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="$s_sub_cmd"
description="list available topics"
#since help doesn't exec anything many common options don't apply
commonOptions="--theme=light    # alternate theme"
usage="$breadcrumbs    # list topics"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

function list_topics()
{
  local c_file="$1"
  local crumbs="$2"
 
  g_readLocations "$c_file"

  for s_dir in ${g_locations[@]} ; do
    local first=true
    for topicPath in $s_dir/*.topic.{md,html,txt}
    do
      $first && printf "${dim}${c_file_list[i]##*/} topics:${reset}\n"

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

c_file_list=()
crumbsList=()
g_findCommands "${g_file}" ${g_name}


TOPIC="${1:-}"

if [ -z "$TOPIC" ]; then
  for i in "${!c_file_list[@]}"
  do
    list_topics "${c_file_list[i]}" "${crumbsList[i]}"
  done
  
  echo

  exit 0
fi

if [ -n "$TOPIC" ]; then
  for i in "${!c_file_list[@]}"
  do
    g_readLocations "${c_file_list[i]}"

    for s_dir in ${g_locations[@]} ; do
  
      target="${TOPIC}*.topic.*"

      # if an exact match is available - upgrade the target to prioritize the exact match
      for topicPath in "$s_dir/$TOPIC.topic."*
      do
          target="$TOPIC.topic.*"
      done

      for topicPath in $s_dir/$target
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
