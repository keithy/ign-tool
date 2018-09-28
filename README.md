# Groan

/ɡrəʊn/

_noun_
	
1. the noise that emits from a smalltalk programmer forced to code in bash. 

Groan is a simple extensible bash framework (similar to [sub](https://github.com/basecamp/sub))
for creating a suite of scripts that have similar command, sub-command usage style to git/bzr/hg etc. 

## Highlights

Groan is recursively merge-able/compose-able. Assemble a named suite of sub-command scripts in a folder, 
that folder may become a sub-command within another suite, or be merged into another suite.

Groan uses/demonstrates this internally to implement the help sub-command. 
The `groan help` sub-command of `groan` is implemented by the nested command `helper`. 

In the folder hierarchy yourcommandname/groan/helper there is a fully functioning suite of 
bash commands called "helper", nested as a sub-command within another suite called "groan", 
merged with another for you to customize called "yourcommandname". 

## How to fork and roll your own command

Fork to yourrepo/groan then create your working branch with the name of your new command suite
then you can pull-request your enhancements, and others can see what you are using it for.

## History

This incarnation of groan was conceived in about 2009, in 2017 I used 'sub' extensively 
and then fed that experience back into groan (in 2018), rather than port existing groan
based projects. I also want to use groan as a base for incorporating "fish" based scripts
if I should ever develop any.

## Groan vs sub

* Is recursively composeable and mergeable
* Is much simpler than sub
* Sub-commands provide usage and documentation
* Support for additional documentation topics/reporting
* Demonstrates simple implementation conventions and patterns (e.g. options handling)
* Adopts the informal [bash "strict" mode](http://redsymbol.net/articles/unofficial-bash-strict-mode/) which considerably aids debugging.
* (does not yet support command completion.)

## Features

* supports default option flags (--verbose --quiet --help --debug --dry-run --confirm)
* finds sub-commands via a configurable search path (allows local overides)
* finds config files via a configurable search path
* reads a config file (to set environment vars) before running sub-commands
* sub-commands may be written in any shell or language
* sub-commands can run as source, exec, or eval
* help subcommand included provides:
	* list of help topics - `groan help topics`
	* list of commands and their usage - `groan help commands`
	* markdown viewer support
	
## General Principles

Groan subcommands are called after having:

* processed and filtered out the standard set of flags.
	* --verbose
	* --debug
	* --quiet
	* --dry-run  # enabled by default
	* --confirm  # disables --dry-run flag for destructive operations
* attempted to work out what platform it is running on. 
* found and 'sourced' a config-file.

## Make Your own

Download the __groan__ project, rename its directory and all "groan" files to that of your own chosen script name, e.g. "[grow](https://launchpad.net/grow)". 

## Config Files

Groan looks for config files in a number of places. This is configured in groan.locations. Edit the groan.locations file to use your own project name for it's own config files.

## Sub-Commands

...follow the convention `<groan>.<subcommand>.cmd.sh`

* `<name>.cmd.sh` will source the subcommand
* `<name>.cmd.exec` will exec the subcommand
* `<name>.cmd.*` will eval the subcommand
	* `<name>.cmd.rb`
	* `<name>.cmd.fish` ...etc

### Subcommand - help topics

The help subcommand included provides:

* Display text file giving information on a topic e.g. `groan help test`
	* `<name>.<topicname>.topic.txt`
		* e.g. `groan.test.topic.txt`    
* Generate topic information via code e.g. `groan help topics`
	* `<name>.<topicname>.topic.sh` #sourced
		* e.g. `groan.topics.topic.sh` # lists the available topics
		* e.g. `groan.commands.topic.sh`# lists the available commands
	* `<name>.<topicname>.topic.rb` #evaled

#### Help Meta Data

Commands are implemented expecting that they may be run with the METADATAONLY flag, in which case they populate variables and exit prior to doing anything:

* `$command`
* `$description`
* `$usage`

### Subcommand - environment

The environment subcommand prints out the environment variables (or evaluates a given expression) in the context of where scripts will run, after applying the config file.

* groan environment --eval "echo $PATH"

### Subcommand - configure

A number of template conf files can be provided, the user can choose a file and a place to install it. Out of the box, local, user and global config options are provided

    ./groan config --options
    Available options:
    1) local config : /Users/coding/wip/groan.conf
    2) user config : /Users/bob/.groan.conf
    3) global config : /Users/bob/.local/bin/groan/groan.conf
       
    Available templates:
        default.conf
        
    Install configuration with:
    
    ./groan config default.conf --install 3 --confirm 
        
### Subcommand - self-install

    groan self-install /usr/local/bin --link --confirm

## Test Suite

To verify all is well try:

    groan
    groan help
    groan help test
    groan help commands
    groan help topics
    groan help test-markdown
    groan con #outputs> Warning: Command 'con' is ambiguous (use --debug for more info)
    groan env
    groan env -a
    groan env --eval "echo $PATH"
    groan configure
    groan configure --options
    groan configure groan.conf
    groan configure groan.conf --install
    groan configure groan.conf --install 1
    groan configure groan.conf --install 3 --confirm
    groan self-install /usr/local/bin --link 
    groan self-install /usr/local/bin --link --confirm
    groan self-install /usr/local/bin --link --unlink 
    groan self-install /usr/local/bin --link --unlink --confirm
    
    
