# `system-storage-map.md`

### 1. The High-Level View

In Fedora/Arch, the `/var` directory is the primary location for variable data. When your disk fills up, **90% of the time, the culprit is in `/var/lib`**.

| Path | Purpose | Why it grows |
| :--- | :--- | :--- |
| `/var/lib/libvirt/images` | **Virtual Machines** | Stores `.qcow2` files (virtual hard drives). |
| `/var/lib/docker` | **Docker Containers** | Stores image layers, volumes, and logs. |
| `/var/lib/flatpak` | **Flatpak Apps** | Stores runtimes (GNOME, Nvidia) and app data. |
| `/var/log` | **System Logs** | Stores journal files and service error logs. |

---

### 2. Deep Dive: The "Big Three" Hogs

#### A. Libvirt (Virtual Machines) — **~41GB**

* **The Logic:** Every time you create a VM (like for your Fedora/Arch testing), a large file is allocated. Even if the VM isn't running, the space is reserved.
* **Location:** `/var/lib/libvirt/images/`
* **Maintenance:**
  * List images: `sudo ls -lh /var/lib/libvirt/images`
  * Delete unused VMs via **Virt-Manager** (preferred) or manually via `rm`.

#### B. Docker — **~25GB**

* **The Logic:** Docker uses a "layered" filesystem. Every version of a container you've ever pulled (like SearXNG) stays on disk as a "dangling" image even after the container is stopped.
* **Maintenance:**
  * **The "Nuke" command:** `sudo docker system prune -af --volumes`
  * (This deletes all stopped containers, unused networks, and dangling images).

#### C. Flatpak — **~16GB**

* **The Logic:** Flatpaks are self-contained. If you have 10 apps, they might share a "Gnome Runtime" or an "Nvidia Driver." When these runtimes update, the old versions aren't always deleted automatically.
* **Maintenance:**
  * **The "Cleanup" command:** `flatpak uninstall --unused`

---

### 3. The "Hidden" System Bloat

#### Systemd Coredumps

* **The Logic:** When a program (like Syncthing or a riced script) crashes, Linux saves the state of the RAM to a file so you can debug it. These "coredumps" can be several GBs each.
* **Location:** `/var/lib/systemd/coredump/`
* **Maintenance:** `sudo rm /var/lib/systemd/coredump/*`

#### Journald Logs

* **The Logic:** Every "Failed to sync" or "Permission denied" error is written to a text file. If a service enters a crash loop, it can write millions of lines per hour.
* **Maintenance:**
  * Check size: `journalctl --disk-usage`
  * Clear all but the last 100MB: `sudo journalctl --vacuum-size=100M`

---

### 4. Btrfs Snapshot Reserved Space

* **The Logic:** Snapshots themselves take **0 bytes** initially. However, as you delete or modify files, the "old" versions of those files are kept in the snapshot.
* **Visualizing the Space:** Standard `du` will report the same file twice (once in `/` and once in the snapshot), which is misleading.
* **True Usage Check:** `sudo btrfs filesystem usage /`

---

### Summary Table for Fast Reference

| Action | Command | Frequency |
| :--- | :--- | :--- |
| **Clean Package Cache** | `sudo dnf clean all` | Monthly |
| **Clean Flatpaks** | `flatpak uninstall --unused` | After updates |
| **Clean Docker** | `docker system prune -f` | After testing |
| **Vacuum Logs** | `journalctl --vacuum-time=3d` | If space is <5% |

---
