# SupplyFlow Git Practical Guide

This document provides practical guidance for common Git scenarios that developers might encounter while working on the SupplyFlow project.

## Table of Contents

1. [Setting Up Your Environment](#setting-up-your-environment)
2. [Daily Development Workflow](#daily-development-workflow)
3. [Common Scenarios](#common-scenarios)
4. [Troubleshooting](#troubleshooting)
5. [Git Commands Cheat Sheet](#git-commands-cheat-sheet)

## Setting Up Your Environment

### Initial Repository Setup

```bash
# Clone the repository
git clone https://github.com/your-org/supplyflow.git
cd supplyflow

# Set up your user information
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Add the upstream remote if you're working on a fork
git remote add upstream https://github.com/original-org/supplyflow.git
```

### Git Configuration for the Project

Create a `.gitconfig` file in your home directory with the following settings:

```
[core]
    editor = code --wait
    autocrlf = input
    
[pull]
    rebase = true
    
[push]
    default = current
    
[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    unstage = reset HEAD --
    last = log -1 HEAD
```

## Daily Development Workflow

### Starting Your Day

```bash
# Switch to develop branch
git checkout develop

# Get the latest changes
git pull origin develop

# Create a new feature branch
git checkout -b feature/123-feature-name

# Start coding!
```

### During Development

```bash
# Check what files you've changed
git status

# See your changes
git diff

# Stage specific files
git add file1.rb file2.rb

# Stage all changes
git add .

# Commit your changes
git commit -m "feat(module): add feature xyz"

# Push your branch to remote
git push -u origin feature/123-feature-name
```

### Keeping Your Branch Updated

```bash
# Save your current work
git stash

# Update develop
git checkout develop
git pull origin develop

# Return to your branch
git checkout feature/123-feature-name

# Rebase on develop
git rebase develop

# Restore your work
git stash pop

# Force push if you've already pushed your branch
git push --force-with-lease origin feature/123-feature-name
```

### Finishing a Feature

1. Push your final changes
   ```bash
   git push origin feature/123-feature-name
   ```

2. Create a Pull Request in GitHub

3. Address review feedback
   ```bash
   # Make changes
   git add .
   git commit -m "fix(module): address PR feedback"
   git push origin feature/123-feature-name
   ```

4. After approval and merge, clean up
   ```bash
   git checkout develop
   git pull origin develop
   git branch -d feature/123-feature-name
   ```

## Common Scenarios

### Scenario 1: Combining Multiple Commits Before PR

```bash
# Interactive rebase to squash commits
git rebase -i HEAD~3  # Replace 3 with the number of commits to include

# In the editor, change 'pick' to 'squash' or 's' for commits to combine
# Save and close the editor
# In the next editor, update the commit message
# Save and close

# Force push to update remote
git push --force-with-lease origin feature/123-feature-name
```

### Scenario 2: Resolving Merge Conflicts

```bash
# During a rebase with conflicts
git status  # See which files have conflicts

# Edit the files to resolve conflicts
# Look for markers like <<<<<<< HEAD, =======, and >>>>>>>

# After resolving
git add .
git rebase --continue

# If you want to abort
git rebase --abort
```

### Scenario 3: Temporarily Switching Tasks

```bash
# Save current work
git stash save "WIP: Feature XYZ implementation"

# Switch to another branch
git checkout other-branch

# Do other work...

# Return to original branch
git checkout feature/123-feature-name

# Restore your work
git stash pop
```

### Scenario 4: Undoing Changes

```bash
# Undo staged changes for a file
git reset HEAD file.rb

# Discard changes in working directory
git checkout -- file.rb

# Undo the last commit but keep changes staged
git reset --soft HEAD^

# Undo the last commit and discard changes
git reset --hard HEAD^

# Undo a pushed commit (creates a new commit that reverses changes)
git revert HEAD
```

### Scenario 5: Cherry-Picking Commits

```bash
# Get the commit hash
git log

# Cherry-pick a specific commit
git cherry-pick abc123def

# Cherry-pick without committing
git cherry-pick -n abc123def
```

## Troubleshooting

### Issue: "Your local changes would be overwritten by merge"

```bash
# Option 1: Stash changes
git stash
git pull
git stash pop

# Option 2: Commit changes
git commit -m "WIP: Saving changes before pull"
git pull
```

### Issue: Accidentally Committed to Wrong Branch

```bash
# Get the commit hash
git log -1

# Create a new branch with the current state
git branch feature/correct-branch

# Reset the current branch
git reset --hard HEAD^

# Switch to the correct branch
git checkout feature/correct-branch
```

### Issue: Need to Undo a Merge

```bash
# If the merge is the last commit
git reset --hard HEAD^

# If the merge is already pushed
git revert -m 1 <merge-commit-hash>
```

### Issue: Accidentally Pushed Sensitive Information

```bash
# Remove the sensitive file from git but keep it locally
git rm --cached sensitive_file.txt

# Commit the removal
git commit -m "Remove sensitive file"

# Push the change
git push origin your-branch

# Add to .gitignore
echo "sensitive_file.txt" >> .gitignore
git add .gitignore
git commit -m "Add sensitive file to gitignore"
git push origin your-branch

# IMPORTANT: Contact the repository admin to purge the file from git history
```

## Git Commands Cheat Sheet

### Basic Commands

```bash
git init                  # Initialize a new repository
git clone <url>           # Clone a repository
git status                # Check status
git add <file>            # Stage a file
git commit -m "message"   # Commit changes
git pull                  # Fetch and merge changes
git push                  # Push changes to remote
```

### Branch Management

```bash
git branch                # List branches
git branch <name>         # Create a branch
git checkout <branch>     # Switch to a branch
git checkout -b <branch>  # Create and switch to a branch
git merge <branch>        # Merge a branch into current branch
git branch -d <branch>    # Delete a branch
```

### History and Differences

```bash
git log                   # View commit history
git log --oneline         # Compact history view
git diff                  # View changes
git diff --staged         # View staged changes
git blame <file>          # See who changed what in a file
```

### Remote Operations

```bash
git remote -v             # List remotes
git remote add <name> <url> # Add a remote
git fetch <remote>        # Fetch from remote
git pull <remote> <branch> # Pull from remote
git push <remote> <branch> # Push to remote
```

### Advanced Operations

```bash
git rebase <branch>       # Rebase current branch onto another
git stash                 # Stash changes
git stash pop             # Apply stashed changes
git cherry-pick <commit>  # Apply a commit from another branch
git tag <name>            # Create a tag
git reset --hard <commit> # Reset to a specific commit
```

---

Remember that Git is a powerful tool, and there are many ways to accomplish the same task. This guide covers common scenarios, but feel free to adapt these workflows to your specific needs. If you're unsure about a Git operation, especially one that might modify history, ask for help from a team member.
