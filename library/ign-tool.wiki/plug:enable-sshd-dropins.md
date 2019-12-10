Files in `/etc/ssh/sshd_config.d` are appended to `sshd_config` on first boot, thus providing a dropin capability for `sshd_config` that can be used by other ignition **plugs**.

```yaml
systemd.units[+]:       
    name: sshd-config-dropins.service
    enabled: true
    contents: |
        [Unit]
        Description=Compose sshd_config
        ConditionFirstBoot=yes
        After=multi-user.target
        Before=sshd.service
        [Service]
        Type=oneshot
        ExecStart=-sh -c 'find /etc/ssh/sshd_config.d -type f -name *.conf -exec cat {} + >> /etc/ssh/sshd_config'
        [Install]
        WantedBy=multi-user.target
        RequiredBy=sshd.service
```