#!/bin/bash

#e2fsck -f /dev/vgroot/lvroot

#e2fsck -f /dev/ocivolume
#civolume

#e2fsck -f /dev/ocivolume/oled
#e2fsck -f /dev/ocivolume/root

https://yallalabs.com/linux/how-to-reduce-shrink-the-size-of-a-lvm-partition-formatted-with-xfs-filesystem/

yum install xfsdump -y
xfsdump -f /tmp/test.dump /test


lvreduce -Ly 10G /dev/ocivolume/oled

resize2fs /dev/ocivolume/oled




I feel you can resize the LVM as below

Boot with rescue disk
Use resize2fs to shrink the filesystem
Use lvresize to shrink the logical volume
use pvresize to shrink the physical volume
At this stage you may have to use partition tools to reduce the partion to create free space
Once the new partition is created, use pvcreate to create new volume
use vgextend to extend your volume on /dev/sdb
use lvextend to extend the /var filesystem
I will suggest to try this on a trial system to avoid possible dataloss.

Do let me know if this procedure was helpful.



