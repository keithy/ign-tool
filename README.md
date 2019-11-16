[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE.md)
[![Build Status](https://travis-ci.com/keithy/groan-dev.svg?branch=master)](https://travis-ci.com/keithy/groan-dev)
[![GitHub issues](https://img.shields.io/github/issues/keithy/groan.svg)](https://github.com/keithy/groan/issues)

# IGN - Tools for working with fcct/ignition

## Getting Started

Having cloned this project, add `ign` to your path - `ign` has a `self-install` command.
(inherited from the `groan` framework.)
```
./ign self-install ~/bin --link --confirm
```
Now setup a project directory, and create a configuration file there. Using the `--local` option for configurations
will use the configuration of the current working directory, allowing `ign` to be used on several projects simultaneously.

To see available options `ign configure --options`
To view the example `ign configure example'
To install the example.conf in your local project folder
```
ign configure --install=local example --confirm
```
To get started `ign` has handy templates - `ign new` - lists the available options
```
ign new 
```



### dependencies:

- yq
- fcct


## issues

- https://gitlab.com/keithy/ign-tool
 
### groan

Ign is assembled using groan, the groan framework is a basis for composing hierarchical CLI interfaces with bash and other languages.

- http://github.com/keithy/groan