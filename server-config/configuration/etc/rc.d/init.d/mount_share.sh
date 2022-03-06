#!/bin/bash
#script will umount and then mount share folder 


umount -lf /mnt/share_app1
umount -lf /mnt/share_app2
umount -lf /mnt/share_app3
umount -lf /mnt/share_app4

#Mount share 


mount demoapp1:/share /mnt/share_app1
mount demoapp2:/share /mnt/share_app2
mount demoapp3:/share /mnt/share_app3
mount demoapp4:/share /mnt/share_app4
df -k