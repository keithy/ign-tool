## Install Toolbox

This **plug** adds the toolbox package to `/opt/inbox/package/core/toolbox_vX.Y.Z.tar.xz`

## Origin/Docs

https://github.com/containers/toolbox 

## Notes:
Adding overlays to rpm-ostree is risky due to the push model used for providing server updates. Upstream testing will not have been performed on your specific combination of packages.

### The Package:
```yaml
## Toolbox https://github.com/containers/toolbox 
storage: 
  files:
    - path: /opt/inbox/package/core/toolbox_v0.0.16.tar.xz
      mode: 0644
      contents:
        source: https://github.com/containers/toolbox/releases/download/0.0.16/toolbox-0.0.16.tar.xz
        verification:
          hash: sha512-4b87c023090a5862c0b16aa994eb3778158e199525e3a0e8836e361824238df4fae58b020df91b0131a6fb7ac6dc1ee3eaa153cc50f6232826b55eb5a0903c90
```