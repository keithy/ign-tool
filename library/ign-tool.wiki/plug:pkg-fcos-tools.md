## Install fcos-tools

This **plug** adds the fcos-tools package to `/opt/inbox/package/core/fcos-tools_vX.Y.Z.tar.xz`

## Origin/Docs

https://github.com/keithy/fcos-tools

## Notes:

FCOS-tools is a **composable** collection of utility commands for use on an FCOS server.

It is similar in style to `ign-tool`, being built with the **composable** '[groan](https://github.com/keithy/groan)' framework, so it comes with help/topics/installing/updating functions included. FCOS also has bundled:

- 'sensible' tool for remote deployment and execution.
- 'layerbox' tool for `chroot`ed layers and shells.

`ign-tool` was concieved for the purpose of provisioning a server that is ready to run `fcos-tools`.

### The Package:
```yaml
storage.files[+]:
    path: /opt/inbox/trusted/core/fcos-tools_v0.1.tar.gz
    mode: 0644
    contents:
      source: https://github.com/keithy/fcos-tools/archive/fcos-tools_v0.1-fedora31-x86_64.tar.gz
      verification:
        hash: sha512-935b3d516e996f6d25948ba8a54c1b7f70f7f0e3f517e36481fdf0196c2c5cfc2841f86e891f3df9517746b7fb605db47cdded1b8ff78d9482ddaa621db43a34

```