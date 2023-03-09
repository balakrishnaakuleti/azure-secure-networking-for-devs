#!/bin/bash

TeamName=$1
Location="westeurope"
if [ -z "$TeamName" ]; then
  echo >&2 "Required parameter \"TeamName\" missing"
  exit 1
fi


Environment="dev"
ResourceGroupName="rg-${TeamName}-${Environment}"
VnetName="vnet-${TeamName}-${Location}-${Environment}"
SharedSubnetName="snet-${TeamName}-shared-${Environment}"

echo -e "\nCreating resource group..."
az group create --name $ResourceGroupName --location $Location

echo -e "\nCreating virtual network..."

az network vnet create \
    --name $VnetName \
    --location $Location \
    --resource-group $ResourceGroupName \
    --address-prefixes "10.0.0.0/22"

echo -e "\nCreating subnet for Azure Bastion..."

az network vnet subnet create \
    --name "AzureBastionSubnet" \
    --resource-group $ResourceGroupName \
    --vnet-name $VnetName \
    --address-prefixes "10.0.0.0/26" \
    --disable-private-endpoint-network-policies false \
    --disable-private-link-service-network-policies false

echo -e "\nCreating subnet for shared resources..."

az network vnet subnet create \
    --name $SharedSubnetName \
    --resource-group $ResourceGroupName \
    --vnet-name $VnetName \
    --address-prefixes "10.0.0.64/26" \
    --disable-private-endpoint-network-policies false \
    --disable-private-link-service-network-policies false \
    --service-endpoints Microsoft.KeyVault Microsoft.Storage