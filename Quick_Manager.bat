@echo off
REM One-Click FBR SAP Integration Service Manager
REM Double-click this file to quickly manage the service

title FBR SAP Integration - One Click Manager
color 0A

:main_menu
cls
echo.
echo  ===============================================
echo  FBR SAP B1 Integration - One Click Manager
echo  ===============================================
echo.

REM Check if service exists
sc query FBR_SAP_Integration >nul 2>&1
if %errorLevel% neq 0 (
    echo  [ERROR] Service not found!
    echo  Please run deployment\deploy.bat first to install the service.
    echo.
    goto :end_pause
)

REM Get current service status
echo  Checking service status...
deployment\nssm.exe status FBR_SAP_Integration >nul 2>&1
if %errorLevel% equ 0 (
    for /f %%i in ('deployment\nssm.exe status FBR_SAP_Integration') do set SERVICE_STATUS=%%i
) else (
    set SERVICE_STATUS=UNKNOWN
)

echo  Service Status: %SERVICE_STATUS%
echo.

if /i "%SERVICE_STATUS%"=="SERVICE_RUNNING" (
    echo  [1] Stop Service
    echo  [2] Restart Service
    echo  [3] View Logs
    echo  [4] Test Application
    echo  [5] Service Details
    echo  [0] Exit
) else (
    echo  [1] Start Service  
    echo  [2] View Logs
    echo  [3] Test Application
    echo  [4] Service Details
    echo  [5] Reinstall Service
    echo  [0] Exit
)

echo.
set /p choice="Select option (0-5): "

if "%choice%"=="0" goto :exit
if "%choice%"=="1" goto :option1
if "%choice%"=="2" goto :option2
if "%choice%"=="3" goto :option3
if "%choice%"=="4" goto :option4
if "%choice%"=="5" goto :option5

echo Invalid choice. Please try again.
timeout /t 2 >nul
goto :main_menu

:option1
cls
if /i "%SERVICE_STATUS%"=="SERVICE_RUNNING" (
    echo Stopping FBR SAP Integration service...
    deployment\nssm.exe stop FBR_SAP_Integration
    if %errorLevel% equ 0 (
        echo Service stopped successfully.
    ) else (
        echo Failed to stop with NSSM, trying alternative...
        net stop FBR_SAP_Integration
    )
) else (
    echo Starting FBR SAP Integration service...
    deployment\nssm.exe start FBR_SAP_Integration
    if %errorLevel% equ 0 (
        echo Service started successfully.
        echo Waiting for initialization...
        timeout /t 5 /nobreak >nul
    ) else (
        echo Failed to start with NSSM, trying alternative...
        net start FBR_SAP_Integration
    )
)
echo.
pause
goto :main_menu

:option2
cls
if /i "%SERVICE_STATUS%"=="SERVICE_RUNNING" (
    echo Restarting FBR SAP Integration service...
    deployment\nssm.exe restart FBR_SAP_Integration
    if %errorLevel% equ 0 (
        echo Service restarted successfully.
        echo Waiting for initialization...
        timeout /t 5 /nobreak >nul
    ) else (
        echo Failed to restart with NSSM, trying manual restart...
        net stop FBR_SAP_Integration
        timeout /t 3 /nobreak >nul
        net start FBR_SAP_Integration
    )
) else (
    echo Viewing recent logs...
    goto :show_logs
)
echo.
pause
goto :main_menu

:option3
:show_logs
cls
echo ===============================================
echo Recent Application Logs
echo ===============================================
if exist "logs\fbr_integration.log" (
    powershell -command "Get-Content logs\fbr_integration.log -Tail 20" 2>nul || (
        echo [PowerShell not available, showing last part of log]
        type logs\fbr_integration.log
    )
) else (
    echo No application log found: logs\fbr_integration.log
)

