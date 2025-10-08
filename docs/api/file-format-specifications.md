# File Format Specifications

## Overview

This document defines the file formats supported by Carmen.NET for data import, export, and integration with external systems.

## Supported Formats

- **CSV** (Comma-Separated Values): Data import/export
- **Excel** (XLSX): Batch data entry and reporting
- **JSON**: API-based integration
- **XML**: Legacy system integration
- **PDF**: Document generation
- **TXT**: Bank statement formats

---

## CSV Formats

### General CSV Rules

- **Encoding**: UTF-8 with BOM
- **Delimiter**: Comma (,)
- **Text Qualifier**: Double quote (")
- **Date Format**: yyyy-MM-dd (ISO 8601)
- **Decimal Separator**: Period (.)
- **Header Row**: Required
- **Max File Size**: 100 MB
- **Max Records**: 100,000 per file

### AP Invoice Import (CSV)

**File Name**: `ap-invoice-import.csv`

**Format**:
```csv
InvoiceNumber,InvoiceDate,DueDate,VendorCode,Description,Amount,TaxAmount,WHTAmount,AccountCode,LineDescription,LineAmount
INV-2025-001,2025-10-06,2025-11-05,V001,Professional Services,100000.00,7000.00,5000.00,5100,Consulting Services,100000.00
INV-2025-002,2025-10-07,2025-11-06,V002,Office Supplies,5000.00,350.00,0,5200,Stationery,5000.00
```

**Field Specifications**:

| Field | Type | Max Length | Required | Description |
|-------|------|------------|----------|-------------|
| **InvoiceNumber** | Text | 50 | Yes | Unique invoice number |
| **InvoiceDate** | Date | 10 | Yes | Invoice date (yyyy-MM-dd) |
| **DueDate** | Date | 10 | Yes | Payment due date |
| **VendorCode** | Text | 20 | Yes | Must exist in vendor master |
| **Description** | Text | 500 | No | Invoice description |
| **Amount** | Decimal | - | Yes | Total invoice amount |
| **TaxAmount** | Decimal | - | No | VAT amount |
| **WHTAmount** | Decimal | - | No | Withholding tax amount |
| **AccountCode** | Text | 20 | Yes | GL expense account |
| **LineDescription** | Text | 500 | No | Line item description |
| **LineAmount** | Decimal | - | Yes | Line item amount |

**Validation Rules**:
- InvoiceNumber must be unique per vendor
- InvoiceDate <= DueDate
- VendorCode must exist and be active
- Sum of LineAmount must equal Amount
- AccountCode must exist and allow posting

**Sample Import**:
```csv
InvoiceNumber,InvoiceDate,DueDate,VendorCode,Description,Amount,TaxAmount,WHTAmount,AccountCode,LineDescription,LineAmount
"INV-2025-001","2025-10-06","2025-11-05","V001","Professional Services - October",100000.00,7000.00,5000.00,"5100","Consulting Services",100000.00
"INV-2025-002","2025-10-07","2025-11-06","V002","Office Supplies",5000.00,350.00,0,"5200","Stationery and Paper",3000.00
"INV-2025-002","2025-10-07","2025-11-06","V002","Office Supplies",5000.00,350.00,0,"5200","Printer Ink",2000.00
```

### AR Invoice Import (CSV)

**File Name**: `ar-invoice-import.csv`

**Format**:
```csv
InvoiceNumber,InvoiceDate,DueDate,CustomerCode,Description,Amount,TaxAmount,RevenueAccountCode,LineDescription,LineAmount
AR-2025-001,2025-10-06,2025-11-05,C001,Monthly Subscription,50000.00,3500.00,4100,Software License,50000.00
```

**Field Specifications**:

| Field | Type | Max Length | Required | Description |
|-------|------|------------|----------|-------------|
| **InvoiceNumber** | Text | 50 | Yes | Unique invoice number |
| **InvoiceDate** | Date | 10 | Yes | Invoice date |
| **DueDate** | Date | 10 | Yes | Payment due date |
| **CustomerCode** | Text | 20 | Yes | Must exist in customer master |
| **Description** | Text | 500 | No | Invoice description |
| **Amount** | Decimal | - | Yes | Total invoice amount |
| **TaxAmount** | Decimal | - | No | VAT amount |
| **RevenueAccountCode** | Text | 20 | Yes | GL revenue account |
| **LineDescription** | Text | 500 | No | Line item description |
| **LineAmount** | Decimal | - | Yes | Line item amount |

### Bank Statement Import (CSV)

**File Name**: `bank-statement-{AccountCode}-{Date}.csv`

**Format**:
```csv
TransactionDate,ValueDate,Description,ReferenceNumber,DebitAmount,CreditAmount,Balance
2025-10-01,2025-10-01,Opening Balance,OB-001,0,0,1000000.00
2025-10-02,2025-10-02,Check Payment,CHK-100,50000.00,0,950000.00
2025-10-03,2025-10-03,Wire Receipt,WIRE-001,0,100000.00,1050000.00
```

**Field Specifications**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| **TransactionDate** | Date | Yes | Transaction date |
| **ValueDate** | Date | Yes | Value date (for interest calculation) |
| **Description** | Text | Yes | Transaction description |
| **ReferenceNumber** | Text | Yes | Bank reference number |
| **DebitAmount** | Decimal | Yes | Debit amount (0 if credit) |
| **CreditAmount** | Decimal | Yes | Credit amount (0 if debit) |
| **Balance** | Decimal | Yes | Running balance after transaction |

---

## Excel Formats (XLSX)

### General Excel Rules

- **File Format**: Excel 2007+ (.xlsx)
- **Sheet Name**: Must match template name
- **Header Row**: Row 1
- **Data Start**: Row 2
- **Max Rows**: 100,000
- **Max File Size**: 100 MB

### AP Invoice Batch Entry Template

**File Name**: `AP_Invoice_Template.xlsx`

**Sheet 1: Invoice Header**

| Column | Field | Type | Required | Notes |
|--------|-------|------|----------|-------|
| A | InvoiceNumber | Text | Yes | Unique per vendor |
| B | InvoiceDate | Date | Yes | mm/dd/yyyy |
| C | DueDate | Date | Yes | mm/dd/yyyy |
| D | VendorCode | Text | Yes | Lookup from vendor list |
| E | Description | Text | No | Max 500 chars |
| F | TotalAmount | Currency | Yes | Auto-calculated |
| G | TaxAmount | Currency | No | VAT amount |
| H | WHTAmount | Currency | No | Withholding tax |

**Sheet 2: Invoice Lines**

| Column | Field | Type | Required | Notes |
|--------|-------|------|----------|-------|
| A | InvoiceNumber | Text | Yes | Must match header |
| B | LineNo | Number | Yes | Sequential |
| C | AccountCode | Text | Yes | GL account |
| D | DepartmentCode | Text | No | Cost center |
| E | Description | Text | No | Line description |
| F | Amount | Currency | Yes | Line amount |

**Data Validation**:
- VendorCode: List from Master Data sheet
- AccountCode: List from Chart of Accounts sheet
- InvoiceDate: Date picker
- Amount: Number format with 2 decimals

**Formulas**:
```excel
// Total Amount (Sheet 1, Column F)
=SUMIF('Invoice Lines'!$A:$A, A2, 'Invoice Lines'!$F:$F)

// Net Payment (Sheet 1, Column I)
=F2 + G2 - H2
```

### GL Journal Entry Template

**File Name**: `GL_JV_Template.xlsx`

**Format**:

| Column | Field | Type | Required |
|--------|-------|------|----------|
| A | JVNumber | Text | Yes |
| B | JVDate | Date | Yes |
| C | Description | Text | Yes |
| D | LineNo | Number | Yes |
| E | AccountCode | Text | Yes |
| F | DebitAmount | Currency | Conditional |
| G | CreditAmount | Currency | Conditional |
| H | LineDescription | Text | No |

**Validation**:
```excel
// Ensure balanced entry
=IF(SUMIF($A:$A, A2, $F:$F) = SUMIF($A:$A, A2, $G:$G), "Balanced", "UNBALANCED")
```

---

## JSON Formats

### General JSON Rules

- **Encoding**: UTF-8
- **Date Format**: ISO 8601 (yyyy-MM-ddTHH:mm:ssZ)
- **Decimal Format**: Number (not string)
- **Null Values**: Allowed for optional fields
- **Max File Size**: 50 MB

### AP Invoice (JSON)

```json
{
  "invoices": [
    {
      "invoiceNumber": "INV-2025-001",
      "invoiceDate": "2025-10-06",
      "dueDate": "2025-11-05",
      "vendorCode": "V001",
      "description": "Professional Services",
      "amount": 100000.00,
      "taxAmount": 7000.00,
      "whtAmount": 5000.00,
      "lines": [
        {
          "lineNo": 1,
          "accountCode": "5100",
          "description": "Consulting Services",
          "amount": 100000.00,
          "departmentCode": "IT"
        }
      ]
    }
  ]
}
```

### Batch Import Response (JSON)

```json
{
  "success": true,
  "summary": {
    "totalRecords": 100,
    "successCount": 95,
    "errorCount": 5,
    "processingTime": "12.5s"
  },
  "results": [
    {
      "recordNumber": 1,
      "success": true,
      "id": "12345",
      "message": "Invoice created successfully"
    },
    {
      "recordNumber": 2,
      "success": false,
      "errors": [
        {
          "field": "vendorCode",
          "code": "VENDOR_NOT_FOUND",
          "message": "Vendor V999 does not exist"
        }
      ]
    }
  ]
}
```

---

## XML Formats

### General XML Rules

- **Encoding**: UTF-8
- **Schema**: XSD validation supported
- **Namespace**: `http://schemas.carmen.com/erp/v1`
- **Max File Size**: 50 MB

### AP Invoice (XML)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<invoices xmlns="http://schemas.carmen.com/erp/v1">
  <invoice>
    <invoiceNumber>INV-2025-001</invoiceNumber>
    <invoiceDate>2025-10-06</invoiceDate>
    <dueDate>2025-11-05</dueDate>
    <vendor>
      <vendorCode>V001</vendorCode>
    </vendor>
    <description>Professional Services</description>
    <amounts>
      <amount>100000.00</amount>
      <taxAmount>7000.00</taxAmount>
      <whtAmount>5000.00</whtAmount>
    </amounts>
    <lines>
      <line>
        <lineNo>1</lineNo>
        <accountCode>5100</accountCode>
        <description>Consulting Services</description>
        <amount>100000.00</amount>
        <departmentCode>IT</departmentCode>
      </line>
    </lines>
  </invoice>
</invoices>
```

---

## Bank File Formats

### MT940 (SWIFT Bank Statement)

**Format**: Fixed-width text file

**Sample**:
```
:20:STATEMENT001
:25:BANK001/1234567890
:28C:00001/001
:60F:C251001THB1000000,00
:61:251002C50000,00NCHKCHK-100//REF001
:86:Check Payment
:62F:C251002THB950000,00
```

**Field Mapping**:

| Tag | Field | Description |
|-----|-------|-------------|
| :20: | Reference | Statement reference |
| :25: | Account | Bank account number |
| :28C: | Number | Statement number |
| :60F: | Opening Balance | Opening balance |
| :61: | Transaction | Transaction details |
| :86: | Description | Transaction description |
| :62F: | Closing Balance | Closing balance |

---

## PDF Generation

### Invoice PDF Template

**Requirements**:
- **Page Size**: A4
- **Margins**: 1 inch all sides
- **Font**: Arial 10pt
- **Logo**: Top left (max 200x80px)
- **Barcode**: Bottom right (Code 128)

**Sections**:
1. Company Header
2. Invoice Details
3. Bill To / Ship To
4. Line Items Table
5. Totals
6. Payment Terms
7. Footer with Tax Information

**File Naming**: `{InvoiceType}-{InvoiceNumber}-{Date}.pdf`

Example: `AP-INV-2025-001-20251006.pdf`

---

## Import/Export API Endpoints

### Import Data

**Endpoint**: `POST /api/import/{module}/{entity}`

**Request (Multipart)**:
```http
POST /api/import/ap/invoice HTTP/1.1
Content-Type: multipart/form-data; boundary=----Boundary

------Boundary
Content-Disposition: form-data; name="file"; filename="invoices.csv"
Content-Type: text/csv

[CSV content here]
------Boundary
Content-Disposition: form-data; name="options"
Content-Type: application/json

{
  "validateOnly": false,
  "skipErrors": true,
  "batchSize": 100
}
------Boundary--
```

**Response**:
```json
{
  "success": true,
  "jobId": "import-12345",
  "status": "Processing",
  "totalRecords": 1000,
  "processedRecords": 0
}
```

### Check Import Status

**Endpoint**: `GET /api/import/status/{jobId}`

**Response**:
```json
{
  "success": true,
  "jobId": "import-12345",
  "status": "Completed",
  "totalRecords": 1000,
  "successCount": 995,
  "errorCount": 5,
  "startTime": "2025-10-06T10:00:00Z",
  "endTime": "2025-10-06T10:05:30Z",
  "errorFile": "/downloads/import-12345-errors.csv"
}
```

### Export Data

**Endpoint**: `GET /api/export/{module}/{entity}`

**Query Parameters**:
- `format`: csv, excel, json, xml
- `fromDate`, `toDate`: Date range
- `status`: Filter by status
- Additional filters as query parameters

**Response Headers**:
```http
Content-Type: text/csv
Content-Disposition: attachment; filename="ap-invoices-20251006.csv"
```

---

## Error File Format

When imports fail, an error file is generated with the original data plus error columns.

**Error CSV Format**:
```csv
RowNumber,ErrorCode,ErrorMessage,[Original Columns...]
2,VENDOR_NOT_FOUND,Vendor V999 does not exist,INV-2025-001,2025-10-06,...
5,DUPLICATE_INVOICE,Invoice number already exists,INV-2025-001,2025-10-06,...
```

---

## Best Practices

### Data Preparation

1. **Clean Data**: Remove duplicates, validate formats
2. **Test Import**: Use validateOnly=true first
3. **Batch Size**: Use batches of 100-1000 records
4. **Encoding**: Always use UTF-8 with BOM for CSV
5. **Backup**: Backup data before import

### Performance

1. **File Size**: Keep files under 50 MB
2. **Record Count**: Max 100,000 per file
3. **Compression**: Use ZIP for large files
4. **Async Processing**: Use async import for > 1000 records

### Error Handling

1. **Validation**: Validate data before import
2. **Skip Errors**: Use skipErrors=true for partial success
3. **Error Review**: Review error files thoroughly
4. **Retry**: Retry failed records after correction

---

**Document Version**: 1.0
**Last Updated**: 2025-10-06
**Status**: Phase 4 - API & Integration Documentation
