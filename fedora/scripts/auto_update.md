Using a Systemd Timer for `dnf update` is much more reliable than a cron job because it can handle "missed" events if your laptop is closed.

However, running `dnf update` requires **root (sudo)** privileges. To make this fully automated without the script stopping to ask you for a password, we will use a **System-level** timer instead of a user-level one.

---

### Step 1: Create the Update Script

First, let's create a simple script that handles the update. Using the `-y` flag is critical so it doesn't wait for a "Yes/No" confirmation.

**Create the file:** `/usr/local/bin/auto-update.sh`

```bash
#!/bin/bash
# Update the package database and upgrade all packages
dnf update -y
# Optional: Clean up old cached packages to save space on your 128GB SSD
dnf clean packages

```

**Make it executable:**

```bash
sudo chmod +x /usr/local/bin/auto-update.sh

```

---

### Step 2: Create the Systemd Service

This file defines *what* to run. Since it is in `/etc/systemd/system/`, it will automatically run as the **root** user.

**Create the file:** `/etc/systemd/system/dnf-auto-update.service`

```ini
[Unit]
Description=Daily System Update
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/auto-update.sh

[Install]
WantedBy=multi-user.target

```

---

### Step 3: Create the Systemd Timer

This defines *when* to run. Let’s set it for 10:00 PM (22:00), or any time you’re usually at your desk at NIT Rourkela.

**Create the file:** `/etc/systemd/system/dnf-auto-update.timer`

```ini
[Unit]
Description=Trigger Daily System Update

[Timer]
# Run every day at 10 PM
OnCalendar=*-*-* 22:00:00
# If the laptop was off at 10 PM, run it as soon as it boots up
Persistent=true
# Randomize the start time by 15 minutes to avoid server spikes
RandomizedDelaySec=15m

[Install]
WantedBy=timers.target

```

---

### Step 4: Enable and Test

Since this is a system-level service, you need to use `sudo` to enable it.

1. **Reload the system manager:**
```bash
sudo systemctl daemon-reload

```


2. **Enable and start the timer:**
```bash
sudo systemctl enable --now dnf-auto-update.timer

```


3. **Check if it’s scheduled:**
```bash
systemctl list-timers --all | grep dnf-auto-update

```



---

### Important Considerations for Fedora

* **The "Offline" Alternative:** Fedora actually has a built-in tool for this called `dnf-automatic`. It is highly polished and can be configured to just download updates, or download and install them automatically. If you’d prefer the official tool over a custom script, you can install it with `sudo dnf install dnf-automatic`.
* **Kernel Updates:** If `dnf update` installs a new kernel, your system won't use it until you **reboot**.
* **Power Awareness:** If you are on battery, `dnf update` can be power-intensive. You can add `ConditionACPower=true` to the `[Unit]` section of the `.timer` file if you only want it to run when your laptop is plugged in.

---

Here is the complete, integrated code for your **Fedora** update script. This version includes the timestamped logging, automatic folder creation, and the ownership fix so your mirror script can back it up to GitLab.

### The Update Script

**Location:** `/usr/local/bin/auto-update.sh`

```bash
#!/bin/bash

# 1. Setup Paths
# Pointing to your GitHub backup directory
LOG_DIR="/home/p_retrover/github/backup/system_logs"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
LOG_FILE="$LOG_DIR/update_$TIMESTAMP.log"

# 2. Ensure the log directory exists
# Since this runs as root, we create it now if it's missing
mkdir -p "$LOG_DIR"

# 3. Start Logging
echo "==========================================" > "$LOG_FILE"
echo "FEDORA AUTO-UPDATE: $(date)" >> "$LOG_FILE"
echo "==========================================" >> "$LOG_FILE"

# 4. Run DNF Update
# -y: assume yes to all prompts
# 2>&1: captures both standard output and errors
dnf update -y >> "$LOG_FILE" 2>&1

# 5. Cleanup Metadata (Optional but keeps your 128GB SSD clean)
dnf clean internal >> "$LOG_FILE" 2>&1

# 6. Housekeeping: Keep only the last 30 days of logs
find "$LOG_DIR" -name "update_*.log" -type f -mtime +30 -delete >> "$LOG_FILE" 2>&1

echo "==========================================" >> "$LOG_FILE"
echo "UPDATE FINISHED: $(date)" >> "$LOG_FILE"

# 7. FIX PERMISSIONS
# Because DNF runs as root, the log is created as root.
# This changes it back to your user so your Git script can push it.
chown -R p_retrover:p_retrover "$LOG_DIR"

```

---

### How to apply this code:

1. **Create the file:**
`sudo nano /usr/local/bin/auto-update.sh`
2. **Paste the code above** into the editor, then save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).
3. **Make it executable:**
`sudo chmod +x /usr/local/bin/auto-update.sh`
4. **Test it manually** to see it create your first log:
`sudo /usr/local/bin/auto-update.sh`

---

Since you are using **Systemd**, you have two ways to check the run: one to see if the **process** finished successfully and another to see the **actual package changes** in your log files.

---

### 1. Check the System Status (The "Process" Check)

You can ask Systemd for the last time the service ran and whether it hit any errors.

**To see the Service status:**

```bash
systemctl status dnf-auto-update.service

```

**To see the Timer schedule (when it will run next):**

```bash
systemctl list-timers dnf-auto-update.timer

```

---

### 2. Check the System Logs (The "Detailed" Check)

Systemd keeps its own logs (journal), which is useful if the script itself failed to start.

**View the background logs:**

```bash
journalctl -u dnf-auto-update.service --since today

```

---

### 3. Check your Custom Log File (The "Package" Check)

Since we added a custom logging step to save files in your GitHub backup folder, this is the best way to see exactly which packages were updated (e.g., if your kernel or `gh` CLI were upgraded).

**List the logs in your backup folder:**

```bash
ls -lh /home/p_retrover/github/backup/system_logs/

```

**Read the latest log:**

```bash
# This uses 'ls' to find the newest file and 'cat' to read it
cat $(ls -t /home/p_retrover/github/backup/system_logs/update_*.log | head -n 1)

```

---

### 4. Pro-Tip: Real-time Monitoring

If you happen to be at your laptop at 10:00 PM and want to watch the update happen live, you can "tail" the log file:

```bash
tail -f /home/p_retrover/github/backup/system_logs/$(ls -t /home/p_retrover/github/backup/system_logs/ | head -n 1)

```

---
