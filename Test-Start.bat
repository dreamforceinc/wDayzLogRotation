@echo off
:: !!! Needs 'DAYZSERVERSLOCATION' envvar defined !!!
:: !!! setx DAYZSERVERSLOCATION Z:\Servers\DayZServer [/m]

::Server name
set serverName=RU11 Test Server
::Server files location
set serverLocation=%DAYZSERVERSLOCATION%
::Server profile location
set serverProfile=Instance_4
::Server Port
set serverPort=35400
::Logical CPU cores to use (Equal or less than available)
set serverCPU=2
::Server config
set serverConfig=serverDZ.cfg
::Server mods
set serverMods=
::Client mods
set clientMods=@CF;@VPPadminTools;@VanillaPlusPlusMap;@KAMAZ
::Startup parameters
set startupParams=-profiles=%serverProfile% -config=%serverProfile%\%serverConfig% -name=Server -port=%serverPort%
::Additional Startup parameters
set additionalParams=-cpuCount=%serverCPU% -adminLog
::Path to log rotation script
set scriptLocation=D:\Sync\SRC\PowerShell\wDayzLogRotation\wDayzLogRotation.ps1
@REM set scriptLocation=%serverLocation%\wDayzLogRotation.ps1
::BEC location
set becLocation=%serverLocation%\BEC
@REM set becLocation=
::AdminTool's logs location
set adminToolLogsLocation=%serverLocation%\%serverProfile%\VPPadminTools\Logging
@REM set adminToolLogsLocation=


:: !!! (DON'T EDIT BELOW) !!!
::Sets title for terminal
title %serverName% batch
set cwd=%CD%
cd /d "%serverLocation%"

::Prepare commandline
if defined serverMods set tsm="-serverMod=%serverMods%"
if defined clientMods set tcm="-mod=%clientMods%"
set allMods=%tsm% %tcm%
set cmdLine="DayZServer_x64.exe" %startupParams% %additionalParams% %allMods%

::BEC's logs location
if defined becLocation (
	set becLogsLocation=%becLocation%\Log\%serverProfile%
) else (
	set becLogsLocation=
)

::Start log rotation
powershell.exe -File "%scriptLocation%" "%serverLocation%" "%serverLocation%\%serverProfile%" "%becLogsLocation%" "%adminToolLogsLocation%"

goto _exit

timeout 3 /nobreak >nul
echo.

::Start DayZServer
start "DayZ %serverProfile%" /high %cmdLine%

::Start BEC
cd /d "%becLocation%"
start "BEC %serverProfile%" "%becLocation%\Bec.exe" -f %serverProfile%.cfg --dsc

:_exit
cd /d "%cwd%"
echo END
