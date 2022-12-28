$origPath = Get-Location
$origPath = $origPath.Path
Set-Location $PSScriptRoot

$config = Get-Content "../../config/variables.json" | ConvertFrom-Json
$envConfig = $config.$($config.env)

$rgName = $envConfig.resourceGroup
$trafficManager = $envConfig.trafficManager

# create instance
az network traffic-manager profile create --name $trafficManager --resource-group $rgName --routing-method "Priority" --unique-dns-name $trafficManager

# TODO create endpoints in IaC