#!/bin/sh
###

#export SUBSCRIPTION=""
#export SP_ID=""
#export SP_PASSWORD=""
#export SP_TENANT=""
#export CUSTOM_DOMAIN=""
#export UPSTREAM_DNS=""
valset=0
## check params 
if [ -z ${SUBSCRIPTION+x} ]; then echo "SUBSCRIPTION is unset";valset="1"; else echo " subscription is set to '$SUBSCRIPTION'"; fi

if [ -z ${SP_ID+x} ]; then echo "SP_ID is unset";valset="1"; else echo "SP_PASSWORD is set to '$SP_ID'"; fi

if [ -z ${SP_PASSWORD+x} ]; then echo "SP_PASSWORD is unset"; valset="1"; else echo "Vsubscription is set to '$SP_PASSWORD'"; fi

if [ -z ${SP_TENANT+x} ]; then echo "SP_TENANT is unset"; valset="1"; else echo "TENAT is set to '$SP_TENANT'"; fi

if [ -z ${CUSTOM_DOMAIN+x} ]; then echo "CUSTOM_DOMAIN is unset"; valset="1"; else echo "CUSTOM_CUSTOM_DOMAINN is set to '$SP_TENANT'"; fi

if [ -z ${UPSTREAM_DNS+x} ]; then echo "UPSTREAM_DNS is unset"; valset="1"; else echo "UPSTREAM_DNS is set to '$SP_TENANT'"; fi


if [ "$valset" -eq "1" ]; then
   echo "false";
   exit;
fi
echo loggin user 
## first backup previous configi

az login  --service-principal -u $SP_ID -p $SP_PASSWORD --tenant $SP_TENANT
az account set --subscription=$SUBSCRIPTION

while true; do echo 'Hit CTRL+C'; 
mv /etc/dnsmasq.conf /etc/dnsmasq.confi.bak
## sets set the template 
echo "refreshing custom domain $CUSTOM_DOMAIn"
echo "refreshing  upstream  upstream $CUSTOM_DNS"
 sed  "s/CUSTOMDOMAIN/$CUSTOM_DOMAIN/g" dnsmasq.conf.tmp > /etc/dnsmasq.conf
 sed  "s/UPSTREAM_DNS/$UPSTREAM_DNS/g" resolv.conf.upstream.tmp > /etc/resolv.conf.upstream

az vm list -d --query "[?provisioningState=='Succeeded'].{ ip: privateIps, rg: resourceGroup, name: name}"  -o table | awk -F" " '{print "address=/"$3"."$2".CUSTOM_DOMAIN/"$1 }' | tail -n+3  | sed "s/CUSTOM_DOMAIN/$CUSTOM_DOMAIN/g" >> /etc/dnsmasq.conf
#az vm list -d --query "[?provisioningState=='Succeeded'].{ ip: privateIps, rg: resourceGroup, name: name}"  -o table | awk -F" " '{print $1 " " $3"."$2"." $3 }' | tail -n+3 >> /etc/dnsmasq.conf
killall dnsmasq
dnsmasq
sleep 200
 
done











