$origPath = Get-Location
$origPath = $origPath.Path
Set-Location $PSScriptRoot

$config = Get-Content "../config/variables.json" | ConvertFrom-Json
$envConfig = $config.$($config.env)

# green configuration will be the primary region for common resources (RG, ACR, etc.)

$rgName = $envConfig.resourceGroup
$trafficManager = $envConfig.trafficManager
$location = $envConfig.location_green

Write-Host "Creating RG..."
az group create --name $rgName --location $location
Write-Host "Created RG"

Write-Host "Creating traffic manager..."
# create instance
az network traffic-manager profile create --name $trafficManager --resource-group $rgName --routing-method "Priority" --unique-dns-name $trafficManager
Write-Host "Created traffic manager"

# TODO create endpoints in IaC

function CreateEndpoint {
    param (

        [string]$ClusterName,
        [int]$Priority # 1-1000
    )
    # get IP
    az aks get-credentials --resource-group $rgName --name $ClusterName --overwrite-existing
    $ingressObject = $(kubectl get svc -n $ingressNamespace -ojson | ConvertFrom-Json)
    $ingressIp = $($ingressObject.items | ForEach-Object { $_.status.loadBalancer.ingress.ip })
    
    # create endpoint with IP
    az network traffic-manager endpoint create --resource-group $rgName --name $ClusterName --profile-name $trafficManager --type "externalEndpoints" --endpoint-status "Enabled" --target $ingressIp --priority $Priority
    Write-Host "Created Endpoint in $trafficManager for $ingressIp ($ClusterName)"

    # get URL of traffic manager
    $trafficManagerUrl = $(az network traffic-manager profile show  --resource-group $rgName --name $trafficManager  --query "dnsConfig.fqdn" -o tsv)
    Write-Host "Traffic Manager URL: $trafficManagerUrl"
}

CreateEndpoint -ClusterName $envConfig.aksClusterName_green -Priority 1
CreateEndpoint -ClusterName $envConfig.aksClusterName_blue -Priority 2