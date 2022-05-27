#! /bin/bash

ZABBIX_USER="Admin"
ZABBIX_PASS="zabbix"
ZABBIX_API="http://ip/api_jsonrpc.php"


ZABBIX_AUTH_TOKEN=$(curl -s -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${ZABBIX_USER}"\",\"password\":\""${ZABBIX_PASS}"\"},\"auth\": null,\"id\":0}" $ZABBIX_API |  jq -r .result)

GET_HOST_ID=$(curl -s -H 'Content-Type: application/json-rpc' -d "

{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.update\",
    \"params\": {
        \"hostid\": \"$1\",
        \"groups\": [
	{
      		\"groupid\":\"$2\"
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

RESULT=$(echo $GET_HOST_ID | grep -i "error" &> /dev/null ; echo $?)
TESTE=$(echo $GET_HOST_ID | jq .error.data)

if [ $RESULT -eq 0 ]; 
then
	echo "`date +%d-%m-%y_%H:%M:%S` $1: $TESTE" >> log.txt | tee < log.txt
else 
	echo "`date +%d-%m-%y_%H:%M:%S` $1: $GET_HOST_ID" >> log.txt
fi
