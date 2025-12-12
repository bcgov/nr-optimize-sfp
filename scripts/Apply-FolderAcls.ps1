#
# Apply-FolderAcls.ps1 (v2)
# Bulk-apply NTFS ACLs from a CSV. CSV permissions win by default.
# Adds SDDL backups alongside JSON for reliable rollback.

param(
    [Parameter(Mandatory=$true)]
    [string]$CsvPath,

    [switch]$WhatIf,
    [switch]$BackupAcl,
    [switch]$ReplaceExistingExplicit,

    [switch]$PreferSuffixRights,
    [switch]$TraversePure = $false,
    [switch]$ListStrict   = $false,

    [string]$LogPath = ".\Apply-FolderAcls.log"
)

function Write-Log { param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] $Message"
    Write-Host $line
    Add-Content -Path $LogPath -Value $line
}

function Get-BundleRights { param([string]$suffix)
    switch ($suffix) {
        '__R' { return 'ReadAndExecute, Synchronize' }
        '__C' { return 'Modify, Synchronize' }
        '__F' { return 'FullControl' }
        '__T' { if ($TraversePure) { return 'Traverse' } else { return 'ReadAndExecute, Synchronize' } }
        '__L' { if ($ListStrict) { return 'ListDirectory' } else { return 'ListDirectory, ReadAttributes, ReadExtendedAttributes, Synchronize' } }
        default { return $null }
    }
}

function Get-Suffix { param([string]$identity)
    $m = [regex]::Match($identity, '__([RCFTLD])($|[^A-Za-z0-9])')
    if ($m.Success) { return "__" + $m.Groups[1].Value }
    return $null
}

function Parse-Rights { param([string]$rightsText)
    if ($null -eq $rightsText -or [string]::IsNullOrWhiteSpace($rightsText)) { return [System.Security.AccessControl.FileSystemRights]::None }
    if ($rightsText -match '^\s*FullControl\s*$') { return [System.Security.AccessControl.FileSystemRights]::FullControl }
    $rightsEnum = 0
    foreach ($token in ($rightsText -split ',' | ForEach-Object { $_.Trim() })) {
        if ([string]::IsNullOrWhiteSpace($token)) { continue }
        try { $rightsEnum = $rightsEnum -bor [System.Enum]::Parse([System.Security.AccessControl.FileSystemRights], $token, $true) }
        catch { Write-Log "WARN: Unknown right '$token' in '$rightsText' – skipping that bit." }
    }
    return [System.Security.AccessControl.FileSystemRights]$rightsEnum
}

function Parse-InheritanceFlags { param([string]$inheritText)
    if ($inheritText -eq $null -or $inheritText.Trim().Length -eq 0 -or $inheritText -match '^\s*None\s*$') { return [System.Security.AccessControl.InheritanceFlags]::None }
    $flags = 0
    foreach ($token in ($inheritText -split ',' | ForEach-Object { $_.Trim() })) {
        switch -Regex ($token) {
            '^ContainerInherit$' { $flags = $flags -bor [System.Security.AccessControl.InheritanceFlags]::Container }
            '^ObjectInherit$'    { $flags = $flags -bor [System.Security.AccessControl.InheritanceFlags]::Object }
            default { Write-Log "WARN: Unknown inheritance flag '$token' – skipping." }
        }
    }
    return [System.Security.AccessControl.InheritanceFlags]$flags
}

function Parse-PropagationFlags { param([string]$propText)
    if ($propText -eq $null -or $propText.Trim().Length -eq 0 -or $propText -match '^\s*None\s*$') { return [System.Security.AccessControl.PropagationFlags]::None }
    switch -Regex ($propText.Trim()) {
        '^NoPropagateInherit$' { return [System.Security.AccessControl.PropagationFlags]::NoPropagateInherit }
        '^InheritOnly$'        { return [System.Security.AccessControl.PropagationFlags]::InheritOnly }
        default { Write-Log "WARN: Unknown propagation flag '$propText' – defaulting to None."; return [System.Security.AccessControl.PropagationFlags]::None }
    }
}

function Infer-AccessType { param([string]$identity, [string]$fallback = 'Allow')
    if ($identity -match '__D($|[^A-Za-z0-9])') { return [System.Security.AccessControl.AccessControlType]::Deny }
    return [System.Security.AccessControl.AccessControlType]::Parse([System.Security.AccessControl.AccessControlType], $fallback, $true)
}

