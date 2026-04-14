param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [string]$Location = "australiaeast",

    [string]$ResourceGroupName = "rg-tfstate-bupa-lab",

    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,

    [string]$ContainerName = "tfstate"
)

$ErrorActionPreference = "Stop"

Write-Host "Setting subscription context..."
az account set --subscription $SubscriptionId | Out-Null

Write-Host "Creating resource group..."
az group create `
  --name $ResourceGroupName `
  --location $Location | Out-Null

Write-Host "Creating storage account..."
az storage account create `
  --name $StorageAccountName `
  --resource-group $ResourceGroupName `
  --location $Location `
  --sku Standard_LRS `
  --kind StorageV2 `
  --allow-blob-public-access false `
  --min-tls-version TLS1_2 | Out-Null

Write-Host "Getting storage key..."
$key = az storage account keys list `
  --resource-group $ResourceGroupName `
  --account-name $StorageAccountName `
  --query "[0].value" -o tsv

Write-Host "Creating state container..."
az storage container create `
  --name $ContainerName `
  --account-name $StorageAccountName `
  --account-key $key | Out-Null

Write-Host "Terraform backend created successfully."
Write-Host "Use these values in backend.hcl:"
Write-Host "resource_group_name  = `"$ResourceGroupName`""
Write-Host "storage_account_name = `"$StorageAccountName`""
Write-Host "container_name       = `"$ContainerName`""
Write-Host 'key                  = "bupa-lab/sandbox.tfstate"'
