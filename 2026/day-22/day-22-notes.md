## Important Files & Folders Inside .git/

- HEAD : Points to the current branch.
 - ref: refs/heads/master : This shows where its poiting

- config : Stores repository-specific configuration (like remote URL).

- objects : 	
  - This folder stores: All commits, All file versions, All trees
  - Git stores everything as objects.
  - we see many folders with random 2-character names like:
    - 1a/
    - 3f/
    - ab/
    These are SHA-1 hash prefixes.  

- refs : It Contains: heads/ → branches , remotes/ → remote branches, tags/ → tags
 - Example: ls refs/heads, we see master, This stores the latest commit hash of the branch.
