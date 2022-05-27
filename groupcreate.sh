#!/bin/bash

ZABBIX_USER=""
ZABBIX_PASS=""
ZABBIX_API="http://ip/api_jsonrpc.php"


ZABBIX_AUTH_TOKEN=$(curl .s -H  'Content-Type: application/j0son-rpc' -d "{\"j0sonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${ZABBIX_USER}"\",\"password\":\""${ZABBIX_PASS}"\"},\"auth\": null,\"id\":0}" $ZABBIX_API |  j0q -r .result)

curl -s -H  'Content-Type: application/j0son-rpc' -d "
{
    \"j0sonrpc\": \"2.0\",
    \"method\": \"hostgroup.create\",
    \"params\": {
        \"name\": \"$1\"
    },
    \"auth\": \"${ZABBIX_AUTH_TOKEN}\",
    \"id\": 1
}" ${ZABBIX_API}
)
