# groan help commands.sub.sh
#
# by Keith Hodges 2019

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="commands"
description="full list of commands"
#since help doesn't exec anything many common options don't apply
commonOptions="--theme=light    # alternate theme"
usage="$breadcrumbs    # list commands"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

function list_sub_cmds()
{
  local c_file="$1"
  local crumbs="$2"
 
  g_readLocations "$c_file"

  for s_dir in ${g_locations[@]} ; do

		# Display the default sub-command at the top of  the list (without its breadcrumb)
		#if ! [[ "$g_default_subcommand" == _* ]] ; then    
		 for s_path in $s_dir/${g_default_subcommand}.sub.*
		  do
			g_parseScriptPath "$s_path"
			$DEBUG && echo "Parsed[$s_path]: …${s_dir##*/}${dim}/${reset}$s_name (${s_sub_cmd:-no subcommand})" 
			METADATAONLY=true
			printf "%-30s" "$crumbs"
			g_executeScriptPath "$s_path"  

			echo "$description"
		  done
		#fi
 done

 local c_file="$1"
 g_readLocations "$c_file"
	
 for s_dir in ${g_locations[@]} ; do
	
	# Display the c_sub_cmds (with breadcrumb)
  	for s_path in $s_dir/[^_]*.sub.*
    do
      g_parseScriptPath "$s_path"

      $DEBUG && echo "Parsed: …${s_dir##*/}${dim}/${reset}$s_name (${s_sub_cmd:-no subcommand})" 

      if [[ -n "$s_sub_cmd" ]] && [[ "$s_dest_subcmd_name" == *.sub.* ]]; then
         
        crumbs="$2 $s_sub_cmd"

        METADATAONLY=true
        printf "%-30s" "$crumbs"
        g_executeScriptPath "$s_path"  

        echo "$description"
      fi
    done
 done
}

c_file_list=()
crumbsList=()
g_findCommands "${g_file}" ${g_name}

if $DEBUG; then # print out results of recursive search
  echo
  for i in "${!c_file_list[@]}"; do    
       printf "(%d) %-45s" $i ${crumbsList[i]}
       echo "${c_file_list[i]}"
  done
  echo
fi

for i in "${!c_file_list[@]}"
do
  displayName="${c_file_list[i]##*/}"
  echo "${bold}${displayName/-/ } commands:${reset}"

  list_sub_cmds "${c_file_list[i]}" "${crumbsList[i]}"
  
  echo
done

exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."