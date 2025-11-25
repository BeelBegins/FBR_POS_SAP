"""
Test script to verify the invoice type handling after revert
"""

import sys
import os
import json

# Add src directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from invoice_processor import InvoiceProcessor

def test_invoice_types():
    """Test all three invoice types"""
    
    # Create invoice processor
    processor = InvoiceProcessor()
    
    # Test InvoiceType 1 (Sales Invoice)
    print("=== Testing InvoiceType 1 (Sales Invoice) ===")
    sales_invoice = [{
        'DocType': 'AR INVOICE',
        'InvoiceType': '1',
        'DocEntry': 12345,
        'DocNum': 100001,
        'ObjType': '13',
        'DocDate': '2025-10-09 10:30:00',
        'BuyerName': 'Test Customer',
        'BuyerNTN': '1234567',
        'BuyerCNIC': '1234567890123',
        'ValueSalesExcludingST': 100.0,
        'SalesTaxApplicable': 18.0,
        'Quantity': 1,
        'ItemCode': 'ITEM001',
        'ProductDescription': 'Test Product',
        'Rate': 18,
        'HSCode': '12345678'
    }]
    
    try:
        fbr_payload = processor.transform_to_fbr_format(sales_invoice)
        print(f"InvoiceType: {fbr_payload['InvoiceType']}")
        print(f"USIN: '{fbr_payload['USIN']}'")
        print(f"RefUSIN: '{fbr_payload['RefUSIN']}'")
        print("✅ Sales Invoice processed correctly\n")
    except Exception as e:
        print(f"❌ Error: {e}\n")
    
    # Test InvoiceType 2 (True Credit Note - if used)
    print("=== Testing InvoiceType 2 (True Credit Note) ===")
    credit_note = [{
        'DocType': 'AR Credit',
        'InvoiceType': '2',
        'DocEntry': 12346,
        'DocNum': 200001,
        'ObjType': '14',
        'DocDate': '2025-10-09 10:30:00',
        'BuyerName': 'Test Customer',
        'BuyerNTN': '1234567',
        'BuyerCNIC': '1234567890123',
        'ValueSalesExcludingST': 100.0,
        'SalesTaxApplicable': 18.0,
        'Quantity': 1,
        'ItemCode': 'ITEM001',
        'ProductDescription': 'Test Product',
        'Rate': 18,
        'HSCode': '12345678',
        'BaseDoc': '100001'
    }]
    
    try:
        fbr_payload = processor.transform_to_fbr_format(credit_note)
        print(f"InvoiceType: {fbr_payload['InvoiceType']}")
        print(f"USIN: '{fbr_payload['USIN']}'")
        print(f"RefUSIN: '{fbr_payload['RefUSIN']}'")
        print("✅ Credit Note processed correctly\n")
    except Exception as e:
        print(f"❌ Error: {e}\n")
    
    # Test InvoiceType 3 (Refund - what user's credit notes now use)
    print("=== Testing InvoiceType 3 (Refund) ===")
    refund = [{
        'DocType': 'AR Credit',
        'InvoiceType': '3',
        'DocEntry': 12347,
        'DocNum': 300001,
        'ObjType': '14',
        'DocDate': '2025-10-09 10:30:00',
        'BuyerName': 'Test Customer',
        'BuyerNTN': '1234567',
        'BuyerCNIC': '1234567890123',
        'ValueSalesExcludingST': 100.0,
        'SalesTaxApplicable': 18.0,
        'Quantity': 1,
        'ItemCode': 'ITEM001',
        'ProductDescription': 'Test Product',
        'Rate': 18,
        'HSCode': '12345678',
        'BaseDoc': '100001'
    }]
    
    try:
        fbr_payload = processor.transform_to_fbr_format(refund)
        print(f"InvoiceType: {fbr_payload['InvoiceType']}")
        print(f"USIN: '{fbr_payload['USIN']}'")
        print(f"RefUSIN: '{fbr_payload['RefUSIN']}'")
        print("✅ Refund processed correctly\n")
    except Exception as e:
        print(f"❌ Error: {e}\n")

if __name__ == "__main__":
    print("Testing Invoice Type Handling")
    print("=" * 50)
    test_invoice_types()
    print("=" * 50)
    print("Test completed!")