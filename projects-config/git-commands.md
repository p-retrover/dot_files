# Git commands cheatsheet

1. this creates a private repo and pushes the current git repo. (make sure you have gh)

```bash
gh repo create my-cv --private --source=. --remote=origin --push
```

2. if you accidentally deleted a branch, or a bad rebase, or want to recover lost commit (```bash git reset --hard ```) it's like your undo button.

```bash
git reflog

# then to go to a particular commit
git reset --hard HEAD@{index}

# if you see an entry in the reflog, but aren't sure, take a peek
git show HEAD@{index}

# if you want one specific commit from the reflog history to be applied to current branch , rather than moving your whole history back, use cherry-pick
git cherry-pick <commit-hash>
```
