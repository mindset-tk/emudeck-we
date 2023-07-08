::::::::::::::::::::::::::::::::::::::::::::
:: Elevate.cmd - Version 4
:: Automatically check & get admin rights
:: see "https://stackoverflow.com/a/12264592/1016343" for description
::::::::::::::::::::::::::::::::::::::::::::
 @Write-Output off
 CLS
 ECHO.
 Write-Output =============================
 Write-Output Running Admin shell
 Write-Output =============================

:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~dpnx0"
 rem this works also from cmd shell, other than %~0
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (Write-Output ELEV & shift /1 & goto gotPrivileges)
  ECHO.
  Write-Output **************************************
  Write-Output Invoking UAC for Privilege Escalation
  Write-Output **************************************

  Write-Output Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  Write-Output args = "ELEV " >> "%vbsGetPrivileges%"
  Write-Output For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  Write-Output args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  Write-Output Next >> "%vbsGetPrivileges%"
  
  if '%cmdInvoke%'=='1' goto InvokeCmd 

  Write-Output UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  Write-Output args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  Write-Output UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

 ::::::::::::::::::::::::::::
 ::START
 ::::::::::::::::::::::::::::


echo|set /p="Setting up Steam UI..."
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /t REG_SZ /d "cmd /c start /min """GamingMode""" """%USERPROFILE%\AppData\Roaming\EmuDeck\backend\tools\gamemode\logon.bat"""" /f
IF %ERRORLEVEL% == 0 ( Write-Output OK! ) ELSE ( Write-Output FAIL! )
taskkill /F /IM sihost.exe

echo|set /p="Waiting for changes to be enabled, this will take some seconds..." 
timeout /T 5 /nobreak > NUL 2>NUL
start C:\Windows\System32\sihost.exe
timeout /T 5 /nobreak > NUL 2>NUL
IF %ERRORLEVEL% == 0 ( Write-Output OK! ) ELSE ( Write-Output FAIL! )

taskkill /f /im explorer.exe
"C:\Program Files (x86)\Steam\steam.exe" "-bigpicture" && cmd /c start /min "" "%USERPROFILE%\AppData\Roaming\EmuDeck\backend\tools\gamemode\desktopmode.bat"

echo|set /p="Starting Steam UI" 
exit