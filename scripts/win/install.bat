@echo off
setlocal

:: Check if the script is running with administrative privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This script must be run as an Administrator.
    echo Right-click the file and select "Run as administrator".
    pause
    exit /b
)

:: Configure log file path
set "LOG_FILE=%~dp0installation_log.txt"

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
start "" /wait msiexec.exe /i "%~1" /qn /norestart
call :Log %errorlevel% "%~2"
goto :eof

:InstallEXE
echo Installing: %~2...
echo [%TIME%] INSTALLING: %~2 >> "%LOG_FILE%"
start "" /wait "%~1" /S /silent /quiet /qn
call :Log %errorlevel% "%~2"
goto :eof

:: ---------------------------------------------------
:: LOGGING
:: ---------------------------------------------------
:Log
set "CODE=%1"
set "FILE_NAME=%~2"

if %CODE% equ 0 (
    echo [SUCCESS] %FILE_NAME% installed successfully. >> "%LOG_FILE%"
) else if %CODE% equ 3010 (
    echo [WARNING] %FILE_NAME% installed successfully, but requires a REBOOT. >> "%LOG_FILE%"
) else (
    echo [ERROR] %FILE_NAME% failed with exit code: %CODE% >> "%LOG_FILE%"
)
echo --------------------------------------------------- >> "%LOG_FILE%"
goto :eof