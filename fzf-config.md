# fzf setup

## 1\. Installation

### **Linux (Fedora & Arch)**

On Linux, it is best to install via the native package managers to handle dependencies.

* **Arch Linux:** `sudo pacman -S fzf fd`
* **Fedora:** `sudo dnf install fzf fd-find`

### **Windows**

Use **Winget** for the cleanest installation. If you use PowerShell, the `PSFzf` module is highly recommended to bridge the gap between Unix-style piping and Windows objects.

* **Binary:** `winget install fzf`
* **PowerShell Module:** `Install-Module -Name PSFzf -Scope CurrentUser`

-----

## 2\. Universal Configuration Strategy

To keep your config files clean, define your `fzf` logic in a standalone script or shell-specific file (e.g., `.bashrc` or `Microsoft.PowerShell_profile.ps1`).

### **Linux Setup (.bashrc or .zshrc)**

Since you are a performance-focused user, replace the default `find` backend with `fd` (or `ripgrep`) to ignore `.git` folders and respect your `.gitignore`.

```bash
# Set fd as the default source for fzf
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Minimalist UI: Rounded borders and Catppuccin-style colors
export FZF_DEFAULT_OPTS="
  --height 40% --layout=reverse --border --margin=1 --padding=1
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# Fast directory jumping for your dotfiles
alias dot='cd ~/dotfiles && fzf'
```

### **Windows Setup (PowerShell Profile)**

Open your profile with `notepad $PROFILE` and add:

```powershell
# Set fzf to use fd for speed
$env:FZF_DEFAULT_COMMAND = 'fd --type f --strip-cwd-prefix --hidden --exclude .git'

# Initialize PSFzf for better Ctrl+T / Ctrl+R behavior
Import-Module PSFzf
Set-PsFzfOption -Height 15 -ViMode

# Function to quickly edit config files
function conf {
    $file = fd . "$HOME\AppData\Local" --type f | fzf
    if ($file) { nvim $file }
}
```

-----

## 3\. Advanced Dotfile Integration

### **The "Edit Config" Function**

Add this to your Linux shell config to quickly jump into any dotfile regardless of where you are in the file system:

```bash
fe() {
  local files
  IFS=$'\n' files=($(fd . ~/dotfiles --type f | fzf --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-nvim} "${files[@]}"
}
```

* **Usage:** Typing `fe hypr` will immediately open your Hyprland config in Neovim.

-----

## 4\. Resources & Further Reading

### **Official Documentation**

* **[fzf GitHub Wiki](https://www.google.com/search?q=https://github.com/junegunn/fzf/wiki):** The ultimate source for community-contributed examples (e.g., fzf for git, docker, and process killing).
* **[fd GitHub Repo](https://github.com/sharkdp/fd):** Essential for understanding how to refine your search exclusions.

### **Deep Dives**

* **[Fzf-native for Telescope](https://github.com/nvim-telescope/telescope-fzf-native.nvim):** If you use Neovim, this C-extension makes Telescope significantly faster by using the fzf sorting algorithm.
* **[A Guide to Advanced FZF](https://thevaluable.dev/fzf-shell-integration/):** A deep technical look at using fzf as a general-purpose UI for any CLI tool.
* **[Vim Universe: fzf.vim](https://github.com/junegunn/fzf.vim):** For those who want to use fzf for buffer switching and line searching within their editor.

### **Advanced Concepts to Explore**

* **Preview Windows:** Use `fzf --preview 'bat --color=always --style=numbers {}'` to see file contents in a side pane before opening them.
* **Exact Mode:** If you find fuzzy matching too "loose," use the `-e` or `--exact` flag for literal string matching.
