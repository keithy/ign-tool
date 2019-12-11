## Install Toolbox

This **plug** adds the toolbox package to `/opt/inbox/package/core/toolbox_vX.Y.Z.tar.xz`

## Origin/Docs

https://github.com/containers/toolbox 

## Notes:
(not tested yet - soon)

### The Package:
```yaml
## Toolbox https://github.com/containers/toolbox 
storage.files[+]:
  path: /opt/inbox/package/core/toolbox_v0.0.17.tar.xz
  contents:
    source: https://github.com/containers/toolbox/releases/download/0.0.17/toolbox-0.0.17.tar.xz
    verification:
      hash: sha512-0be37d12da982f2e630461de508edbcac58443c33b3c57a8ced008d5115031d0cc61e00eb4d90f9edcdb556aff88af8817bfd468cfe208036793633da5047fb6
  mode: 0644
```