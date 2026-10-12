@echo off
setlocal enabledelayedexpansion

:: --- ADMIN PRIVILEGES CHECK ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator.
    echo Right-click the file and select "Run as administrator".
    pause
    exit /b
)

:: --- CONFIGURATION ---
set "LOG_FILE=%~dp0installation_log.txt"
:: ---------------------

echo =================================================== >> "%LOG_FILE%"
echo Installation started on %DATE% at %TIME% >> "%LOG_FILE%"
echo =================================================== >> "%LOG_FILE%"

echo Processing installers... Please wait.
echo Logs are being saved to: %LOG_FILE%
echo.

:: 1. LOOP THROUGH MSI FILES
for %%F in ("%~dp0*.msi") do (
    call :InstallMSI "%%F" "%%~nxF"
)

:: 2. LOOP THROUGH EXE FILES
for %%F in ("%~dp0*.exe") do (
    if /I "%%~nxF" neq "%~nx0" (
        call :InstallEXE "%%F" "%%~nxF"
    )
)

echo =================================================== >> "%LOG_FILE%"
echo Installation cycle complete at %TIME% >> "%LOG_FILE%"
echo =================================================== >> "%LOG_FILE%"

echo Process finished. Please review "%LOG_FILE%" for detailed error tracking.
pause
exit /b

:: ---------------------------------------------------
:: SUB-ROUTINES
:: ---------------------------------------------------

:InstallMSI
echo Installing: %~2...
echo [%TIME%] INSTALLING: %~2 >> "%LOG_FILE%"

:: Standard MSI switches with forced shortcut creation property if supported
start "" /wait msiexec.exe /i "%~1" /qn /norestart ADDSHORTCUT=1
set "EXIT_CODE=%errorlevel%"

call :LogAndShortcut %EXIT_CODE% "%~1" "%~2"
goto :eof

:InstallEXE
echo Installing: %~2...
echo [%TIME%] INSTALLING: %~2 >> "%LOG_FILE%"

:: Check if the file is the REAPER installer to avoid conflicting switches
echo "%~2" | find /i "reaper" >nul
if %errorlevel% equ 0 (
    :: REAPER strictly requires a lone, capital /S switch
    start "" /wait "%~1" /S
) else (
    :: Standard common fallback switches for other EXEs
    start "" /wait "%~1" /S /silent /quiet /qn
)
set "EXIT_CODE=%errorlevel%"

call :LogAndShortcut %EXIT_CODE% "%~1" "%~2"
goto :eof

:: ---------------------------------------------------
:: LOGGING & START MENU SHORTCUT ENFORCEMENT
:: ---------------------------------------------------
:LogAndShortcut
set "CODE=%1"
set "FULL_PATH=%~2"
set "FILE_NAME=%~3"
set "APP_NAME=%~n3"

if %CODE% equ 0 (
    echo [SUCCESS] %FILE_NAME% installed successfully. >> "%LOG_FILE%"
) else if %CODE% equ 3010 (
    echo [WARNING] %FILE_NAME% installed successfully, but requires a REBOOT. >> "%LOG_FILE%"
    set CODE=0
) else (
    echo [ERROR] %FILE_NAME% failed with exit code: %CODE% >> "%LOG_FILE%"
)

:: If the installation was successful, check/force a Start Menu shortcut
if %CODE% equ 0 (
    :: Search both Common and User Start Menu paths for any matching shortcut name
    set "FOUND_LNK=0"
    if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\*%%APP_NAME%*.lnk" set "FOUND_LNK=1"
    if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\*%%APP_NAME%*.lnk" set "FOUND_LNK=1"
    
    :: Specialized check for REAPER path architecture
    if exist "%ProgramData%\Microsoft\Windows\Start Menu\Programs\REAPER*" set "FOUND_LNK=1"
    
    :: If no shortcut was made natively by the silent flag, create it manually via Program Files lookup
    if !FOUND_LNK! equ 0 (
        echo [INFO] Enforcing Start Menu shortcut for %APP_NAME%...
        
        powershell -NoProfile -ExecutionPolicy Bypass -Command ^
            "$appName = '%APP_NAME%';" ^
            "$target = Get-ChildItem -Path 'C:\Program Files', 'C:\Program Files (x86)' -Filter \"*$appName*.exe\" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1;" ^
            "if ($target) {" ^
            "    $wshell = New-Object -ComObject WScript.Shell;" ^
            "    $lnkPath = \"$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$appName.lnk\";" ^
            "    $shortcut = $wshell.CreateShortcut($lnkPath);" ^
            "    $shortcut.TargetPath = $target.FullName;" ^
            "    $shortcut.WorkingDirectory = $target.DirectoryName;" ^
            "    $shortcut.Save();" ^
            "    Add-Content '%LOG_FILE%' '[SHORTCUT] Successfully forced Start Menu item for: '$appName;" ^
            "} else {" ^
            "    Add-Content '%LOG_FILE%' '[SHORTCUT ALERT] Could not auto-locate deployed .exe in Program Files to create shortcut.';" ^
            "}"
    )
)
echo --------------------------------------------------- >> "%LOG_FILE%"
goto :eof
