# Requirements (for tests?)

### Command suites may be defined for a company or domain

The user can rename the top level command to any name, that suits their business or use-case.

### Sub-commands may be written in any language

Subcommands may be added to a nearby sub-commands folder, which may also be re-named. The default name is `sub-sommands`.

- Renaming of the sub-commands folder is supported since at any level a command finds its sub-commands folder via a config file at the same level.

### Commands are physically compose-able, via drag and drop.

An existing command with its own sub-commands may be added within a folder (of any name) to any other command. (e.g. The command `helper` is added to a folder called `help` within the groan command.)

### Separate suites of sub-commands may be merged at the same level.

One command, may reference another [folder-contained] command's sub-commands at the same level as it's own sub-commands.

- the top-level command finds another command's sub-commands via the config file, in the same manner as it finds its own sub-commands.

### Commands at all levels are similar, differing in name only

1. most "commands" are running exactly the same code
2. therefore they share the same top-level options and identical features
3. their implementation file content may be hard-linked.
4. the implementation of `_dispatch.sh` is also identical throughout. Commands with alternative implementations should configure and use a different name for their `defaultDispatch`.

### A folder-contained command may be invoked as a variety of sub-commands

1. A folder contained command (e.g. `help\helper`) may be invoked as a sub-command of another command. (e.g. `groan help`)
2. Synonyms are supported, (e.g. `groan grep` or `groan find`)
3. Variations are supported (e.g. the help command is called as 'command' or 'topics')

A specific sub-command (e.g. `groan topic`) may be defined using the script named `topic.sub.help.cmd.sh` This defines the `topic` sub-command as implemented by the command contained in the command folder `help`. All sub-command suites defined by `help`'s config are scanned, but a specialised dispatcher called `_topic_dispatch.sh` will override the default `_dispatch.sh`. This implements a "called as" semantic. i.e. the help command was invoked as `topic`. 

	- help.cmd.help.sub.sh -> ../help/sub-commands/_help_dispatch.sh
	- commands.cmd.help.sub.sh -> ../help/sub-commands/_commands_dispatch.sh
	- topic.cmd.help.sub.sh -> ../help/sub-commands/_topic_dispatch.sh
	- docs.cmd.help.sub.sh -> ../help/sub-commands/_docs_dispatch.sh
	- $1.cmd.$2.sub.sh -> ../$2/sub-commands/_$1_dispatch.sh
	
1. All uses of this pattern, use the same code (may be hard-linked) the route is encoded by the script name.

### The default implementation of a command is provided by the `sub-command/default`
