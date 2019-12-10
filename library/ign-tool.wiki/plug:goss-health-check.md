(not tested)
```yaml
#storage.files[+]:     
#    path: /etc/sshd_config.d/mortals.conf
#    mode: 0644
#    user:
#        id: 0
#    group:
#        id: 0
#    contents:
#        inline: |
#            # COMPOSITION OF SSHD_CONFIG
#            Match Group mortal
#                    ForceCommand mortals-safety.sh

    #
    # ./goss_v0.2/pkg/scripts/install.sh is run under the user chosen here (goss).
    # - installs a symlink to itself in the users ~/bin
    # The user can use goss according to their access rights
    # The user can be given privileged but restricted ssh access
    # In theory the user doesnt even need a home dir 
storage.files[+]:
    path: /opt/inbox/trusted/goss/goss_v0.2.tar.gz
    mode: 0644
    contents:
        source: https://github.com/keithy/portable_goss/archive/goss_v0.2-fedora31-x86_64.tar.gz
#          verification:
#              hash: sha512-4b87c023090a5862c0b16aa994eb3778158e199525e3a0e8836e361824238df4fae58b020df91b0131a6fb7ac6dc1ee3eaa153cc50f6232826b55eb5a0903c90

storage.files[+]:
      #
      # Metadata for AngelBox installation 
      #  - A platform type identifier
      #  - selection of its update streams wip/next/stable
      #
    path: /etc/ssh/sshd_config.d/extra_keys.conf
    mode: 0600
    contents:
        inline: |
            # Added from ignition
            Match User *
                AuthorizedKeysFile /etc/ssh/sshd_config.d/authorized_keys_%u

storage.files[+]:
    path: /etc/ssh/sshd_config.d/authorized_keys_goss-homeless
    mode: 0644
    user:
        id: 1111
    contents:
        inline: |
            command="sudo /usr/local/lib/goss/pkg/usr/local/bin/goss -g /etc/goss/goss.yaml validate ${SSH_ORIGINAL_COMMAND:-}" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG7mD9tPBt0F1QViMXdyC5eBlXPg4uTIVanU9a5kCpbT keith@samson.flat

passwd.users[+]:
      #
      # Healthz Check User
      #      
    name: goss # health check
    uid: 111
    ssh_authorized_keys:
      - command="sudo goss validate ${SSH_ORIGINAL_COMMAND:-}" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG7mD9tPBt0F1QViMXdyC5eBlXPg4uTIVanU9a5kCpbT keith@samson.flat
    home_dir: /home/goss
    no_create_home: false
    primary_group: mortal
    groups:
    - sudo
    shell: /bin/bash

passwd.users[+]:
     #
      # Healthz Check User
      #      
    name: goss-homeless # health check
    uid: 1111
    ssh_authorized_keys:
    - command="sudo /usr/local/lib/goss/pkg/usr/local/bin/goss validate ${SSH_ORIGINAL_COMMAND:-}" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG7mD9tPBt0F1QViMXdyC5eBlXPg4uTIVanU9a5kCpbT keith@samson.flat
    no_create_home: true
    primary_group: mortal
    groups:
    - sudo
```