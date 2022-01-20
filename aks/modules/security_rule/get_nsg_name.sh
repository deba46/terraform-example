#!/bin/bash
#echo "get network network security name..."
az resource list --resource-group $1  --resource-type "Microsoft.Network/networkSecurityGroups" --query "[].{name:name}" | sed 's/[][]//g'