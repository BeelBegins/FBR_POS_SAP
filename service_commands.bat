@echo off
REM FBR SAP Integration Service Management Commands
REM Use these commands in Command Prompt (cmd) on any Windows system

echo ===============================================
echo FBR SAP Integration Service Management
echo ===============================================
echo.

if "%1"=="" goto :show_commands

if /i "%1"=="start" goto :start_service
if /i "%1"=="stop" goto :stop_service  
if /i "%1"=="restart" goto :restart_service
if /i "%1"=="status" goto :check_status
if /i "%1"=="logs" goto :view_logs
if /i "%1"=="test" goto :test_app
if /i "%1"=="help" goto :show_commands
goto :show_commands

:start_service
echo Starting FBR SAP Integration service...
deployment\nssm.exe start FBR_SAP_Integration
if %errorLevel% equ 0 (
    echo Service start command sent successfully.
    timeout /t 3 /nobreak >nul
    echo Checking status...
    deployment\nssm.exe status FBR_SAP_Integration
) else (
    echo Failed to start service with NSSM, trying Windows service command...
    net start FBR_SAP_Integration
)
goto :end

:stop_service
echo Stopping FBR SAP Integration service...
deployment\nssm.exe stop FBR_SAP_Integration
if %errorLevel% equ 0 (
    echo Service stop command sent successfully.
    timeout /t 2 /nobreak >nul
    deployment\nssm.exe status FBR_SAP_Integration
) else (
    echo Failed to stop service with NSSM, trying Windows service command...
    net stop FBR_SAP_Integration
)
goto :end

:restart_service
echo Restarting FBR SAP Integration service...
deployment\nssm.exe restart FBR_SAP_Integration
if %errorLevel% equ 0 (
    echo Service restart command sent successfully.
    timeout /t 5 /nobreak >nul
    deployment\nssm.exe status FBR_SAP_Integration
) else (
    echo Failed to restart with NSSM, trying manual stop/start...
    net stop FBR_SAP_Integration
    timeout /t 3 /nobreak >nul
    net start FBR_SAP_Integration
)
goto :end

:check_status
echo Checking FBR SAP Integration service status...
echo.
echo NSSM Status:
deployment\nssm.exe status FBR_SAP_Integration
echo.
echo Windows Service Status:
sc query FBR_SAP_Integration
echo.
echo Service Manager Status:
net start | findstr /i "FBR"
goto :end

:view_logs
echo Recent Application Logs:
echo ========================
if exist "logs\fbr_integration.log" (
    echo Last 15 lines from application log:
    powershell -command "Get-Content logs\fbr_integration.log -Tail 15" 2>nul || (
        echo PowerShell not available, showing with more command:
        type logs\fbr_integration.log | more
    )
) else (
    echo Application log file not found: logs\fbr_integration.log
)

echo.
echo Recent Service Error Logs:
echo ==========================
if exist "logs\service_stderr.log" (
    echo Last 10 lines from service error log:
    powershell -command "Get-Content logs\service_stderr.log -Tail 10" 2>nul || (
        type logs\service_stderr.log | more
    )
) else (
    echo No service error log found (this is normal if no errors occurred)
)

echo.
echo Recent Service Output Logs:
echo ===========================
if exist "logs\service_stdout.log" (
    echo Last 10 lines from service output log:
    powershell -command "Get-Content logs\service_stdout.log -Tail 10" 2>nul || (
        type logs\service_stdout.log | more
    )
) else (
    echo No service output log found
)
goto :end

:test_app
echo Testing FBR SAP Integration application...
echo.
echo Running validation test...
venv\Scripts\python.exe src\main.py --validate
if %errorLevel% equ 0 (
    echo.
    echo Validation successful! Running one-time processing test...
    venv\Scripts\python.exe src\main.py --run-once
) else (
    echo.
    echo Validation failed. Please check your configuration in .env file
)
goto :end

:show_commands
echo Usage: service_commands.bat [command]
echo.
echo Available commands:
echo   start     - Start the FBR SAP Integration service
echo   stop      - Stop the FBR SAP Integration service  
echo   restart   - Restart the FBR SAP Integration service
echo   status    - Show detailed service status
echo   logs      - Display recent log entries
echo   test      - Test the application manually
echo   help      - Show this help message
echo.
echo Examples:
echo   service_commands.bat start
echo   service_commands.bat status
echo   service_commands.bat logs
echo.
echo Direct commands you can also use:
echo   deployment\nssm.exe status FBR_SAP_Integration
echo   deployment\nssm.exe start FBR_SAP_Integration
echo   deployment\nssm.exe stop FBR_SAP_Integration
echo   net start FBR_SAP_Integration
echo   net stop FBR_SAP_Integration
echo   sc query FBR_SAP_Integration
echo.
echo Log files location:
echo   logs\fbr_integration.log     - Main application log
echo   logs\service_stderr.log      - Service error log
echo   logs\service_stdout.log      - Service output log
echo.

:end
echo.
echo For more help, see TROUBLESHOOTING.md file
echo.
pause