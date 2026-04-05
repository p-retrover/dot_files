# gnome settings

## 1. The Setup Script (`install.sh`)

Instead of just copying the extensions folder, your repository's install script should ideally:

1. Symlink your local extensions folder to the repo.
2. Load the `dconf` settings.
3. Restart the GNOME Shell.

## 2. Tracking Extension Settings

Don't just run a one-time dump. Create a small `backup.sh` script in your repo to keep things updated:

```bash
#!/bin/bash
# Export extension settings to a tracked file
dconf dump /org/gnome/shell/extensions/ > gnome_extensions_settings.ini

# Export general GNOME shell settings (including the 'enabled' list)
dconf dump /org/gnome/shell/ > gnome_shell_general.ini
```

## 3. Handling the "Enabled" List

As mentioned before, the `enabled-extensions` key is vital. It's stored in `/org/gnome/shell/`, which is why I included that second dump command above. Without it, you'll have the extension files and their settings, but GNOME won't know it's supposed to run them.

## Recommended Repo Structure

```text
my-dotfiles/
├── gnome/
│   ├── extensions/          # Symlinked to ~/.local/share/gnome-shell/extensions/
│   ├── settings.ini         # The dconf dump
│   └── setup_gnome.sh       # Script to 'dconf load' the settings
├── hyprland/                # (Since you use Hyprland as well)
├── scripts/
└── install.sh
```

### ⚠️ A Note on Portability

* **Hardware-Specific Settings:** Some dconf settings (like display scaling or touchpad speed) might vary between your 32GB Fedora machine and other setups. You might want to dump `/org/gnome/shell/extensions/` separately from your main system settings to avoid hardware conflicts.
* **Extension Versions:** Arch often has newer GNOME versions than Fedora. If you sync extension *files* across both, they might break on the older version. Many dotfile veterans prefer to track a **list** of extensions and have a script download them via `pip` or a CLI tool like `gext` rather than storing the actual code in Git.

use a dotfile manager like `stow` or `chezmoi`.
