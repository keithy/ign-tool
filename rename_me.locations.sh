#locations to search for configuration *.conf files

configOptions=("local" "user" "global")

configFileLocations=(
	"$workingDir/$commandName.conf"  # --local
	"$HOME/.$commandName.conf"       # --user
	"$commandDir/$commandName.conf"  # --global
)

#locations to search for commands
locations=(
	"$configDir/sub-commands"         # your own sub-commands
	"$configDir/groan/groan-commands" # merge with groan sub-commands 
)

defaultDispatch="_dispatch.sh"
defaultSubSubcommand="default"

markdownViewerUtility="mdv -t 715.1331"

# "This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
# Any additional contribution submitted for incorporation into or for distribution with this 
# file shall be presumed subject to the same license."