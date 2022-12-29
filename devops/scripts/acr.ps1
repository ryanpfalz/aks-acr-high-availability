$origPath = Get-Location
$origPath = $origPath.Path
Set-Location $PSScriptRoot

$config = Get-Content "../config/variables.json" | ConvertFrom-Json
$envConfig = $config.$($config.env)

# green configuration will be the primary region for common resources (RG, ACR, etc.)

$rgName = $envConfig.resourceGroup
$locationPrimary = $envConfig.location_green
$locationSecondary = $envConfig.location_blue
$acrName = $envConfig.containerRegistryName

# RG deploy
Write-Host "Creating RG..."
az group create --name $rgName --location $locationPrimary
Write-Host "Created RG"

# ACR
Write-Host "Creating Container Registry..."

# SKU needs to be Premium for geo replication; set primary location first then replicate
# as of development, zone reduncancy is under preview and can only be enabled at creation time
az acr create --name $acrName --resource-group $rgName --location $locationPrimary --sku Premium --zone-redundancy Enabled --admin-enabled true

# alternatively set this on map in portal
az acr replication create --resource-group $rgName --location $locationSecondary --registry $acrName 

Write-Host "Created Container Registry"

# programmatically get credentials:
# $acrUsername =  $(az acr credential show --name $acrName --query "username").Replace("`"","")
# $acrPassword =  $(az acr credential show --name $acrName --query "passwords[0].value").Replace("`"","")