# wDayzLogRotation v0.7
# Copyright (c) 2024 Vladislav Salikov aka W0LF aka 'dreamforce'
# https://github.com/dreamforceinc
#
# Input parameters:
#   <Path to server location>           : Absolute, fully qualified path to server's root folder.
#   <Path to instance>                  : Absolute, fully qualified path to server's instance folder.
#   [Path to BEC's logs location]       : Optional. By default, BEC location inside the server's root folder.
#   [Path to Admin Tool's logs location]: Optional. By default, AT location inside the instance's folder.
#
# Example:
#   powershell.exe -File "wDayzLogRotation.ps1" "Z:\Servers\DayZServer" "Z:\Servers\DayZServer\profiles\Instance_1" "D:\server tools\BEC" "Z:\Servers\DayZServer\profiles\Instance_1\VPPadminTools"

# ------------------------------[ Configuration ]------------------------------
$daysAmount = 7     # Number of days to store logs
$noDelete   = $true # For tests - don't delete logs
# -----------------------------------------------------------------------------

# -------------------------[ !!! DON'T EDIT BELOW !!! ]------------------------
$serverLocation  = $args[0]
$instanceDir     = $args[1]
$becLogDir       = $null
$adminToolLogDir = $null
if ($args[2]) { $becLogDir = $args[2] }
if ($args[3]) { $adminToolLogDir = $args[3] }

$daysAmount = [Math]::Abs($daysAmount)
$instance = Split-Path -Path "${instanceDir}" -Leaf
$destDir = "${instanceDir}\RotatedLogs"
$destDelDir = "${destDir}\DeletedLogs"
if ($becLogDir) { $becDestDir = "${destDir}\BEC" }
if ($adminToolLogDir) { $adminToolDestDir = "${destDir}\AdminTool" }

### Debug output ###
# Write-Host "   serverLocation: '${serverLocation}'"
# Write-Host "      instanceDir: '${instanceDir}'"
# Write-Host "         instance: '${instance}'"
# Write-Host "          destDir: '${destDir}'"
# Write-Host "       destDelDir: '${destDelDir}'"
# Write-Host "        becLogDir: '${becLogDir}'"
# Write-Host "       becDestDir: '${becDestDir}'"
# Write-Host "  adminToolLogDir: '${adminToolLogDir}'"
# Write-Host " adminToolDestDir: '${adminToolDestDir}'"

Write-Host "Start Log rotation powershell script"
$date = Get-Date
$fileList = $null

#region ### DayZ Game ###
Write-Host "Rotating DAYZ logs..."

If (!(Test-Path -PathType Container $destDir)) {
    New-Item -ItemType Directory -Path $destDir | Out-Null
    Write-Host "Created new folder: ${destDir}"
}

$fileList = Get-Item -Path $instanceDir\*.rpt, $instanceDir\*.log, $instanceDir\*.adm | Where-Object { $_.LastWriteTime.Date -lt $date.Date }
# Write-Host $fileList -Separator "`r`n"

Write-Host "Moving RPTs, ADMs and LOGs to ${destDir}:"
foreach ($file in $fileList) {
    Move-Item -Path $file -Destination $destDir -Force
    Write-Host "Moved ${file} to ${destDir}"
}
Write-Host "Total: $($fileList.Length)"

$fileList = Get-Item -Path $destDir\*.rpt, $destDir\*.log, $destDir\*.adm | Where-Object { $_.LastWriteTime -lt $date.AddDays(-($daysAmount)) }
# Write-Host $fileList -Separator "`r`n"

Write-Host "Removing RPTs, ADMs and LOGs:"
if ($noDelete) {
    If (!(Test-Path -PathType Container $destDelDir)) {
        New-Item -ItemType Directory -Path $destDelDir | Out-Null
        Write-Host "Created new folder: ${destDelDir}"
    }
    
    foreach ($file in $fileList) {
        Move-Item -Path $file -Destination $destDelDir -Force
        Write-Host "Moved ${file} to ${destDelDir}"
    }
} else {
    foreach ($file in $fileList) {
        Remove-Item -Path $file
        Write-Host "Removed ${file}!"
    }
}
Write-Host "Total: $($fileList.Length)"
Write-Host ""
#endregion

