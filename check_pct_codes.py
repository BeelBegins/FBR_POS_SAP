import sys
import os
sys.path.append('src')

from database_manager import get_db_manager

# Check what PCT/HS codes exist in the item master
db = get_db_manager()

print("Checking PCT/HS codes in item master data...")

# Check the structure and data in OITM table
results = db.execute_query("""
    SELECT TOP 10 
        ItemCode, 
        U_HSCODE,
        U_PCTCode,
        ItemName
    FROM OITM 
    WHERE ItemCode IN ('D&B-000065', 'D&B-000064', 'D&B-000062')
""")

print("Item master data for our sample items:")
print("-" * 80)
for r in results:
    print(f"Item: {r['ItemCode']} | HSCode: {r['U_HSCODE']} | PCTCode: {r.get('U_PCTCode', 'N/A')} | Name: {r['ItemName']}")

print("\nChecking all available columns in OITM table for PCT/HS codes:")
results2 = db.execute_query("""
    SELECT TOP 5 * FROM OITM 
    WHERE ItemCode = 'D&B-000065'
""")

if results2:
    print("Available columns:")
    columns = list(results2[0].keys())
    pct_columns = [col for col in columns if 'PCT' in col.upper() or 'HS' in col.upper() or 'TAX' in col.upper()]
    print(f"PCT/HS/Tax related columns: {pct_columns}")
    
    # Check if there are any populated PCT codes
    print("\nChecking for any populated PCT codes:")
    results3 = db.execute_query("""
        SELECT TOP 10 ItemCode, U_HSCODE
        FROM OITM 
        WHERE U_HSCODE IS NOT NULL AND U_HSCODE != ''
    """)
    
    if results3:
        print("Items with populated HS codes:")
        for r in results3:
            print(f"Item: {r['ItemCode']} | HSCode: {r['U_HSCODE']}")
    else:
        print("No items found with populated HS codes")