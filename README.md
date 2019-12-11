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
ign generate --confirm
```

## Getting Started

Clone `[ign-tool](https://github.com/keithy/ign-tool)`,
`ign` includes a setup utility command `self-install` that
links it to somewhere on your path.
```
./ign-tool/ign setup self-install ~/bin --link --confirm
```
To create a new project, `ign` includes a handy template working directory (like rust cargo etc.)
```
ign setup new 
ign setup new my.ign --starter --confirm
cd my.ign
nano ign.conf
```
The local configuration file `ign.conf` is applied to all commands when running `ign` within
this working directory.
The `ign` command edits a workspace of yaml snippets in `my.ign/inputs` which are merged
together and output by `ign generate --yaml` 

### The ignition snippets library - spark-"plugs"

A library of useful snippets is published on the [repo wiki](https://github.com/keithy/ign-tool/wiki)

### dependencies:

built in dependency installer
```
ign setup dependencies --confirm
```

- `bash` >= 4.4
- `[yq](https://github.com/mikefarah/yq/releases)` # yaml query tool
- `[fcct](https://github.com/coreos/fcct/releases)` # Fedora Configuration Transpiler 
- `sudo pip3 install passlib` # for generating user/group password hash
- `sudo yum install expect` # (TESTING ONLY) password interaction

## issues

- https://gitlab.com/keithy/ign-tool
- ignition features not supported by the tool (plugs can still add them)
    - systemd dropins
    - files append
     
### groan

`ign` is assembled using groan, the groan framework is a basis for composing hierarchical CLI interfaces with bash and other languages.

- http://github.com/keithy/groan
