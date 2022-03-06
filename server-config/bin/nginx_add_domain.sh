#!/bin/bash
#Script will create basic configuration file for nginx webserver for provided domain name 
DOMAIN_NAME=$1
if [ ${DOMAIN_NAME}"x" == "x" ]; then 
  echo "Enter as parameter a domain name"
  exit
fi

#Check if this is domain or subdomain 
num = `expr match ${DOMAIN_NAME} [.]`
echo "Numbers of the \".\": $num"


#Create folder structure for domain 
# Set space as the delimiter
IFS='.'

#Read the split words into an array based on space delimiter
read -a DOMAIN_NAME_ARRAY <<< "${DOMAIN_NAME}"

IFS='|'
#Count the total words
echo "There are ${#DOMAIN_NAME_ARRAY[*]} words in the text."
#last two words use as domain 
#remaining use as a subdomains
i=${#DOMAIN_NAME_ARRAY[*]}
SUBDOMAIN=""
DOMAIN=""
 
for val in "${DOMAIN_NAME_ARRAY[@]}";
do
  printf "$val\n"
  if [ ${i} -eq 4 ]; then 
    SUBDOMAIN=${val}"."
  elif [ ${i} -eq 3 ]; then 
    SUBDOMAIN="${SUBDOMAIN}${val}"
  elif [ ${i} -eq 2 ]; then 
    DOMAIN=${val}
  elif [ ${i} -eq 1 ]; then
    DOMAIN="${DOMAIN}.${val}"
  fi

  

  #echo "Subdoman: " ${SUBDOMAIN}
  #echo "Domain:   " ${DOMAIN}
  #echo "i: " ${i}
  #echo "-----"
  i=`expr ${i} - 1`
done

set +x 

echo "Subdoman: " ${SUBDOMAIN}
echo "Domain:   " ${DOMAIN}

#Define ROOT-DIR-PATH
#DOMAIN-NAME

if [ ${SUBDOMAIN}"x" != "x" ]; then 
  ROOT_DIR=/data/www/subdomain/${DOMAIN}/${SUBDOMAIN}/htdocs
else
  ROOT_DIR="/data/www/domain/${DOMAIN}/htdocs"
fi
#copy sample file to confg file 
CONF_FILE=/etc/nginx/conf.d/${DOMAIN_NAME}.conf
cp /etc/nginx/conf.d/0.sample.conf.txt ${CONF_FILE}

sed -i "s|DOMAIN-NAME|${DOMAIN_NAME}|g" ${CONF_FILE}
sed -i "s|ROOT-DIR-PATH|${ROOT_DIR}|g" ${CONF_FILE}

mkdir -p ${ROOT_DIR}
echo "${DOMAIN}" > ${ROOT_DIR}/test.html

/home/opc/bin/set_permissions.sh
#restart nginx
systemctl restart nginx

#sync configuration to remaining server 
rsync_app_server.sh

echo "Completed"
exit