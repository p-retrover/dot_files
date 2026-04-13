# `recovery-cheatsheet.md`

## Emergency Triage (The First 60 Seconds)

If the system is reporting **>95% usage**, run these to find the target immediately:

1. **Check Hardware Reality:**
    `sudo btrfs filesystem usage /`
2. **Find the Root Hog:**
    `sudo du -xhd 1 / | sort -h`
3. **Find the `/var` Hog:**
    `sudo du -xhd 1 /var | sort -h`

---

## Stage 1: Safe Immediate Cleanup

*No risk of losing data; clears temporary caches.*

* **Vacuum Journal Logs (Reclaims ~1-5GB):**
    `sudo journalctl --vacuum-size=100M`
* **Clear Package Cache (Reclaims ~1-2GB):**
    `sudo dnf clean all` (Fedora) or `sudo paccache -r` (Arch)
* **Clear Flatpak Runtimes (Reclaims ~2-10GB):**
    `flatpak uninstall --unused -y`

---

## Stage 2: Application Pruning

*Clears data from Docker and Containers.*

* **Docker System Prune (Reclaims ~5-30GB):**
    `sudo docker system prune -af --volumes`
* **Podman System Prune:**
    `podman system prune -a`

---

## Stage 3: The "Ghost" Hunt (Btrfs Only)

*Use this if `df` shows full but `du` doesn't find the files.*

1. **Mount the Real Root (ID 5):**
    `sudo mkdir -p /mnt/real_root && sudo mount -o subvolid=5 /dev/partition_name /mnt/real_root`
2. **Check for Orphaned Folders:**
    `sudo du -sh /mnt/real_root/*`
3. **Check for Hidden Subvolumes:**
    `sudo btrfs subvolume list /mnt/real_root`
4. **The "Commit" (Forces Btrfs to update its math):**
    `sync`

---

## Stage 4: Filesystem Maintenance

*Reclaims space held by empty chunks or fragmented metadata.*

* **Reclaim Empty Chunks:**
    `sudo btrfs balance start -dusage=0 /`
* **Reclaim Metadata Chunks:**
    `sudo btrfs balance start -musage=10 /`

---

## Final Verification

After running the cleanup, confirm your **"Unallocated"** space has increased:
`sudo btrfs filesystem usage / | grep Unallocated`

> **Note:** If "Unallocated" is less than 1GB, the drive is in "Read-Only" danger territory. Perform Stage 1 and 2 immediately.

---
