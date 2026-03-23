Running out of space on `/boot` is a classic Fedora headache, especially since Fedora keeps old kernels by default. When `/boot` hits **0 bytes**, it can prevent system updates and even cause boot failures because there’s no room for temporary files or new kernel images.

### 1\. Remove Old Kernels (The Fastest Fix)

Fedora usually keeps the last 3 kernels. If an update failed halfway, you might have partially installed kernels taking up space. You can force-remove old ones, keeping only the current running version.

Open your terminal and run:

```bash
sudo dnf remove $(dnf repoquery --installonly --latest-limit=-1 -q)
```

  * **What this does:** It identifies all installed kernels except the one you are currently booted into and removes them.

### 2\. Limit the Number of Kernels Permanently

To prevent this from happening again, you should tell Fedora to only keep 2 kernels instead of the default 3 (or more).

1.  Edit the DNF configuration file:
    `sudo nano /etc/dnf/dnf.conf`
2.  Find the line `installonly_limit=3` and change it to:
    `installonly_limit=2`
3.  Save and exit (Ctrl+O, Enter, Ctrl+X).

### 3\. Clean Up DNF Cache

Sometimes the package manager leaves metadata and temporary files in the boot partition if it's mounted strangely, though usually, this lives in `/var`. Still, it's good practice:

```bash
sudo dnf clean all
```

-----

### 4\. Check for "Ghost" Files

If the commands above didn't free up enough space, something else might be hiding there. Run this to see what is actually eating the space:

```bash
du -sh /boot/* | sort -h
```

**Look for:**

  * **initramfs images:** These are usually the largest files. If you see many versions, the kernel removal in Step 1 should have handled them.
  * **Lost+Found:** If the system crashed, there might be recovered fragments here.

### Important Note on Hibernation

Since you've mentioned having issues with **hibernation and unresponsiveness** in Fedora before, a full `/boot` partition can sometimes be the culprit if the system is trying to write bootloader updates or state changes to a drive with zero capacity. Fixing this might actually improve your system's stability when waking from sleep.
