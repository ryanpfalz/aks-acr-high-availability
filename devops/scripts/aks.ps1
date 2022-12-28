param(
    [Parameter()]
    [String]$clusterParam
)

$origPath = Get-Location
$origPath = $origPath.Path
Set-Location $PSScriptRoot

$config = Get-Content "../../config/variables.json" | ConvertFrom-Json
$envConfig = $config.$($config.env)

$rgName = $envConfig.resourceGroup
$acrName = $envConfig.containerRegistryName

if ($clusterParam.ToLower() -eq 'green') {
    $location = $envConfig.location_green
    $aksClusterName = $envConfig.aksClusterName_green
}
else {
    $location = $envConfig.location_blue
    $aksClusterName = $envConfig.aksClusterName_blue
}

# blue configuration will be the primary region for common resources (RG, ACR, etc.)

# RG deploy
Write-Host "Creating RG..."
az group create --name $rgName --location $location
Write-Host "Created RG"

Write-Host "Creating AKS cluster..."
# create AKS cluster and integrate with ACR
az aks create --resource-group $rgName --name $aksClusterName --node-count 1 --node-vm-size b2s --generate-ssh-keys --attach-acr $acrName --location $location

az aks get-credentials --resource-group $rgName --name $aksClusterName

# assign role
$kubeletIdentityId = $(az aks show -g $rgName -n $aksClusterName --query "identityProfile.kubeletidentity.clientId" -o tsv)
$acrId = $(az acr show --name $acrName --resource-group $rgName --query "id" --output tsv)
az role assignment create --assignee $kubeletIdentityId --scope $acrId --role acrpull

# ingress controller
$ingressNamespace = "ingress-basic"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --create-namespace --namespace $ingressNamespace
Write-Host "Created AKS cluster"