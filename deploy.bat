@echo off
setlocal enabledelayedexpansion

REM ================================================================================
REM Complete Bundled Installer for FBR SAP B1 Integration
REM Version 3.0 - Includes Python 3.11 Installation
REM
REM This script:
REM 1. Checks if Python 3.11 is already installed
REM 2. If not, installs the bundled Python 3.11 (64-bit) silently
REM 3. Creates virtual environment
REM 4. Installs dependencies
REM 5. Configures and installs Windows service
REM ================================================================================

:: Set script directory as the base path
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"

echo.
echo ================================================================================
echo FBR SAP B1 Integration - Complete Installation
echo ================================================================================
echo Base directory: %BASE_DIR%
echo.

cd /d "%BASE_DIR%" 2>nul
if %errorLevel% neq 0 (
    echo [ERROR] Cannot access installation directory: %BASE_DIR%
    goto:FAILURE
)

REM ================================================================================
REM Step 1: Administrator Check
REM ================================================================================

:CHECK_ADMIN
echo [INFO] Step 1: Checking for Administrator privileges...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This installer must be run as Administrator.
    echo Please right-click the file and select "Run as administrator".
    echo.
    goto:FAILURE
)
echo [OK] Administrator privileges confirmed.
echo.

REM ================================================================================
REM Step 2: Python Installation Check and Setup
REM ================================================================================

:CHECK_PYTHON
echo [INFO] Step 2: Checking Python installation...
set "PYTHON_INSTALLED=0"
set "PYTHON_CMD="
set "BUNDLED_PYTHON=%BASE_DIR%\python\python.exe"
set "BUNDLED_INSTALLER=%BASE_DIR%\installers\python-3.11.9-amd64.exe"

REM Check if bundled Python already installed
if exist "%BUNDLED_PYTHON%" (
    echo [INFO] Found bundled Python installation at: %BUNDLED_PYTHON%
    "%BUNDLED_PYTHON%" --version >nul 2>&1
    if !errorLevel! equ 0 (
        set "PYTHON_CMD=%BUNDLED_PYTHON%"
        set "PYTHON_INSTALLED=1"
        echo [OK] Using bundled Python installation.
        goto:VALIDATE_PYTHON
    )
)

REM Check system Python
echo [INFO] Checking for system Python installation...
python --version >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do set "SYS_PYTHON_VER=%%i"
    echo [INFO] Found system Python: !SYS_PYTHON_VER!
    echo !SYS_PYTHON_VER! | findstr /B "3.11" >nul
    if !errorLevel! equ 0 (
        python -c "import sys; sys.exit(0 if sys.maxsize > 2**32 else 1)" >nul 2>&1
        if !errorLevel! equ 0 (
            set "PYTHON_CMD=python"
            set "PYTHON_INSTALLED=1"
            echo [OK] Compatible system Python found. Using system Python.
            goto:VALIDATE_PYTHON
        )
    )
)

REM No compatible Python found - install bundled version
echo [INFO] No compatible Python found. Installing bundled Python 3.11...
goto:INSTALL_BUNDLED_PYTHON

:INSTALL_BUNDLED_PYTHON
if not exist "%BUNDLED_INSTALLER%" (
    echo [ERROR] Bundled Python installer not found at:
    echo %BUNDLED_INSTALLER%
    echo.
    echo Please ensure the installer is placed in the 'installers' folder.
    echo Download from: https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe
    goto:FAILURE
)

echo [INFO] Installing Python 3.11 to: %BASE_DIR%\python
echo [INFO] This may take a few minutes...

REM Silent install with custom location
"%BUNDLED_INSTALLER%" /quiet InstallAllUsers=0 ^
    TargetDir="%BASE_DIR%\python" ^
    PrependPath=0 ^
    Include_test=0 ^
    Include_doc=0 ^
    Include_dev=1 ^
    Include_lib=1 ^
    Include_pip=1 ^
    Include_tcltk=0

if %errorLevel% neq 0 (
    echo [ERROR] Python installation failed. Error code: %errorLevel%
    echo Please check if:
    echo 1. The installer file is not corrupted
    echo 2. You have sufficient disk space
    echo 3. Antivirus is not blocking the installation
    goto:FAILURE
)

echo [INFO] Waiting for installation to complete...
timeout /t 5 /nobreak >nul

if not exist "%BUNDLED_PYTHON%" (
    echo [ERROR] Python installation completed but python.exe not found.
    goto:FAILURE
)

set "PYTHON_CMD=%BUNDLED_PYTHON%"
set "PYTHON_INSTALLED=1"
echo [OK] Python 3.11 installed successfully.
echo.

:VALIDATE_PYTHON
echo [INFO] Validating Python installation...
"%PYTHON_CMD%" --version
if %errorLevel% neq 0 (
    echo [ERROR] Python validation failed.
    goto:FAILURE
)

