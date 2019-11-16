#locations to search for configuration *.conf files

configOptions=("--local" "--user" "--global")

configFileLocations=(
	"$workingDir/$commandName.conf.sh"  # --local
	"$HOME/.$commandName.conf.sh"       # --user
	"$commandDir/$commandName.conf.sh"  # --global
)

configPresetLocations=(
    "$commandDir"
)

#locations to search for commands
locations=(
	"$commandDir/../groan/groan.commands"
	"$commandDir/../groan/coder.commands"
)

defaultDispatch="_dispatch.sh"
defaultSubcommand="help"
 
themePath=( "$commandDir/groan.themes.sh" "$commandDir/groan.theme-$THEME.sh" )

markdownViewerUtility="mdv -t 715.1331"

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."