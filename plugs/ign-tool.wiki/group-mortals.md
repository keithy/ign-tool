## Mortals are falliable

The group `mortal` is created such that users are logged in to a safe chrooted shell

```yaml
storage.files[+]:     
    path: /etc/sshd_config.d/mortal.conf
    mode: 0644
    user:
        id: 0
    group:
        id: 0
    contents:
        inline: |
            # Contributed by ign plug +group-mortals
            Match Group mortals
                ForceCommand /usr/local/lib/layerbox/shells/layer-wrapper.sh
    
storage.files[+]
    path: /opt/inbox/none/root/layerbox_latest.tar.gz
    contents:
        source: https://gitlab.com/keithy/layerbox/-/archive/master/layerbox-master.tar.gz

passwd.groups[+]:
    name: mortal
    gid: 2000
```