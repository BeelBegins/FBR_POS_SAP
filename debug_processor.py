import sys
import os
import traceback
sys.path.append('src')

try:
    from invoice_processor import get_invoice_processor
    processor = get_invoice_processor()
    
    print("Testing invoice processor...")
    print(f"Stop on error: {processor.stop_on_error}")
    print(f"Process single: {processor.process_single_invoice}")
    
    # Test fetching invoices
    print("\nFetching invoices...")
    invoices = processor.fetch_pending_invoices()
    print(f"Found {len(invoices)} invoices")
    
    if invoices:
        print("\nTesting single invoice processing...")
        result = processor.process_single_invoice(invoices[0])
        print(f"Processing result: {result}")
    
except Exception as e:
    print(f"Error: {str(e)}")
    print("\nFull traceback:")
    traceback.print_exc()