function Identity-Exists { param([string]$identity)
    try { $nt = New-Object System.Security.Principal.NTAccount($identity); $null = $nt.Translate([System.Security.Principal.SecurityIdentifier]); return $true }
    catch { return $false }
}

if (-not (Test-Path -LiteralPath $CsvPath)) { Write-Error "CSV not found: $CsvPath"; exit 1 }
Write-Log "Starting ACL apply from CSV: $CsvPath"

$rows = Import-Csv -Path $CsvPath
$required = @('Folder Name','Group/User','Permissions','Inheritance','Propagation')
foreach ($c in $required) { if (-not ($rows | Get-Member -MemberType NoteProperty | Where-Object Name -eq $c)) { Write-Error "CSV missing required column '$c'."; exit 1 } }

foreach ($row in $rows) {
    $path        = $row.'Folder Name'.Trim()
    $identity    = $row.'Group/User'.Trim()
    $permTextCsv = $row.'Permissions'.Trim()
    $inheritText = $row.'Inheritance'.Trim()
    $propText    = $row.'Propagation'.Trim()

    if ([string]::IsNullOrWhiteSpace($path) -or [string]::IsNullOrWhiteSpace($identity)) { Write-Log "SKIP: Blank path/identity in row: $($row | ConvertTo-Json -Compress)"; continue }
    if (-not (Test-Path -LiteralPath $path)) { Write-Log "ERROR: Path not found: $path"; continue }
    if (-not (Identity-Exists -identity $identity)) { Write-Log "ERROR: Identity not found: $identity"; continue }

    $suffix = Get-Suffix -identity $identity
    $bundleText = if ($suffix) { Get-BundleRights -suffix $suffix } else { $null }

    $effectiveRightsText = if ($PreferSuffixRights -and $bundleText) { $bundleText } elseif (-not [string]::IsNullOrWhiteSpace($permTextCsv)) { $permTextCsv } else { $bundleText }

    if ([string]::IsNullOrWhiteSpace($effectiveRightsText)) { Write-Log "ERROR: No rights resolved for identity '$identity' (suffix=$suffix, CSV='$permTextCsv') – row skipped."; continue }

    $rights       = Parse-Rights -rightsText $effectiveRightsText
    $inheritFlags = Parse-InheritanceFlags -inheritText $inheritText
    $propFlags    = Parse-PropagationFlags  -propText  $propText
    $accessType   = Infer-AccessType -identity $identity -fallback 'Allow'

    try {
        $acl = Get-Acl -LiteralPath $path

        if ($BackupAcl) {
            $backupBase = Join-Path (Split-Path -Parent $path) (".ACLBackup_" + (Split-Path -Leaf $path))
            $backupJson = $backupBase + ".json"
            $backupSddl = $backupBase + ".sddl"
            # Save JSON for inspection
            $acl | ConvertTo-Json | Set-Content -Path $backupJson -Encoding utf8
            # Save SDDL for robust rollback
            Set-Content -Path $backupSddl -Value $acl.Sddl -Encoding utf8
            Write-Log "Backup ACL exported: $backupJson and $backupSddl"
        }

        if ($ReplaceExistingExplicit) {
            $existing = $acl.Access | Where-Object { $_.IdentityReference -eq $identity -and -not $_.IsInherited }
            foreach ($ace in $existing) {
                Write-Log "Removing explicit ACE for $identity on $path: $($ace.FileSystemRights)"
                if (-not $WhatIf) { $acl.RemoveAccessRule($ace) | Out-Null }
            }
        }

        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity, $rights, $inheritFlags, $propFlags, $accessType)

        $already = $acl.Access | Where-Object {
            $_.IdentityReference -eq $rule.IdentityReference -and
            $_.FileSystemRights  -eq $rule.FileSystemRights  -and
            $_.AccessControlType -eq $rule.AccessControlType -and
            $_.InheritanceFlags  -eq $rule.InheritanceFlags  -and
            $_.PropagationFlags  -eq $rule.PropagationFlags  -and
            -not $_.IsInherited }
        if ($already) { Write-Log "SKIP (exists): $identity on $path => $effectiveRightsText [$inheritText | $propText]"; continue }

        $msg = "APPLY: $identity on $path => $effectiveRightsText [$inheritText | $propText] ($accessType)"
        if ($WhatIf) { Write-Log "WHATIF: $msg" }
        else { $acl.AddAccessRule($rule) | Out-Null; Set-Acl -LiteralPath $path -AclObject $acl; Write-Log $msg }
    } catch { Write-Log "ERROR applying ACL to $path for $identity: $($_.Exception.Message)" }
}

Write-Log "Completed."
