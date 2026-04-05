# Mamba / Micromamba Setup Guide (Platform-Agnostic)

A comprehensive reference for setting up and using **Mamba** / **Micromamba** as a fast, reproducible environment manager across Linux, macOS, and Windows.

## What is Mamba?

**Mamba** is a fast, drop-in replacement for Conda—used to manage **software environments and packages**, especially in Python-heavy workflows.

At its core, it does two things:

1. **Creates isolated environments**
   Each project gets its own sandbox with its own Python version and dependencies.

2. **Installs and resolves packages**
   It figures out compatible versions of libraries (e.g., NumPy, Pandas) and installs them.

---

## Why Mamba instead of Conda?

Mamba uses a high-performance dependency solver (`libsolv`), which makes it:

* **Much faster** (especially for complex environments)
* **More reliable** in resolving conflicts
* **Parallelized** for downloads and installs

👉 Functionally, it behaves the same as Conda—but significantly faster.

---

## What is it used for?

### 1. Reproducible Development Environments

Create consistent setups across machines:

```bash
micromamba create -n project python=3.12 numpy pandas
```

---

### 2. Dependency Isolation

Avoid “it works on my machine” problems:

* Project A → Python 3.10 + older libs
* Project B → Python 3.12 + latest libs

No conflicts.

---

### 3. Data Science / Scientific Computing

Widely used for managing heavy dependencies like:

* NumPy, SciPy
* PyTorch, TensorFlow
* CUDA toolkits

---

### 4. Cross-Platform Package Management

Works across:

* Linux
* macOS
* Windows

With consistent environments.

---

### 5. CI/CD and Automation

Especially with **micromamba**:

* Lightweight
* Fast environment setup
* Ideal for pipelines and containers

---

## Mamba vs Micromamba (quick clarity)

* **mamba** → installed inside Conda
* **micromamba** → standalone binary (no Conda required)

👉 Most modern setups use **micromamba**.

---

## One-line intuition

> **Mamba is a fast environment and package manager that lets you create clean, reproducible development setups without dependency conflicts.**

---

# ⚡ Quick-Start Reference (TL;DR)

If you're in a hurry:

| Goal            | Command                                                                    |
| :-------------- | :------------------------------------------------------------------------- |
| **Install**     | `curl -Ls https://micro.mamba.pm/install.sh \| bash`                       |
| **Initialize**  | `micromamba shell init -s bash -p ~/micromamba`                            |
| **Create & Go** | `micromamba create -n dev python=3.12 numpy -y && micromamba activate dev` |

---

# 1. Overview

## What is Mamba?

Mamba is a **drop-in replacement for Conda** with:

* Faster dependency resolution (libsolv)
* Parallel downloads
* Full conda compatibility

## Variants

| Tool         | Description                     |
| ------------ | ------------------------------- |
| `mamba`      | Runs inside Conda               |
| `micromamba` | Standalone binary (recommended) |

👉 **Recommendation:** Use **micromamba** for minimal, portable setups.

---

# 2. Installation

## Linux / macOS

```bash
curl -Ls https://micro.mamba.pm/install.sh | bash
source ~/.bashrc  # or ~/.zshrc
```

## Windows (PowerShell)

```powershell
Invoke-Expression (Invoke-WebRequest -Uri https://micro.mamba.pm/install.ps1 -UseBasicParsing).Content
```

## Verify

```bash
micromamba --version
```

---

# 3. Shell Initialization

```bash
micromamba shell init -s bash -p ~/.micromamba
```

Other shells:

```bash
micromamba shell init -s zsh
micromamba shell init -s fish
```

Reload shell:

```bash
source ~/.bashrc
```

---

# 4. Configuration

## The "Golden" `.condarc`

```yaml
channels:
  - conda-forge
  - nodefaults
channel_priority: strict
auto_activate_base: false
show_channel_urls: true
```

### Why this matters

* **`conda-forge`** → consistent ecosystem
* **`nodefaults`** → prevents binary incompatibility with defaults
* **strict priority** → avoids solver conflicts

---

# 5. Environment Management

## Create

```bash
micromamba create -n myenv python=3.12
```

## Activate / Deactivate

```bash
micromamba activate myenv
micromamba deactivate
```

## List

```bash
micromamba env list
```

## Remove

```bash
micromamba remove -n myenv --all
```

---

