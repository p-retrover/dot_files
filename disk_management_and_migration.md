# Disk Management & Partition Migration Guide

This guide summarizes the strategy for removing Windows and managing the Fedora/Arch dual-boot layout on the primary NVMe drive.

## 1. Current Disk Profile (Reference)

*As of March 2026*

| Partition | Label | UUID | Filesystem | Purpose |
| --- | --- | --- | --- | --- |
| `nvme0n1p1` | SYSTEM | `BC06-DEF9` | vfat | Shared EFI Bootloader |
| `nvme0n1p5` | fedora_boot | `b231f965-...` | ext4 | Fedora Boot |
| `nvme0n1p6` | fedora | `c3fce8ce-...` | btrfs | Fedora Root/Home |
| `nvme0n1p8` | arch | `2926c50b-...` | ext4 | Arch Root |
| `nvme0n1p10` | archboot | `39791943-...` | ext4 | Arch Boot |

---

## 2. Windows Removal Strategy

To reclaim space without the high risk of moving the physical "start" of Linux partitions:

1. **Deletion:** Boot into a Live USB and use GParted to delete `p3`, `p4`, and `p7`.
* **WARNING:** Do not delete `p1` (EFI), as it contains the boot entries for Fedora and Arch.


2. **Repurposing (The Safe Way):** * Format the resulting unallocated space as `ext4` or `Btrfs`.
* Label it (e.g., `DataHoard` or `Storage`).
* Mount it in `/etc/fstab` to a directory like `/mnt/storage` or `/data`.


3. **Migration (The "Clean" Way - High Risk):**
* Slide `p5` and `p6` to the left into the unallocated space.
* Expect a long wait time and mandatory GRUB repair.



---

## 3. Maintenance & Recovery

### Verifying UUIDs

Before and after any disk operation, verify that UUIDs remain identical to ensure `/etc/fstab` doesn't break:

```bash
lsblk -f

```

### Emergency GRUB Repair (Fedora Focus)

If the system fails to boot after a move, use a Live USB to chroot and regenerate the config:

1. **Mount Root:** `sudo mount /dev/nvme0n1p6 /mnt` (and `p5` to `/mnt/boot`).
2. **Bind System Dirs:**
```bash
for i in /dev /dev/pts /proc /sys /run; do sudo mount -B $i /mnt$i; done

```


3. **Chroot:** `sudo chroot /mnt`
4. **Regenerate Config:**
* **Fedora:** `grub2-mkconfig -o /boot/grub2/grub.cfg`
* **Arch:** `grub-mkconfig -o /boot/grub/grub.cfg`



---

## 4. Best Practices

* **Zero-Inference Rule:** Modern NVMe drives do not have "faster" sectors at the start. Moving partitions to the "front" is purely for visual organization and provides no performance benefit.
* **Backup First:** Always `rsync` or copy the `~/.config` and critical project directories to external storage before modifying the partition table.
* **Batching:** Do not queue multiple move/resize operations in GParted. Apply them one by one.