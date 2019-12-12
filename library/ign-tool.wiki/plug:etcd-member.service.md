example from: https://docs.fedoraproject.org/en-US/fedora-coreos/getting-started/
```yaml
systemd.units[+]:
    name: etcd-member.service
    enabled: true
    contents: |
      [Unit]
      Description=Run single node etcd
      After=network-online.target
      Wants=network-online.target

      [Service]
      ExecStartPre=mkdir -p /var/lib/etcd
      ExecStartPre=-/bin/podman kill etcd
      ExecStartPre=-/bin/podman rm etcd
      ExecStartPre=-/bin/podman pull quay.io/coreos/etcd
      ExecStart=/bin/podman run --name etcd --volume /var/lib/etcd:/etcd-data:z --net=host quay.io/coreos/etcd:latest /usr/local/bin/etcd --data-dir /etcd-data --name node1 \
              --initial-advertise-peer-urls http://127.0.0.1:2380 --listen-peer-urls http://127.0.0.1:2380 \
              --advertise-client-urls http://127.0.0.1:2379 \
              --listen-client-urls http://127.0.0.1:2379 \
              --initial-cluster node1=http://127.0.0.1:2380

      ExecStop=/bin/podman stop etcd

      [Install]
      WantedBy=multi-user.target
```