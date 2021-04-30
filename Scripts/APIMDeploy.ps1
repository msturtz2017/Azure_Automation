
$APIMRG = "cool-tst-akw-east2-rg"
$VNETRG = "cool-tst-nonprod-east2-rg"
$RGs = @($VNETRG,$APIMRG)

foreach ($RG in $RGs) {
    
   $RGStatus = (az group create --location eastus2 --resource-group $RG) | convertfrom-json

   if($($RGStatus.properties.provisioningState) -ne "Succeeded")
   {
       Write-Error "The creation of resource group $RG was not successfull `nplease check your settings and try again"
       throw
   }

   Write-Host "The creation of resource group $RG was successfull" -ForegroundColor Green
}

$APIM = "APIM-$((New-Guid).Guid)"
$ScriptsDir = "$(Split-Path $MyInvocation.MyCommand.Path -Parent)"
$BasePath = $ScriptsDir.Substring(0,$ScriptsDir.IndexOf("\Scripts"))
$ArmTemplatePath = "$BasePath\ARMTemplate"

if(!(Test-Path -Path $ArmTemplatePath))
{
    Write-Error "The path $ArmTemplatePath is invalid `nPlease check your settings and try again"
    throw
}

$APIMDeploymentName = "APIM-$(Get-Date -Format "MM-dd-yyyy-HH-mm-ss-ffff")"
$VNetDeploymentName = "VNET-$(Get-Date -Format "MM-dd-yyyy-HH-mm-ss-ffff")"

$FullPathToARMTemplate = "$BasePath\ARMTemplate\APIMDeploy.json"
$FullPathToARMParameter = "$BasePath\ARMTemplate\APIMDeploy.parameters.json"

$FullPathToVNETTemplate = "$BasePath\ARMTemplate\VNet-Template.json"
$FullPathToVNETParameter = "$BasePath\ARMTemplate\VNet-Template.parameters.json"

$VNetStatus = "$(az deployment group create --resource-group  $VNETRG --name $VNetDeploymentName --template-file $FullPathToVNETTemplate --parameters $FullPathToVNETParameter)" | convertfrom-json

if(($VNetStatus.properties.provisioningState) -ne "Succeeded")
{
    Write-Error "The $VNET deployment of $APIM was not successfull`nplease check your settings and try again"
    throw
}

$APMStatus = "$(az deployment group create --resource-group $APIMRG --name $APIMDeploymentName --template-file $FullPathToARMTemplate --parameters $FullPathToARMParameter apiManagementServiceName="$APIM")" | convertfrom-json 
if(($APMStatus.properties.provisioningState) -ne "Succeeded")
{
    Write-Error "The APIM deployment of $APIM was not successfull`nplease check your settings and try again"
    throw
}

$specFormat ="OpenAPI"
$specURL ="https://conferenceapi.azurewebsites.net/?format=json"
Write-Host "The APIM deployment of $APIM was successfull" -ForegroundColor Green

$APIStatus = "$(az apim api import --path "/" --resource-group "$APIMRG" --service-name "$APIM" --specification-format "$specFormat" --specification-url "$specURL")" | ConvertFrom-Json

Write-Host ""