## Install rpms using ostree overlays

This **plug** installs the overlays listed in the environment variable OSTREE_OVERLAY.

Environment variables set in file: `plug:rpm-ostree-overlay.env`
```env
OSTREE_OVERLAY=htop nano
#OSTREE_OVERLAY=htop
OSTREE_OVERLAY_INSTALL_ACTION=ex livefs --i-like-danger
#OSTREE_OVERLAY_INSTALL_ACTION=--reboot
```

## Notes:
Adding overlays to rpm-ostree is risky due to the push model used for providing server updates. Upstream testing will not have been performed on your specific combination of packages. It is possible to mitigate this risk by having some servers running on the 'next' update stream so you know whats coming.

### The Plug:
```yaml
systemd.units[+]:
    name: install-overlayed-rpms.service
    enabled: true
    contents: |
        [Unit]
        Description=Install Overlay Packages
        ConditionFirstBoot=yes
        Wants=network-online.target
        After=network-online.target
        After=multi-user.target
        After=boot-complete.target
        [Service]
        Type=oneshot
        ExecStart=rpm-ostree ${OSTREE_OVERLAY}
        # --reboot OR ex livefs --i-like-danger
        ExecStartPost=rpm-ostree ${OSTREE_OVERLAY_INSTALL_ACTION}
        [Install]
        WantedBy=multi-user.target
        RequiredBy=boot-complete.target
```