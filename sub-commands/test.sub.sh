# groan test.sh
#
# by Keith Hodges 2010
#
# A Dummy

$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="test"
description="dummy (test for duplication)"
usage="usage:
$breadcrumbs test"

$SHOWHELP && executeHelp
$METADATAONLY && return

echo "Test successful: ($@)"

exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."

# Scratchpad

# Keys and value pairs
for i in "${!keys[@]}"
do
  key="${keys[i]}"
  value="${values[i]}"
    $DEBUG && echo "$key=$value"
  if [[ -z "$value" ]]; then
  	  sed -i.bak "s~[ #][ #]\( *\)${key}:.*~##\1${key}:~" "$thePath"
  else
	  sed -i.bak "s~[ #][ #]\( *\)${key}:.*~  \1${key}: ${value}~" "$thePath"
  fi
done

awk -f - << EOD

EOD

#Keys and value adding to list of strings
for i in "${!keys_del[@]}"; do
  keyA="${keys_del[i]%.*}"
  keyB="${keys_del[i]#*.}"
  if [[ "$keyB" == "$keyA" ]]; then #array delete entry
	sed -i.bak -e "\~${keyA}~=" -e "/   *- ${values_del[i]}/d" "$thePath"
  else # dictionary comment out entry
  	sed -i.bak -e "\~${keyA}~=" -e "s~[# ][# ]\( *\)${keyB}:.*~##\1${keyB}:~" "$thePath"
  fi
done

#Keys and value adding to list of strings
for i in "${!keys_add[@]}"; do
  keyA="${keys_add[i]%.*}"
  keyB="${keys_add[i]#*.}"
  [[ "$keyA" == "keys" ]] && key="ssh_authorized_keys"
  value="${values_add[i]}"
  if [[ "$keyB" == "$keyA" ]]; then #array add entry
	NL=$'\n'
	sed -i.bak -e "\~${keyA}:~=" -e "s~[ #][ #]\( *\)${key}:.*~  \1${key}:\\${NL}  \1- ${value}~g" "$thePath"				
  else # dictionary uncomment and add entry
  fi
done