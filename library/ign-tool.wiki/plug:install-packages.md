## Packages and Portable - Porous Containers

This **unit** finds all tarballs placed by **ignition** in the `/opt/inbox` directory and 
feeds them to an installer script `coreos-install-pkg.sh` (see below)

```yaml
systemd.units[+]:
    name: install-pkgs.service
    enabled: true
    contents: |
        [Unit]
        Description=Install Packages & Attach Portable Services
        ConditionFirstBoot=yes
        After=multi-user.target
        Before=boot-complete.target
        [Service]
        Type=oneshot
        ExecStartPre=setenforce Permissive
        ExecStart=-find /opt/inbox -mindepth 3 -maxdepth 3 -name "*.tar.[xg]z" \
                  -exec sh /usr/local/libexec/coreos-install-pkg.sh {} \;
        [Install]
        WantedBy=multi-user.target
        RequiredBy=boot-complete.target
```
This installer script unpacks the tarball and treats it as either

* A Portable Service - attached, enabled and started (under the specified security profile)
* A Package - installed (./pkg/install.sh is run under a specified user account)
* or both

```yaml
storage.files[+]:
    path: /usr/local/libexec/coreos-install-pkg.sh
    mode: 0755
    user:
        id: 0
    group:
        id: 0
    contents:
        inline: |
            set -o allexport
            PACKAGES="/usr/local/lib"
            TAR_PATH="$1"
            IFS=/ read -r a b c PROFILE USER ARCHIVE <<< "$TAR_PATH"
            PKG="${ARCHIVE%.tar.[xg]z}"
            PKG_NAME=${PKG%_*}
            mkdir -p "$PACKAGES/$PKG"
            tar xvzf "$TAR_PATH" --strip-components 1 -C $PACKAGES/$PKG && \
              ln -s "$PACKAGES/$PKG" "$PACKAGES/$PKG_NAME"
            INSTALL_SH="$PACKAGES/$PKG/pkg/scripts/install.sh"
            if [[ ! -e "$INSTALL_SH" ]]; then
               su -m "$USER" "$INSTALL_SH" "$PACKAGES/$PKG_NAME"
            fi
            METADATA="$PACKAGES/$PKG/pkg/pkg-release"
            portablectl attach --no-reload --copy=symlink "--profile=$PROFILE" "$PACKAGES/$PKG" && \
              systemctl enable $(grep "^UNITS_ENABLE=" "$METADATA" | cut -d '=' -f2) && \
              systemctl start $(grep "^UNITS_START=" "$METADATA" | cut -d '=' -f2) || true
            echo "Finished installing $PACKAGES/$PKG"        
```