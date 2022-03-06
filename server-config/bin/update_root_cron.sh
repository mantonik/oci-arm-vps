#!/bin/bash
#
# Version
# 1.0 - 1/8/2022 Initial version
# 1.1 - add check for root.cron.custom 
# 1.2 - fix loading issues
###################################################
#Script will udpate root.cron 

#To do:
# Check if script is running as root

########
version=1.2

cat /home/opc/cron/root.cron > /tmp/root.cron
if [ -e /home/opc/cron/root.cron.custom ]; then
  echo /home/opc/cron/root.cron.custom >> /tmp/root.cron
fi 
echo "---------------------------"
cat /tmp/root.cron 
echo "---------------------------"
echo "Update root crontab:"
crontab /tmp/root.cron
rm -f /tmp/root.cron 
echo "---------------------------"
sudo crontab -l
echo ""
echo "---------------------------"
echo "Version: ${version}"
echo "---------------------------"
# end 
