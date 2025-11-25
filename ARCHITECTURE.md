# Project Structure Overview

## Complete File Structure
```
C:\FBR_SAP_Integration\
├── src\                           # Source code
│   ├── __init__.py               # Package initialization
│   ├── main.py                   # Main application controller with CLI
│   ├── invoice_processor.py      # Core invoice processing logic
│   ├── database_manager.py       # SAP B1 database connection handler
│   ├── fbr_api_client.py        # FBR API integration client
│   ├── logging_config.py        # Logging and error handling
│   └── windows_service.py       # Windows service implementation
│
├── config\                       # Configuration files
│   ├── __init__.py              # Package initialization
│   └── database_queries.py     # SQL queries (easily modifiable)
│
├── deployment\                   # Deployment scripts
│   ├── deploy.bat               # One-click deployment script
│   ├── uninstall.bat           # Uninstall script
│   ├── test.bat                # Quick test script
│   └── manage_service.bat      # Service management script
│
├── tests\                       # Test files
│   └── test_components.py      # Component testing script
│
├── logs\                        # Log files (created automatically)
│   └── fbr_integration.log     # Application logs
│
├── .env                         # Environment configuration (your settings)
├── .env.example                # Environment template
├── requirements.txt            # Python dependencies
└── README.md                   # Complete documentation
```

## Key Components

### 1. Core Processing Engine (`invoice_processor.py`)
- Fetches pending invoices from SAP B1 database
- Transforms SAP data to FBR POS format
- Handles both Sales Invoices and Credit Notes
- Implements retry logic for failed submissions
- Logs all transactions to database

### 2. Database Manager (`database_manager.py`)
- Robust pyodbc connection handling
- Connection pooling and retry logic
- Transaction support
- Query execution with parameter binding
- Validates required FBR tables

### 3. FBR API Client (`fbr_api_client.py`)
- Sandbox and production environment support
- Bearer token authentication
- Request/response handling
- Rate limiting and timeout management
- Mock mode for testing

### 4. Main Controller (`main.py`)
- CLI interface with multiple operation modes
- Daemon mode for continuous processing
- Windows service integration
- System validation
- Status monitoring and reporting

### 5. Windows Service (`windows_service.py`)
- Native Windows service implementation
- Service lifecycle management
- Event log integration
- Graceful shutdown handling

### 6. Logging System (`logging_config.py`)
- File logging with rotation
- Colored console output
- Database error logging
- Email notifications for critical errors
- Multiple log levels and filtering

## Database Integration

### Required Tables (Already exist in your database)
1. **FBRInvoices** - Tracks invoice submission requests
2. **FBR_LOG** - Detailed logging of all FBR transactions

### SQL Queries (`config/database_queries.py`)
- **SALES_INVOICE_QUERY** - Fetches pending sales invoices
- **CREDIT_NOTE_QUERY** - Fetches pending credit notes
- **INSERT/UPDATE queries** - For logging and status tracking

## Configuration Options

### Environment Variables (.env)
- SAP B1 database connection settings
- FBR API URLs and tokens (sandbox/production)
- Company information and business rules
- Application behavior settings
- Logging and monitoring options
- Windows service configuration

### Business Logic Filters
- `FBR_POS_INVOICE_REQUIRED=Yes` - Only process marked customers
- `FBR_IMPLEMENTATION_DATE=2025-10-02` - Cutoff date for processing
- Invoice type filtering (Sales/Credit)
- Status-based processing (exclude already processed)

## Deployment Options

### One-Click Deployment
```batch
# Run as Administrator
deployment\deploy.bat
```
This script:
1. Validates Python installation
2. Creates virtual environment
3. Installs dependencies
4. Validates configuration
5. Tests system components
6. Installs Windows service
7. Starts the service

### Manual Operations
```batch
# Test system
python src\main.py --validate

# Process once
python src\main.py --run-once

# Install service
python src\main.py --install-service

# Run daemon mode
python src\main.py --daemon
```

## Monitoring and Management

### Service Management
- Windows Services console
- Command line: `net start/stop FBR_SAP_Integration`
- Management script: `deployment\manage_service.bat`

### Logging and Monitoring
- Application logs: `logs\fbr_integration.log`
- Database logs: FBR_LOG table
- Windows Event Log integration
- Real-time status monitoring

### Database Monitoring Queries
```sql
-- Success rate
SELECT COUNT(*) as Total,
       SUM(CASE WHEN FBRStatusCode = '00' THEN 1 ELSE 0 END) as Successful
FROM FBR_LOG

-- Recent submissions
SELECT TOP 100 * FROM FBR_LOG ORDER BY SubmissionTimestamp DESC

-- Failed invoices needing retry
SELECT * FROM FBR_LOG WHERE FBRStatusCode != '00' AND RetryCount < 3
```

## Error Handling Strategy

### Development Mode
- `STOP_ON_ERROR_DEVELOPMENT=True` - Stops on first error for debugging

### Production Mode  
- `STOP_ON_ERROR_PRODUCTION=False` - Logs errors and continues processing
- Automatic retry mechanism with exponential backoff
- Email notifications for critical errors
- Database logging for all errors

## Testing Features

### Test Modes
- `TEST_MODE=True` - Skips actual FBR API calls
- `MOCK_FBR_RESPONSES=True` - Returns mock responses
- `PROCESS_SINGLE_INVOICE=True` - Processes only one invoice

### Validation Tools
- System component validation
- Database connectivity testing
- FBR API connectivity testing
- Configuration validation

This is a production-ready, enterprise-grade solution that handles all aspects of FBR integration including error recovery, monitoring, and service management.