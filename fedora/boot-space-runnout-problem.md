# Fedora `/boot` Maintenance & Optimization

When `/boot` hits **0 bytes** (or close to it), DNF updates will fail, and the system may become unresponsive during boot or hibernation. This is usually caused by heavy `initramfs` images and the "Rescue" kernel.

## 1. Diagnose the Bloat
To see exactly what is eating the space, run:
```bash
sudo du -sh /boot/* | sort -h
```
**Common Culprits:**
* `initramfs-0-rescue-*.img`: Often **200MB+**. This is a generic image designed to boot on any hardware.
* `initramfs-*.img`: Standard boot images, usually **50MB - 100MB**.

## 2. Limit Kernel Count
Edit `/etc/dnf/dnf.conf` to ensure Fedora doesn't keep too many old versions.

```ini
[main]
# Keep only 2 kernels (Current + 1 Fallback)
installonly_limit=2
# Ensure dependencies are purged
clean_requirements_on_remove=True
```

## 3. Advanced Optimization (The "Permanent" Fix)
By default, Fedora builds `initramfs` images that are "one-size-fits-all." On a personal machine, you can shrink these by **~70%** using Dracut configurations.

Create `/etc/dracut.conf.d/99-small-boot.conf`:
```text
# Use XZ compression (Better than default gzip)
compress="xz"
# Only include drivers for THIS hardware
hostonly="yes"
# Stop generating the massive rescue image
dracut_rescue_image="no"
```

**Apply changes immediately:**
```bash
sudo rm /boot/*rescue*
sudo dracut -f --all
```

---

## 4. Drawbacks and Implications

| Change | Pro | Con |
| :--- | :--- | :--- |
| **`installonly_limit=2`** | Frees ~100-200MB. Prevents partition overflow. | You only have one "fallback" kernel. If an update breaks two kernels, you need a Live USB. |
| **`hostonly="yes"`** | Shrinks images from ~100MB to ~30MB. | If you move your SSD to a different computer (e.g., different CPU/GPU), it might not boot. |
| **`compress="xz"`** | Significant space savings. | Generating the image (during kernel updates) takes slightly longer (CPU intensive). |
| **`dracut_rescue_image=no`**| Reclaims **~250MB** instantly. | Removes the "Rescue" entry from GRUB. You must use a Fedora Live USB for emergency repairs. |

## 5. Maintenance Commands
* **Force cleanup of old kernels:**
  `dnf repoquery --installonly --latest-limit=-1 -q | xargs -r sudo dnf remove`
* **Check remaining space:**
  `df -h /boot`
