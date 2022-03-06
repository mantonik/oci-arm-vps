#!/bin/bash


sudo dnf -y erase nginx php php-fpm php-mysqlnd php-json sendmail htop \
tmux mc rsync clamav clamav-update rclone \
setroubleshoot-server setools-console nfs-utils squid \
mysql-server 

echo "End uninstall all packages"
echo "----"

