<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER deploymentName
    The deployment name.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.

.PARAMETER storageAccountName
    The storageaccount

#>

param(
    #[Parameter(Mandatory=$True)]
    [string]
    $subscriptionId = "3c1acdbb-6c4a-4709-b589-1e6fe59ccd99",
   
    #[Parameter(Mandatory=$True)]
    [string]
    $resourceGroupName = "automyresourcegroup",
   
    [string]
    $resourceGroupLocation = "westeurope",
   
    #[Parameter(Mandatory=$True)]
    [string]
    $deploymentName = "automydeploymentname",
   
    [string]
    $templateFilePath = "template.json",
   
    [string]
    $parametersFilePath = "parameters2.json",

    [string]
    $storageAccountName = "mystorageac",

    [string]
    $virtualnetworkname = "VnetVPC",

    [string]
    $vpc = "10.0.0.0/16",

    [string]
    $subnetzero = "10.0.0.0/24",

    [string]
    $subnetone = "10.0.1.0/24",

    [string]
    $vmname = "ubuntu-vps",

    [string]
    $login = "mayandrey",

    [string]
    $passwd = "#Epam2017!Z",
    
    [string]
    $sqlsrv = "mysqlsbcdpepam",

    [string]
    $manualsqldbAdminLogin = "sqladmincdp",

    [string]
    $netSecGrName = "netSecurityGroupName",

    [string]
    $manualsqldbname = "sqlDBname24may"
   )

   Write-Host "Logging in...";
   Login-AzureRmAccount; 

   $deploymentParameter = @{
    "storageAccounts_mycdpstorageaccount_name" = $storageAccountName + ((Get-AzureRmContext).Subscription.Id).Replace('-','').substring(0, 11);
    "location_infrastructure" = $resourceGroupLocation;
    "subnetzero" = $subnetzero;
    "subnetone" = $subnetone;
    "virtualnetworkname" = $virtualnetworkname;
    "vmname" = $vmname;
    "login" = $login;
    "vpc" = $vpc;
    "sqlsrv" = $sqlsrv;
    "pwd" = $passwd;
    "manualsqldbAdminLogin" = $manualsqldbAdminLogin;
    "netSecGrName" = $netSecGrName;
    "sqldbname" = $manualsqldbname;
}
<#
.SYNOPSIS
    Registers RPs
#>
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace;
}

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# sign in


# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# Register RPs
$resourceProviders = @("microsoft.storage");
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

# Start the deployment
Write-Host "Starting deployment...";
if(Test-Path $parametersFilePath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath;
} else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterObject $deploymentParameter -Verbose;
}
