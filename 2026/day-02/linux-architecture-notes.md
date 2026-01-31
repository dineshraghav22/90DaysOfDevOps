## Core Components of Linux
- Works on ASK principle
### Kernel
- The core of the operating system
- Manages CPU, memory, devices, and system calls
- Acts as a bridge between hardware and software

### User Space
- Where user applications and tools run
- Includes shells, utilities, libraries, and services
- Interacts with the kernel through system calls

### Init / systemd
- The first process started by the kernel
- Has Process ID (PID) 1
- Responsible for starting and managing system services

## Process Creation and Management

- Processes are created using the `fork()` system call
- A new process gets a unique Process ID (PID)
- The kernel schedules processes using priority and time slices
- Processes can be in states like Running, Sleeping, Stopped, or Zombie
- Parent processes manage child processes

## What systemd Does and Why It Matters

- Initializes the system during boot
- Starts, stops, and manages services

# Linux Procss State
 - Running : Any time the process is in executable state
 - Sleepin : Waiting for event
 - Zombie : Hung process ,finished execution but not yet cleaned up
 - Stopped : finished execution

# 5 Commands We could use daily
   - free : To see memory available
   - cat :  To see content of file
   - lsblk : to list down block devices
   - scp : to copy/to get files or directory from one machine to another
   - mv : moving files from place to another or to rename the files/directory
   - other commands commonly used : ps, top, df, du, echo, sed, pwd, cd, chown, chmod