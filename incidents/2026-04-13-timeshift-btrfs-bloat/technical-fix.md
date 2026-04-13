# fixing

## The Ghost Hunting Process: Finding the Invisible 300GB+

When `df -h` says a disk is 99% full but `du -sh /` says it's only 30% full, the data is "ghosted." On a Btrfs system, this means the files exist in a subvolume or directory that isn't part of the current active mount tree.

### 1. Diagnosing the Discrepancy

We first used the Btrfs filesystem tool to get the "ground truth" of the hardware.

```bash
sudo btrfs filesystem usage /
```

* **The Result:** This confirmed that **441GiB** was physically occupied by data chunks, proving the space wasn't just a reporting error—it was physically gone.

### 2. Identifying the "Hall of Mirrors" (The 1.8TB Phantom)

When we ran the deep scan on the root:

```bash
sudo du -xhd 1 / | sort -h
```

Standard `du` was confused. Because Timeshift was in **RSYNC mode** on a **Btrfs partition**, it used hard-links to create snapshots. When the process crashed, it left behind a recursive directory structure.

* **The 1.8TB calculation:** `du` follows every link it finds. In a recursive RSYNC loop, it counts the same files over and over as it drills down into nested folders. This is how a **450GB** physical drive can appear to contain **1.8TB** of data—it's a mathematical illusion caused by directory recursion.

### 3. Mounting the "Real Root" (Subvol ID 5)

To find where the files were actually sitting, we had to bypass the Fedora "root" subvolume and look at the raw partition. In Btrfs, the partition itself is **Subvolume ID 5**.

```bash
# We created a gateway to the entire partition
sudo mkdir -p /mnt/real_root
sudo mount -t btrfs -o subvolid=5 /dev/nvme0n1p6 /mnt/real_root
```

### 4. The "Smoking Gun"

Once mounted, we looked at the top-level directory. Standard `du` stays within the subvolume it's told to, so by mounting the "Real Root," we forced it to see everything.

```bash
cd /mnt/real_root
sudo du -sh ./*
```

* **The Discovery:** This revealed the hidden directory: **`./timeshift` (382GB)**.
* **The Logic:** This folder existed outside of the `root` subvolume. Because Fedora only mounts the `root` subvolume to `/`, any files sitting in the "Real Root" (ID 5) are invisible to the OS during normal operation, but they still occupy physical blocks on the SSD.

---

### The Fix: Forced Deletion

Once identified, the only way to reclaim the space was a manual "nuke" of that orphaned directory:

```bash
# This took significant time as the Btrfs metadata had to un-link 382GB of recursive files
sudo rm -rf /mnt/real_root/timeshift
```

---

## Changing the subvolume layout

### 1. The Challenge

Timeshift (BTRFS mode) requires a specific subvolume layout:

* Root must be named `@`
* Home must be named `@home`

Fedora defaults to `root` and `home`. Without this migration, Timeshift will throw the error: *"Selected snapshot device is not a system disk."*

---

### 2. Phase 1: Accessing the "Real Root"

To rename the subvolumes that the OS is currently running on, we had to mount the Btrfs partition at the highest level (**ID 5**).

```bash
# Create a mount point for the top-level partition
sudo mkdir -p /mnt/real_root

# Mount the hardware partition (adjust device name as needed)
sudo mount -t btrfs -o subvolid=5 /dev/nvme0n1p6 /mnt/real_root

# Enter the root and verify current structure
cd /mnt/real_root
ls
# Output should show: root  home
```

---

### 3. Phase 2: Renaming the Subvolumes

We performed the move directly on the filesystem level.

```bash
# Rename Fedora defaults to Timeshift standards
sudo mv root @
sudo mv home @home

# Verify change
ls
# Output should show: @  @home
```

---

### 4. Phase 3: Updating the System Map (`/etc/fstab`)

Because the subvolume names changed, the system would fail to mount the drive on the next boot. We had to update the mount instructions.

**File:** `/etc/fstab`
**Change:**

* `subvol=root` $\rightarrow$ `subvol=@`
* `subvol=home` $\rightarrow$ `subvol=@home`

```text
# Example updated lines:
UUID=c3fce8ce-88f8-4c51-a52a-9f2a76d0ee1e /      btrfs  subvol=@,compress=zstd:1 0 0
UUID=c3fce8ce-88f8-4c51-a52a-9f2a76d0ee1e /home  btrfs  subvol=@home,compress=zstd:1 0 0
```

---

### 5. Phase 4: Updating the Bootloader (GRUB & BLS)

The kernel needs to know where the new root is located to start the boot process.

**Step A: Update GRUB**

```bash
# Regenerate the main GRUB configuration
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Update kernel arguments using grubby
sudo grubby --update-kernel=ALL --args="rootflags=subvol=@"
```

**Step B: Update BLS Entries**
Fedora stores specific boot entries for each kernel version. These must be updated to avoid a "root device not found" error.

```bash
# Bulk update all .conf files in the loader entries
sudo sh -c "sed -i 's/subvol=root/subvol=@/g' /boot/loader/entries/*.conf"
```

---

### 6. Phase 5: Finalizing

1. **Unmount:** `cd ~ && sudo umount /mnt/real_root`
2. **Reboot:** `sudo reboot`
3. **Timeshift Setup:**
    * Open Timeshift $\rightarrow$ Settings $\rightarrow$ Type: **BTRFS**.
    * Select the device (it will now be accepted).
    * Enable **@home** snapshots if desired in the "Users" tab.

---

### ⚠️ Warning for Future Use

If the system fails to boot after a similar migration, the "Emergency Fix" is to press `e` at the GRUB menu and manually edit the `linux` line, changing `subvol=root` to `subvol=@`.

---
