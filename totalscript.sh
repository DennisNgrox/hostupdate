#! /bin/bash

ZABBIX_USER="Admin"
ZABBIX_PASS="zabbix"
ZABBIX_API="http://192.168.126.139/api_jsonrpc.php"

ZABBIX_AUTH_TOKEN=$(curl -s -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${ZABBIX_USER}"\",\"password\":\""${ZABBIX_PASS}"\"},\"auth\": null,\"id\":0}" $ZABBIX_API |  jq -r .result)

GET_HOST_ID=$(curl -s -H 'Content-Type: application/json-rpc' -d "

{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.get\",
    \"params\": {
        \"filter\": {
            \"host\":[
                \"$1\"
            ]
        }
    },
    \"auth\": \"${ZABBIX_AUTH_TOKEN}\",
    \"id\": 1
}" ${ZABBIX_API} | jq . | egrep -i '"hostid":'|cut -d\: -f2 | sed 's/"host": //g' | sed 's/"//g' | sed 's/,//g' | sed 's/[[:space:]]//g'
)
    
    GROUP_ID=$(curl -s -H 'Content-Type: application/json-rpc' -d "

 {
    \"jsonrpc\": \"2.0\",
    \"method\": \"hostgroup.get\",
    \"params\": {
        \"output\": \"extend\",
        \"filter\": {
            \"name\": [
                \"$2\"
            ]
        }
    },
        \"auth\": \"${ZABBIX_AUTH_TOKEN}\",
        \"id\": 1

    }" ${ZABBIX_API} | jq . | grep "groupid" | cut -d: -f2 | sed 's/"//g' | sed 's/,//g' | sed 's/[[:space:]]//g'
)


SAIDA=$(curl -s -H 'Content-Type: application/json-rpc' -d "

{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.update\",
    \"params\": {
        \"hostid\": \"${GET_HOST_ID}\",
        \"groups\": [
        {
                \"groupid\":\"${GROUP_ID}\"
        }
        ],
        \"tags\": {
            \"tag\": \"Host-App\",
            \"value\": \"$3\"
        }
    },
    \"auth\": \"${ZABBIX_AUTH_TOKEN}\",
    \"id\": 1
}" ${ZABBIX_API}
)

echo $SAIDA


 for i in $(cat listinha); do HOST_ID=$(echo $i | cut -d\; -f1) ; GRUPO_ID=$(echo $i | cut -d\; -f2); TAG=$(echo $i | cut -d\; -f3); ./miyagi.sh ${HOST_ID} ${GRUPO_ID} ${TAG}; done
