# windows pandoc setup guide

## 1. Install Scoop

If you haven't already, open **PowerShell** (not CMD) and run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Get.scoop.sh | Inverse-Expression
```

---

## 2. Add Required Buckets

Some of your technical tools reside in the `extras` and `main` buckets.

```powershell
scoop bucket add extras
scoop bucket add main
```

---

## 3. Install Core Build Tools

These packages will allow your **Makefile** to function on Windows exactly as it does on your **Arch Linux** partition.

```powershell
# Install Pandoc, Make (to run the build), and Ghostscript (for PDF processing)
scoop install pandoc make ghostscript
```

---

## 4. Install the LaTeX Engine

For your CV, you need **XeLaTeX** to handle specific fonts like **EB Garamond**, **Montserrat**, and **Inter**.

You have two main options through Scoop:

* **Option A: TeX Live (The "Rigorous" Choice)**
    This is the most stable and comprehensive, similar to what you use on Linux.

    ```powershell
    scoop install latex
    ```

* **Option B: MikTeX (The "Lightweight" Choice)**
    Better if you want a smaller initial download; it installs missing packages (like `fontawesome5` or `titlesec`) on the fly.

    ```powershell
    scoop install miktex
    ```

---

## 5. System Font Setup

On Windows, XeLaTeX pulls fonts from the system font store. You need to manually install the fonts we configured for your "cool but professional" header.

1. **Download the Fonts:**
    * **Montserrat:** `scoop install ttf-montserrat`
    * **Inter:** `scoop install ttf-inter`
    * **EB Garamond:** Download from Google Fonts or similar.
2. **Install:** Right-click the `.ttf` files and select **"Install for all users."**

---

## 6. Troubleshooting Windows-Specific Issues

### The `/dev/null` Conflict

In your **Makefile**, you used `/dev/null` as a dummy input to silence Pandoc warnings. Windows uses `NUL` instead. To make your repo cross-platform, you can update your Makefile variable:

```makefile
# Cross-platform NUL/null
ifeq ($(OS),Windows_NT)
    NULL_DEVICE = NUL
else
    NULL_DEVICE = /dev/null
endif

technical:
 pandoc $(NULL_DEVICE) --metadata-file=data/details.yml ...
```

### Font Cache

If XeLaTeX on Windows doesn't see your new fonts (like **Montserrat**), run the following in PowerShell to refresh the cache:

```powershell
fc-cache -fv
```
