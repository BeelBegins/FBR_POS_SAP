@echo off
setlocal enabledelayedexpansion

REM ================================================================================
REM Python 3.11 Downloader Script
REM Downloads Python 3.11.9 (64-bit) for bundled installation
REM ================================================================================

set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"

echo ================================================================================
echo Python 3.11.9 (64-bit) Downloader
echo ================================================================================
echo.

cd /d "%BASE_DIR%"

REM Check if installers directory exists
if not exist "%BASE_DIR%\installers" (
    echo [INFO] Creating 'installers' directory...
    mkdir "%BASE_DIR%\installers"
)

set "INSTALLER_PATH=%BASE_DIR%\installers\python-3.11.9-amd64.exe"
set "DOWNLOAD_URL=https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"

REM Check if already downloaded
if exist "%INSTALLER_PATH%" (
    echo [INFO] Python installer already exists at:
    echo %INSTALLER_PATH%
    echo.
    choice /C YN /M "Do you want to re-download it"
    if errorlevel 2 (
        echo [INFO] Using existing installer.
        goto:END
    )
    echo [INFO] Deleting existing installer...
    del "%INSTALLER_PATH%"
)

echo [INFO] Downloading Python 3.11.9 (64-bit) installer...
echo [INFO] Source: %DOWNLOAD_URL%
echo [INFO] Destination: %INSTALLER_PATH%
echo [INFO] Size: ~26 MB - This may take a few minutes...
echo.

REM Try PowerShell download (works on Windows 7+)
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%INSTALLER_PATH%' -UseBasicParsing; exit 0 } catch { Write-Host 'Download failed:' $_.Exception.Message; exit 1 }}"

if %errorLevel% neq 0 (
    echo [ERROR] Download failed using PowerShell.
    echo.
    echo Please download manually from:
    echo %DOWNLOAD_URL%
    echo.
    echo Save it to: %INSTALLER_PATH%
    echo.
    goto:FAILURE
)

if not exist "%INSTALLER_PATH%" (
    echo [ERROR] Download completed but file not found.
    goto:FAILURE
)

REM Check file size (should be around 25-30 MB)
for %%A in ("%INSTALLER_PATH%") do set "FILE_SIZE=%%~zA"
if %FILE_SIZE% LSS 20000000 (
    echo [ERROR] Downloaded file is too small (%FILE_SIZE% bytes^).
    echo The download may have failed or been corrupted.
    del "%INSTALLER_PATH%"
    goto:FAILURE
)

echo.
echo [SUCCESS] Python installer downloaded successfully!
echo Location: %INSTALLER_PATH%
echo Size: %FILE_SIZE% bytes
echo.
echo You can now run the main installation script.
goto:END

:FAILURE
echo.
echo [FAILED] Could not download Python installer automatically.
echo.
echo MANUAL DOWNLOAD INSTRUCTIONS:
echo 1. Open your web browser
echo 2. Go to: https://www.python.org/downloads/release/python-3119/
echo 3. Scroll down to "Files" section
echo 4. Download: "Windows installer (64-bit)"
echo 5. Save it as: python-3.11.9-amd64.exe
echo 6. Place it in: %BASE_DIR%\installers\
echo.

:END
echo Press any key to exit...
pause >nul
exit /b