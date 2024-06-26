@echo off
:: Start-Test-Server v0.3
:: Copyright (c) 2024 Vladislav Salikov aka W0LF aka 'dreamforce'
:: https://github.com/dreamforceinc

:: !!! Needs 'DAYZSERVER' envvar defined !!!
:: !!! Example: SETX DAYZSERVER Z:\Servers\DayZServer

::Server name
set serverName=RU11 Test Server
::Server files location. Required!
set serverLocation=%DAYZSERVER%
::Server profile location
set serverProfile=Instance_0
::Server Port
set serverPort=2302
::Logical CPU cores to use (Equal or less than available)
set serverCPU=2
::Server config
set serverConfig=serverDZ.cfg
::Server mods
set serverMods=
::Client mods
set clientMods=@CF;@VPPadminTools;@VanillaPlusPlusMap
::Startup parameters
set startupParams=-profiles=profiles\%serverProfile% -config=profiles\%serverProfile%\%serverConfig% -name=Server -port=%serverPort%
::Additional Startup parameters
set additionalParams=-cpuCount=%serverCPU% -adminLog
::Path to log rotation script
set scriptLocation=%serverLocation%\wDayzLogRotation.ps1
::Path to store rotated logs. Required!
set rotatedLogsLocation=%serverLocation%\.RotatedLogs\%serverProfile%
::BEC location. Optional. Leave it blank if you don't use BEC.
set becLocation=%serverLocation%\BEC
::AdminTool's logs location. Optional. Leave it blank if you don't use any admin tool.
set adminToolLogsLocation=%serverLocation%\profiles\%serverProfile%\VPPadminTools\Logging



::
:: !!! (DON'T EDIT BELOW) !!!
::
if not defined serverLocation (
    echo.
    echo ERROR !!!
    echo Environment variable DAYZSERVER is not defined!
    echo You MUST define it before calling this batch script
    echo by command 'SETX DAYZSERVER "drive:\path\to\server"'
    goto _exit
)
if not defined rotatedLogsLocation (
    echo.
    echo ERROR !!!
    echo You MUST provide 'rotatedLogsLocation' variable!
    goto _exit
)

::Sets title for terminal
title %serverName% batch
set CWD=%CD%
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

:: Debug output ::
@REM echo serverLocation = '%serverLocation%'
@REM echo rotatedLogsLocation = '%rotatedLogsLocation%'
@REM echo becLocation = '%becLocation%'
@REM echo adminToolLogsLocation = '%adminToolLogsLocation%'
@REM echo.

::Start log rotation
powershell.exe -File "%scriptLocation%" -Server "%serverLocation%" -Instance "%serverLocation%\%serverProfile%" -RotatedLogs "%rotatedLogsLocation%" -BecLogs "%becLogsLocation%" -ATLogs "%adminToolLogsLocation%"
timeout 5 /nobreak >nul
echo.

::Start DayZServer
start "DayZ %serverProfile%" /high %cmdLine%
echo.

::Start BEC
if defined becLocation (
    cd /d "%becLocation%"
    start "BEC %serverProfile%" "%becLocation%\Bec.exe" -f %serverProfile%.cfg --dsc
    echo.
)

:_exit
cd /d "%CWD%"
