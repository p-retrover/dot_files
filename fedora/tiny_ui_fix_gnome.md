# HiDPI Scaling Fixes for Linux (GNOME/Fedora)

When using high-resolution monitors, many applications (especially non-GTK ones) fail to scale their UI, resulting in "tiny" text and icons. This is because different frameworks (Qt, Java, Electron) handle scaling independently of GNOME.

## 1. Tool-Specific Fixes

### **MEGAsync (Qt Framework)**
MEGAsync on Fedora often defaults to XWayland and fails to auto-detect scaling. The "Magic Formula" below forces the UI to scale manually.

* **Temporary Test:**
    ```bash
    QT_AUTO_SCREEN_SCALE_FACTOR=0 QT_SCREEN_SCALE_FACTORS=1.5 QT_SCALE_FACTOR=1.5 megasync
    ```
* **Permanent Fix:** Edit `~/.local/share/applications/megasync.desktop` and update the `Exec` line:
    ```ini
    Exec=env QT_AUTO_SCREEN_SCALE_FACTOR=0 QT_SCREEN_SCALE_FACTORS=1.5 QT_SCALE_FACTOR=1.5 megasync %u
    ```

### **MATLAB (Java/Swing Framework)**
MATLAB doesn't use system environment variables for its internal desktop scaling. It must be set within the MATLAB engine itself.

* **Fix:** Run this in the MATLAB Command Window:
    ```matlab
    s = settings; s.matlab.desktop.DisplayScaleFactor.PersonalValue = 1.5
    ```
    *(Restart MATLAB to apply).*

### **DaVinci Resolve (Qt Framework)**
DaVinci Resolve is notoriously stubborn with Linux scaling. It uses an older implementation of Qt.

* **Fix:** Launch with the `QT_DEVICE_PIXEL_RATIO` variable.
    ```bash
    QT_DEVICE_PIXEL_RATIO=2 QT_AUTO_SCREEN_SCALE_FACTOR=true /opt/resolve/bin/resolve
    ```
    *Note: DaVinci often only supports integer scaling (1 or 2). If 2 is too big, you may need to use GNOME's "Font Scaling" instead.*

---

## 2. General Troubleshooting: How to fix future apps

If you install a new app and the UI is tiny, follow this workflow:

### **Step 1: Identify the Toolkit**
The fix depends on what "language" the app was built with.
* **Qt (Common for KDE apps, VLC, OBS, MEGA):** Usually responds to `QT_SCALE_FACTOR`.
* **GTK (Common for GNOME apps, GIMP, Inkscape):** Usually responds to `GDK_SCALE`.
* **Electron (Discord, VS Code, Slack, Obsidian):** Usually responds to the flag `--force-device-scale-factor`.
* **Java (MATLAB, JetBrains IDEs):** Usually responds to `-Dsun.java2d.uiScale=2`.

### **Step 2: Apply the Correct Variable**
Try running the app from the terminal with these prefixes to see which one works:

| Toolkit | Command Prefix |
| :--- | :--- |
| **Qt** | `env QT_SCALE_FACTOR=1.5 app-name` |
| **GTK** | `env GDK_SCALE=2 app-name` |
| **Electron** | `app-name --force-device-scale-factor=1.5` |
| **Java** | `_JAVA_OPTIONS='-Dsun.java2d.uiScale=1.5' app-name` |

### **Step 3: Check for XWayland vs. Wayland**
If you are on GNOME Wayland but the app looks blurry or won't scale, it is likely running in **XWayland** (X11 compatibility mode).
* Force Wayland for Qt: `QT_QPA_PLATFORM=wayland`
* Force Wayland for Electron: `--ozone-platform-hint=auto`

---

## 3. Window Management (The "Unmovable" Fix)
If an app (like MEGA) opens but you cannot grab the title bar to move it:

1.  **Alt + F7:** Turns your cursor into a "move" tool. Use arrow keys or mouse to reposition.
2.  **Super + Left/Right:** Snaps the window to the side, resetting its coordinates.
3.  **Super + Drag:** In GNOME, holding the `Super` (Windows) key allows you to click and drag **anywhere** inside a window to move it.

---

## 4. System-Wide Fallback
If specific app fixes fail, use **GNOME Tweaks** to adjust the **Interface Text Scaling Factor**.
* **Command:** `sudo dnf install gnome-tweaks`
* **Setting:** `Fonts` -> `Scaling Factor` -> Set to `1.25` or `1.5`.
* **Why:** This forces almost all apps to scale their text, even if their icons stay small. It is the most "stable" way to handle HiDPI without causing blurriness.