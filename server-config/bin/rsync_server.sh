#!/bin/bash 
# script will sync configuration file with server 
#
# 1.0 1/8/2022 Initial version
# 1.1 add sync permissions, add update root crontab
# 1.2 - remove mount share mount during rsync of server
#
version=1.1

func_required_folders() {

    if [ ! -e $1 ]; then 
        echo "Create folder"
        mkdir -p $1
    fi 
}

# ref: https://askubuntu.com/a/30157/8698
if ! [ $(id -u) = 0 ]; then
   echo "The script need to be run as root." >&2
   exit 1
fi

if [ $SUDO_USER ]; then
    real_user=$SUDO_USER
else
    real_user=$(whoami)
fi


echo ""
echo "Rsync configuration folder wtih root file system"
rsync -rltDv --no-owner /home/opc/configuration/ /


#update root crontab 
/home/opc/bin/update_root_cron.sh

#Check for required folders
func_required_folders "/var/log/clamav"

#set permissions
/home/opc/bin/set_permissions.sh

#Update export nfs setting
exportfs -a

#restart mount
#/etc/init.d/mount_share.sh

echo "--- Completed ---"
echo "----------------------"
echo "Version: ${version}"
echo "----------------------"
# END
 