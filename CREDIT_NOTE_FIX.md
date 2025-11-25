# Credit Note USIN Fix Documentation

## Issue Description
Credit notes (InvoiceType 2) were not being successfully uploaded to FBR because the USIN field was being populated, when it should be null for credit notes according to FBR API requirements.

## Root Cause
In the `transform_to_fbr_format` method in `invoice_processor.py`, the USIN was being generated and set for all invoice types without checking if it was a credit note.

## Solution Implemented

### 1. Modified Invoice Processor (`src/invoice_processor.py`)
- Updated the `transform_to_fbr_format` method to handle credit notes differently
- For InvoiceType 2 (credit notes):
  - Set `USIN` to `null`
  - Set `RefUSIN` to reference the original invoice from `BaseDoc` field
- For InvoiceType 1 (sales invoices):
  - Continue setting `USIN` as before
  - Set `RefUSIN` to the same value as `USIN`
- Added logging to track credit note processing

### 2. Improved Credit Note Query (`config/database_queries.py`)
- Enhanced the `BaseDoc` field in `CREDIT_NOTE_QUERY` to ensure proper formatting
- Added formatting to ensure the reference invoice number is properly padded with leading zeros

## Key Changes Made

### invoice_processor.py
```python
# Generate USIN (Unique Sales Invoice Number)
# For credit notes (InvoiceType 2), USIN should be null
invoice_type = int(header.get('InvoiceType', 1))
if invoice_type == 2:
    usin = None
    # For credit notes, RefUSIN should reference the original invoice
    ref_usin = header.get('BaseDoc', f"{header['DocNum']:06d}")
    logger.info(f"Credit note {header['DocNum']}: USIN set to null, RefUSIN set to {ref_usin}")
else:
    usin = f"{header['DocNum']:06d}"
    ref_usin = usin
    logger.debug(f"Sales invoice {header['DocNum']}: USIN and RefUSIN set to {usin}")
```

### database_queries.py
```sql
CASE 
    WHEN T1.BaseDocNum IS NOT NULL AND T1.BaseDocNum != '' 
    THEN FORMAT(T1.BaseDocNum, '000000')
    ELSE FORMAT(T0.DocNum, '000000')
END as BaseDoc
```

## Testing Results
- Sales invoices (InvoiceType 1): USIN populated correctly ✅
- Credit notes (InvoiceType 2): USIN set to null, RefUSIN references original invoice ✅

## Impact
- Credit notes should now upload successfully to FBR
- Sales invoices continue to work as before
- Proper logging added for debugging credit note processing
- No breaking changes to existing functionality

## Next Steps
1. Test with actual credit note data from SAP B1
2. Monitor FBR submission logs for successful credit note uploads
3. Verify that RefUSIN correctly references the original invoice numbers

Date: October 9, 2025