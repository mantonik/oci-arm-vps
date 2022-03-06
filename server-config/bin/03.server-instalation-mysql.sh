#!/bin/bash
# #Script is executed as root user
# 1/16/2022 - add more comments to script. script didn't executed on app2 server 
#   fix if condition
#   remove server_id entry before adding new entry
# #Remvoe MySQL server first if neede d
# dnf remove mysql-server
# rm -rf /var/lib/mysql
# 2/20/2022 - add debug for create repusr



set +x 

LOGFILE=/root/log/mysql.setup.log

##################
# FUNCTION
##################
function mysql_create_repusr() {
  #set -x
  #mysql --login-path=r3306 -e "GRANT REPLICATION SLAVE, REPLICATION_SLAVE_ADMIN, SUPER, REPLICATION CLIENT ON *.* TO 'repusr'@'10.10.1.0/24' IDENTIFIED BY '${REPUSRMYQLP}';" 
  
  sed -e "s/REPUSRMYQLP/${REPUSRMYQLP}/g" /home/opc/sql/create.repusr.template.sql > /home/opc/sql/create.repusr.sql
  chown opc /home/opc/sql/create.repusr.sql
  ehco "----"
  cat  /home/opc/sql/create.repusr.sql
  echo ""
  #mysql --login-path=r3306 < /home/opc/sql/create.repusr.sql

  mysql -u root < /home/opc/sql/create.repusr.sql

  #echo "dipsplay master status as repusr"
  #mysql -u repusr -p${REPUSRMYQLP} -e "show master status \G"
  #echo ""

  MASTER_STATUS_FILE=/share/mysql_${HOSTNAME: -4}_master_status.txt
  mysql -u root -e "show master status;" > ${MASTER_STATUS_FILE}
  sed -e 's/\t/ /g' -i ${MASTER_STATUS_FILE}
  chmod 666 ${MASTER_STATUS_FILE}
  #set +x
  echo "Finish - mysql_create_repusr"
}



function mysql_set_replication (){
  #BINLOG_STATUS_FILE=$1
  export APP2_HOSTNAME=${HOSTNAME::-1 }"2"
  echo "APP2_HOSTNAME: " ${APP2_HOSTNAME}REPUSRMYQLP

  echo "'"
  echo "--- Set replication - app4"
  echo "'"

  BINLOG_LINE=`cat /mnt/share_app2/mysql_app2_master_status.txt |grep "binlog."`
  BINLOG_FILE=${BINLOG_LINE:0:13}
  BINLOG_POSITION=${BINLOG_LINE:14}
  echo "app2 mysql master configuration"
  echo "binlog file:" ${BINLOG_FILE}
  echo "binlog position:" ${BINLOG_POSITION}
  echo "repusr password:" ${REPUSRMYQLP}

echo "Configure replication on APP4 Servver - master is app2"
mysql -u root -e "CHANGE REPLICATION SOURCE TO
SOURCE_HOST='${APP2_HOSTNAME}',
SOURCE_USER='repusr',
SOURCE_PASSWORD='${REPUSRMYQLP}',
SOURCE_LOG_FILE='${BINLOG_FILE}',
SOURCE_LOG_POS=${BINLOG_POSITION};
start slave;
show slave status\G;
"
sleep 5
echo "--------------"
echo "Display replication status on the APP4 server "
mysql -u root  -e "show slave status\G;"
echo "--------------"

  echo ""
  echo "set replication app2"

  BINLOG_LINE=`cat /share/mysql_app4_master_status.txt |grep "binlog."`
  BINLOG_FILE=${BINLOG_LINE:0:13}
  BINLOG_POSITION=${BINLOG_LINE:14}
  echo "binlog file:" ${BINLOG_FILE}
  echo "binlog position:" ${BINLOG_POSITION}
  echo "repusr password:" ${REPUSRMYQLP}
  echo "app2 hostname: " ${APP2_HOSTNAME}

mysql -u repusr  -p${REPUSRMYQLP}  -h ${APP2_HOSTNAME} -e "stop slave;
CHANGE REPLICATION SOURCE TO
SOURCE_HOST='${HOSTNAME}',
SOURCE_USER='repusr',
SOURCE_PASSWORD='${REPUSRMYQLP}',
SOURCE_LOG_FILE='${BINLOG_FILE}',
SOURCE_LOG_POS=${BINLOG_POSITION};
start slave;
show slave status\G;
"
sleep 5
echo "--------------"
echo "Display replication status on APP2 server"
mysql -u repusr  -p${REPUSRMYQLP}  -h ${APP2_HOSTNAME} -e "show slave status\G;"

echo "Finish - function mysql_set_replication"
echo "------------"
}

function update_mysql_root_password() {
  echo "Update MySQL Root Passowrd"
  
  export ROOTMYQL=`cat /mnt/share_app2/.my.p|grep root`
  export ROOTMYQLP=${ROOTMYQL:5}
  echo "----------------------------"
  echo "ROOTMYQLP: "${ROOTMYQLP}
  echo "----------------------------"
  mysql -u root -v -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOTMYQLP}';"
  echo "Display databases"
  mysql -u root -v -p${ROOTMYQLP} -e "show databases;"
  echo "MySQL root passwrod updated"

  #set login path
  set_root_login_path

  echo "Finish - update_mysql_root_password"
}


