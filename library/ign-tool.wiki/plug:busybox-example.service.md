example from: https://docs.fedoraproject.org/en-US/fedora-coreos/getting-started/
```yaml
systemd.units[+]:
    name: hello.service
    enabled: true
    contents: |
      [Unit]
      Description=MyApp
      After=network-online.target
      Wants=network-online.target
      [Service]
      TimeoutStartSec=0
      ExecStartPre=-/bin/podman kill busybox1
      ExecStartPre=-/bin/podman rm busybox1
      ExecStartPre=/bin/podman pull busybox
      ExecStart=/bin/podman run --name busybox1 busybox /bin/sh -c "trap 'exit 0' INT TERM; while true; do echo Hello World; sleep 1; done"

      [Install]
      WantedBy=multi-user.target
```