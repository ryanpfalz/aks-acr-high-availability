$origPath = Get-Location
$origPath = $origPath.Path
Set-Location $PSScriptRoot

$config = Get-Content "../../config/variables.json" | ConvertFrom-Json
$envConfig = $config.$($config.env)

$rgName = $envConfig.resourceGroup
$locationPrimary = $envConfig.location_blue
$locationSecondary = $envConfig.location_green
$acrName = $envConfig.containerRegistryName

# blue configuration will be the primary region for common resources (RG, ACR, etc.)

# RG deploy
Write-Host "Creating RG..."
az group create --name $rgName --location $locationPrimary
Write-Host "Created RG"

# ACR
Write-Host "Creating Container Registry..."

# SKU needs to be Premium for geo replication; set primary location first then replicate
az acr create --name $acrName --resource-group $rgName --location $locationPrimary --sku Premium
az acr replication create -r $acrName -l $locationSecondary

Write-Host "Created Container Registry"