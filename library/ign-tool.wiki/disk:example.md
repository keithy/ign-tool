An example disk as a test

```yaml
storage.disks[+]
  device: /dev/disk/by-partlabel/var
  wipe_table: true
  partitions:
    - label: var
      wipe_partition_entry: true
```