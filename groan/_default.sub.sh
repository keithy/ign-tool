# grow.help.cmd.sh
#
# by Keith Hodges 2010
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

# General Help On Commands

# may have been invoked with a partial name
# so set the full command name
command="default"
description="show topical help"
#since help doesn't exec anything many common options don't apply
commonOptions="--theme=light    # alternate theme"
usage="$breadcrumbs <command|topic>
$breadcrumbs commands
$breadcrumbs --help    # this text"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

helpRequest=""
for arg in $@
do
  case $arg in
  --all | -a)
      VERBOSE=true
  ;;
  *)
      if [[ -z "$helpRequest" ]]; then
         helpRequest=$arg
      fi
  ;;
  esac
done

$DEBUG && echo "Help request: '$helpRequest'"

#check user has given us a file reference
if [[ -z "$helpRequest" ]]; then
  g_displayHelp
  printf "\nPlease give me a help topic\n"
  exit 1
fi

helpFile=""
target="help.$helpRequest*.topic.*"
exact="help.$helpRequest.topic.*"

previous=""

for loc in ${g_locations[@]}
do
  $DEBUG && echo "Looking for $target in: $loc"

  [[ "$previous" == "$loc" ]] && continue
  previous="$loc"

  $DEBUG && echo "Looking for $target in: $loc"

  # if an exact match is available - upgrade the target to prioritise the exact match
  for found in $loc/$exact
  do
    target=$exact
  done

  for found in $loc/$target
  do
    if [ -f "$found" ]; then
      $DEBUG && echo "Found: $found"
      helpFile="$found"
      continue 2
    fi
  done
done

if [[ "$helpFile" = "" ]]; then
  $LOUD && echo "Warning: help for '$helpRequest' not found"
  exit 1
fi
	
case ${helpFile##*.} in
  txt | text)
      $DEBUG && echo "Viewing txt: $found"
      cat $helpFile
      echo
  ;;
  md)
      $DEBUG && echo "Using $g_markdown_viewer to display markdown: $found"
      ${g_markdown_viewer%% *} ${g_markdown_viewer#* } $helpFile
  ;;
  sh)
      $DEBUG && echo "Running source: $found"
      source $helpFile
  ;;
  *)
      $DEBUG && echo "Running eval: $found"
      eval $helpFile
  ;;
esac

exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."