function set_root_login_path() {

  echo "Set Root login-path"
  export ROOTMYQL=`cat /mnt/share_app2/.my.p|grep root`
  export ROOTMYQLP=${ROOTMYQL:5}
  echo "Type root passwrod below: "${ROOTMYQLP}
  mysql_config_editor set --login-path=r3306 -u root -p --socket=/var/lib/mysql/mysql.sock

  echo "Validate login path"
  mysql --login-path=r3306 -e "show databases;"
  
  echo "-------------------------------------"
  echo "Login to mysql server as root"
  echo "sudo -s"
  echo "mysql --login-path=r3306 "
  echo ""
  echo "Set login path if you change passwrod as to local server"
  echo "mysql_config_editor set --login-path=r3306 -u root -p --socket=/var/lib/mysql/mysql.sock"
  echo "-------------------------------------"
  echo "Finish - set_root_login_path"
}



##################
# Main
##################


#Install MySQL on app2 and app4
if [[ "$HOSTNAME" == *"app1"* ]] || [[ "$HOSTNAME" == *"app3"* ]] ; then
  echo "This is not Desing to run on app1 or app3"
  echo "Please run this script on app2 and app4 for MySQL instance"
  exit
fi

#mount share drive 
if [[ "$HOSTNAME" == *"app2"* ]]  ; then
  echo "mount app2 share"
  mount -t nfs 10.10.1.12:/share /mnt/share_app2
fi

if [[ "$HOSTNAME" == *"app4"* ]] ; then
  mount -t nfs 10.10.1.14:/share /mnt/share_app4
  mount -t nfs 10.10.1.12:/share /mnt/share_app2
fi


echo "Host app2 or app4 - install MySQL"
dnf install -y mysql-server 
#Update configuration of the server 
#sed -i '/^server-id=/d' /etc/my.cnf.d/mysql-server.cnf
#echo "server-id="${HOSTNAME: -1} >> /etc/my.cnf.d/mysql-server.cnf

#Copy configuration files 
cd /etc/my.cnf.d
if [[ "$HOSTNAME" == *"app2"* ]]  ; then
  \cp /etc/my.cnf.d/mysql-server.cnf.app2 /etc/my.cnf.d/mysql-server.cnf
fi

if [[ "$HOSTNAME" == *"app4"* ]] ; then
  \cp /etc/my.cnf.d/mysql-server.cnf.app4 /etc/my.cnf.d/mysql-server.cnf
fi

echo "----"
echo "mysql-server.cnf file"
cat /etc/my.cnf.d/mysql-server.cnf

echo "Start MySQLD"
systemctl start mysqld

#Installing on server 2
#Generate root and usrrep passwrod and put files on share point and in root file 
# .private 
# .private/my.p
# root:PASSWORD
# repusr:PASSWORD

#Create random string for root and repusr
echo "Create .private folder to store root password"
mkdir ~/.private
chmod 700 ~/.private

#rm -f /share/.my.p

#Run this only on app2 server
echo "Exeucte on specific server"
if [[ "$HOSTNAME" == *"app2"* ]]; then 

  echo "Execute on app2 server"

  echo "Generate root and repusr password"
  ROOTMYQLP=`tr -dc A-Za-z0-9 </dev/urandom | head -c 20`
  export ROOTMYQLP="${ROOTMYQLP:1:8}1Yk"
  REPUSRMYQLP=`tr -dc A-Za-z0-9 </dev/urandom | head -c 20`
  export REPUSRMYQLP="${REPUSRMYQLP:6:8}4hD"

  echo "root:${ROOTMYQLP}" > ~/.private/.my.p
  echo "repusr:${REPUSRMYQLP}" >> ~/.private/.my.p
  chmod 400 ~/.private/.my.p

  cp ~/.private/.my.p /share
  chmod 666 /share/.my.p
  cat /share/.my.p

  echo "Execute create repusr"
  mysql_create_repusr

  #Update root passwrod for MySQL instance
  echo "Update root passwrod for MySQL instance"
  update_mysql_root_password



elif [[ "$HOSTNAME" == *"app4"* ]]; then 
  echo "Exeucte on app4 server"
  #Create copy of the password file 
  cp /mnt/share_app2/.my.p ~/.private
  chmod 400 ~/.private/.my.p

  #Read slave passwrod from share drive
  export REPUSRMYQL=`cat /mnt/share_app2/.my.p|grep repusr`
  export REPUSRMYQLP=${REPUSRMYQL:7}
  echo "REPUSRMYQL: "${REPUSRMYQL}
  echo "REPUSRMYQLP: "${REPUSRMYQLP}
  
  #Craete replication user
  mysql_create_repusr

  #Set replication on app4
  mysql_set_replication

  #Set root login-path
  #Once replication start root user password should be replicated from app2 as it was set after repuser account
  set_root_login_path

else
  echo "Error - script executed on wrong server, please delete MySQL from this server"
fi



#   mysql -u root -e "select user,host from mysql.user;"
#   mysql -u root -e "stop slave; start slave;show slave status\G;"
#   mysql -u root -e "show slave status\G;"
#   mysql -u repusr -p${REPUSRMYQLP} -h demoapp2
# mysql -u repusr -p${REPUSRMYQLP} -h demoapp4