"%PYTHON_CMD%" -c "import sys; print(f'Architecture: {64 if sys.maxsize > 2**32 else 32}-bit')"
"%PYTHON_CMD%" -c "import sys; sys.exit(0 if sys.maxsize > 2**32 else 1)"
if %errorLevel% neq 0 (
    echo [ERROR] 32-bit Python detected. This application requires 64-bit Python.
    goto:FAILURE
)
echo [OK] Python validation passed.
echo.

REM ================================================================================
REM Step 3: Check Required Files
REM ================================================================================

:CHECK_FILES
echo [INFO] Step 3: Checking for required files...
if not exist "%BASE_DIR%\requirements.txt" (
    echo [ERROR] requirements.txt not found.
    goto:FAILURE
)
if not exist "%BASE_DIR%\src\main.py" (
    echo [ERROR] src\main.py not found.
    goto:FAILURE
)
echo [OK] All required files found.
echo.

REM ================================================================================
REM Step 4: Create Virtual Environment
REM ================================================================================

:CREATE_VENV
echo [INFO] Step 4: Creating Python virtual environment...
if exist "%BASE_DIR%\venv" (
    echo [INFO] Removing existing virtual environment...
    rmdir /s /q "%BASE_DIR%\venv" 2>nul
    if exist "%BASE_DIR%\venv" (
        echo [ERROR] Failed to remove existing venv. Please close any programs using it.
        goto:FAILURE
    )
)

echo [INFO] Creating new virtual environment...
"%PYTHON_CMD%" -m venv "%BASE_DIR%\venv"
if %errorLevel% neq 0 (
    echo [ERROR] Failed to create virtual environment.
    goto:FAILURE
)
echo [OK] Virtual environment created.
echo.

REM ================================================================================
REM Step 5: Install Dependencies
REM ================================================================================

:INSTALL_DEPS
echo [INFO] Step 5: Installing dependencies...
set "VENV_PYTHON=%BASE_DIR%\venv\Scripts\python.exe"

if not exist "%VENV_PYTHON%" (
    echo [ERROR] Virtual environment Python not found.
    goto:FAILURE
)

echo [INFO] Upgrading pip...
"%VENV_PYTHON%" -m pip install --upgrade pip --quiet
if %errorLevel% neq 0 (
    echo [WARNING] Failed to upgrade pip, continuing...
)

echo [INFO] Installing requirements (this may take several minutes)...
"%VENV_PYTHON%" -m pip install -r "%BASE_DIR%\requirements.txt"
if %errorLevel% neq 0 (
    echo [ERROR] Failed to install dependencies.
    echo Please check your internet connection and try again.
    goto:FAILURE
)
echo [OK] All dependencies installed.
echo.

REM ================================================================================
REM Step 6: Environment Configuration
REM ================================================================================

:SETUP_ENV
echo [INFO] Step 6: Setting up environment configuration...
if not exist "%BASE_DIR%\.env" (
    if not exist "%BASE_DIR%\.env.example" (
        echo [ERROR] .env.example template not found.
        goto:FAILURE
    )
    
    echo [INFO] Creating .env file from template...
    copy "%BASE_DIR%\.env.example" "%BASE_DIR%\.env" >nul
    
    echo.
    echo ========================================================================
    echo ACTION REQUIRED: Configuration Setup
    echo ========================================================================
    echo A new configuration file '.env' has been created.
    echo You MUST edit this file with your:
    echo   - Database credentials (SAP B1)
    echo   - FBR API credentials
    echo   - Other configuration settings
    echo.
    echo Press any key to open the configuration file in Notepad...
    pause >nul
    start "" notepad.exe "%BASE_DIR%\.env"
    echo.
    echo Please complete the configuration, save the file, and close Notepad.
    echo Then press any key to continue...
    pause >nul
) else (
    echo [OK] Configuration file (.env) already exists.
)
echo.

REM ================================================================================
REM Step 7: System Validation
REM ================================================================================

:VALIDATE_SYSTEM
echo [INFO] Step 7: Validating system configuration...
"%VENV_PYTHON%" "%BASE_DIR%\src\main.py" --validate
if %errorLevel% neq 0 (
    echo [ERROR] System validation failed.
    echo Please check the .env configuration file and error messages above.
    goto:FAILURE
)
echo [OK] System validation passed.
echo.

REM ================================================================================
REM Step 8: Install Windows Service
REM ================================================================================

:INSTALL_SERVICE
echo [INFO] Step 8: Installing Windows Service...
set "NSSM_EXE=%BASE_DIR%\deployment\nssm.exe"
set "SERVICE_NAME=FBR_SAP_Integration"

if not exist "%NSSM_EXE%" (
    echo [ERROR] NSSM executable not found at: %NSSM_EXE%
    echo Please download NSSM from https://nssm.cc/download
    echo and place nssm.exe in the 'deployment' folder.
    goto:FAILURE
)

