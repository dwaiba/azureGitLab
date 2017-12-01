#!/bin/bash

storageName="persistentStore"
storageResourceGroup="storageGroup"
resourceGroupLocation="westeurope"

az group create --name $storageResourceGroup --location $resourceGroupLocation

az group deployment create --resource-group $storageResourceGroup --name DepolyStorage --template-file https://raw.githubusercontent.com/dwaiba/azureGitLab/master/deployStorage.json --parameters $storageParameterFilePath

az storage account show-connection-string --name $storageName --resource-group $storageResourceGroup

storageConnectionString=$(az storage account show-connection-string --name $storageName --resource-group $storageResourceGroup)

az storage share create --name share1 --connection-string=$storageConnectionString
az storage share create --name share2 --connection-string=$storageConnectionString
az storage share create --name share3 --connection-string=$storageConnectionString
az storage share create --name share4 --connection-string=$storageConnectionString
az storage share create --name share5 --connection-string=$storageConnectionString

# apt-get install jq
storageKey=$(az storage account keys list --account-name $storageName --resource-group $storageResourceGroup | jq -r '.[0].value')
