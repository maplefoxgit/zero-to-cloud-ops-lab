param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [string]$RequiredTags = "owner,environment,costCentre",

    [bool]$WhatIfMode = $true
)

$ErrorActionPreference = "Stop"

function Merge-Hashtable {
    param(
        [hashtable]$Base,
        [hashtable]$Overlay
    )

    $result = @{}
    if ($Base) {
        foreach ($key in $Base.Keys) {
            $result[$key] = $Base[$key]
        }
    }
    if ($Overlay) {
        foreach ($key in $Overlay.Keys) {
            $result[$key] = $Overlay[$key]
        }
    }

    return $result
}

Write-Output "Connecting with Automation Account managed identity..."
Connect-AzAccount -Identity | Out-Null
Set-AzContext -Subscription $SubscriptionId | Out-Null

$requiredTagList = $RequiredTags.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ }
$resources = Get-AzResource | Where-Object { $_.ResourceGroupName }
$healed = 0
$skipped = 0
$failed = 0

foreach ($resource in $resources) {
    try {
        if (-not $resource.ResourceId) { continue }

        $currentTags = @{}
        if ($resource.Tags) {
            foreach ($key in $resource.Tags.Keys) {
                $currentTags[$key] = $resource.Tags[$key]
            }
        }

        $missingTags = @()
        foreach ($tag in $requiredTagList) {
            if (-not $currentTags.ContainsKey($tag) -or [string]::IsNullOrWhiteSpace([string]$currentTags[$tag])) {
                $missingTags += $tag
            }
        }

        if ($missingTags.Count -eq 0) {
            continue
        }

        $rg = Get-AzResourceGroup -Name $resource.ResourceGroupName -ErrorAction SilentlyContinue
        $candidateTags = @{}

        foreach ($tag in $missingTags) {
            if ($rg -and $rg.Tags -and $rg.Tags.ContainsKey($tag) -and -not [string]::IsNullOrWhiteSpace([string]$rg.Tags[$tag])) {
                $candidateTags[$tag] = $rg.Tags[$tag]
            }
        }

        if ($candidateTags.Count -eq 0) {
            $skipped++
            Write-Warning "Skipped $($resource.Name) because no suitable tags were found on resource group $($resource.ResourceGroupName)."
            continue
        }

        $mergedTags = Merge-Hashtable -Base $currentTags -Overlay $candidateTags

        if ($WhatIfMode) {
            Write-Output "[WhatIf] Would heal $($resource.Name) with tags: $($candidateTags | ConvertTo-Json -Compress)"
            continue
        }

        Update-AzTag -ResourceId $resource.ResourceId -Tag $mergedTags -Operation Merge | Out-Null
        $healed++
        Write-Output "Healed $($resource.Name) with tags: $($candidateTags | ConvertTo-Json -Compress)"
    }
    catch {
        $failed++
        Write-Error "Failed to process $($resource.Name): $($_.Exception.Message)"
    }
}

Write-Output "Tag healing complete."
Write-Output "Healed: $healed"
Write-Output "Skipped: $skipped"
Write-Output "Failed: $failed"
