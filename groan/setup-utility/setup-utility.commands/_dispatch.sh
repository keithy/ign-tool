# This g_dispatcher is looking for the chosen sub-command (in this directory)
# It was invoked from the context of a top level command whose <cmd>.locations.sh
# specified this as the g_dispatcher.
#
# Features:
# Running c_sub_cmd <sub>.sub.<ext>
# Mapping c_sub_cmd to that of another command <sub>.sub.<cmd>.cmd.<cmdsub>.sub.<ext>
# Failthrough to _not_found_sub.<cmd>.cmd.<cmdsub>.sub.<ext>
# Partial matching of c_sub_cmds is supported

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

#######
#These functions implement the format/policy of each command script for this folder
#######
function g_parseScriptPath()
{
  s_path="$1"
  s_name="${s_path##*/}"
  s_dir="${s_path%/*}"
  s_sub_cmd=""
  s_dest_cmd=""
  s_dest_subcmd_name=""

  #we remove everything .sub. onwards to avoid getting false matches on .sub
  local scriptRoute="${s_name%%.cmd.*}" 

  if [[ "$scriptRoute" =~ \.sub\. ]]; then #a c_sub_cmd is defined

    if [[ -f "$s_path" ]]; then

      s_sub_cmd="${scriptRoute%%.sub.*}" # everything before the first .sub
      s_dest_cmd="${scriptRoute#*sub.}"  # keep everything after first .sub.
      s_dest_path="${s_dir%/*}/${s_dest_cmd}/${s_dest_cmd:-$c_name}"
      s_dest_subcmd_name="${s_name#*.cmd.}"  # keep everything after .cmd.

    fi
  fi
}

# Recursively scan the c_sub_cmds for those that call the g_dispatcher of a contained command
# g_findCommands populates two arrays
# c_file_list= each element is a sub-command file (e.g. helper)
# breadcrumbsList= each element is a list of c_sub_cmds that reaches the above command

function g_findCommands()
{
  local c_file="$1"
  local crumbs="$2"

  c_file_list+=("$c_file")
  crumbsList+=("$crumbs")

  local s_dir
  local s_path

  g_readLocations "$c_file"

  for s_dir in "${g_locations[@]}"
  do
    for s_path in "$s_dir"/*.sub.*.cmd.*
    do
      g_parseScriptPath "$s_path"

      if [ -n "s_sub_cmd" ]; then
        if ! [[ "$s_dest_subcmd_name" == *.sub.* ]]; then #this c_sub_cmd invokes a g_dispatcher
          crumbs="$2 $s_sub_cmd"
          g_findCommands "$s_dest_path" "$crumbs"
        fi
      fi
    done
  done
}

#note $c_sub_cmd requested may be partial and $s_sub_cmd is the matched result
[ -z "$c_sub_cmd" ] && c_sub_cmd="$g_default_subcommand"

target="${c_sub_cmd}*.sub.*"
exact="${c_sub_cmd}.sub.*"

$DEBUG && echo "Looking for $target in: $s_dir"

# if an exact match is available - upgrade the target to prioritize the exact match
for s_path in $s_dir/$exact
do
    target=$exact
done

list=()
for s_path in $s_dir/$target
do
    g_parseScriptPath "$s_path"

    if [ -n "$s_sub_cmd" ]; then
      list+=($s_sub_cmd)
      $DEBUG && echo "Found #${#list[@]} : $s_path"
    fi
done

if [ ${#list[@]} -eq 1 ]; then #One script matches
  for s_path in $s_dir/$target
  do
      [[ "$s_sub_cmd" == _* ]] || breadcrumbs="$breadcrumbs $s_sub_cmd"
      g_executeScriptPath "$s_path"
      $SHOWHELP && exit
      $METADATAONLY && return || exit 
  done
fi

if [ ${#list[@]} -gt 1 ]; then
    $LOUD && echo "Multiple options exist for requested '${c_sub_cmd}' (${list[@]})"
    exit 1
fi

#not found scenario, continue to next g_dispatcher


