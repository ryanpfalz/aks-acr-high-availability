$origPath = Get-Location
$origPath = $origPath.Path
Set-Location $PSScriptRoot

$config = Get-Content "../config/variables.json" | ConvertFrom-Json
$envConfig = $config.$($config.env)

# green configuration will be the primary region for common resources (RG, ACR, etc.)

$rgName = $envConfig.resourceGroup
$frontDoor = $envConfig.frontDoor
# $location = $envConfig.location_green

# RG deploy
Write-Host "Creating RG..."
az group create --name $rgName --location $envConfig.location_green
Write-Host "Created RG"

function GetClusterIngressIp {
    param (

        [string]$ClusterName
    )
    # get IP
    az aks get-credentials --resource-group $rgName --name $ClusterName --overwrite-existing
    $ingressObject = $(kubectl get svc -n $ingressNamespace -ojson | ConvertFrom-Json)
    $ingressIp = $($ingressObject.items | ForEach-Object { $_.status.loadBalancer.ingress.ip })
    return $ingressIp
}

# deploy AFD with initial backend service (green cluster)
$greenIp = GetClusterIngressIp -ClusterName $envConfig.aksClusterName_green

az network front-door create --name $frontDoor --resource-group $rgName --backend-address $greenIp --backend-host-header $greenIp --protocol Http --forwarding-protocol HttpOnly

# add additional backend service (blue cluster)
$blueIp = GetClusterIngressIp -ClusterName $envConfig.aksClusterName_blue

az network front-door backend-pool backend add --resource-group $rgName --front-door-name $frontDoor --pool-name DefaultBackendPool --address $blueIp --backend-host-header $blueIp

# to get the endpoint of front door, run the following
# az network front-door frontend-endpoint list  --front-door-name $frontDoor  --resource-group $rgName --query '[].hostName' -o tsv