echo [INFO] Removing any existing service...
"%NSSM_EXE%" stop %SERVICE_NAME% >nul 2>&1
"%NSSM_EXE%" remove %SERVICE_NAME% confirm >nul 2>&1

echo [INFO] Installing service...
"%NSSM_EXE%" install %SERVICE_NAME% "%VENV_PYTHON%" "\"%BASE_DIR%\src\main.py\" --run-forever"
if %errorLevel% neq 0 (
    echo [ERROR] Failed to install Windows service.
    goto:FAILURE
)

echo [INFO] Configuring service...
"%NSSM_EXE%" set %SERVICE_NAME% AppDirectory "%BASE_DIR%"
"%NSSM_EXE%" set %SERVICE_NAME% DisplayName "FBR SAP B1 Integration Service"
"%NSSM_EXE%" set %SERVICE_NAME% Description "Automated integration service between FBR and SAP Business One"
"%NSSM_EXE%" set %SERVICE_NAME% Start SERVICE_AUTO_START

echo [INFO] Configuring logging...
if not exist "%BASE_DIR%\logs" mkdir "%BASE_DIR%\logs"
"%NSSM_EXE%" set %SERVICE_NAME% AppStdout "%BASE_DIR%\logs\service_stdout.log"
"%NSSM_EXE%" set %SERVICE_NAME% AppStderr "%BASE_DIR%\logs\service_stderr.log"
"%NSSM_EXE%" set %SERVICE_NAME% AppRotateFiles 1
"%NSSM_EXE%" set %SERVICE_NAME% AppRotateOnline 1
"%NSSM_EXE%" set %SERVICE_NAME% AppRotateSeconds 86400
"%NSSM_EXE%" set %SERVICE_NAME% AppRotateBytes 10485760

echo [OK] Service installed and configured.
echo.

REM ================================================================================
REM Step 9: Start Service
REM ================================================================================

:START_SERVICE
echo [INFO] Step 9: Starting the service...
"%NSSM_EXE%" start %SERVICE_NAME%
if %errorLevel% neq 0 (
    echo [WARNING] Service installed but failed to start.
    goto:POST_FAILURE_INFO
)

echo [INFO] Waiting for service to initialize...
timeout /t 5 /nobreak >nul

"%NSSM_EXE%" status %SERVICE_NAME% | find "SERVICE_RUNNING" >nul
if %errorLevel% neq 0 (
    echo [WARNING] Service is not running.
    goto:POST_FAILURE_INFO
)

echo [OK] Service is running.
goto:SUCCESS

REM ================================================================================
REM Success Message
REM ================================================================================

:SUCCESS
echo.
echo ================================================================================
echo INSTALLATION COMPLETED SUCCESSFULLY!
echo ================================================================================
echo.
echo Service Name: %SERVICE_NAME%
echo Status: Running
echo Startup: Automatic
echo.
echo Python Installation: %PYTHON_CMD%
echo Application Directory: %BASE_DIR%
echo.
echo Log Files:
echo   - Application: %BASE_DIR%\logs\fbr_integration.log
echo   - Service Output: %BASE_DIR%\logs\service_stdout.log
echo   - Service Errors: %BASE_DIR%\logs\service_stderr.log
echo.
echo Management Commands:
echo   Start:   "%NSSM_EXE%" start %SERVICE_NAME%
echo   Stop:    "%NSSM_EXE%" stop %SERVICE_NAME%
echo   Status:  "%NSSM_EXE%" status %SERVICE_NAME%
echo   Restart: "%NSSM_EXE%" restart %SERVICE_NAME%
echo.
goto:END

REM ================================================================================
REM Troubleshooting Info
REM ================================================================================

:POST_FAILURE_INFO
echo.
echo [TROUBLESHOOTING]
echo The service was installed but failed to start. Please check:
echo.
echo 1. Service error log:
echo    type "%BASE_DIR%\logs\service_stderr.log"
echo.
echo 2. Run validation manually:
echo    "%VENV_PYTHON%" "%BASE_DIR%\src\main.py" --validate
echo.
echo 3. Test run once:
echo    "%VENV_PYTHON%" "%BASE_DIR%\src\main.py" --run-once
echo.
echo 4. Check Windows Event Viewer for service errors
echo.
goto:END

:FAILURE
echo.
echo ================================================================================
echo INSTALLATION FAILED
echo ================================================================================
echo Please review the error messages above.
echo.
echo Common solutions:
echo 1. Ensure you ran this as Administrator
echo 2. Check internet connectivity for downloading dependencies
echo 3. Verify all required files are present
echo 4. Check antivirus isn't blocking the installation
echo.

:END
echo.
echo Press any key to exit...
pause >nul
exit /b %errorLevel%