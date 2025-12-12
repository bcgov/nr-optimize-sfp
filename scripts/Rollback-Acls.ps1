#
# Rollback-Acls.ps1
# Restores NTFS ACLs from backup sidecars created by Apply-FolderAcls.ps1 (v2).
# Prefers SDDL backups (.sddl) for reliable restore; falls back to JSON if it contains Sddl.
#
# USAGE EXAMPLES
#   # Roll back all folders listed in the same CSV you used to apply:
#   .\Rollback-Acls.ps1 -CsvPath .\Folder_Permissions.csv -WhatIf
#   .\Rollback-Acls.ps1 -CsvPath .\Folder_Permissions.csv
#
#   # Or specify explicit paths:
#   .\Rollback-Acls.ps1 -Path E:\GeoDriveCache\wlrsobj3\LUPCE\CSCEM, E:\GeoDriveCache\wlrsobj3\LUPCE\PSSP
#
#   # Search recursively from a root for .ACLBackup_*.sddl and restore them:
#   .\Rollback-Acls.ps1 -Root E:\GeoDriveCache\wlrsobj3 -Recurse
#
param(
    [string]$CsvPath,
    [string[]]$Path,
    [string]$Root,
    [switch]$Recurse,
    [switch]$WhatIf,
    [string]$LogPath = ".\Rollback-Acls.log"
)

function Write-Log { param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] $Message"
    Write-Host $line
    Add-Content -Path $LogPath -Value $line
}

function Get-BackupFilesForPath { param([string]$p)
    $base = Join-Path (Split-Path -Parent $p) (".ACLBackup_" + (Split-Path -Leaf $p))
    return @{ Sddl = $base + ".sddl"; Json = $base + ".json" }
}

$targets = @()
if ($Path -and $Path.Count -gt 0) {
    $targets += $Path
} elseif ($CsvPath) {
    if (-not (Test-Path -LiteralPath $CsvPath)) { Write-Error "CSV not found: $CsvPath"; exit 1 }
    $rows = Import-Csv -Path $CsvPath
    if (-not ($rows | Get-Member -MemberType NoteProperty | Where-Object Name -eq 'Folder Name')) { Write-Error "CSV missing 'Folder Name' column."; exit 1 }
    $targets += ($rows | ForEach-Object { $_.'Folder Name'.Trim() })
} elseif ($Root) {
    if (-not (Test-Path -LiteralPath $Root)) { Write-Error "Root path not found: $Root"; exit 1 }
    $pattern = ".ACLBackup_*.sddl"
    $files = Get-ChildItem -Path $Root -Filter $pattern -File -Recurse:$Recurse
    foreach ($f in $files) {
        # Infer target folder from backup filename
        $leaf = ($f.BaseName -replace '^\.ACLBackup_', '')
        $p = Join-Path $f.Directory.FullName $leaf
        $targets += $p
    }
} else {
    Write-Error "Provide -CsvPath, -Path, or -Root."; exit 1
}

if ($targets.Count -eq 0) { Write-Error "No target folders to restore."; exit 1 }

foreach ($t in $targets) {
    if (-not (Test-Path -LiteralPath $t)) { Write-Log "SKIP: Target path not found: $t"; continue }
    $bk = Get-BackupFilesForPath -p $t

    $sddlContent = $null

    if (Test-Path -LiteralPath $bk.Sddl) {
        $sddlContent = Get-Content -LiteralPath $bk.Sddl -Raw
        Write-Log "Found SDDL backup: $($bk.Sddl)"
    } elseif (Test-Path -LiteralPath $bk.Json) {
        try {
            $j = Get-Content -LiteralPath $bk.Json -Raw | ConvertFrom-Json
            if ($j.PSObject.Properties.Name -contains 'Sddl') {
                $sddlContent = $j.Sddl
                Write-Log "Found SDDL in JSON backup: $($bk.Json)"
            } else {
                Write-Log "ERROR: JSON backup lacks Sddl property: $($bk.Json). Cannot auto-restore."
                continue
            }
        } catch {
            Write-Log "ERROR: Failed to parse JSON backup: $($bk.Json): $($_.Exception.Message)"
            continue
        }
    } else {
        Write-Log "ERROR: No backup files found for $t (expected $($bk.Sddl) or $($bk.Json))"
        continue
    }

    try {
        $sec = New-Object System.Security.AccessControl.DirectorySecurity
        $sec.SetSecurityDescriptorSddlForm($sddlContent)
        if ($WhatIf) {
            Write-Log "WHATIF: Would restore ACL on $t from SDDL."
        } else {
            Set-Acl -LiteralPath $t -AclObject $sec
            Write-Log "Restored ACL on $t"
        }
    } catch {
        Write-Log "ERROR restoring ACL on $t: $($_.Exception.Message)"
    }
}

Write-Log "Rollback completed."
