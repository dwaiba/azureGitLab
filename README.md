# azureGitLab
### Run Dockerized azure-cli locally with authentication of cli via aka.ms/devicelogin

``
docker pull -dti --name=azure-cli-python --restart=always azuresdk/azure-cli-python
docker exec -ti azure-cli-python bash -c "az login && bash"
``
### Deploy from CLI - Once inside the CLI Container and logged into azzure cli please deploy the whole gitlab cluster as follows
#### deployStorage

``

export storageName="rystore"

export storageResourceGroup="storageGroup"

export resourceGroupLocation="westeurope"

az group create --name $storageResourceGroup --location $resourceGroupLocation
az group deployment create --resource-group $storageResourceGroup --name DeployStorage --template-uri https://raw.githubusercontent.com/dwaiba/azureGitLab/master/deployStorage.json --parameters "{\"name\":{\"value\":\"rystore\"},\"location\":{\"value\":\"westeurope\"},\"accountType\":{\"value\":\"Standard_GRS\"}}" --debug

``

The following are shot post storage availability

``
az storage account show-connection-string --name $storageName --resource-group $storageResourceGroupstorageConnectionString=$(az storage account show-connection-string --name $storageName --resource-group $storageResourceGroup|grep connectionString|awk '{print $2 }')
az storage share create --name share1 --connection-string=$storageConnectionString
storageKey=$(az storage account keys list --account-name $storageName --resource-group $storageResourceGroup | jq -r '.[0].value')

``

#### deployInfra
Use the shares created above with the key to shoot the following
``
az group create -l westeurope -n gitlabazurewe && az group deployment create -g gitlabazurewe -n gitlabazurewe --template-uri https://raw.githubusercontent.com/Annonator/azureGitlabDeployment/master/deployInfrastructure.json --parameters "{\"vmssName\":{\"value\":\"gitlab\"},\"instanceCount\":{\"value\": 2},\"adminPassword\":{\"value\":\"<<your admin password for admin user git>>\"},\"storageAccountName\":{\"value\":\"Nab00Dag0baH\"},\"storageAccountKey1\":{\"value\":\"<<account key1>\"},\"storageAccountKey2\":{\"value\":\"<<account key 2>\"},\"storageAccountKey3\":{\"value\":\"<account key 3>>\"},\"shareName\":{\"value\":\"<<your share name>>\"},\"rediscacheName\":{\"value\":\"<<your redis cache name>>\"},\"sqlServerName\":{\"value\": \"<<your sql server name>\"},\"sqladministratorLogin\":{\"value\":\"<<sql admin name - please do not use reserved names like admin>>\"},\"sqlAdministratorLoginPassword\":{\"value\":\"<<password>>\"},\"customScriptUri\":{\"value\":\"https://raw.githubusercontent.com/Annonator/azureGitlabDeployment/master/mountazurefiles.sh\"}}" --debug
``
A suitable example would be the following

``
az group create -l westeurope -n gitlabazurewe && az group deployment create -g gitlabazurewe -n gitlabazurewe --template-uri https://raw.githubusercontent.com/Annonator/azureGitlabDeployment/master/deployInfrastructure.json --parameters "{\"vmssName\":{\"value\":\"gitlavmss\"},\"instanceCount\":{\"value\": 2},\"adminPassword\":{\"value\":\"bangboom23D#\"},\"storageAccountName\":{\"value\":\"rystore\"},\"storageAccountKey1\":{\"value\":\"APvyiEbt3UlR2A+fG49Cyp2yBUyU0jq8ayAAeUOHn4glcxHLc9g13OFgmSl9d0IK+ng8UTs2UIq0VEpvfyIA7Q==\"},\"shareName\":{\"value\":\"share1\"},\"rediscacheName\":{\"value\":\"gitlabredis\"},\"sqlServerName\":{\"value\": \"gitlabsql\"},\"sqladministratorLogin\":{\"value\":\"sqladmin1\"},\"sqlAdministratorLoginPassword\":{\"value\":\"bangboom23D#\"},\"customScriptUri\":{\"value\":\"https://raw.githubusercontent.com/Annonator/azureGitlabDeployment/master/mountazurefiles.sh\"}}" --debug

``

### Deploy from Portal

<a href="https://preview.portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdwaiba%2FazureGitLab%2Fmaster%2FdeployInfrastructure.json" target="_blank"><img alt="Deploy to Azure" src="https://camo.githubusercontent.com/9285dd3998997a0835869065bb15e5d500475034/687474703a2f2f617a7572656465706c6f792e6e65742f6465706c6f79627574746f6e2e706e67" /></a>

Please provide the following as the deployment script in the portal parameter
``
https://raw.githubusercontent.com/dwaiba/azureGitLab/master/deploy.sh
``
### Visualize
<a href="http://armviz.io/#/?load=https://preview.portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdwaiba%2FazureGitLab%2Fmaster%2FdeployInfrastructure.json" target="_blank">  <img src="http://armviz.io/visualizebutton.png" /> </a> 
