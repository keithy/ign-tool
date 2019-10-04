# groan test.sub.sh
#
# by Keithy 2019
#
#
$DEBUG && echo "${dim}${BASH_SOURCE}${reset}"

command="test"
description="test remote connections via ssh"
usage=\
"$breadcrumbs               # test ssh connections
$breadcrumbs --help        # this message"

$SHOWHELP && executeHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

LISTHOSTS=false
INSTALL=false
tags=("all")

for arg in "$@"
do
  case "$arg" in
    --hosts|--list)
      LISTHOSTS=true
      tags=('all')
    ;;
    --tags=* | --tag=*)
      IFS=',' tags=(${arg##--t*=}) #interpret (comma separated) as an array
    ;;
    --all)
      tags=('all')
    ;;
    --*)
    ;;
    -*)
    # ignore other options
    ;;
    # ? in this context is a single letter wildcard 
    ?*) 
        configureName="$arg"
    ;;
  esac
done
 
ssh_options=()

if $DRYRUN; then
  ssh_options+=('-n')
fi

if $VERBOSE; then
  ssh_options+=('-v')
fi

if $DDEBUG; then
  ssh_options+=('-vv')
fi

if $LISTHOSTS; then
  for host in ${sensible_host_names[@]}; do
    if [[ ",all,${sensible_tags[$host]}," == *,"$tags,"* ]]; then
      printf "$host (${sensible_tags[$host]}): ${sensible_deploy[$host]}\n"
    fi
  done
  exit 0
fi

for host in ${sensible_host_names[@]}; do
  for tag in ${tags[@]}; do

    if [[ ",all,${sensible_tags[$host]}," == *,"$tag,"* ]]; then
      out=$(ssh "${ssh_options[@]}" "${sensible_deploy[$host]%:*}" echo "ok")
      [[ "$out" == "ok" ]] && out="\xE2\x9C\x94" || out="\xE2\x9D\x8C"
      printf "${sensible_deploy[$host]%:*} $out\n" 
    else
      printf "\n"
    fi
  done
done

exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."