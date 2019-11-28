#g_locations to search for configuration *.conf files

g_config_options=("--local" "--user" "--global")

g_config_file_locations=(
	"$g_working_dir/$c_name.conf.sh"  # --local
	"$HOME/.$c_name.conf.sh"       # --user
	"$c_dir/$c_name.conf.sh"  # --global
)

g_config_preset_locations=(
    "$c_dir"
)

#g_locations to search for commands
g_locations=(
	"$c_dir/../groan/groan.commands"
	"$c_dir/../groan/coder.commands"
)

g_default_dispatch="_dispatch.sh"
g_default_subcommand="_default"
 
g_theme_path=( "$c_dir/groan.themes.sh" "$c_dir/groan.theme-$THEME.sh" )

g_markdown_viewer="mdv -t 715.1331"

#"This Code is distributed subject to the MIT License, as in http://www.opensource.org/licenses/mit-license.php . 
#Any additional contribution submitted for incorporation into or for distribution with this file shall be presumed subject to the same license."