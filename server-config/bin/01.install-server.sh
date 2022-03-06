#!/bin/bash
#Script will perform instalation of the app and db servers 
#Scritp should be executed as root user, 
# check if user is root

#Run main instalation on each server 
version=1.1

echo "Run instalation script"
sudo /home/opc/bin/02.server-instalation-script-app.sh

#Run DB instalation on app2 and app4 only 

if [ "$HOSTNAME" == *"app2"* ] || [ "$HOSTNAME" == *"app4"* ] ; then
  echo "Run MySQL server instalation "

fi

echo "---------------------------"
echo "Version: ${version}"
echo "---------------------------"
