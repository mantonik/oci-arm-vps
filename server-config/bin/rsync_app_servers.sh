#!/bin/bash
# Script to rsync servers 
# Script is installed in app1 server /root/bin folder 
# it will be trigger on changes in those folders 
# required folders to rsync
##################
# Vesrion 1.0
# 11/27/2021 inital version
######################################################
. /etc/profile
#SERVER_FARM=( demoapp1 demoapp2 demoapp3 demoapp4 )
SERVER_FARM=( demoapp2 demoapp3 demoapp4 )



SYNC_DIR=(
  /data/www/
  /etc/nginx/
  /etc/profile.d/

)

#Loop throw server list
for server in ${SERVER_FARM[@]}; do
  if [ $HOSTNAME != ${server} ]; then 
    echo "Sync to server "${server}

    if [ $1"x" == "x" ]; then
      #SYNC_FOLDER
      for DIR in ${SYNC_DIR[@]}; do
        echo "Sync directory: " ${DIR}
        rsync  -avr -e 'ssh -i /root/.ssh/id_rsa_rsync' ${DIR}  ${server}:${DIR}
        ssh -i /root/.ssh/id_rsa_rsyn ${server}  -t  "echo 'restart services'; systemctl restart php-fpm.service; systemctl restart nginx"
      done
    else
      rsync  -avr -e 'ssh -i /root/.ssh/id_rsa_rsync' $1  ${server}:$1
    fi
  fi
done

exit



