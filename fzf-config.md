# fzf setup

At its core, **fzf** (Fuzzy Finder) is an interactive Unix filter for the command line. It’s written in Go and is designed to take any list of text as input, let you search through it using partial or "fuzzy" matches, and output your selection.

Think of it as the "Spotlight Search" or "Alfred" for your terminal, but much faster and infinitely more scriptable.

### 1. What makes it "Fuzzy"?
Unlike standard `grep` or `find`, which require exact matches, `fzf` uses a **fuzzy matching algorithm**. 
* If you want to find a file at `~/dotfiles/hypr/hyprland.conf`, you don't need to type the whole path.
* You could just type **`hyconf`** or **`hland`**, and `fzf` will find the best match by looking for those characters in that order, even if there are other characters in between.

### 2. The "Killer Features"
While it's just a filter, it comes with built-in shell integrations that change how you use your terminal:

* **`Ctrl + R` (History Search):** Instead of cycling through old commands one by one, it opens a full-screen searchable list of every command you’ve ever typed.
* **`Ctrl + T` (File Finder):** Instantly search for any file in your current directory and paste the path directly onto your command line.
* **`Alt + C` (Smart CD):** Fuzzy search for a subdirectory and `cd` into it immediately.
* **The `**` Trigger:** In Bash or Zsh, you can type `vim **<TAB>` to trigger a fuzzy file picker specifically for that command.

### 3. Why it’s a "Must-Have" for Power Users
For someone like you managing **Arch**, **Fedora**, and **Windows**, `fzf` acts as a glue for your workflow:

* **Speed:** It can handle lists with millions of items (like a massive `/home` directory) without breaking a sweat.
* **Portability:** It's a single binary. Your config for it on Arch will work exactly the same on Fedora and Windows.
* **Preview Windows:** You can pipe it into tools like `bat` (a cat clone with syntax highlighting). As you scroll through the list in `fzf`, a side window can show you a live preview of the file's code.
* **Vim/Neovim Integration:** It is the primary engine behind most fast file-switchers in the Neovim ecosystem.

### 4. How it looks in practice
Instead of doing this:
```bash
ls -R | grep "my_script"
# ... wait for output ...
# ... copy path ...
# ... type nvim and paste path ...
```

You just do this:
```bash
nvim $(fzf)
# ... start typing "myscr" ...
# ... hit Enter ...
```

**In short:** `fzf` is the tool that stops you from having to remember where you put things or exactly what you named them. It allows you to *discover* your files and commands rather than *recall* them.

## Installation

### **Linux (Fedora & Arch)**

On Linux, it is best to install via the native package managers to handle dependencies.

* **Arch Linux:** `sudo pacman -S fzf fd`
* **Fedora:** `sudo dnf install fzf fd-find`

### **Windows**

Use **Winget** for the cleanest installation. If you use PowerShell, the `PSFzf` module is highly recommended to bridge the gap between Unix-style piping and Windows objects.

* **Binary:** `winget install fzf`
* **PowerShell Module:** `Install-Module -Name PSFzf -Scope CurrentUser`

-----

## Universal Configuration Strategy

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

## Advanced Dotfile Integration

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

## Resources & Further Reading

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
