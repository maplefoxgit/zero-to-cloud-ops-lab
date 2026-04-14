param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [string]$Location = "australiaeast"
)

$ErrorActionPreference = "Stop"
$suffix = Get-Random -Minimum 10000 -Maximum 99999
$storageName = ("sttagheal{0}" -f $suffix).ToLower()

Write-Host "Creating demo resource group with correct tags..."
az group create `
  --name $ResourceGroupName `
  --location $Location `
  --tags owner=ryan environment=lab costCentre=cloudops-lab project=secure-cloud-baseline-lab | Out-Null

Write-Host "Creating unattached managed disk without required tags..."
az disk create `
  --resource-group $ResourceGroupName `
  --name "orphan-disk-$suffix" `
  --size-gb 32 `
  --sku Standard_LRS | Out-Null

Write-Host "Creating unassociated public IP without required tags..."
az network public-ip create `
  --resource-group $ResourceGroupName `
  --name "orphan-pip-$suffix" `
  --location $Location `
  --allocation-method Static `
  --sku Standard | Out-Null

Write-Host "Creating storage account without required tags..."
az storage account create `
  --name $storageName `
  --resource-group $ResourceGroupName `
  --location $Location `
  --sku Standard_LRS | Out-Null

Write-Host "Demo resources created."
Write-Host "Run TagHeal to inherit tags from the resource group."
Write-Host "Run FindOrphanedResources to detect the disk and public IP."
