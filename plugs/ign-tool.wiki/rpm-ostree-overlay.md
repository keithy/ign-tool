# Install rpms using ostree overlays

This **plug** demonstrates the facility. Future editions will allow the list of rpms to be specified as a parameter.

Adding overlays to rpm-ostree is risky due to the push model used for providing server updates. Upstream testing will not have been performed on your specific combination of packages. Mitigate this risk by having some servers running on the 'next' stream so you know whats coming. 
```conf
OSTREE_OVERLAY=""
OSTREE_OVERLAY_POSTINSTALL=--reboot
#OSTREE_OVERLAY_POSTINSTALL="ex livefs --i-like-danger"
```

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
        Before=boot-complete.target
        [Service]
        Type=oneshot
        ExecStart=rpm-ostree install ${OSTREE_OVERLAY} 
        # An alternative to --reboot
        ExecStartPost=rpm-ostree ${OSTREE_OVERLAY_POSTINSTALL}
        [Install]
        WantedBy=multi-user.target
        RequiredBy=boot-complete.target
```
