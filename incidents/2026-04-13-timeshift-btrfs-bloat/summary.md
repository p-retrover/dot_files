# Incident 001: The Timeshift Recursive RSYNC Crisis

**Date:** April 13, 2026  
**System:** Fedora (Btrfs)  
**Severity:** Critical (System near-lockup)

## 1. Executive Summary

The system reported **99% disk usage** (441GB/450GB). However, standard directory analysis (`du`) only accounted for **~127GB** of files. The "missing" **314GB** was discovered to be orphaned data from a failed Timeshift RSYNC process, trapped in a Btrfs subvolume layer (ID 5) invisible to the standard root mount.

---

## 2. The Root Cause: "The Hall of Mirrors"

The incident was triggered by two simultaneous configuration errors:

1. **RSYNC Mode on Btrfs:** Using RSYNC instead of the native BTRFS snapshot mode.
2. **Recursive Destination:** Setting the snapshot destination to a folder on the **same partition** as the source.

### Why it failed

In RSYNC mode, Timeshift follows file paths literally. Because the destination was on the same drive, the backup process attempted to back up the backup itself. This created a **recursive loop**, leading to a "phantom" file tree that `du` calculated at **1.8TB** despite only having **450GB** of physical hardware.

---

## 3. The Recovery Workflow

The recovery required a four-stage intervention:

### Phase A: Identification

Standard tools (`df`, `du`) failed to see the data. The breakthrough occurred by mounting the **Btrfs Top-Level Subvolume (ID 5)**:

```bash
sudo mount -o subvolid=5 /dev/nvme0n1p6 /mnt/real_root
```

This revealed a **382GB** directory named `/timeshift` that did not appear in the standard `/` file tree.

### Phase B: Cleanup

The orphaned data was manually purged. Because the files were hard-linked and recursive, the deletion process took significant time to un-link from the Btrfs metadata tree.

### Phase C: Structural Migration (The "Ubuntu-Layout" Fix)

Timeshift's BTRFS mode expects a specific subvolume naming convention (`@` and `@home`). Fedora’s default (`root` and `home`) caused a "Selected device is not a system disk" error.

* **Action:** Renamed subvolumes to `@` and `@home`.
* **Action:** Updated `/etc/fstab` and GRUB BLS entries to point to the new subvolume names.

### Phase D: Verification

After a reboot, Timeshift was successfully switched to **BTRFS mode**, which uses atomic pointers rather than file copies, making recursive loops physically impossible.

---

## 4. Key Lessons

* **Btrfs Layers:** The "Real Root" (Subvol 5) can hide data that `/` (Subvol root) cannot see.
* **Tool Choice:** Never use RSYNC for local backups on a Btrfs system; always use native snapshots.
* **Monitoring:** Syncthing's "Insufficient Space" error was the "canary in the coal mine" that prevented a total OS crash.

---
