FBR SAP B1 Integration - Troubleshooting Guide
==============================================

This guide helps resolve common deployment and runtime issues on different systems.

SYSTEM REQUIREMENTS
==================
- Windows 10/11 or Windows Server 2016/2019/2022
- Python 3.11 (recommended) or 3.8-3.12
- Administrator privileges
- Network access to FBR portal (esp.fbr.gov.pk)
- Network access to SAP Business One server

COMMON DEPLOYMENT ISSUES
========================

1. PYTHON NOT FOUND
   Problem: "Python is not installed or not in PATH"
   Solutions:
   - Install Python from https://python.org
   - Ensure "Add to PATH" is checked during installation
   - Restart command prompt after installation
   - Try using 'python3' command if 'python' doesn't work

2. VIRTUAL ENVIRONMENT CREATION FAILS
   Problem: "Failed to create virtual environment"
   Solutions:
   - Run command prompt as Administrator
   - Install virtualenv: python -m pip install virtualenv
   - Check disk space (need at least 500MB free)
   - Temporarily disable antivirus during installation
   - Check User Account Control (UAC) settings

3. DEPENDENCY INSTALLATION FAILS
   Problem: "Failed to install dependencies"
   Solutions:
   - Ensure internet connectivity
   - Update pip: python -m pip install --upgrade pip
   - Install Visual C++ Redistributable if needed
   - Clear pip cache: pip cache purge
   - Use alternative index: pip install -r requirements.txt -i https://pypi.org/simple/

4. NSSM NOT FOUND OR NOT WORKING
   Problem: "nssm.exe not found" or "NSSM executable is not working"
   Solutions:
   - Download NSSM from https://nssm.cc/download
   - Use correct architecture (32-bit vs 64-bit)
   - Check antivirus hasn't quarantined nssm.exe
   - Verify file permissions
   - Try running nssm.exe manually to test

5. SERVICE INSTALLATION FAILS
   Problem: "Failed to install Windows service"
   Solutions:
   - Run deployment script as Administrator
   - Check Windows Event Viewer for detailed errors
   - Temporarily disable antivirus
   - Verify Python and script paths are correct
   - Check if service name conflicts with existing service

6. SERVICE WON'T START
   Problem: Service installs but won't start
   Solutions:
   - Check logs\service_stderr.log for errors
   - Verify Python virtual environment is intact
   - Test manually: venv\Scripts\python src\main.py --run-once
   - Check .env file configuration
   - Verify database connectivity
   - Check FBR portal accessibility

7. DATABASE CONNECTION ISSUES
   Problem: "Database connection test failed"
   Solutions:
   - Verify SAP_SERVER and SAP_DATABASE settings in .env
   - Check SAP_USERNAME and SAP_PASSWORD
   - Ensure SAP Business One server is accessible
   - Check firewall settings
   - Verify SAP HANA/SQL Server is running
   - Test connection from SAP Business One client

8. FBR API CONNECTION ISSUES
   Problem: "FBR API connection test failed"
   Solutions:
   - Check internet connectivity
   - Verify FBR_API_URL in .env file
   - Check firewall allows HTTPS connections
   - Verify FBR credentials (FBR_USERNAME, FBR_PASSWORD)
   - Test manually: ping esp.fbr.gov.pk

RUNTIME ISSUES
==============

1. SERVICE STOPS UNEXPECTEDLY
   - Check logs\fbr_integration.log for errors
   - Review logs\service_stderr.log
   - Check Windows Event Viewer
   - Verify database is still accessible
   - Check if certificate issues with FBR API

2. INVOICES NOT PROCESSING
   - Check if invoices meet FBR requirements
   - Verify invoice status in SAP Business One
   - Check FBR portal for submission status
   - Review processing logs for specific errors

3. PERFORMANCE ISSUES
   - Monitor system resources (CPU, Memory, Disk)
   - Check database query performance
   - Review network latency to FBR portal
   - Consider adjusting DAEMON_CHECK_INTERVAL_MINUTES

DIAGNOSTIC COMMANDS
==================
Use these commands to diagnose issues:

Check service status:
  deployment\nssm.exe status FBR_SAP_Integration

View recent logs:
  type logs\fbr_integration.log | more
  type logs\service_stdout.log | more
  type logs\service_stderr.log | more

Test application manually:
  venv\Scripts\python src\main.py --validate
  venv\Scripts\python src\main.py --run-once

Start/stop service:
  deployment\nssm.exe start FBR_SAP_Integration
  deployment\nssm.exe stop FBR_SAP_Integration
  deployment\nssm.exe restart FBR_SAP_Integration

Check Windows service:
  sc query FBR_SAP_Integration
  Get-Service FBR_SAP_Integration

CONFIGURATION FILES
===================
Key files to check:

.env - Main configuration (database, FBR settings)
logs\fbr_integration.log - Application logs
logs\service_stdout.log - Service output
logs\service_stderr.log - Service errors
src\config\database_queries.py - Database queries
requirements.txt - Python dependencies

GETTING HELP
============
When seeking support, please provide:

1. Windows version and architecture
2. Python version
3. Complete error messages
4. Content of logs\service_stderr.log
5. Last 50 lines of logs\fbr_integration.log
6. Output of: deployment\nssm.exe status FBR_SAP_Integration
7. .env file (with sensitive data removed)

CONTACT INFORMATION
==================
For technical support, contact your system administrator or the development team.

Last Updated: October 2025