echo.
echo ===============================================
echo Recent Service Errors (if any)
echo ===============================================
if exist "logs\service_stderr.log" (
    powershell -command "if ((Get-Content logs\service_stderr.log -ErrorAction SilentlyContinue) -ne $null) { Get-Content logs\service_stderr.log -Tail 10 } else { Write-Host 'No errors logged' }" 2>nul || (
        if exist "logs\service_stderr.log" (
            type logs\service_stderr.log
        ) else (
            echo No errors logged
        )
    )
) else (
    echo No error log found (normal if no errors occurred)
)
echo.
pause
goto :main_menu

:option4
cls
echo Testing FBR SAP Integration application...
echo.
echo Step 1: Validating system configuration...
venv\Scripts\python.exe src\main.py --validate
set VALIDATE_RESULT=%errorLevel%

echo.
if %VALIDATE_RESULT% equ 0 (
    echo Validation successful!
    echo.
    echo Step 2: Running one-time processing test...
    venv\Scripts\python.exe src\main.py --run-once
    if %errorLevel% equ 0 (
        echo.
        echo Test completed successfully!
    ) else (
        echo.
        echo Test completed with warnings. Check logs for details.
    )
) else (
    echo Validation failed!
    echo Please check your .env configuration file.
    echo Common issues:
    echo - Database connection settings
    echo - FBR API credentials
    echo - Network connectivity
)
echo.
pause
goto :main_menu

:option5
cls
if /i "%SERVICE_STATUS%"=="SERVICE_RUNNING" (
    echo ===============================================
    echo Service Details
    echo ===============================================
    echo.
    echo NSSM Status:
    deployment\nssm.exe status FBR_SAP_Integration
    echo.
    echo Windows Service Info:
    sc query FBR_SAP_Integration
    echo.
    echo Service Configuration:
    echo Working Directory: %CD%
    echo Python Path: %CD%\venv\Scripts\python.exe
    echo Script Path: %CD%\src\main.py
    echo Log Directory: %CD%\logs
    echo.
    echo Recent Performance:
    if exist "logs\fbr_integration.log" (
        echo Last application startup:
        findstr /C:"FBR Integration Service initialized" logs\fbr_integration.log | powershell -command "$input | Select-Object -Last 1" 2>nul || (
            findstr /C:"Service initialized" logs\fbr_integration.log
        )
    )
) else (
    echo Reinstalling FBR SAP Integration service...
    echo.
    echo This will:
    echo 1. Remove existing service
    echo 2. Reinstall with current configuration
    echo 3. Start the service
    echo.
    set /p confirm="Continue? (y/n): "
    if /i not "%confirm%"=="y" goto :main_menu
    
    echo.
    echo Removing existing service...
    deployment\nssm.exe stop FBR_SAP_Integration >nul 2>&1
    deployment\nssm.exe remove FBR_SAP_Integration confirm >nul 2>&1
    
    echo Installing service...
    deployment\nssm.exe install FBR_SAP_Integration "%CD%\venv\Scripts\python.exe" "%CD%\src\main.py" --run-forever
    if %errorLevel% neq 0 (
        echo Failed to install service!
        goto :end_pause
    )
    
    echo Configuring service...
    deployment\nssm.exe set FBR_SAP_Integration AppDirectory "%CD%"
    deployment\nssm.exe set FBR_SAP_Integration DisplayName "FBR SAP B1 Integration Service"
    deployment\nssm.exe set FBR_SAP_Integration Start SERVICE_AUTO_START
    deployment\nssm.exe set FBR_SAP_Integration AppStdout "%CD%\logs\service_stdout.log"
    deployment\nssm.exe set FBR_SAP_Integration AppStderr "%CD%\logs\service_stderr.log"
    
    echo Starting service...
    deployment\nssm.exe start FBR_SAP_Integration
    if %errorLevel% equ 0 (
        echo Service reinstalled and started successfully!
    ) else (
        echo Service installed but failed to start. Check logs for details.
    )
)
echo.
pause
goto :main_menu

:exit
cls
echo.
echo Thank you for using FBR SAP Integration Manager!
echo.
timeout /t 2 >nul
exit /b 0

:end_pause
echo.
pause
exit /b 1