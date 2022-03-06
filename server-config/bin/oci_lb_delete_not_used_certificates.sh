
#!/bin/bash 
# Script will delete all not used SSL certificates.
#
# 2/3/2022 createa script 
#
#

LB_OCIID=`cat /root/etc/oci_network.cfg|grep LB_OCIID:|sed 's/^.\{9\}//g' `
#Get active SSL certificate 

ACTIVE_CERT=`oci lb load-balancer get --load-balancer-id ${LB_OCIID}| jq -r '.data.listeners' |grep  certificate-name|tr -s " "|cut -d" " -f 3|sed 's/,//g'|sed 's/"//g'`

#list of all SSL certificates
oci lb certificate list --load-balancer-id ${LB_OCIID}|grep  certificate-name |grep -v ${ACTIVE_CERT}|cut -d: -f2|tr -s " "|sed 's/,//g'|sed 's/"//g'|sed 's/ //g'|
while read CERT
do
  echo "Delete certificat: " ${CERT}
  oci lb certificate delete --load-balancer-id ${LB_OCIID} --certificate-name ${CERT} --force
  sleep 5
done
echo "Wait 15s for delete process to complete"
sleep 15
echo ""
echo "List of available certificates in LB"
oci lb certificate list --load-balancer-id ${LB_OCIID}|grep  certificate-name

echo ""
exit