#region ### BEC ###
if ($becDestDir) {
    Write-Host "Rotating BEC logs..."
    # $fileList = $null

    If (!(Test-Path -PathType Container $becDestDir)) {
        New-Item -ItemType Directory -Path $becDestDir | Out-Null
        Write-Host "Created new folder: ${becDestDir}"
    }

    $fileList = Get-ChildItem -Path $becLogDir\*.log -Recurse | Where-Object { $_.LastWriteTime.Date -lt $date.Date }
    # Write-Host $fileList -Separator "`r`n"

    Write-Host "Moving BEC's LOGs to ${becDestDir}:"
    foreach ($file in $fileList) {
        Move-Item -Path $file -Destination $becDestDir -Force
        Write-Host "Moved ${file} to ${becDestDir}"
    }
    Write-Host "Total: $($fileList.Length)"

    $fileList = Get-Item -Path $becDestDir\*.log | Where-Object { $_.LastWriteTime -lt $date.AddDays(-($daysAmount)) }
    # Write-Host $fileList -Separator "`r`n"
    
    Write-Host "Removing BEC's LOGs:"
    if ($noDelete) {
        If (!(Test-Path -PathType Container $destDelDir)) {
            New-Item -ItemType Directory -Path $destDelDir | Out-Null
            Write-Host "Created new folder: ${destDelDir}"
        }
        
        foreach ($file in $fileList) {
            Move-Item -Path $file -Destination $destDelDir
            Write-Host "Moved ${file} to ${destDelDir}"
        }
    } else {
        foreach ($file in $fileList) {
            Remove-Item -Path $file
            Write-Host "Removed ${file}!"
        }
    }
    Write-Host "Total: $($fileList.Length)"
    Write-Host ""
}
#endregion

#region ### Admin Tool ###
if ($adminToolDestDir) {
    Write-Host "Rotating AdminTool logs..."
    
    If (!(Test-Path -PathType Container $adminToolDestDir)) {
        New-Item -ItemType Directory -Path $adminToolDestDir | Out-Null
        Write-Host "Created new folder: ${adminToolDestDir}"
    }
    
    $fileList = Get-ChildItem -Path $adminToolLogDir\*.txt, $adminToolLogDir\*.log -Recurse | Where-Object { $_.LastWriteTime.Date -lt $date.Date }
    # Write-Host $fileList -Separator "`r`n"

    Write-Host "Moving admintool's LOGs to ${adminToolDestDir}:"
    foreach ($file in $fileList) {
        Move-Item -Path $file -Destination $adminToolDestDir -Force
        Write-Host "Moved ${file} to ${adminToolDestDir}"
    }
    Write-Host "Total: $($fileList.Length)"

    $fileList = Get-Item -Path $adminToolDestDir\*.txt, $adminToolDestDir\*.log | Where-Object { $_.LastWriteTime -lt $date.AddDays(-($daysAmount)) }
    # Write-Host $fileList -Separator "`r`n"
    
    Write-Host "Removing admintool's LOGs:"
    if ($noDelete) {
        If (!(Test-Path -PathType Container $destDelDir)) {
            New-Item -ItemType Directory -Path $destDelDir | Out-Null
            Write-Host "Created new folder: ${destDelDir}"
        }

        foreach ($file in $fileList) {
                Move-Item -Path $file -Destination $destDelDir -Force
                Write-Host "Moved ${file} to ${destDelDir}"
        }
    } else {
        foreach ($file in $fileList) {
            Remove-Item -Path $file
            Write-Host "Removed ${file}!"
        }
    }
    Write-Host "Total: $($fileList.Length)"
    Write-Host ""
}
#endregion

Write-Host "End Log rotation powershell script"
