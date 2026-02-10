#!/bin/bash

# 1. Configuration
GITHUB_USER=$(gh api user -q .login)
GITLAB_USER=$GITHUB_USER 
BASE_DIR=$(pwd)
TEMP_DIR="$BASE_DIR/temp_mirror_work"

echo "Running Interactive Mirror in: $BASE_DIR"
mkdir -p "$TEMP_DIR"

# 2. Get Repo names and visibility
REPOS_DATA=$(gh repo list --limit 1000 --json name,visibility -q '.[] | "\(.name)\t\(.visibility)"' | tr '[:upper:]' '[:lower:]')

# 3. Use a different file descriptor (3) to avoid "eating" the repo list
while IFS=$'\t' read -u 3 -r REPO VISIBILITY; do
    [ -z "$REPO" ] && continue

    echo "==================================="
    # We force 'read' to look at /dev/tty (your keyboard) instead of the piped list
    read -p "Mirror '$REPO' ($VISIBILITY) to GitLab? [Y/n]: " -r RESPONSE < /dev/tty
    
    if [[ "$RESPONSE" =~ ^[Nn]$ ]]; then
        echo "Skipping $REPO..."
        continue
    fi

    # A. Create project on GitLab
    # Added --no-infrastructure back only if your glab version supports it, 
    # otherwise, this standard create is safer.
    glab repo create "$REPO" --"$VISIBILITY" --name "$REPO" --yes 2>/dev/null || echo "Note: $REPO already on GitLab."

    # B. Clone from GitHub
    if git clone --mirror "https://github.com/$GITHUB_USER/$REPO.git" "$TEMP_DIR/$REPO.git"; then
        cd "$TEMP_DIR/$REPO.git" || continue

        # C. Set GitLab target (HTTPS for campus network compatibility)
        git remote add gitlab "https://gitlab.com/$GITLAB_USER/$REPO.git"
        # --- LFS INTEGRATION START ---
        # Check if the repository uses LFS
        if git lfs ls-files &>/dev/null; then
            echo "LFS detected in $REPO. Fetching and pushing LFS objects..."
            git lfs fetch --all origin
            git lfs push --all gitlab
        fi
        # --- LFS INTEGRATION END ---
        echo "Pushing $REPO to GitLab..."
        git push --mirror gitlab

        # D. Clean up
        cd "$BASE_DIR" || exit
        rm -rf "$TEMP_DIR/$REPO.git"
    else
        echo "Error: Could not clone $REPO from GitHub."
    fi

done 3<<< "$REPOS_DATA"

# Final Cleanup
rm -rf "$TEMP_DIR"
echo "==================================="
echo "Backup Complete!"
