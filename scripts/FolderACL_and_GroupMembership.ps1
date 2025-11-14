# Modules
Import-Module ActiveDirectory
Import-Module ImportExcel

# Variables
$PSDefaultParameterValues['*-AD*:Server'] = 'IDIR'
$FolderPath = Read-Host -Prompt 'Enter the absolute folder path to scan ' # i.e. "\\sfp.idir.bcgov\S140\S40004\Optimization_Team"
$Counter = 1
$ScriptPath = "E:\scripts"

# Save folder
$SavePath = "$($ScriptPath)\folderpermissions\Output_$((Get-Date).ToString('yyyy-MM-dd_hh-mm-ss'))"

# Save file name 
$SaveName = "Folder_Permissions_$((Get-Date).ToString('yyyy-MM-dd_hh-mm-ss'))"



if (Test-Path -Path $ScriptPath) {

# Create folder if does not exist
if (!(Test-Path -Path $SavePath))
{
    $paramNewItem = @{
        Path      = $SavePath
        ItemType  = 'Directory'
        Force     = $true
    }
    New-Item @paramNewItem
}
} 

# Get server name and determine alias
$ServerName = $env:COMPUTERNAME.ToUpper()
switch ($ServerName) {
    "DISCOVERY" { $Alias = "\\objectstore.nrs.bcgov\" }
    "OPTIMIST"  { $Alias = "\\objectstore2.nrs.bcgov\" }
    "VACANT"    { $Alias = "\\objectstore3.nrs.bcgov\" }
    default     { $Alias = "Unknown" }
}

#Get All Folders from the Path. If parent folder permissions inheirited to subfolders, no need to include in output
$Folders = Get-ChildItem  -Recurse -Directory -Depth 1 -Path $FolderPath -Force -ErrorAction SilentlyContinue # if folder depth is too much and you only want info on the root folders, take out "-Recurse -Directory -Depth 1"
$TotalFolders = $Folders.Count

# omit built in and system security groups
$excludepattern = 'nt authority\system', 'builtin\administrators', 'creator owner', 'builtin\users' 

# create containers to store the information
$ResultArray = @()
$GroupArray = @()

#Iterate through each folder and get the ACL exported to Excel
foreach ($Folder in $Folders) {
    # progress bar
     Write-Progress -PercentComplete (($Counter/$TotalFolders)*100) -Status "Getting Folder Permissions" -Activity "Processing Folder '$($Folder.FullName)' ($Counter of $TotalFolders)"
    # get ACL info on folder
    $Aclist = Get-Acl -Path $Folder.FullName
    
    ForEach ($Access in $Aclist.Access | where identityreference -notin $excludepattern) {
        # Aquire information arrays based on the current host name
        $Properties = @([ordered]@{
            'Folder Name' = $Folder.FullName
            'Group/User'  = $Access.IdentityReference
            'Permissions' = $Access.FileSystemRights
            'Inherited'   = $Access.IsInherited
            'Inheritance' = $Access.InheritanceFlags
            'Propagation' = $Access.PropagationFlags
            'Alias'       = $Alias
        })


        for ($i = 0; $i -lt $Properties.Count; $i++) {
            # store all relevant values into the Result object
            $ResultObject = New-Object -TypeName PSObject -Property $Properties[$i]
            }

            # store tracked data in the result object for final display 
            $ResultArray += $ResultObject
        }
        $Counter++
        # get group membership lists from folders' ACL info 
        $ACLs = Get-Acl $Folder.FullName | ForEach-Object { $_.Access }
        ForEach ($ACL in $ACLs) {   
            If ($ACL.IdentityReference -match "\\") {   
                If ($ACL.IdentityReference.Value.Split("\")[0].ToUpper() -eq 'IDIR'.ToUpper()) {   
                    $Name = $ACL.IdentityReference.Value.Split("\")[1]
                    If ((Get-ADObject -Filter 'SamAccountName -eq $Name').ObjectClass -eq "group") {   
                        $GroupArray += $Name
                    }
                }
            }
        }
    }

# Export the final result as the desired spreadsheet
$ResultArray | Sort-Object FullName | Export-Excel $SavePath\$SaveName.xlsx -Append -WorkSheetname 'Folder Permission Report' -AutoSize -BoldTopRow -FreezeTopRow -TableStyle Light15 -ErrorAction SilentlyContinue

if (Test-Path -Path "$($SavePath)\$($SaveName).xlsx") {
    Write-Host -ForegroundColor Yellow "`nYour file $SaveName has been saved to $SavePath. Thank you!`n"
    }
elseif (!(Test-Path -Path "$($SavePath)\$($SaveName).xlsx")) {
    Write-Host -ForegroundColor Yellow "`nThere was an issue and the report was not created. Please check for error messages.`n"}

function Get-ADGroupMembers {
    [alias ("gadgm")]
    param (
        
        [String[]]$groups 
    ) 
    foreach ($secgr in $groups | Sort-Object -unique) {
        if ($secgr -notin $excludepattern) {
        Write-Host -ForegroundColor Yellow "`nPulling AD membership list for $secgr...`n"
        Get-ADGroupMember $secgr -Recursive |
        Get-ADUser -Properties Mail | Select-Object -ExpandProperty SamAccountName |
        Sort-Object SamAccountName |
        Set-Content -Path "$($SavePath)\$($secgr).txt" -Force
        }
        Write-Host -ForegroundColor Yellow "`nGroup Membership lists have been saved to $SavePath.`n"
    }
}

# Run group membership function 
gadgm -groups $GroupArray 

Start-Sleep -Seconds 5

# Check group lists for nested groups & get their memberships too
$GMList = Get-Content $SavePath\*.txt
$GMArray = @()

Foreach ($GM in $GMList) {
    If ((Get-ADObject -Filter 'SamAccountName -eq $GM').ObjectClass -eq "group") {   
        $GMArray += $GM
    }
}

# Run group membership function
If ($GMArray.count -gt 0) { 
    gadgm -groups $GMArray
    }
Else {
    continue
    }
    
