## 1. Prepare the Script for Automation

Cron runs in a non-interactive shell. To make the script work without you being there, we should create a "Non-Interactive" version or pass a flag to skip the `read` prompts.

### Quick Modification for Cron

Add an environment variable check at the top of your script so it doesn't wait for your input when running via Cron:

```bash
# Near the top of the script
[[ "$1" == "--force" ]] && AUTO_CONFIRM=true || AUTO_CONFIRM=false

# Update the confirmation logic:
if [[ "$AUTO_CONFIRM" == "false" ]]; then
    read -p "Mirror '$REPO' ($VISIBILITY) to GitLab? [Y/n]: " -r RESPONSE < /dev/tty
    if [[ "$RESPONSE" =~ ^[Nn]$ ]]; then
        echo "Skipping $REPO..."
        continue
    fi
fi

```

---

## 2. Setting Up the Cron Job

Follow the steps you outlined, but with these specific paths for your backup project:

### Edit your Crontab

```bash
EDITOR=nano crontab -e

```

### Add the Automation Entry

Let's schedule it to run every Sunday at midnight. We’ll also add the `--force` flag (if you added the logic above) and redirect output to a log file so you can check it on Monday morning.

```cron
# Run the GitLab mirror every Sunday at 00:00
0 0 * * 0 /home/p_retrover/github/backup/gitlab_mirror.sh --force >> /home/p_retrover/github/backup/mirror_log.txt 2>&1

```

---

## 3. Crucial Fedora/Cron Troubleshooting

When running Git scripts through Cron on Fedora, there are three things that usually trip people up:

* **PATH Issues:** Cron's `$PATH` is very limited. It might not find `gh` or `glab`. Add this to the top of your `crontab` file:
```bash
PATH=/usr/local/bin:/usr/bin:/bin:/home/p_retrover/.local/bin

```


* **Git Credentials:** Cron won't have access to your active SSH agent or your session's keyring.
* **Solution:** Ensure you've run `git config --global credential.helper store` so the token is saved in a file the background process can read.


* **Working Directory:** Cron starts in your `$HOME`. Since our script uses `$(pwd)`, make sure the script explicitly `cd`s into the backup folder at the start, or use absolute paths throughout.

---

## 4. The "Fedora Way": Systemd Timers (Alternative)

Since you're ready to automate this on **Fedora**, let's set up a **Systemd Timer**. While Cron is classic, Systemd is the "Fedora way"—it's more robust because if your laptop is powered off during the scheduled time, Systemd can catch up and run the task immediately upon boot.

We will create two files: a **Service** (the "what") and a **Timer** (the "when").

---

### Step 1: Create the Service File

This file tells Fedora how to run your script. Create it here: `~/.config/systemd/user/gitlab-mirror.service`

```ini
[Unit]
Description=Mirror GitHub Repos to GitLab
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
# Set the working directory to your backup folder
WorkingDirectory=/home/p_retrover/github/backup
# Use the absolute path to your script. 
# We add a '--batch' flag (we'll add this logic to your script next)
ExecStart=/usr/bin/bash /home/p_retrover/github/backup/gitlab_mirror.sh --batch
# Ensure the service has access to your PATH for gh and glab
Environment="PATH=/usr/local/bin:/usr/bin:/bin:/home/p_retrover/.local/bin"

[Install]
WantedBy=default.target

```

---

### Step 2: Create the Timer File

This file tells Fedora when to trigger the service. Create it here: `~/.config/systemd/user/gitlab-mirror.timer`

```ini
[Unit]
Description=Run GitLab Mirroring Weekly

[Timer]
# Run every Sunday at 3:00 AM
OnCalendar=Sun *-*-* 03:00:00
# If the machine was off, run it 10 minutes after booting
Persistent=true

[Install]
WantedBy=timers.target

```

---

### Step 3: Add "Batch Mode" to Your Script

To prevent the script from hanging forever waiting for a "Y/n" input that will never come (since it's running in the background), we need to add a quick check for the `--batch` flag at the top of your `gitlab_mirror.sh`:

```bash
#!/bin/bash

# --- BATCH LOGIC START ---
# Check if the first argument is --batch
BATCH_MODE=false
if [[ "$1" == "--batch" ]]; then
    BATCH_MODE=true
fi
# --- BATCH LOGIC END ---

# ... (keep your existing config/variables) ...

while IFS=$'\t' read -u 3 -r REPO VISIBILITY; do
    [ -z "$REPO" ] && continue

    echo "==================================="
    
    # --- UPDATED CONFIRMATION LOGIC ---
    if [ "$BATCH_MODE" = false ]; then
        read -p "Mirror '$REPO' ($VISIBILITY) to GitLab? [Y/n]: " -r RESPONSE < /dev/tty
        if [[ "$RESPONSE" =~ ^[Nn]$ ]]; then
            echo "Skipping $REPO..."
            continue
        fi
    else
        echo "Batch mode active: Automatically mirroring $REPO..."
    fi
    # ----------------------------------

    # ... (rest of the script remains exactly the same) ...

```

---

### Step 4: Enable and Start

Run these commands as your normal user (do **not** use `sudo`, as we want this to run with your user's Git credentials):

1. **Reload the daemon:**
`systemctl --user daemon-reload`
2. **Enable the timer:**
`systemctl --user enable --now gitlab-mirror.timer`
3. **Check the status:**
`systemctl --user list-timers`

---

### Why this is better

* **Logging:** You can check exactly why a backup failed by running `journalctl --user -u gitlab-mirror.service`.
* **Reliability:** The `Persistent=true` flag is the killer feature. If you're traveling or your laptop is closed on Sunday morning, the backup will trigger the moment you open it back up.
* **Network Awareness:** The `Wants=network-online.target` ensures the script doesn't even try to run until Fedora confirms your WiFi (like the NIT Rourkela network) is actually connected.
