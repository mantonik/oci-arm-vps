#!/bin/bash 


showmount -e 192.168.1.12
mount -t nfs 10.10.1.12:/share /mnt/share_app1
mount -t nfs 10.10.1.12:/share /mnt/share_app2
mount -t nfs 10.10.1.13:/share /mnt/share_app3
mount -t nfs 10.10.1.14:/share /mnt/share_app4
