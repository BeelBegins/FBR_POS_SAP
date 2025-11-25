@echo off
echo ================================================================================
echo DIAGNOSTIC TEST SCRIPT
echo ================================================================================
echo This script will help diagnose why the deployment script crashes.
echo.

echo TEST 1: Script Location
echo ------------------------
echo Script file: %~f0
echo Script directory: %~dp0
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"
echo Base directory (cleaned): %BASE_DIR%
echo Current directory: %CD%
echo.

echo TEST 2: Change Directory
echo ------------------------
cd /d "%BASE_DIR%" 2>nul
if %errorLevel% neq 0 (
    echo [FAILED] Cannot change to base directory!
    goto :END
) else (
    echo [OK] Changed to: %CD%
)
echo.

echo TEST 3: Administrator Check
echo ------------------------
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [FAILED] Not running as Administrator
    echo Please right-click and "Run as administrator"
) else (
    echo [OK] Running with Administrator privileges
)
echo.

echo TEST 4: Python Check
echo ------------------------
python --version 2>nul
if %errorLevel% neq 0 (
    echo [FAILED] 'python' command not found
    python3 --version 2>nul
    if %errorLevel% neq 0 (
        echo [FAILED] 'python3' command not found either
        echo Python is not installed or not in PATH
    ) else (
        echo [OK] 'python3' command works
    )
) else (
    echo [OK] 'python' command works
)
echo.

echo TEST 5: File Structure Check
echo ------------------------
echo Looking for requirements.txt...
if exist "%BASE_DIR%\requirements.txt" (
    echo [OK] Found: requirements.txt
) else (
    echo [FAILED] Missing: requirements.txt
)

echo Looking for src\main.py...
if exist "%BASE_DIR%\src\main.py" (
    echo [OK] Found: src\main.py
) else (
    echo [FAILED] Missing: src\main.py
    if not exist "%BASE_DIR%\src" (
        echo [FAILED] src folder doesn't exist!
    )
)

echo Looking for .env.example...
if exist "%BASE_DIR%\.env.example" (
    echo [OK] Found: .env.example
) else (
    echo [WARNING] Missing: .env.example (optional)
)

echo Looking for deployment\nssm.exe...
if exist "%BASE_DIR%\deployment\nssm.exe" (
    echo [OK] Found: deployment\nssm.exe
) else (
    echo [WARNING] Missing: deployment\nssm.exe (needed for service install)
)
echo.

echo TEST 6: Current Directory Contents
echo ------------------------
echo Files and folders in %BASE_DIR%:
dir "%BASE_DIR%" /b
echo.

echo TEST 7: System Information
echo ------------------------
echo OS: %OS%
echo Processor: %PROCESSOR_ARCHITECTURE%
echo Computer: %COMPUTERNAME%
echo User: %USERNAME%
echo.

:END
echo ================================================================================
echo DIAGNOSTIC COMPLETE
echo ================================================================================
echo.
echo Please review the results above.
echo If any tests show [FAILED], that's likely the cause of the crash.
echo.
echo Press any key to exit...
pause >nul