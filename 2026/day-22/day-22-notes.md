### What is the difference between git add and git commit?
 - git add: Adds changes to the staging area (preparing them to be committed)
 - git commit: To commit everything in the staging area, create a permanent snapshot of the changes
#### What does the staging area do? Why doesn't Git just commit directly?
 - Staging area : It is a buffer between the working directory and repository. Lets you select which changes to include in the next commit.
 - Why not commit directly?
    - Sometimes when we  modify multiple files but only want some of them in the next commit, Staging allows you to organize commits logically.
#### What information does git log show you?
 - git log displays commit history. For each commit, it shows: Commit hash (unique ID), Author, Date/time, Commit Message
#### What is the .git/ folder and what happens if you delete it?
- Important Files & Folders Inside .git/
 - HEAD : Points to the current branch.
  -  ref: refs/heads/master : This shows where its poiting
 - config : Stores repository-specific configuration (like remote URL).
 - objects :  This folder stores: All commits, All file versions, All tree, Git stores everything as objects.
    - we see many folders with random 2-character names like:
    - 1a/
    - 3f/
    - ab/
 These are SHA-1 hash prefixes.  

 - refs : It Contains: heads/ → branches , remotes/ → remote branches, tags/ → tags
  - Example: ls refs/heads, we see master, This stores the latest commit hash of the branch.
  And few more, will continue study .git more
#### What is the difference between a working directory, staging area, and repository?
- Working Directory : local files in active working copy; can modify files freely
- Staging Area (Index): selected changes we want to commit,Let us choose which changes to include
- Repository (.git/) : Committed snapshots of the project
