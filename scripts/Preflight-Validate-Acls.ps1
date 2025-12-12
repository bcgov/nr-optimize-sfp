#
# Preflight-Validate-Acls.ps1
# Validates a CSV before applying ACL changes. No ACLs are modified.
# Reports missing paths, unresolved identities, and unknown rights/inheritance/propagation tokens.

param(
    [Parameter(Mandatory=$true)]
    [string]$CsvPath
)

# Output: a summary CSV next to the input file
$ReportPath = [System.IO.Path]::Combine((Split-Path -Parent $CsvPath), ("Preflight_" + (Split-Path -Leaf $CsvPath)))

function Test-Identity {
    param([string]$Identity)
    try { $nt = New-Object System.Security.Principal.NTAccount($Identity); $null = $nt.Translate([System.Security.Principal.SecurityIdentifier]); return $true }
    catch { return $false }
}

function Check-RightsToken {
    param([string]$token)
    if ([string]::IsNullOrWhiteSpace($token)) { return $true }
    try { $null = [System.Enum]::Parse([System.Security.AccessControl.FileSystemRights], $token.Trim(), $true); return $true }
    catch { return $false }
}

function Check-InheritanceToken {
    param([string]$token)
    switch -Regex ($token.Trim()) {
        '^ContainerInherit$' { return $true }
        '^ObjectInherit$'    { return $true }
        '^None$'             { return $true }
        default { return $false }
    }
}

function Check-PropagationToken {
    param([string]$token)
    switch -Regex ($token.Trim()) {
        '^None$'               { return $true }
        '^NoPropagateInherit$' { return $true }
        '^InheritOnly$'        { return $true }
        default { return $false }
    }
}

if (-not (Test-Path -LiteralPath $CsvPath)) { Write-Error "CSV not found: $CsvPath"; exit 1 }
$rows = Import-Csv -Path $CsvPath
$required = @('Folder Name','Group/User','Permissions','Inheritance','Propagation')
foreach ($c in $required) { if (-not ($rows | Get-Member -MemberType NoteProperty | Where-Object Name -eq $c)) { Write-Error "CSV missing required column '$c'."; exit 1 } }

$report = @()

foreach ($row in $rows) {
    $path        = $row.'Folder Name'.Trim()
    $identity    = $row.'Group/User'.Trim()
    $permText    = $row.'Permissions'.Trim()
    $inheritText = $row.'Inheritance'.Trim()
    $propText    = $row.'Propagation'.Trim()

    $issues = @()

    if ([string]::IsNullOrWhiteSpace($path)) { $issues += 'Blank path' }
    elseif (-not (Test-Path -LiteralPath $path)) { $issues += 'Path not found' }

    if ([string]::IsNullOrWhiteSpace($identity)) { $issues += 'Blank identity' }
    elseif (-not (Test-Identity -Identity $identity)) { $issues += 'Identity not found' }

    # Rights: check each token
    foreach ($tok in ($permText -split ',' | ForEach-Object { $_.Trim() })) {
        if ($tok.Length -gt 0 -and -not (Check-RightsToken -token $tok)) { $issues += "Unknown rights token '$tok'" }
    }

    # Inheritance: accept comma-separated tokens; all must be valid
    foreach ($tok in ($inheritText -split ',' | ForEach-Object { $_.Trim() })) {
        if ($tok.Length -gt 0 -and -not (Check-InheritanceToken -token $tok)) { $issues += "Unknown inheritance token '$tok'" }
    }

    # Propagation: single token expected but allow comma split
    foreach ($tok in ($propText -split ',' | ForEach-Object { $_.Trim() })) {
        if ($tok.Length -gt 0 -and -not (Check-PropagationToken -token $tok)) { $issues += "Unknown propagation token '$tok'" }
    }

    if ($issues.Count -gt 0) {
        $report += [pscustomobject]@{
            Path=$path; Identity=$identity; Permissions=$permText; Inheritance=$inheritText; Propagation=$propText; Issues=($issues -join '; ')
        }
    }
}

if ($report.Count -eq 0) {
    Write-Host "Preflight passed: no issues found." -ForegroundColor Green
} else {
    $report | Export-Csv -Path $ReportPath -NoTypeInformation -Encoding UTF8
    Write-Host "Preflight issues found. See report: $ReportPath" -ForegroundColor Yellow
    $report | Format-Table -AutoSize
}
