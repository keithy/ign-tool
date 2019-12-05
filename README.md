[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE.md)
[![Build Status](https://travis-ci.com/keithy/ign-tool.svg?branch=ign)](https://travis-ci.com/keithy/ign-tool)
[![GitHub issues](https://img.shields.io/github/issues/keithy/ign-tool.svg)](https://github.com/keithy/ign-tool/issues)

# IGN - Tools for working with fcct/ignition

[![asciicast](https://asciinema.org/a/285507.svg)](https://asciinema.org/a/285507)

Ign provides a working environment for building an ignition provisioning script from the command line.

Find your SSH public keys
```
#> ign ssh --find
found:
  A)  ssh-ed25519 AAAAC3N...9a5kCpbT bob@your.uncle
  B)      ssh-rsa AAAAB3N...fzh3oUGZ bob@your.uncle
```
Provisioning a user in one line with the above keys and also direct password entry:
```
#> ign user bob --add ssh+=A,B uid=2000 primary_group=mortals groups+=sudo shell=/usr/local/bin/layer-shell --password
#> Password: <enter password>
```
Generating the ignition.json to the designated target (configured in ign.conf)
```
ign generate --json
```

## Getting Started

Clone this project,  `ign` includes a setup utility command `self-install` that
links it to somewhere on your path.
```
./ign-tool/ign setup self-install ~/bin --link --confirm
```
To create a new project `ign` includes a handy template working directory (like rust cargo etc.)
```
ign setup new 
ign setup new my.ign --start --confirm
cd my.ign
nano ign.conf
```
The local configuration file `ign.conf` applies when running `ign` within this working directory.
The `ign` command creates yaml snippets in `my.ign/inputs` which are merged together by
`ign generate --yaml` 

### dependencies:

- `bash` >= 4.4
- `yq` # yaml query tool
- `fcct` # Fedora Configuration Transpiler
- `pip3 install passlib` # for generating password hash
- `apt-get install expect` # for testing password interaction

## issues

- https://gitlab.com/keithy/ign-tool
- not supported
    - systemd dropins
    - files append
     
### groan

Ign is assembled using groan, the groan framework is a basis for composing hierarchical CLI interfaces with bash and other languages.

- http://github.com/keithy/groan
