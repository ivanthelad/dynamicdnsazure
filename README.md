# dynamicdnsazure
DNS service that discovers all servers deployed under a subscription and dynamically manages a dnsmasq instance. The goal is to allow to provide a dns service on a private network

The container runs a DNSMasq instance and a basic process that queries the azure api for available servers. 
 - any queries that it cannot service are set to either the azure upstream dns or another configurable dns server (on premises upstream dns)

The purpose of this project is make it easier to implement the following dns forwarded concepts outlined in Azure documentation. This container is not dependant on persistent storage or any state. it can be started and stopped as many times as needed. The container will always discover its configuration from the Azure API.

https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances
https://github.com/Azure/azure-quickstart-templates/tree/master/301-dns-forwarder

## Parameters and configuration 
The container is configured using environment varaibles 

### SUBSCRIPTION 
The subscription where the the servers are running.  
To get the subscription id execute ```az account list -o table``

### SP_ID
the serivce principle app_id. The service principle is used to query the api for the VM ip addresses. To create a new Service principle that only has readonly rights 

``` az ad sp create-for-rbac --role=Reader ```
this command will output  the following. Where app_id can is passed as the SP_ID environment variable. It is recommend to note the information down 
```
{
  "appId": "XXXXXXX",
  "displayName": "XXXXX",
  "name": "XXXXX",
  "password": "XXXXXXX",
  "tenant": "XXXXXXX"
}
```
For more info on service principle creation see https://docs.microsoft.com/en-us/cli/azure/ad/sp#create-for-rbac

### SP_PASSWORD
This is the password of the service principle output from the previous step 
### SP_TENANT
This is the TENANT of the service principle output from the previous step 

### CUSTOM_DOMAIN
This is the custom domain that the container applies to all discovered vms. The current format uses a combination of vmname, resourcegorup and CUSTOM_DOMAIN. 
For example a vm called "testvm" running in "testgroup" with a CUSTOM_DOMAIN=myapps.com will take the following format

- $vmname.$resourcegorup.$CUSTOM_DOMAIN
and result in 
- testvm.tesgroup.myapps.com

#### note: currently this only a poc. the building of domains may change in the future 

### UPSTREAM_DNS
The parmater is a configurable upstream dns server. This parameter can be used to tell the server to forward any queries it cannot resolve to an upstream dns server. 
ideal use case is forwarding requests from the cloud vms to an onpremise dns service 



## Running using docker

to run uisng plain old simle docker the following 
```
docker run   --privileged -p 0.0.0.0:53:53 \
            -e SUBSCRIPTION=XXXXXXX \
            -e SP_ID=XXXXXXX \
            -e SP_PASSWORD=XXXXXXX \
            -e SP_TENANT=XXXXXX \
            -e CUSTOM_DOMAIN=mycustom.domain \
            -e UPSTREAM_DNS=8.8.8.8  --net=host dynamicdnsazure
```
### Running using Azure Container Services. Recommended 
#### Note: the environment variables are passed with space seperated values
#### Note: Currently deploying in azure container instances does not function as expected, possible due to a issue with UDP port not been exposed. please deploy with a docker enabled vm 
```
az container create --image=ivmckinl/dynamicdnsazure:latest \
			--location=westeurope \
			--name=mydnsservice \
			--resource-group=dynamicdns \
			--port=53 \
			--ip-address=public \
			-e SUBSCRIPTION=XXXXx \
			   SP_ID=XXXXXXX \
                           SP_PASSWORD=XXXXX \
                           SP_TENANT=XXXX \
                           CUSTOM_DOMAIN=mehe.en \
			   UPSTREAM_DNS=8.8.8.8
```
