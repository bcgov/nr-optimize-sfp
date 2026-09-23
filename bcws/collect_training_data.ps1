# --------------------------------------------------------------------
# Generate BCWS "training$" folder inventory report
# This must run on NRIDS server "WAREHOUSE" by someone with an "_A" IDIR
# Currently set to run as a scheduled task under HHAY_A (Heather Hay)
# Michelle Aubrey: you do not need to run this script, it is a backup copy
# --------------------------------------------------------------------

$SavePath = 'E:\Scripts\BCWS_Output'
$Path     = '\\bcwsdata.nrs.bcgov\training$'

$SaveName = 'bcws_training_report_{0:yyyy-MM-dd_HHmm}.csv' -f (Get-Date)
$OutputFile = Join-Path $SavePath $SaveName

# --------------------------------------------------------------------
# Ensure output folder exists
# --------------------------------------------------------------------

if (-not (Test-Path -Path $SavePath)) {
    New-Item -Path $SavePath -ItemType Directory -Force | Out-Null
}

# --------------------------------------------------------------------
# Verify source path exists
# --------------------------------------------------------------------

if (-not (Test-Path -Path $Path)) {
    Write-Error "Source path unavailable: $Path"
    exit 1
}

# --------------------------------------------------------------------
# Export file inventory
# --------------------------------------------------------------------

Get-ChildItem `
-Path $Path `
-Recurse `
-Force `
-File `
-ErrorAction SilentlyContinue |
    Select-Object `
        @{Name = 'path';             Expression = { $_.DirectoryName } },
        @{Name = 'filename';         Expression = { $_.Name } },
        @{Name = 'sizemb';           Expression = { $_.Length / 1MB } },
        @{Name = 'creationdate';     Expression = { $_.CreationTime } },
        @{Name = 'lastaccessdate';   Expression = { $_.LastAccessTime } },
        @{Name = 'modificationdate'; Expression = { $_.LastWriteTime } } |
    Export-Csv -Path $OutputFile `
               -Encoding UTF8 `
               -NoTypeInformation

Write-Output "Report saved to $OutputFile. Please send a copy to Michelle Aubrey at the end of every fiscal quarter."