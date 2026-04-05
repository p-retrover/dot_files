# Git History Cleanup Guide

A guide for purging Git history, whether resetting a repository to a "fresh" state or removing sensitive files/secrets from the commit log.

> [!CAUTION]
> **Warning:** These operations are **destructive** and rewrite Git history. Always backup your repository locally before proceeding.

---

## Quick Reference: Which Method?

| Goal | Method | Use Case |
| --- | --- | --- |
| **Start Repo Clean** | [A) Orphan Branch](https://www.google.com/search?q=%23a-delete-all-git-history-keep-current-code) | Creating a "v1.0" from a messy dev history. |
| **Remove Data / Keys** | [B) git-filter-repo](https://www.google.com/search?q=%23b-remove-specific-files-from-git-history) | Deleting leaked `.env` files or heavy binaries. |
| **Undo Recent Work** | `git reset` | Fixing a mistake in the last few commits (not covered here). |

---

## A) Delete ALL Git history (Keep current code)

This resets the repository to a single "Initial commit" while preserving your current file structure.

### 1. Create a new orphan branch

An orphan branch has no parents and no history.

```bash
git checkout --orphan fresh-start

```

### 2. Add and commit everything

```bash
git add .
git commit -m "Initial commit"

```

### 3. Delete the old branch

*(Replace `main` with `master` if necessary)*

```bash
git branch -D main

```

### 4. Rename the current branch to main

```bash
git branch -m main

```

### 5. Force-push to remote

```bash
git push -f origin main

```

**Result:** The remote repository now shows only one commit.

---

## B) Remove specific files from Git history

Use this to scrub sensitive data (API keys, `.env`) or large files from every single commit in the repo's past.

### 1. Install `git-filter-repo`

On Fedora:

```bash
sudo dnf install git-filter-repo

```

### 2. Remove file/folder from all history

Use the `--invert-paths` flag to tell Git to keep everything *except* the specified path.

**Example: Remove a directory**

```bash
git filter-repo --path data/ --invert-paths

```

**Example: Remove a specific secrets file**

```bash
git filter-repo --path .env --invert-paths

```

### 3. Force-push rewritten history

```bash
git push --force --all
git push --force --tags

```

> [!IMPORTANT]
> **If secrets were leaked:** Rewriting history does not "un-leak" them. **Rotate your keys immediately.** Assume any credential previously committed has been compromised.

---

## Sanity Check

After performing either cleanup, verify the history length:

```bash
git log --oneline

```

* **For Method A:** You should see exactly one commit.
* **For Method B:** The files should be gone from the log, but your commit count may remain similar.

---
