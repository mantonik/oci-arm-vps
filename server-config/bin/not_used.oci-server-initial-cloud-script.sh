#!/bin/bash
# script will perform inital configuration and download setup file
#
# Version 
# 1.1 - add list of files to download
# 1.2 - add repo veriable 
#
# this file 
# export https_proxy=http://10.10.1.11:3128; wget https://raw.githubusercontent.com/mantonik/oci-always-free-high-availability/main/server-config/oci-server-initial-cloud-script.sh
# chmod 750 oci-server-initial-cloud-script.sh
# ./oci-server-initial-cloud-script.sh

export REPO=dev
mkdir $HOME/bin 
cd $HOME/bin  
#download instalation files 
wget https://raw.githubusercontent.com/mantonik/oci-always-free-high-availability/${REPO}/server-config/bin/02.server-instalation-script-app.sh  
chmod 750 *.sh
sudo -s
/home/opc/bin/02.server-instalation-script-app.sh | tee /var/log/server_setup.log
