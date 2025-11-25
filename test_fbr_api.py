import sys
import os
import json
sys.path.append('src')

from fbr_api_client import get_fbr_client
from invoice_processor import get_invoice_processor

# Test just the FBR API client
processor = get_invoice_processor()
fbr_client = get_fbr_client()

print("Getting a sample invoice...")
invoices = processor.fetch_pending_invoices()
if invoices:
    print(f"Found {len(invoices)} invoices")
    
    # Transform to FBR format
    fbr_payload = processor.transform_to_fbr_format(invoices[0])
    
    print("\nFBR Payload Preview:")
    print(f"USIN: {fbr_payload['USIN']}")
    print(f"Total Amount: {fbr_payload['TotalBillAmount']}")
    print(f"Items Count: {len(fbr_payload['Items'])}")
    print(f"POSID: {fbr_payload['POSID']}")
    
    print("\nSubmitting to FBR API...")
    success, response = fbr_client.submit_invoice(fbr_payload)
    
    print(f"\nResponse Success: {success}")
    print(f"Response Data: {json.dumps(response, indent=2)}")
    
    # Let's also see the full payload structure
    print(f"\nFull FBR Payload:")
    print(json.dumps(fbr_payload, indent=2))