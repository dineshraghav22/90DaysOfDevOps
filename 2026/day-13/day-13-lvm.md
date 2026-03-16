# Day 13 – Linux Volume Management (LVM)

## What is LVM?
LVM (Logical Volume Manager) adds a layer of abstraction over physical disks, letting you:
- Combine multiple disks into one pool (Volume Group)
- Create flexible "partitions" (Logical Volumes) that can be resized live
- Extend storage without downtime or repartitioning

**Stack:** Physical Volume (PV) → Volume Group (VG) → Logical Volume (LV) → Filesystem → Mount

---

## Existing LVM on This System

Before practice, checked the current setup:
```bash
lsblk
pvs
vgs
lvs
```

**Output:**
```
NAME        SIZE  TYPE  MOUNTPOINT
sda          30G  disk
├─sda1      600M  part  /boot/efi
├─sda2        1G  part  /boot
└─sda3     28.4G  part
  ├─ol-root 75.4G  lvm  /
  └─ol-swap   3G  lvm  [SWAP]
sdb          50G  disk
└─ol-root  75.4G  lvm  /

PV        VG  PSize    PFree
/dev/sda3 ol  28.41g   0
/dev/sdb  ol  50.00g   0

VG  #PV  #LV  VSize    VFree
ol    2    2  78.41g   0
```

The system already uses LVM: two physical disks (`sda3` + `sdb`) combined into VG `ol`, with a single 75GB logical volume for `/`.

---

## Hands-On Practice: Creating a New LVM Stack

### Task 1: Check Storage
```bash
lsblk        # shows disk tree
pvs          # physical volumes
vgs          # volume groups
lvs          # logical volumes
df -h        # filesystem usage
```

### Task 2: Create Virtual Disk (no spare disk available)
```bash
dd if=/dev/zero of=/tmp/disk1.img bs=1M count=1024
losetup -fP /tmp/disk1.img
losetup -a
# Output: /dev/loop0: [64512] (/tmp/disk1.img)
```
This creates a 1GB virtual disk device `/dev/loop0` — works exactly like a real disk for LVM purposes.

### Task 3: Create Physical Volume
```bash
pvcreate /dev/loop0
pvs
```
**Output:**
```
Physical volume "/dev/loop0" successfully created.
/dev/loop0    lvm2  ---    1.00g  1.00g
```

### Task 4: Create Volume Group
```bash
vgcreate devops-vg /dev/loop0
vgs devops-vg
```
**Output:**
```
VG         #PV  #LV  #SN  VSize    VFree
devops-vg    1    0    0  1020.00m  1020.00m
```

### Task 5: Create Logical Volume
```bash
lvcreate -L 500M -n app-data devops-vg
lvs devops-vg
```
**Output:**
```
LV        VG         Attr        LSize
app-data  devops-vg  -wi-a-----  500.00m
```

### Task 6: Format and Mount
```bash
mkfs.ext4 /dev/devops-vg/app-data
mkdir -p /mnt/app-data
mount /dev/devops-vg/app-data /mnt/app-data
df -h /mnt/app-data
```
**Output:**
```
Filesystem                        Size  Used  Avail  Use%  Mounted on
/dev/mapper/devops--vg-app--data  474M   14K   445M    1%  /mnt/app-data
```

### Task 7: Extend the Volume (Online — No Downtime!)
```bash
lvextend -L +200M /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data
df -h /mnt/app-data
```
**Output:**
```
Logical volume devops-vg/app-data changed from 500.00 MiB to 700.00 MiB.
Filesystem at /dev/devops-vg/app-data is mounted on /mnt/app-data; on-line resizing required

Filesystem                        Size  Used  Avail  Use%
/dev/mapper/devops--vg-app--data  668M   14K   631M    1%
```
Volume grew from 474M → 668M **while mounted and in use**. No service restart needed.

---

## Key Commands Reference

```bash
# Check existing setup
lsblk && pvs && vgs && lvs && df -h

# Create virtual disk (when no spare hardware)
dd if=/dev/zero of=/tmp/disk1.img bs=1M count=1024
losetup -fP /tmp/disk1.img

# LVM setup stack
pvcreate /dev/loop0                        # physical volume
vgcreate devops-vg /dev/loop0             # volume group
lvcreate -L 500M -n app-data devops-vg   # logical volume

# Format and mount
mkfs.ext4 /dev/devops-vg/app-data
mkdir -p /mnt/app-data
mount /dev/devops-vg/app-data /mnt/app-data

# Online resize
lvextend -L +200M /dev/devops-vg/app-data
resize2fs /dev/devops-vg/app-data
```

---

## What I Learned

1. **LVM enables live storage expansion** — you can add disk space to a mounted filesystem without unmounting or rebooting. This is critical for production database servers that can't have downtime.
2. **Virtual disks via loop devices** — `dd` + `losetup` lets you practice LVM without real hardware. The virtual device behaves identically to physical disks for LVM purposes.
3. **LVM is already everywhere in Linux** — this Oracle Linux system uses LVM for its root partition. Understanding it means you can manage system storage, not just application data.
