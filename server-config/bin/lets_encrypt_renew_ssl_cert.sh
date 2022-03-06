#!/bin/bash
#Script will renew SSL certificate and then update OCL LB 

. /etc/profile 

#Renew SSL certificat 

/usr/local/bin/certbot  certificates 

/usr/local/bin/certbot  certonly --force-renew

certbot-auto renew
certbot --force-renewal -d www.nixcraft.com,nixcraft.com

#certbot renew --deploy-hook ./oci-lb-cert-renewal.sh




