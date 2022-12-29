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