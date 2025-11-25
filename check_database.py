import sys
import os
sys.path.append('src')
from database_manager import get_db_manager

# Check recent FBR log entries
db = get_db_manager()
results = db.execute_query("""
    SELECT TOP 10 
        SAPDocNum, 
        FBRStatusCode, 
        FBRStatusMessage, 
        SubmissionTimestamp,
        FBRInvoiceNumber 
    FROM FBR_LOG 
    ORDER BY SubmissionTimestamp DESC
""")

print("Recent FBR Log Entries:")
print("-" * 80)
for r in results:
    doc_num = str(r['SAPDocNum']) if r['SAPDocNum'] else 'N/A'
    status = str(r['FBRStatusCode']) if r['FBRStatusCode'] else 'N/A'
    fbr_number = str(r['FBRInvoiceNumber']) if r['FBRInvoiceNumber'] else 'N/A'
    timestamp = str(r['SubmissionTimestamp']) if r['SubmissionTimestamp'] else 'N/A'
    print(f"Invoice: {doc_num} | Status: {status} | FBR Number: {fbr_number} | Time: {timestamp}")
    
# Check success rate
stats = db.execute_query("""
    SELECT 
        COUNT(*) as Total,
        SUM(CASE WHEN FBRStatusCode = '00' THEN 1 ELSE 0 END) as Successful,
        (SUM(CASE WHEN FBRStatusCode = '00' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) as SuccessRate
    FROM FBR_LOG
""")

if stats:
    print(f"\nOverall Statistics:")
    print(f"Total Submissions: {stats[0]['Total']}")
    print(f"Successful: {stats[0]['Successful']}")
    print(f"Success Rate: {stats[0]['SuccessRate']:.1f}%")