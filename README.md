# FBR SAP B1 Integration

A comprehensive Python application for uploading SAP Business One invoices to the Federal Board of Revenue (FBR) Pakistan portal using the POS model.

## Features

- **Automatic Invoice Processing**: Fetches pending invoices from SAP B1 database and submits to FBR API
- **Dual Environment Support**: Sandbox and production environments with separate configurations
- **Windows Service**: Runs as a background Windows service with daemon mode
- **Comprehensive Logging**: File logging with rotation and database logging to FBR_LOG table
- **Error Handling**: Robust error handling with retry mechanisms and email notifications
- **One-Click Deployment**: Complete automated setup with batch scripts
- **Real-time Monitoring**: Status monitoring and service management tools

## System Requirements

- Windows 10/11 or Windows Server 2016+
- Python 3.8 or higher
- SQL Server with SAP Business One database
- Network access to FBR API endpoints
- Administrator privileges for service installation

## Quick Start

1. **Download and Extract**: Extract the project to `C:\FBR_SAP_Integration\`

2. **Configure Environment**: Edit `.env` file with your SAP B1 and FBR credentials

3. **One-Click Deploy**: Run as Administrator:
   ```batch
   deployment\deploy.bat
   ```

4. **Verify Installation**: The service will be installed and started automatically

## Manual Installation

If you prefer manual setup:

```batch
# Create virtual environment
python -m venv venv
venv\Scripts\activate.bat

# Install dependencies
pip install -r requirements.txt

# Test configuration
python src\main.py --validate

# Install Windows service
python src\main.py --install-service

# Start service
net start FBR_SAP_Integration
```

## Configuration

### Environment Variables (.env file)

```env
# SAP B1 Database
SAP_SERVER=your_server
SAP_DATABASE=your_database
SAP_UID=your_username
SAP_PWD=your_password

# FBR API Configuration
FBR_ENVIRONMENT=sandbox  # sandbox or production
FBR_TOKEN_Sandbox=your_sandbox_token
FBR_TOKEN_Production=your_production_token

# Company Information
COMPANY_NTN=your_ntn
COMPANY_POSID=your_posid
COMPANY_NAME=Your Company Name

# Processing Options
DAEMON_MODE_ENABLED=True
DAEMON_CHECK_INTERVAL_MINUTES=5
STOP_ON_ERROR_PRODUCTION=False
MAX_RETRY_ATTEMPTS=3
```

## Database Requirements

The following tables must exist in your SAP B1 database:

### FBRInvoices Table
```sql
CREATE TABLE [dbo].[FBRInvoices](
    [FBRInvoiceID] [int] IDENTITY(1,1) NOT NULL,
    [SAPDocEntry] [int] NOT NULL,
    [SAPDocNum] [nvarchar](50) NOT NULL,
    [SAPObjType] [nvarchar](20) NOT NULL,
    [FBRInvoiceTypeSent] [nvarchar](100) NULL,
    [FBRRequestJSON] [nvarchar](max) NOT NULL,
    [ProcessingStatus] [nvarchar](50) NULL,
    [FBR_LogID] [int] NULL,
    [CreationTimestamp] [datetime] NULL,
    [LastUpdateTimestamp] [datetime] NULL
)
```

### FBR_LOG Table
```sql
CREATE TABLE [dbo].[FBR_LOG](
    [LogID] [int] IDENTITY(1,1) NOT NULL,
    [SAPDocEntry] [int] NULL,
    [SAPDocNum] [nvarchar](50) NULL,
    [SAPObjType] [nvarchar](20) NULL,
    [SubmissionTimestamp] [datetime] NULL,
    [FBRInvoiceNumber] [nvarchar](100) NULL,
    [FBRStatusCode] [nvarchar](50) NULL,
    [FBRStatusMessage] [nvarchar](max) NULL,
    [FBRErrors] [nvarchar](max) NULL,
    [HTTPStatusCode] [int] NULL,
    [FBRRequestPayload] [nvarchar](max) NULL,
    [FBRResponsePayload] [nvarchar](max) NULL,
    [RetryCount] [int] NULL,
    [LastAttemptTimestamp] [datetime] NULL
)
```

## Usage

### Service Management

```batch
# Start service
net start FBR_SAP_Integration

# Stop service  
net stop FBR_SAP_Integration