# 6. Package Management

## Install

```bash
micromamba install numpy
```

## Update

```bash
micromamba update --all
```

## Remove

```bash
micromamba remove numpy
```

---

# 7. Reproducibility

## 7.1 Standard (Portable)

```bash
micromamba env export > environment.yml
micromamba create -f environment.yml
```

Minimal YAML (recommended):

```yaml
name: myenv
channels:
  - conda-forge
dependencies:
  - python=3.12
  - numpy
  - pandas
```

---

## 7.2 Production-Grade (Lockfile)

```bash
micromamba list --explicit > spec.txt
```

Recreate:

```bash
micromamba create -n myenv --file spec.txt
```

### Why?

* Exact binary URLs
* No dependency solving
* Faster + deterministic builds

---

# 8. Advanced Workflows

## Project-local environments

```bash
micromamba create -p ./env python=3.11
micromamba activate ./env
```

## Suggested project structure

```
project/
├── environment.yml
├── env/
└── src/
```

---

# 9. Integration

## VS Code

* `Ctrl + Shift + P`
* Select interpreter:

```
~/.micromamba/envs/myenv/bin/python
```

## Jupyter

```bash
micromamba install ipykernel
python -m ipykernel install --user --name myenv
```

---

# 10. Performance & Maintenance

## Clean cache

```bash
micromamba clean --all
```

## Offline usage

```bash
micromamba install --download-only numpy
micromamba install --offline numpy
```

---

# 💡 Pro-Tips for Power Users

### 1. Dependency Debugging

```bash
micromamba repoquery whoneeds <package>
```

Find what is pulling in large dependencies.

---

### 2. Using pip correctly

```bash
micromamba install pip
pip install --no-cache-dir <package>
```

* Always install pip via micromamba first
* Avoid mixing solvers unnecessarily

---

### 3. Conda Compatibility Alias

```bash
alias conda="micromamba"
```

Most commands are 1:1 compatible.

---

### 4. Repoquery (Advanced)

```bash
micromamba repoquery depends <package>
```

Understand dependency trees deeply.

---

# ⚠️ Common Gotchas

## 1. Shell Activation Issues

* `micromamba activate` requires shell hooks
* Fails in:

  * non-interactive shells
  * raw `sh` scripts

Fix:

```bash
eval "$(micromamba shell hook -s bash)"
```

---

## 2. Base Environment Misuse

🚫 Do NOT install packages in `base`

✔ Use it only for:

* micromamba itself
* global configuration

---

## 3. Mixing pip and conda

* Can break dependency resolution
* Always:

  1. Install via micromamba first
  2. Then use pip if needed

---

## 4. Channel Mixing

Mixing `defaults` and `conda-forge` leads to:

* ABI mismatches
* Broken environments

✔ Solution: use `nodefaults`

---

# 11. Example Setup Script (Dotfiles-Friendly)

```bash
#!/usr/bin/env bash

# install micromamba
curl -Ls https://micro.mamba.pm/install.sh | bash

# initialize shell
micromamba shell init -s bash -p ~/.micromamba

# configure
micromamba config append channels conda-forge
micromamba config set channel_priority strict
micromamba config set auto_activate_base false

# create dev environment
micromamba create -y -n dev python=3.12 git curl
```

---

# 12. Comparison

| Feature    | Conda  | Mamba | Micromamba |
| ---------- | ------ | ----- | ---------- |
| Speed      | Slow   | Fast  | Fastest    |
| Size       | Large  | Large | Tiny       |
| Standalone | No     | No    | Yes        |
| CI/CD      | Medium | Good  | Excellent  |

---

# 13. When to Use What

| Use Case       | Recommendation |
| -------------- | -------------- |
| Minimal setup  | Micromamba     |
| Existing conda | Mamba          |
| CI/CD          | Micromamba     |
| Beginner       | Conda          |

---

# 14. Cheat Sheet

```bash
# create
micromamba create -n env python=3.12

# activate
micromamba activate env

# install
micromamba install numpy

# export
micromamba env export > environment.yml

# recreate
micromamba create -f environment.yml

# remove
micromamba remove -n env --all
```

---

# Final Notes

Micromamba is:

* Fast
* Deterministic
* Script-friendly
* Ideal for reproducible environments

👉 If you're maintaining a config/dotfiles repo, this should be your **default environment manager**.

---
