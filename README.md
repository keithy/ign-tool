[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE.md)
[![Build Status](https://travis-ci.com/keithy/groan-dev.svg?branch=master)](https://travis-ci.com/keithy/groan-dev)
[![GitHub issues](https://img.shields.io/github/issues/keithy/groan.svg)](https://github.com/keithy/groan/issues)

# IGN - Tools for working with fcct/ignition

## Getting Started

Having cloned this project,  `ign` includes a setup utility command `self-install` that adds it to your path .
```
./ign-tool/ign setup self-install ~/bin --link --confirm
```
To create a new project `ign` includes handy templates.
```
ign setup new
ign setup new sandbox.ign --start --confirm
cd sandbox.ign
```
The local configuration file `ign.conf` applies when running `ign` from the new directory.


### dependencies:

- yq
- fcct


## issues

- https://gitlab.com/keithy/ign-tool
- systemd dropins not supported in the direct editor
 
### groan

Ign is assembled using groan, the groan framework is a basis for composing hierarchical CLI interfaces with bash and other languages.

- http://github.com/keithy/groan
