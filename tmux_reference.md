# Tmux Configuration & Reference Note

**Tmux** is an open-source terminal multiplexer created in 2007 by Nicholas Marriott, licensed under the BSD license. It allows you to run a terminal inside your terminal, letting other terminal programs run inside of it while juggling multiple terminal sessions from a single window. 

This note covers everything from core concepts to configuration file settings and keybindings.

## Core Concepts

Tmux is built on three fundamental layers:
1. **Sessions:** The highest level. Sessions run in the background, allowing you to detach from them and reattach later without stopping any running processes.
2. **Windows:** Similar to tabs in a web browser. A new session creates a default window, and you can create as many windows as you need within a session.
3. **Panes:** Windows can be split into smaller, independent terminal pieces called panes. 

## Installation

Tmux can be installed on Unix-like machines, including macOS, Linux, and Windows Subsystem for Linux (WSL). 
* **Debian/Ubuntu-based systems:** `apt install tmux`. (Note: It is also installed by default in many modern environments).

## Configuration (`~/.tmux.conf`)

Tmux configuration is managed in a hidden file in your home directory. Create or edit `~/.tmux.conf` using a text editor like Nano to add custom behaviors. 

```bash
# ~/.tmux.conf

# Enable mouse support (allows clicking to switch panes, resizing with the mouse, and easier copying)
set -g mouse on

# Enable vi-style hotkeys for navigating copy mode
setw -g mode-keys vi
```
*Note: To save this file in Nano, press `Ctrl + X`, then `Y`, and hit `Enter`. Enabling mouse mode is great for convenience, but relying strictly on keyboard shortcuts is faster and keeps your hands glued to the keyboard.*

## Command Line Interface (CLI) Commands

These commands are run in your standard terminal to manage Tmux:

* `tmux` : Start a new default session.
* `tmux new -s <name>` : Create a new session with a specific custom name (e.g., `tmux new -s Bob`).
* `tmux ls` : List all currently active background sessions.
* `tmux a` : Attach to the most recent detached session.
* `tmux a -t <index_or_name>` : Attach to a specific session by its index number (e.g., `0`) or name (e.g., `Bob`).
* `tmux kill-session` : Kill the most recent session completely.
* `tmux kill-session -t <name>` : Kill a specific named session.
* `tmux kill-server` : Terminate the entire Tmux server, killing all active sessions, windows, and panes at once.
* `tmux has-session` : Check if a session already exists (highly useful for writing automated bash scripts).

## Keybindings / Cheatsheet

To issue commands while inside Tmux, you must first press the **Prefix Key**. 
By default, the prefix key is **`Ctrl + B`** (often written in documentation as `C-b`). 

*To use any of the shortcuts below, press and release `Ctrl + B`, then press the corresponding key.*

### Session & Environment Control
* `d` : **Detach** from the current session, leaving it running safely in the background.
* `w` : Open an interactive list of all active **sessions and windows**. You can use the arrow keys to navigate and press `Enter` to jump directly into one.

### Window Management
* `c` : Create a **new window**.
* `,` : **Rename** the current active window.
* `n` : Move to the **next window** sequentially.
* `&` : **Kill** (close) the current window completely.

### Pane Management
* `%` : Split the terminal **horizontally** ("hot dog style" side-by-side).
* `"` : Split the terminal **vertically** ("hamburger style" top-and-bottom).
* `Arrow Keys` (Up, Down, Left, Right): Navigate between open panes.
* `q` : Display the **index numbers** of all active panes. If you quickly type the number while it is displayed, you will instantly jump to that pane.
* `x` : **Kill** the current active pane.
* `Ctrl + Arrow Keys` : **Resize** the active pane in small increments.
* `Alt + Arrow Keys` : **Resize** the active pane in larger steps.
* `Alt + 1` through `Alt + 5` : Apply **pre-selected pane layouts** automatically.

### Copy Mode
Tmux has a dedicated "copy mode" to allow you to scroll through terminal history and copy text without ever touching a mouse.

* `[` : **Enter** copy mode.
* `Space` : **Start selecting/highlighting** text at your cursor's location.
* `Arrow Keys` (or vi-keys like `h, j, k, l` if configured): Move the cursor to select the desired text.
* `Enter` : **Copy** the highlighted text into the Tmux buffer and exit copy mode.
* `]` : **Paste** the copied text into your active pane.

## Ecosystem & Automation

* **Scripting:** Tmux can be completely automated via bash scripts. You can programmatically define sessions, create descriptive window names, assign colors, run commands (like starting Docker, a database, and a web server), and focus on a specific editor upon launch with just a few lines of bash. 
* **Plugins:** Tmux has a robust ecosystem of pre-built plugins. For example, `tmux-resurrect` will automatically restore your entire terminal environment after a system reboot, and `powerline` allows for deep visual customization of the status bar.

## References

[networkchuck](https://youtu.be/nTqu6w2wc68?si=_g3ILQVVSCf80S1o)
[fireship](https://youtu.be/vtB1J_zCv8I?si=j8SoQT-uPeenJpjk)
[tmux wiki](https://github.com/tmux/tmux/wiki)