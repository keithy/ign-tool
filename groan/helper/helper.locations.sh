#locations to search for configuration *.conf files

configOptions=("--local" "--user" "--global")

configFileLocations=(
	"$workingDir/$commandName.conf.sh"  # --local
	"$HOME/.$commandName.conf.sh"       # --user
	"$commandDir/$commandName.conf.sh"  # --global
)

#locations to search for commands

locations=(
	"$configDir/help-commands"
)

defaultDispatch="_help_dispatch.sh"
defaultSubcommand="default"
 
markdownViewerUtility="mdv -t 715.1331"

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."