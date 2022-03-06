#!/bin/bash 
#Script will update OCI LB configuration with SSL certificate 

# 1. get LB OCIID
# 2. Create SSL certificate 
# 3. update SSL certificate for specific listener - domain listener which have a host listener define.

##########
## Version 
# 2/3/2022 - create script
# - fix while loop
# - fix x variable
# - add call to delete SSL cert script
#######

#export LB_OCIID="ocid1.loadbalancer.oc1.iad.aaaaaaaavl7ihlzsqcun4ojqj2nqk63siudt3c5aodazvhstb3v4cy46xtya"
export CERT_DT=`date +%Y%m%d_%H%M`

DOMAIN=$1

#Get LB_OCIID
#  sed 's/^.\{4\}//g

LB_OCIID=`cat /root/etc/oci_network.cfg|grep LB_OCIID:|sed 's/^.\{9\}//g' `

echo "Update SSL certificate in LB for domain: " ${DOMAIN}

cd /etc/letsencrypt/live/${DOMAIN}

oci lb certificate create --certificate-name  ${DOMAIN}.${CERT_DT} \
--load-balancer-id  ${LB_OCIID} \
--ca-certificate-file cert.pem  \
--private-key-file privkey.pem  \
--public-certificate-file fullchain.pem

#Update LB listener to use new certificate 
#echo "Wait 120s before next step. it will take some time to add certificate to LB configuration"
#sleep 120 # it takes minute or two for create certificate - may need also a query to list current available certificates
echo "Wait for certificate file to be added"
x=0
nr=0
while [ ${x} -lt 100 ]
do
  
  sleep 5
  #Check if certificate was added
  nr=`oci lb certificate list --load-balancer-id ${LB_OCIID}|grep  certificate-name|grep ${DOMAIN}.${CERT_DT}| wc -l `
  if [ ${nr} -gt 0 ]; then 
    break  
  fi
  echo -en "."
  x=$((x + 1))
done

echo ""
echo "Update LB with latest certificate"
oci lb listener update \
--default-backend-set-name bk-http \
--port 443 \
--protocol HTTP \
--load-balancer-id ${LB_OCIID} \
--listener-name LS-https \
--ssl-certificate-name  ${DOMAIN}.${CERT_DT} \
--routing-policy-name RP_LS_HTTPS \
--force

echo "Wait for certificate file to be active"
x=0
nr=0
while [ ${x} -lt 100 ]
do
  sleep 5
  #Check if certificate was added
  nr=`oci lb load-balancer get --load-balancer-id ${LB_OCIID}| jq -r '.data.listeners' |grep  certificate-name|grep ${DOMAIN}.${CERT_DT}| wc -l`
  if [ ${nr} -gt 0 ]; then 
    echo "Certificate update in Load Balancer"
    break  
  fi
  echo -en "."
  #x=`exp $x + 1`
  x=$((x + 1))
done
echo ""

#Delete not used SSL certificates
oci_lb_delete_not_used_certificates.sh

exit