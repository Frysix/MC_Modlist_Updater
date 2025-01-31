@echo off
setlocal enabledelayedexpansion
powershell -executionpolicy bypass -command "function Get-AdminStatus {if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {return $false} else {return $true}} $Status = Get-AdminStatus; $Status | out-file -filepath """%~dp0\Status.txt""" -encoding ascii; if (-not ($Status)) {start-process -filepath """%~dp0\Frysix_Server_Modlist_Updater.bat""" -verb runas}"
for /f "usebackq delims=" %%a in ("%~dp0\Status.txt") do (set "Status=%%a")
if "!Status!"=="False" (goto end)
powershell -executionpolicy bypass -command "if (test-path -path """%~dp0\Status.txt""") {remove-item -path """%~dp0\Status.txt""" -recurse -force}"
powershell -executionpolicy bypass -command "if (test-path -path """%~dp0\Updater.ps1""") {remove-item -path """%~dp0\Updater.ps1""" -recurse -force}; function Get-InternetStatus {if (test-connection 'google.com' -count 1 -quiet) {return $true} else {return $false}}; while (-not (Get-InternetStatus)) {Write-Host 'Please Connect to internet to install'}; Invoke-Webrequest -uri 'https://raw.githubusercontent.com/Frysix/MC_Modlist_Updater/refs/heads/main/Updater.ps1' -outfile """%~dp0\Updater.ps1""";"
start powershell -executionpolicy bypass -file "%~dp0\Updater.ps1" -verb runas 
:end
powershell -executionpolicy bypass -command "if (test-path -path """%~dp0\Status.txt""") {remove-item -path """%~dp0\Status.txt""" -recurse -force}"
exit