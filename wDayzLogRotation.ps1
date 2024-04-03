# wDayzLogRotation 0.4
# Input parameters:
# 	<Server location>
# 	<Name (location) of instance>
#
# Example:
# 	powershell.exe -File "wDayzLogRotation.ps1" "Z:\Servers\DayZServer" "Instance_1"
#
$date = Get-Date			# Get current system date
$daysAmount = 7				# Number of days to store logs
$noDelete = $false			# For tests - don't delete logs
$serverLocation = $args[0]	# Path to server's location
$instance = $args[1]		# Instance's name of folder

Write-Host "Start Log rotation powershell script"

$instanceDir = "${serverLocation}\${instance}"
$destDir = "${instanceDir}\RotatedLogs"
$destDelDir = $destDir
$daysAmount = [Math]::Abs($daysAmount)
$becLocation = "${serverLocation}\BEC"
$becLogDir = "${becLocation}\Log\${instance}"
$becDestDir = "${destDir}\BEC"

Write-Host "Now DAYZ..."
$fileList = Get-Item -Path $instanceDir\*.rpt, $instanceDir\*.log | Where-Object { $_.LastWriteTime.Date -lt $date.Date }
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

$fileList = Get-Item -Path $destDir\*.rpt, $destDir\*.log | Where-Object { $_.LastWriteTime -lt $date.AddDays(-($daysAmount)) }
# Write-Host $fileList -Separator "`r`n"

Write-Host "Removing RPTs and LOGs:"
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
