@echo off
REM One-Click FBR SAP Integration - Single Run
REM Process invoices once and show results
REM Perfect for testing and manual processing

title FBR SAP B1 Integration - Single Run Mode
color 0E

echo ================================================================================
echo FBR SAP B1 Integration - Single Run Mode
echo ================================================================================
echo.
echo This will process pending invoices once and show the results.
echo Perfect for testing or manual processing.
echo.

REM Check if virtual environment exists
if not exist "venv\Scripts\python.exe" (
    echo ERROR: Virtual environment not found!
    echo Please run deployment\deploy.bat first.
    pause
    exit /b 1
)

REM Check if .env file exists
if not exist ".env" (
    echo ERROR: Configuration file (.env) not found!
    if exist ".env.example" (
        copy .env.example .env
        echo Created .env from template. Please edit it with your settings.
        notepad .env
    )
    pause
    exit /b 1
)

echo Validating configuration...
venv\Scripts\python.exe src\main.py --validate
if %errorLevel% neq 0 (
    echo.
    echo Configuration validation failed!
    echo Please check your .env file settings.
    pause
    exit /b 1
)

echo.
echo Configuration OK! Processing invoices...
echo.
echo ================================================================================
echo PROCESSING RESULTS
echo ================================================================================

REM Change to application directory
cd /d "%~dp0"

REM Run once and process invoices
venv\Scripts\python.exe src\main.py --run-once

echo.
echo ================================================================================
echo Processing completed!
echo ================================================================================

if %errorLevel% equ 0 (
    echo Status: SUCCESS
    echo Check the output above for processing details.
) else (
    echo Status: COMPLETED WITH WARNINGS
    echo Some issues may have occurred. Check logs for details.
)

echo.
echo Log file: logs\fbr_integration.log
echo.
echo To run continuously, use: Run_App.bat
echo To install as service, use: deployment\deploy.bat
echo.
pause