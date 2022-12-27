$origPath = Get-Location
$origPath = $origPath.Path
Set-Location $PSScriptRoot

$config = Get-Content "../../config/variables.json" | ConvertFrom-Json
$envConfig = $config.$($config.env)

$rgName = $envConfig.resourceGroup
$location = $envConfig.location_blue
$acrName = $envConfig.containerRegistryName

# blue configuration will be the primary region for common resources (RG, ACR, etc.)

# RG deploy
Write-Host "Creating RG..."
az group create --name $rgName --location $location
Write-Host "Created RG"

# ACR
# TODO ENABLE GEO REPLICATION
Write-Host "Creating Container Registry..."
az acr create --name $acrName --resource-group $rgName --sku basic
Write-Host "Created Container Registry"