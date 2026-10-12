@echo off
setlocal enabledelayedexpansion

:: --- ADMIN PRIVILEGES CHECK ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator.
    echo Please right-click this file and select "Run as administrator".
    pause
    exit /b
)

echo Creating shortcuts... Please wait.
echo.

:: --- CONFIGURATION ---
set "START_MENU=%ProgramData%\Microsoft\Windows\Start Menu\Programs"

:: Shortcut 1 Details
set "APP1_NAME=Audacity 4"
set "APP1_EXE=C:\Program Files\Audacity 4\bin\Audacity4.exe"
set "APP1_DIR=C:\Program Files\Audacity 4\bin"

:: Shortcut 2 Details
set "APP2_NAME=Native Access"
set "APP2_EXE=C:\Program Files\Native Instruments\Native Access\Native Access.exe"
set "APP2_DIR=C:\Program Files\Native Instruments\Native Access"

:: --- STEP 1: CREATE AUDACITY SHORTCUT ---
if exist "%APP1_EXE%" (
    echo Set oWS = WScript.CreateObject^("WScript.Shell"^) > "%TEMP%\shortcut.vbs"
    echo sLinkFile = "%START_MENU%\%APP1_NAME%.lnk" >> "%TEMP%\shortcut.vbs"
    echo Set oLink = oWS.CreateShortcut^(sLinkFile^) >> "%TEMP%\shortcut.vbs"
    echo oLink.TargetPath = "%APP1_EXE%" >> "%TEMP%\shortcut.vbs"
    echo oLink.WorkingDirectory = "%APP1_DIR%" >> "%TEMP%\shortcut.vbs"
    echo oLink.Save >> "%TEMP%\shortcut.vbs"
    
    cscript /nologo "%TEMP%\shortcut.vbs"
    del "%TEMP%\shortcut.vbs"
    echo [SUCCESS] Shortcut created for %APP1_NAME%
) else (
    echo [ERROR] Could not find Audacity4.exe at the specified path.
)

:: --- STEP 2: CREATE NATIVE ACCESS SHORTCUT ---
if exist "%APP2_EXE%" (
    echo Set oWS = WScript.CreateObject^("WScript.Shell"^) > "%TEMP%\shortcut.vbs"
    echo sLinkFile = "%START_MENU%\%APP2_NAME%.lnk" >> "%TEMP%\shortcut.vbs"
    echo Set oLink = oWS.CreateShortcut^(sLinkFile^) >> "%TEMP%\shortcut.vbs"
    echo oLink.TargetPath = "%APP2_EXE%" >> "%TEMP%\shortcut.vbs"
    echo oLink.WorkingDirectory = "%APP2_DIR%" >> "%TEMP%\shortcut.vbs"
    echo oLink.Save >> "%TEMP%\shortcut.vbs"
    
    cscript /nologo "%TEMP%\shortcut.vbs"
    del "%TEMP%\shortcut.vbs"
    echo [SUCCESS] Shortcut created for %APP2_NAME%
) else (
    echo [ERROR] Could not find Native Access.exe at the specified path.
)

echo.
echo Operation complete!
pause
