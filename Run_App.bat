@echo off
REM One-Click FBR SAP Integration Application Runner
REM Run the integration directly as an application with real-time logs
REM Use this when the service is not working or for troubleshooting

title FBR SAP B1 Integration - Application Mode
color 0F

echo ================================================================================
echo FBR SAP B1 Integration - Application Mode
echo ================================================================================
echo.
echo This will run the FBR integration directly as an application.
echo You will see real-time logs and can stop it with Ctrl+C.
echo.
echo Use this mode when:
echo - The Windows service is not working
echo - You want to see real-time logs
echo - Troubleshooting configuration issues
echo - Testing the application manually
echo.

REM Check if virtual environment exists
if not exist "venv\Scripts\python.exe" (
    echo ERROR: Virtual environment not found!
    echo Please run deployment\deploy.bat first to set up the environment.
    echo.
    pause
    exit /b 1
)

REM Check if main script exists
if not exist "src\main.py" (
    echo ERROR: Main application script not found!
    echo Please ensure src\main.py exists.
    echo.
    pause
    exit /b 1
)

REM Check if .env file exists
if not exist ".env" (
    echo WARNING: .env configuration file not found!
    echo Creating from template...
    if exist ".env.example" (
        copy .env.example .env
        echo Please edit .env file with your configuration and run this again.
        notepad .env
        pause
        exit /b 1
    ) else (
        echo ERROR: .env.example template not found!
        pause
        exit /b 1
    )
)

echo Checking system configuration...
echo.

REM Quick validation
venv\Scripts\python.exe src\main.py --validate
if %errorLevel% neq 0 (
    echo.
    echo CONFIGURATION ERROR: System validation failed!
    echo Please check your .env file settings.
    echo.
    set /p choice="Do you want to edit .env file now? (y/n): "
    if /i "%choice%"=="y" (
        notepad .env
        echo Please run this application again after fixing configuration.
        pause
        exit /b 1
    ) else (
        echo.
        echo You can still run the application, but it may not work properly.
        set /p choice="Continue anyway? (y/n): "
        if /i not "%choice%"=="y" (
            exit /b 1
        )
    )
)

echo.
echo Configuration OK! Starting FBR SAP Integration...
echo.
echo ================================================================================
echo REAL-TIME APPLICATION LOGS (Press Ctrl+C to stop)
echo ================================================================================
echo.

REM Change to application directory to ensure proper working directory
cd /d "%~dp0"

REM Run the application in daemon mode (continuous processing)
REM This will show real-time logs in the console
venv\Scripts\python.exe src\main.py --daemon

REM If we get here, the application stopped
echo.
echo ================================================================================
echo Application stopped.
echo ================================================================================
echo.

if %errorLevel% equ 0 (
    echo Application ended normally.
) else (
    echo Application ended with error code: %errorLevel%
    echo Check the error messages above for details.
)

echo.
echo Options:
echo - Run again: Double-click this file
echo - View logs: Check logs\fbr_integration.log
echo - Edit config: Edit .env file
echo - Install service: Run deployment\deploy.bat
echo.
pause