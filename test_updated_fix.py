"""
Test the updated credit note fix - USIN as empty string and no InvoiceType in items
"""

import sys
import os
import json

# Add src directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from invoice_processor import InvoiceProcessor

def test_updated_credit_note_fix():
    """Test the updated fix for credit notes"""
    
    # Create mock credit note data with multiple items
    credit_note_lines = [
        {
            'DocType': 'AR Credit',
            'InvoiceType': '2',  # Credit note
            'DocEntry': 12345,
            'DocNum': 103000186,
            'ObjType': '14',
            'DocDate': '2025-10-09 13:08:00',
            'CardCode': 'CUST001',
            'BuyerNTN': '1234567',
            'BuyerCNIC': '1234567890123',
            'BuyerName': 'Test Customer',
            'BuyerType': 'Registered',
            'SaleOriginationProvince': 'Punjab',
            'BuyerFullAddress': 'Test Address, Lahore, Pakistan',
            'DocumentType': 'Credit Note Sales',
            'DocumentNumber': '103000186',
            'SaleType': 'RETE',
            'Rate': 18,
            'HSCode': '12345678',
            'Quantity': 2,
            'ValueSalesExcludingST': 200.0,
            'SalesTaxApplicable': 36.0,
            'ItemCode': 'ITEM001',
            'ProductDescription': 'Test Product 1',
            'VatGroup': 'S8',
            'LineNum': 1,
            'Comments': 'Test credit note',
            'BaseDoc': '103000100'  # Reference to original invoice
        },
        {
            'DocType': 'AR Credit',
            'InvoiceType': '2',  # Credit note
            'DocEntry': 12345,
            'DocNum': 103000186,
            'ObjType': '14',
            'DocDate': '2025-10-09 13:08:00',
            'CardCode': 'CUST001',
            'BuyerNTN': '1234567',
            'BuyerCNIC': '1234567890123',
            'BuyerName': 'Test Customer',
            'BuyerType': 'Registered',
            'SaleOriginationProvince': 'Punjab',
            'BuyerFullAddress': 'Test Address, Lahore, Pakistan',
            'DocumentType': 'Credit Note Sales',
            'DocumentNumber': '103000186',
            'SaleType': 'RETE',
            'Rate': 18,
            'HSCode': '87654321',
            'Quantity': 1,
            'ValueSalesExcludingST': 100.0,
            'SalesTaxApplicable': 18.0,
            'ItemCode': 'ITEM002',
            'ProductDescription': 'Test Product 2',
            'VatGroup': 'S8',
            'LineNum': 2,
            'Comments': 'Test credit note',
            'BaseDoc': '103000100'  # Reference to original invoice
        }
    ]
    
    # Create invoice processor
    processor = InvoiceProcessor()
    
    try:
        # Transform to FBR format
        fbr_payload = processor.transform_to_fbr_format(credit_note_lines)
        
        # Print the result
        print("=== UPDATED Credit Note FBR Payload ===")
        print(json.dumps(fbr_payload, indent=2, ensure_ascii=False))
        
        # Verify key fields
        print("\n=== Verification Results ===")
        print(f"InvoiceType: {fbr_payload['InvoiceType']}")
        print(f"USIN: '{fbr_payload['USIN']}'")
        print(f"RefUSIN: '{fbr_payload['RefUSIN']}'")
        print(f"Number of Items: {len(fbr_payload['Items'])}")
        
        # Check fixes
        all_good = True
        
        # 1. Check USIN is empty string (not null)
        if fbr_payload['InvoiceType'] == 2:
            if fbr_payload['USIN'] == "":
                print("✅ USIN is correctly set to empty string for credit note")
            else:
                print(f"❌ USIN should be empty string for credit note, got: '{fbr_payload['USIN']}'")
                all_good = False
        
        # 2. Check RefUSIN references original invoice
        if fbr_payload['RefUSIN'] == '103000100':
            print("✅ RefUSIN correctly references original invoice")
        else:
            print(f"❌ RefUSIN should reference original invoice, got: {fbr_payload['RefUSIN']}")
            all_good = False
        
        # 3. Check Items don't have InvoiceType field
        items_have_invoice_type = any('InvoiceType' in item for item in fbr_payload['Items'])
        if not items_have_invoice_type:
            print("✅ Items don't have InvoiceType field (good)")
        else:
            print("❌ Items should NOT have InvoiceType field")
            all_good = False
        
        # 4. Check all required item fields are present
        required_fields = ['ItemCode', 'ItemName', 'PCTCode', 'Quantity', 'TaxRate', 'SaleValue', 'TaxCharged', 'TotalAmount', 'Discount', 'FurtherTax']
        for i, item in enumerate(fbr_payload['Items']):
            missing_fields = [field for field in required_fields if field not in item]
            if not missing_fields:
                print(f"✅ Item {i+1} has all required fields")
            else:
                print(f"❌ Item {i+1} missing fields: {missing_fields}")
                all_good = False
        
        return all_good
        
    except Exception as e:
        print(f"❌ ERROR during transformation: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    print("Testing Updated Credit Note Fix")
    print("=" * 60)
    
    success = test_updated_credit_note_fix()
    
    print("\n" + "=" * 60)
    if success:
        print("✅ ALL TESTS PASSED - Credit note should now work with FBR API")
    else:
        print("❌ SOME TESTS FAILED")