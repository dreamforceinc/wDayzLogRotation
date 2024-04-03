# wDayzLogRotation 0.2

$date = Get-Date

Write-Host "Start Log rotation powershell script"

$instanceDir = $args[0]
$destDir = $instanceDir + "\RotatedLogs"
$fileList = Get-Item -Path $instanceDir\*.rpt, $instanceDir\*.log | Where-Object { $_.LastWriteTime.Date -lt $date.Date }
# Write-Host $fileList -Separator "`r`n"

If (!(Test-Path -PathType Container $destDir)) {
	New-Item -ItemType Directory -Path $destDir | Out-Null
}

foreach ($file in $fileList) {
	Move-Item -Path $file -Destination $destDir
	# Write-Host $file -Separator "`r`n"
}
# Write-Host "Total: $($fileList.Length)"

$fileList = Get-Item -Path $destDir\*.rpt, $destDir\*.log | Where-Object { $_.LastWriteTime -lt $date.AddMonths(-1) }
# $destDir += "\DeletedLogs"

# If (!(Test-Path -PathType Container $destDir)) {
# 	New-Item -ItemType Directory -Path $destDir | Out-Null
# }

foreach ($file in $fileList) {
	# Move-Item -Path $file -Destination $destDir
	Remove-Item -Path $file
}

Write-Host "End Log rotation powershell script"
