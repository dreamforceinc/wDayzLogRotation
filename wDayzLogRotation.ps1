# wDayzLogRotation v0.7
# Copyright (c) 2024 Vladislav Salikov aka W0LF aka 'dreamforce'
# https://github.com/dreamforceinc
#
# Input parameters:
# 	<Path to server's location> : Absolute, fully qualified path to server's root folder.
# 	<Name of instance>          : Usually name of folder inside the server's root folder. Can be absolute path.
# 	                            : In this case, the last part of path interpreted as the name of instance.
# 	[Path to BEC location]      : Optional. By default, BEC location inside the server's root folder.
#
# Example:
# 	powershell.exe -File "wDayzLogRotation.ps1" "Z:\Servers\DayZServer" "Instance_1" "D:\server tools\BEC"

# ------------------------------[ Configuration ]------------------------------
$daysAmount		= 7								# Number of days to store logs
$serverLocation	= "Z:\DayZServer"				# Path to server's location
$instance		= "Instance_1"					# Instance's NAME.
$becLocation	= "${serverLocation}\BEC"		# Path to BEC
$noDelete		= $false						# For tests - don't delete logs
# -----------------------------------------------------------------------------

if ($args[0]) { $serverLocation = $args[0] }
if ($args[1]) { $instance = $args[1] }
if ($args[2]) { $becLocation = $args[2] }

if ([System.IO.Path]::IsPathRooted($instance)) {
	$instanceDir = "${instance}"
	$instance = Split-Path -Path "${instanceDir}" -Leaf
} else {
	$instanceDir = "${serverLocation}\${instance}"
}

if (![System.IO.Path]::IsPathRooted($becLocation)) {
	$becLocation = "${serverLocation}\${becLocation}"
}

$destDir = "${instanceDir}\RotatedLogs"
$daysAmount = [Math]::Abs($daysAmount)
$becLogDir = "${becLocation}\Log\${instance}"
$becDestDir = "${destDir}\BEC"

Write-Host "Start Log rotation powershell script"
$date = Get-Date

# # Debug output
# Write-Host "serverLocation: '${serverLocation}'"
# Write-Host "      instance: '${instance}'"
# Write-Host "   instanceDir: '${instanceDir}'"
# Write-Host "       destDir: '${destDir}'"
# Write-Host "    destDelDir: '${destDelDir}'"
# Write-Host "   becLocation: '${becLocation}'"
# Write-Host "     becLogDir: '${becLogDir}'"
# Write-Host "    becDestDir: '${becDestDir}'"

Write-Host "Now DAYZ..."
$fileList = Get-Item -Path $instanceDir\*.rpt, $instanceDir\*.log, $instanceDir\*.adm | Where-Object { $_.LastWriteTime.Date -lt $date.Date }
# Write-Host $fileList -Separator "`r`n"

If (!(Test-Path -PathType Container $destDir)) {
	New-Item -ItemType Directory -Path $destDir | Out-Null
	Write-Host "Created new folder: ${destDir}"
}

Write-Host "Moving RPTs and LOGs to ${destDir}:"
foreach ($file in $fileList) {
	Move-Item -Path $file -Destination $destDir
	Write-Host "Moved ${file} to ${destDir}"
}
Write-Host "Total: $($fileList.Length)"

$fileList = Get-Item -Path $destDir\*.rpt, $destDir\*.log, $destDir\*.adm | Where-Object { $_.LastWriteTime -lt $date.AddDays(-($daysAmount)) }
# Write-Host $fileList -Separator "`r`n"

Write-Host "Removing RPTs, ADMs and LOGs:"
$destDelDir = $destDir
if ($noDelete) {
	$destDelDir = "${destDir}\DeletedLogs"
	
	If (!(Test-Path -PathType Container $destDelDir)) {
		New-Item -ItemType Directory -Path $destDelDir | Out-Null
		Write-Host "Created new folder: ${destDelDir}"
	}

	foreach ($file in $fileList) {
		Move-Item -Path $file -Destination $destDelDir
		Write-Host "Moved ${file} to ${destDelDir}"
	}
}
else {
	foreach ($file in $fileList) {
		Remove-Item -Path $file
		Write-Host "Removed ${file}!"
	}
}
Write-Host "Total: $($fileList.Length)"
Write-Host ""

### BEC ###
Write-Host "Now BEC..."

If (!(Test-Path -PathType Container $becDestDir)) {
	New-Item -ItemType Directory -Path $becDestDir | Out-Null
	Write-Host "Created new folder: ${becDestDir}"
}

$fileList = Get-ChildItem -Path $becLogDir\*.log -Recurse | Where-Object { $_.LastWriteTime.Date -lt $date.Date }
# Write-Host $fileList -Separator "`r`n"

Write-Host "Moving BEC's LOGs to ${becDestDir}:"
foreach ($file in $fileList) {
	Move-Item -Path $file -Destination $becDestDir
	Write-Host "Moved ${file} to ${becDestDir}"
}
Write-Host "Total: $($fileList.Length)"

$fileList = Get-Item -Path $becDestDir\*.log | Where-Object { $_.LastWriteTime -lt $date.AddDays(-($daysAmount)) }
# Write-Host $fileList -Separator "`r`n"

Write-Host "Removing BEC's LOGs:"
if ($noDelete) {
	foreach ($file in $fileList) {
		Move-Item -Path $file -Destination $destDelDir
		Write-Host "Moved ${file} to ${destDelDir}"
	}
}
else {
	foreach ($file in $fileList) {
		Remove-Item -Path $file
		Write-Host "Removed ${file}!"
	}
}
Write-Host "Total: $($fileList.Length)"

Write-Host "End Log rotation powershell script"
