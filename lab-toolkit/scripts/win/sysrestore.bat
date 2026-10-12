@echo off
:: Set variables for software paths and restore point name
set "restorePointName=MaintenanceSept2026"
:: Check if the script is running with administrator privileges
whoami /groups | find "S-1-5-32-544" >nul
if not %errorlevel%==0 (
   echo This script requires administrator privileges.
   echo Please run it as an administrator.
   pause
   exit /b 1
)
:: Create a system-wide restore point after installations
echo Creating system-wide restore point...
powershell -Command "Checkpoint-Computer -Description '%restorePointName%' -RestorePointType 'MODIFY_SETTINGS'"
if %errorlevel%==0 (
   echo System restore point '%restorePointName%' created successfully.
) else (
   echo Failed to create system-wide restore point. Exiting...
   pause
   exit /b 1
)
echo All tasks completed successfully.
pause
exit /b 0