# 📘 Git Commands Reference

This document contains the Git commands used so far, organized by category.

---

# ⚙️ Setup & Config

## git config
**What it does:** Sets Git configuration like username and email.

**Example:**
git config --global user.name "Raghav"
git config --global user.email "raghav.cloudlearning@gmail.com"

## ssh-keygen

What it does: Generates a new SSH key for secure authentication.
Example:
ssh-keygen -t ed25519 -C "raghav.cloudlearning@gmail.com"

## git clone
What it does: Copies a remote repository to your local machine.
Example:
git clone git@github.com:dineshraghav22/90DaysOfDevOps.git


## git add
What it does: Adds changes to the staging area.
Example:
git add git-commands.md

## git commit
What it does: Saves staged changes with a commit message.
Example:
git commit -m "Added git commands documentation"

## git push
What it does: Uploads local commits to the remote repository.
Example:
git push origin main

##git pull
What it does: Fetches and merges changes from the remote repository.
Example:
git pull origin main

##git status
What it does: Shows the current state of the working directory and staging area.
Example:
git status

## git log
What it does: Displays commit history.
Example:
git log

## git diff
What it does: Shows changes between working directory and staging area.
Example:
git diff

## git branch
What it does: Lists or creates branches.
Example:
git branch
