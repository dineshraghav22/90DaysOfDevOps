[root@localhost ~]# df -h
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             4.8G     0  4.8G   0% /dev
tmpfs                4.8G     0  4.8G   0% /dev/shm
tmpfs                4.8G  393M  4.4G   9% /run
tmpfs                4.8G     0  4.8G   0% /sys/fs/cgroup
/dev/mapper/ol-root   62G   28G   31G  48% /
/dev/sda3            976M  216M  694M  24% /boot
/dev/sda1            599M  5.1M  594M   1% /boot/efi
tmpfs                968M     0  968M   0% /run/user/0
overlay               62G   28G   31G  48% /var/lib/docker/overlay2/b8f19706444df256588e3563abb56c1edd73dfb19a33d893e4fccde44453f671/merged
[root@localhost ~]# uname -r
5.4.17-2136.307.3.1.el8uek.x86_64
[root@localhost ~]# uname -a
Linux localhost.localdomain 5.4.17-2136.307.3.1.el8uek.x86_64 #2 SMP Mon May 9 17:29:47 PDT 2022 x86_64 x86_64 x86_64 GNU/Linux

[root@localhost ~]# lsblk 
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda           8:0    0   70G  0 disk 
├─sda1        8:1    0  600M  0 part /boot/efi
├─sda2        8:2    0 68.4G  0 part 
│ ├─ol-root 252:0    0 62.5G  0 lvm  /
│ └─ol-swap 252:1    0  5.9G  0 lvm  [SWAP]
└─sda3        8:3    0    1G  0 part /boot
sr0          11:0    1 10.6G  0 rom  
[root@localhost ~]# 

[root@localhost ~]# cat /etc/os-release 
NAME="Oracle Linux Server"
VERSION="8.6"
ID="ol"
ID_LIKE="fedora"
VARIANT="Server"
...
...



[root@localhost ~]# mkdir /tmp/demo
[root@localhost ~]# cp /etc/hosts /tmp/demo/
[root@localhost ~]# ls -l /tmp/demo/
total 4
-rw-r--r--. 1 root root 182 Feb  9 00:18 hosts
[root@localhost ~]# cat /tmp/demo/hosts 
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6


top command output:


top - 00:19:34 up 4 days,  2:26,  1 user,  load average: 0.28, 0.31, 0.28
Tasks: 235 total,   1 running, 234 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.2 us,  0.2 sy,  0.0 ni, 99.6 id,  0.0 wa,  0.1 hi,  0.1 si,  0.0 st
MiB Mem :   9671.3 total,   8429.4 free,    457.6 used,    784.3 buff/cache
MiB Swap:   6068.0 total,   6068.0 free,      0.0 used.   8575.4 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND                                         
1639368 root      20   0   65576   4932   4016 R   0.7   0.0   0:00.10 top                                             
    956 root      20   0  446204  12232  10180 S   0.3   0.1   8:16.75 vmtoolsd                                        
   1056 root      20   0  496396  34960  18436 S   0.3   0.4  24:56.60 tuned                                           
   1069 root      20   0 1649976  58816  33296 S   0.3   0.6  22:27.04 containerd                                      
1634476 root      20   0       0      0      0 I   0.3   0.0   0:00.39 kworker/5:11-events                             
1639357 root      20   0  356296 120176  29044 S   0.3   1.2   0:03.14 node                                            
      1 root      20   0  240776  13764   9080 S   0.0   0.1   9:27.92 systemd                                         
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.98 kthreadd                         
	  
	  
[root@localhost ~]# ps -o pid,pcpu,pmem,comm -p 1640045
    PID %CPU %MEM COMMAND
1640045 20.2  1.2 node

[root@localhost ~]# free -m
              total        used        free      shared  buff/cache   available
Mem:           9671         458        8472         392         740        8570
Swap:          6067           0        6067

[root@localhost ~]# journalctl -u sshd
-- Logs begin at Wed 2026-02-04 16:27:19 IST, end at Mon 2026-02-09 00:24:44 IST. --
Feb 04 21:53:16 localhost.localdomain systemd[1]: Starting OpenSSH server daemon...
Feb 04 21:53:16 localhost.localdomain sshd[1053]: Server listening on 0.0.0.0 port 22.
Feb 04 21:53:16 localhost.localdomain sshd[1053]: Server listening on :: port 22.
Feb 04 21:53:16 localhost.localdomain systemd[1]: Started OpenSSH server daemon.
Feb 05 20:17:26 localhost.localdomain sshd[371315]: Accepted password for root from 172.16.129.56 port 61388 ssh2
Feb 05 20:17:26 localhost.localdomain sshd[371315]: pam_unix(sshd:session): session opened for user root by (uid=0)
Feb 05 21:10:57 localhost.localdomain sshd[386401]: Accepted password for root from 172.16.129.56 port 59326 ssh2
Feb 05 21:10:57 localhost.localdomain sshd[386401]: pam_unix(sshd:session): session opened for user root by (uid=0)
Feb 07 00:27:39 localhost.localdomain sshd[832988]: Accepted password for root from 172.16.140.204 port 51228 ssh2
Feb 07 00:27:40 localhost.localdomain sshd[832988]: pam_unix(sshd:session): session opened for user root by (uid=0)
Feb 08 00:41:12 localhost.localdomain sshd[1236066]: Accepted password for root from 172.16.140.199 port 52602 ssh2
Feb 08 00:41:13 localhost.localdomain sshd[1236066]: pam_unix(sshd:session): session opened for user root by (uid=0)
Feb 09 00:14:27 localhost.localdomain sshd[1637753]: Accepted password for root from 172.16.140.200 port 54744 ssh2
Feb 09 00:14:28 localhost.localdomain sshd[1637753]: pam_unix(sshd:session): session opened for user root by (uid=0)