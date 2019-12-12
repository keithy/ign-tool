# groan.self-install.sh
#
# by Keith Hodges 2010
#
$DEBUG && echo "${dim}${BASH_SOURCE[0]}${reset}"

command="dependencies"
description="install dependencies"
options=\
"--fcct              # install fcct
--yq                # install yq
--passlib           # install passlib
--expect            # install expect"

usage=\
"$breadcrumbs dependencies ~/bin --confirm       # install all dependencies (default)
$breadcrumbs dependencies ~/bin --yq --confirm  # install a dependency
"

$SHOWHELP && g_displayHelp
$METADATAONLY && return

$DEBUG && echo "Command: '$command'"

ADD_FCCT=false
ADD_YQ=false
ADD_PASSLIB=false
ADD_EXPECT=false
ADD_ALL=true
installPath="$HOME/bin"

for arg in "$@"
do
    case "$arg" in
    --fcct)
        ADD_FCCT=true
        ADD_ALL=false
    ;;
    --yq)
        ADD_YQ=true
        ADD_ALL=false
    ;;
    --passlib)
        ADD_PASSLIB=true
        ADD_ALL=false
    ;;
    --expect)
        ADD_EXPECT=true
        ADD_ALL=false
    ;;
    -*)
    # ignore other options
    ;;
    *)
        installPath="$arg"
    ;;
    esac
done

$VERBOSE && curl_opt="-vL" || curl_opt="-sSL"

$ADD_ALL && { ADD_FCCT=true ; ADD_YQ=true ; ADD_PASSLIB=true ; ADD_EXPECT=true ; }

$DRYRUN && echo "dryrun:  --confirm required to proceed" && exit 1

if $ADD_FCCT; then
  case "${g_PLATFORM}" in
    x86_64-*-linux-gnu)
    	arch="x86_64-unknown-linux-gnu"
    ;;
    x86_64-apple-darwin*)
		arch="x86_64-apple-darwin"
    ;;
    *)
    	printf "Architecture '%s' not yet covered" "$g_PLATFORM" && exit 1
    ;;
  esac
	curl "$curl_opt" "${setup_dependencies_url_fcct}-${arch}" -o "$installPath/fcct" \
	&& chmod a+x "$installPath/yq" && echo "fcct - available"
fi
    
if $ADD_YQ; then
  case "${g_PLATFORM}" in
    x86_64-*-linux-gnu)
    	arch="linux_amd64"
    ;;
    x86_64-apple-darwin*)
		arch="darwin_386"
    ;;
    *)
    	printf "Architecture '%s' not yet covered" "${g_PLATFORM}" && exit 1
    ;;
  esac

  curl "$curl_opt" "${setup_dependencies_url_yq}_${arch}" -o "$installPath/yq" \
	&& chmod a+x "$installPath/yq" && echo "yq - available"
fi

if $ADD_PASSLIB; then	
   	case "$g_PLATFORM" in
	*linux-gnu)
		echo "passlib - using mkpasswd command instead"
	;;
	*darwin*)
	   command -v pip3 && pip3 install passlib \
   		&& echo "passlib - available" \
   		|| echo "Can't install passlib, pip3 not installed" 
	;;
esac
   	
fi

if $ADD_EXPECT; then
  case  "${g_PLATFORM}" in
    *-redhat-linux-gnu)
    	sudo yum install expect -y  && echo "expect - available"
    ;;
    *-apple-darwin*)
		echo "expect - included in Darwin/MacOSX"
    ;;
    *)
    	printf "Architecture '%s' not yet covered"  "${g_PLATFORM}" && exit 1
    ;;
  esac 
fi

exit 0

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."