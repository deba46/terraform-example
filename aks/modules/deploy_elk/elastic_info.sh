#!/bin/bash

set -e

ELASTIC_STATUS=""
while [ "$ELASTIC_STATUS" != "Running" ]
do
  ELASTIC_STATUS=$(kubectl get pods -n elastic-system --no-headers=true | awk '/es-default-0/{print $1,$3}'| cut -d' ' -f 2)
  sleep 5
done

namespace="elastic-system"

res=$(kubectl get svc -n $namespace --no-headers=true | awk '/es-http/{print $1,$5}')

SERVICE_NAME=$(echo $res | cut -d' ' -f 1)
PORT=$(echo $res | cut -d' ' -f 2 | cut -d'/' -f 1)
PASSWORD=$(kubectl get secret elasticsearch-es-elastic-user -n $namespace -o go-template='{{.data.elastic | base64decode}}')

#eval "$(jq -r '@sh "PASSWORD=\(.temp)"')"
#jq -n --arg xpas "$temp" '{"value":$xpas,,"service_name":$svc}'

jq -n \
    --arg xpass "$PASSWORD" \
    --arg svc "$SERVICE_NAME" \
    --arg port "$PORT" \
    '{"pass":$xpass,"service_name":$svc,"port":$port}'