# Check status
sc query FBR_SAP_Integration

# Use management script
deployment\manage_service.bat
```

### Command Line Operations

```batch
# Process invoices once
python src\main.py --run-once

# Validate system
python src\main.py --validate

# Show status
python src\main.py --status

# Run in daemon mode (foreground)
python src\main.py --daemon
```

### Testing

```batch
# Quick test
deployment\test.bat

# Test with single invoice
set PROCESS_SINGLE_INVOICE=True
python src\main.py --run-once
```

## Monitoring

### Log Files
- **Application Logs**: `logs\fbr_integration.log`
- **Windows Event Log**: Check Windows Event Viewer under Application logs

### Database Monitoring
```sql
-- Check processing status
SELECT TOP 100 * FROM FBR_LOG ORDER BY SubmissionTimestamp DESC

-- Success rate
SELECT 
    COUNT(*) as Total,
    SUM(CASE WHEN FBRStatusCode = '00' THEN 1 ELSE 0 END) as Successful,
    (SUM(CASE WHEN FBRStatusCode = '00' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as SuccessRate
FROM FBR_LOG

-- Failed invoices
SELECT * FROM FBR_LOG WHERE FBRStatusCode != '00' AND RetryCount < 3
```

## Troubleshooting

### Common Issues

1. **Service won't start**
   - Check Windows Event Log
   - Verify database connectivity
   - Ensure .env file is properly configured

2. **Database connection errors**
   - Verify SQL Server is running
   - Check firewall settings
   - Validate credentials in .env file

3. **FBR API errors**
   - Check internet connectivity
   - Verify FBR tokens are valid
   - Check if FBR service is available

4. **Invoice not processing**
   - Verify `U_FbrPosInvoice = 'Yes'` in customer master
   - Check implementation date filter
   - Ensure invoice is not already processed

### Debug Mode

Enable debug logging by setting in .env:
```env
LOG_LEVEL=DEBUG
DEBUG_SQL_QUERIES=True
```

### Test Mode

For testing without actual FBR submission:
```env
TEST_MODE=True
MOCK_FBR_RESPONSES=True
```

## Project Structure

```
C:\FBR_SAP_Integration\
├── src\
│   ├── main.py                 # Main application controller
│   ├── invoice_processor.py    # Core invoice processing logic
│   ├── database_manager.py     # Database connection handler
│   ├── fbr_api_client.py      # FBR API integration
│   ├── logging_config.py      # Logging and error handling
│   └── windows_service.py     # Windows service implementation
├── config\
│   └── database_queries.py    # SQL queries (easily modifiable)
├── deployment\
│   ├── deploy.bat             # One-click deployment
│   ├── uninstall.bat          # Uninstall script
│   ├── test.bat               # Quick test script
│   └── manage_service.bat     # Service management
├── logs\                      # Log files
├── .env                       # Environment configuration
├── .env.example              # Configuration template
└── requirements.txt          # Python dependencies
```

## API Documentation

### FBR POS Model JSON Format

```json
{
  "FBRInvoiceNumber": null,
  "POSID": 134272,
  "USIN": "001005",
  "BuyerName": "Customer Name",
  "BuyerNTN": "1234567-8",
  "BuyerCNIC": "",
  "BuyerPhoneNumber": "",
  "DateTime": "2025-02-26 11:59:42.000",
  "TotalSaleValue": "680.04",
  "TotalQuantity": "5",
  "TotalTaxCharged": "104.96",
  "Discount": "0",
  "TotalBillAmount": "786",
  "PaymentMode": 1,
  "InvoiceType": 1,
  "RefUSIN": "001005",
  "Items": [
    {
      "ItemCode": "4426423272392",
      "ItemName": "Product Name",
      "PCTCode": "01011000",
      "Quantity": 1,
      "TaxRate": 18,
      "SaleValue": 449.15,
      "TaxCharged": 80.85,
      "TotalAmount": 530,
      "Discount": 0,
      "FurtherTax": 0,
      "InvoiceType": 1
    }
  ]
}
```

## Support

For technical support:
1. Check logs for error details
2. Review this documentation
3. Verify all configurations
4. Test with sandbox environment first

## License

This project is proprietary software for FBR compliance.

---

**Last Updated**: October 2025  
**Version**: 1.0.0