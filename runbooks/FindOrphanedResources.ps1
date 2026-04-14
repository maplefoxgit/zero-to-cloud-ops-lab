param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [int]$SnapshotAgeDays = 30,

    [bool]$DeleteEligible = $false
)

$ErrorActionPreference = "Stop"

function Remove-IfEligible {
    param(
        [string]$ResourceName,
        [hashtable]$Tags,
        [scriptblock]$DeleteAction
    )

    $eligible = $false
    if ($Tags -and $Tags.ContainsKey("autoCleanup") -and [string]$Tags["autoCleanup"] -eq "true") {
        $eligible = $true
    }

    if (-not $DeleteEligible -or -not $eligible) {
        Write-Output "Detected orphan: $ResourceName. DeleteEligible=$DeleteEligible autoCleanup=$eligible"
        return
    }

    & $DeleteAction
    Write-Output "Deleted eligible orphan: $ResourceName"
}

Write-Output "Connecting with Automation Account managed identity..."
Connect-AzAccount -Identity | Out-Null
Set-AzContext -Subscription $SubscriptionId | Out-Null

$cutoff = (Get-Date).AddDays(-1 * $SnapshotAgeDays)

$unattachedDisks = Get-AzDisk | Where-Object { -not $_.ManagedBy }
$orphanPips = Get-AzPublicIpAddress | Where-Object { -not $_.IpConfiguration }
$orphanNics = Get-AzNetworkInterface | Where-Object { -not $_.VirtualMachine }
$oldSnapshots = Get-AzSnapshot | Where-Object { $_.TimeCreated -lt $cutoff }

Write-Output "Unattached managed disks: $($unattachedDisks.Count)"
foreach ($disk in $unattachedDisks) {
    Remove-IfEligible -ResourceName $disk.Name -Tags $disk.Tags -DeleteAction {
        Remove-AzDisk -ResourceGroupName $disk.ResourceGroupName -DiskName $disk.Name -Force
    }
}

Write-Output "Unassociated public IPs: $($orphanPips.Count)"
foreach ($pip in $orphanPips) {
    Remove-IfEligible -ResourceName $pip.Name -Tags $pip.Tags -DeleteAction {
        Remove-AzPublicIpAddress -ResourceGroupName $pip.ResourceGroupName -Name $pip.Name -Force
    }
}

Write-Output "Detached NICs: $($orphanNics.Count)"
foreach ($nic in $orphanNics) {
    Remove-IfEligible -ResourceName $nic.Name -Tags $nic.Tags -DeleteAction {
        Remove-AzNetworkInterface -ResourceGroupName $nic.ResourceGroupName -Name $nic.Name -Force
    }
}

Write-Output "Old snapshots older than $SnapshotAgeDays days: $($oldSnapshots.Count)"
foreach ($snapshot in $oldSnapshots) {
    Remove-IfEligible -ResourceName $snapshot.Name -Tags $snapshot.Tags -DeleteAction {
        Remove-AzSnapshot -ResourceGroupName $snapshot.ResourceGroupName -SnapshotName $snapshot.Name -Force
    }
}

Write-Output "Orphan detection complete."
