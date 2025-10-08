# Carmen.NET Data Dictionary

**Document Version**: 1.0
**Last Updated**: 2025-10-06
**Status**: Phase 5 - Business Analyst Documentation
**Target Audience**: Business Analysts, Developers, QA Team, Auditors

---

## ⚠️ Important Notice

**This data dictionary reflects VERIFIED entities from the actual Carmen.NET source code.**

**Missing/Not Implemented**:
- Purchase Order (PO) module and related entities
- Goods Receipt (GR) module and related entities
- Three-way match validation (AP Invoice ↔ PO ↔ GR)

The document focuses exclusively on implemented features: Accounts Payable (AP Invoice/Payment), Accounts Receivable (AR Invoice/Receipt), General Ledger (GL Journal Voucher), Asset Management, and Master Data entities.

---

## Overview

This document defines all data fields, enumerations, code tables, and validation rules used in the Carmen.NET ERP system. It serves as the authoritative reference for data definitions across all 11 modules.

**Purpose**: Ensure consistent understanding of data elements across technical and business teams.

---

## Table of Contents

1. [Common Fields](#common-fields)
2. [Accounts Payable (AP)](#accounts-payable-ap)
3. [Accounts Receivable (AR)](#accounts-receivable-ar)
4. [General Ledger (GL)](#general-ledger-gl)
5. [Asset Management](#asset-management)
6. [Master Data](#master-data)
7. [Enumerations](#enumerations)
8. [Code Tables](#code-tables)
9. [Validation Rules](#validation-rules)

---

## Common Fields

**Base Entity Fields** - Present in all database tables

| Field Name | Data Type | Length | Required | Description |
|------------|-----------|--------|----------|-------------|
| **Id** | INT | - | Yes | Primary key, auto-increment |
| **TenantCode** | NVARCHAR | 20 | Yes | Multi-tenant identifier |
| **CreatedBy** | INT | - | Yes | User ID who created record |
| **CreatedDate** | DATETIME | - | Yes | Record creation timestamp |
| **UpdatedBy** | INT | - | No | User ID who last updated record |
| **UpdatedDate** | DATETIME | - | No | Last update timestamp |
| **IsDeleted** | BIT | - | Yes | Soft delete flag (default: 0) |

**Audit Fields** - For financial transactions

| Field Name | Data Type | Length | Required | Description |
|------------|-----------|--------|----------|-------------|
| **Status** | NVARCHAR | 50 | Yes | Transaction status (see enums) |
| **ApprovedBy** | INT | - | No | User ID who approved |
| **ApprovedDate** | DATETIME | - | No | Approval timestamp |
| **PostedBy** | INT | - | No | User ID who posted to GL |
| **PostedDate** | DATETIME | - | No | GL posting timestamp |
| **CancelledBy** | INT | - | No | User ID who cancelled |
| **CancelledDate** | DATETIME | - | No | Cancellation timestamp |
| **CancellationReason** | NVARCHAR | 500 | No | Reason for cancellation |

---

## Accounts Payable (AP)

### VENDOR - Vendor Master Data

| Field Name | Data Type | Length | Required | Validation | Description |
|------------|-----------|--------|----------|------------|-------------|
| **VendorCode** | NVARCHAR | 20 | Yes | Unique per tenant | Vendor identifier |
| **VendorName** | NVARCHAR | 200 | Yes | Min 2 chars | Vendor legal name |
| **TaxId** | NVARCHAR | 20 | Yes | Thai format: 0-0000-00000-00-0 | Tax identification number |
| **Address** | NVARCHAR | 500 | No | - | Vendor address |
| **District** | NVARCHAR | 100 | No | - | District/sub-district |
| **Province** | NVARCHAR | 100 | No | - | Province |
| **PostalCode** | NVARCHAR | 10 | No | 5 digits | Postal code |
| **Country** | NVARCHAR | 50 | Yes | Default: 'Thailand' | Country |
| **ContactPerson** | NVARCHAR | 100 | No | - | Primary contact name |
| **Phone** | NVARCHAR | 20 | No | - | Contact phone |
| **Email** | NVARCHAR | 100 | No | Email format | Contact email |
| **PaymentTerms** | NVARCHAR | 20 | Yes | See PaymentTerms enum | Payment terms (NET 30, etc.) |
| **CreditLimit** | DECIMAL | 18,2 | No | ≥ 0 | Credit limit amount |
| **BankAccountNumber** | NVARCHAR | 50 | No | - | Vendor bank account |
| **BankName** | NVARCHAR | 100 | No | - | Vendor bank name |
| **VendorType** | NVARCHAR | 50 | No | See VendorType enum | Vendor category |
| **Status** | NVARCHAR | 20 | Yes | See VendorStatus enum | Active/Inactive/Blocked |

**Example**:
```json
{
  "vendorCode": "V001",
  "vendorName": "ABC Supply Co., Ltd.",
  "taxId": "0-1234-56789-01-2",
  "paymentTerms": "NET30",
  "status": "Active"
}
```

---

### AP_INVOICE_H - AP Invoice Header

| Field Name | Data Type | Length | Required | Validation | Description |
|------------|-----------|--------|----------|------------|-------------|
| **InvoiceNumber** | NVARCHAR | 50 | Yes | Unique per vendor | Invoice number |
| **InvoiceDate** | DATE | - | Yes | ≤ Today | Invoice date |
| **DueDate** | DATE | - | Yes | ≥ InvoiceDate | Payment due date |
| **VendorCode** | NVARCHAR | 20 | Yes | Must exist | Foreign key to VENDOR |
| **VendorName** | NVARCHAR | 200 | No | - | Vendor name (denormalized) |
| **Description** | NVARCHAR | 500 | No | - | Invoice description |
| **Amount** | DECIMAL | 18,2 | Yes | > 0 | Invoice amount (before tax) |
| **TaxAmount** | DECIMAL | 18,2 | No | ≥ 0 | VAT amount (7%) |
| **WhtAmount** | DECIMAL | 18,2 | No | ≥ 0 | Withholding tax amount |
| **TotalAmount** | DECIMAL | 18,2 | Yes | = Amount + TaxAmount - WhtAmount | Total invoice amount |
| **OutstandingAmount** | DECIMAL | 18,2 | Yes | ≤ TotalAmount | Unpaid amount |
| **CurrencyCode** | NVARCHAR | 3 | Yes | Default: 'THB' | Currency code |
| **ExchangeRate** | DECIMAL | 18,6 | Yes | Default: 1.0 | Exchange rate to base currency |
| **TaxCode** | NVARCHAR | 20 | No | Must exist | Tax code (VAT07, WHT03, etc.) |
| **Status** | NVARCHAR | 50 | Yes | See ApInvoiceStatus enum | Invoice status |

**Calculated Fields**:
- **OutstandingAmount** = TotalAmount - SUM(Payments)
- **TotalAmount** = Amount + TaxAmount - WhtAmount

---

### AP_INVOICE_D - AP Invoice Lines

| Field Name | Data Type | Length | Required | Validation | Description |
|------------|-----------|--------|----------|------------|-------------|
| **InvoiceId** | INT | - | Yes | FK to AP_INVOICE_H | Invoice header ID |
| **LineNo** | INT | - | Yes | Sequential | Line number |
| **AccountCode** | NVARCHAR | 20 | Yes | Must exist, allow posting | GL account code |
| **Description** | NVARCHAR | 500 | No | - | Line description |
| **Amount** | DECIMAL | 18,2 | Yes | ≠ 0 | Line amount |
| **DepartmentCode** | NVARCHAR | 10 | No | Must exist | Department code |
| **ProjectCode** | NVARCHAR | 10 | No | Must exist | Project code |
| **Quantity** | DECIMAL | 18,4 | No | > 0 | Quantity |
| **UnitPrice** | DECIMAL | 18,4 | No | ≥ 0 | Unit price |
| **UnitOfMeasure** | NVARCHAR | 10 | No | - | Unit (EA, KG, M, etc.) |

**Business Rules**:
- Sum of line amounts must equal header amount
- At least one line required
- Account code must allow posting

---

### AP_PAYMENT - AP Payment

| Field Name | Data Type | Length | Required | Validation | Description |
|------------|-----------|--------|----------|------------|-------------|
| **PaymentNumber** | NVARCHAR | 50 | Yes | Unique | Payment number (PAY-YYYY-NNNN) |
| **PaymentDate** | DATE | - | Yes | ≤ Today | Payment date |
| **VendorCode** | NVARCHAR | 20 | Yes | Must exist | Vendor code |
| **PaymentMethod** | NVARCHAR | 20 | Yes | See PaymentMethod enum | Check/Wire/ACH |
| **BankAccountCode** | NVARCHAR | 20 | Yes | Must exist | Company bank account |
| **Amount** | DECIMAL | 18,2 | Yes | > 0 | Payment amount |
| **CheckNumber** | NVARCHAR | 20 | No | Required if method=Check | Check number |
| **TransferReference** | NVARCHAR | 50 | No | Required if method=Wire/ACH | Transfer reference |
| **Description** | NVARCHAR | 500 | No | - | Payment description |
| **Status** | NVARCHAR | 50 | Yes | See PaymentStatus enum | Payment status |

---

## Accounts Receivable (AR)

### CUSTOMER - Customer Master Data

| Field Name | Data Type | Length | Required | Validation | Description |
|------------|-----------|--------|----------|------------|-------------|
| **CustomerCode** | NVARCHAR | 20 | Yes | Unique per tenant | Customer identifier |
| **CustomerName** | NVARCHAR | 200 | Yes | Min 2 chars | Customer legal name |
| **TaxId** | NVARCHAR | 20 | No | Thai format | Tax identification |
| **Address** | NVARCHAR | 500 | No | - | Customer address |
| **ContactPerson** | NVARCHAR | 100 | No | - | Primary contact |
| **Phone** | NVARCHAR | 20 | No | - | Contact phone |
| **Email** | NVARCHAR | 100 | No | Email format | Contact email |
| **PaymentTerms** | NVARCHAR | 20 | Yes | See PaymentTerms enum | Payment terms |
| **CreditLimit** | DECIMAL | 18,2 | No | ≥ 0 | Credit limit |
| **OutstandingBalance** | DECIMAL | 18,2 | Yes | ≥ 0 | Current outstanding |
| **AvailableCredit** | DECIMAL | 18,2 | Yes | Calculated | CreditLimit - OutstandingBalance |
| **Status** | NVARCHAR | 20 | Yes | See CustomerStatus enum | Active/Inactive/Blocked |

---

### AR_INVOICE_H - AR Invoice Header

| Field Name | Data Type | Length | Required | Validation | Description |
|------------|-----------|--------|----------|------------|-------------|
| **InvoiceNumber** | NVARCHAR | 50 | Yes | Unique | Invoice number (AR-YYYY-NNNN) |
| **InvoiceDate** | DATE | - | Yes | ≤ Today | Invoice date |
| **DueDate** | DATE | - | Yes | ≥ InvoiceDate | Payment due date |
| **CustomerCode** | NVARCHAR | 20 | Yes | Must exist | Customer code |
| **CustomerName** | NVARCHAR | 200 | No | - | Customer name (denormalized) |
| **Description** | NVARCHAR | 500 | No | - | Invoice description |
| **ContractNumber** | NVARCHAR | 50 | No | Must exist if provided | Contract reference |
| **Amount** | DECIMAL | 18,2 | Yes | > 0 | Invoice amount (before VAT) |
| **VatAmount** | DECIMAL | 18,2 | No | ≥ 0 | VAT amount (7%) |
| **TotalAmount** | DECIMAL | 18,2 | Yes | = Amount + VatAmount | Total invoice amount |
| **OutstandingAmount** | DECIMAL | 18,2 | Yes | ≤ TotalAmount | Unpaid amount |
| **Status** | NVARCHAR | 50 | Yes | See ArInvoiceStatus enum | Invoice status |

---

### AR_RECEIPT - AR Receipt

| Field Name | Data Type | Length | Required | Validation | Description |
|------------|-----------|--------|----------|------------|-------------|
| **ReceiptNumber** | NVARCHAR | 50 | Yes | Unique | Receipt number (REC-YYYY-NNNN) |
| **ReceiptDate** | DATE | - | Yes | ≤ Today | Receipt date |
| **CustomerCode** | NVARCHAR | 20 | Yes | Must exist | Customer code |
| **PaymentMethod** | NVARCHAR | 20 | Yes | See PaymentMethod enum | Cash/Check/Transfer |
| **Amount** | DECIMAL | 18,2 | Yes | > 0 | Receipt amount |
| **CheckNumber** | NVARCHAR | 20 | No | Required if method=Check | Check number |
| **CheckDate** | DATE | - | No | Required if method=Check | Check date |
| **BankCode** | NVARCHAR | 20 | No | - | Bank code |
| **DepositDate** | DATE | - | No | ≥ ReceiptDate | Bank deposit date |
| **Description** | NVARCHAR | 500 | No | - | Receipt description |
| **Status** | NVARCHAR | 50 | Yes | See ReceiptStatus enum | Receipt status |

---

## General Ledger (GL)

### GL_ACCOUNT - Chart of Accounts

| Field Name | Data Type | Length | Required | Validation | Description |
|------------|-----------|--------|----------|------------|-------------|
| **AccountCode** | NVARCHAR | 20 | Yes | Unique, Format: AAAA-BB-CC-DD | GL account code (10 digits) |
| **AccountName** | NVARCHAR | 200 | Yes | Min 2 chars | Account name |
| **AccountType** | NVARCHAR | 20 | Yes | See AccountType enum | Asset/Liability/Equity/Revenue/Expense |
| **NormalBalance** | NVARCHAR | 10 | Yes | DR or CR | Normal balance (Debit/Credit) |
| **ParentAccountCode** | NVARCHAR | 20 | No | Must exist | Parent account (for hierarchy) |
| **Level** | INT | - | Yes | 1-4 | Hierarchy level |
| **AllowPosting** | BIT | - | Yes | Default: 1 | Allow direct posting |
| **IsActive** | BIT | - | Yes | Default: 1 | Active status |

**Account Code Format**:
- **AAAA**: Main account (1000-9999)
  - 1000-1999: Assets
  - 2000-2999: Liabilities
  - 3000-3999: Equity
  - 4000-4999: Revenue
  - 5000-9999: Expenses
- **BB**: Sub-account (01-99)
- **CC**: Department (01-99)
- **DD**: Project (01-99)

**Example**: `1100-01-10-20` = Cash in Bank - Checking - IT Dept - Project Alpha

---

### GL_JV_H - Journal Voucher Header

| Field Name | Data Type | Length | Required | Validation | Description |
|------------|-----------|--------|----------|------------|-------------|
| **JvNumber** | NVARCHAR | 50 | Yes | Unique | JV number (JV-YYYY-NNNN) |
| **JvDate** | DATE | - | Yes | Within open period | Journal date |
| **Description** | NVARCHAR | 500 | Yes | - | JV description |
| **PeriodYear** | INT | - | Yes | - | Fiscal year |
| **PeriodNumber** | INT | - | Yes | 1-12 | Period number |
| **TotalDebit** | DECIMAL | 18,2 | Yes | > 0 | Total debit amount |
| **TotalCredit** | DECIMAL | 18,2 | Yes | > 0 | Total credit amount |
| **IsBalanced** | BIT | - | Yes | Calculated | TotalDebit = TotalCredit |
| **ReversalJvNumber** | NVARCHAR | 50 | No | Must exist | Original JV if reversal |
| **Status** | NVARCHAR | 50 | Yes | See JvStatus enum | JV status |

**Business Rules**:
- Total debits must equal total credits
- JV date must be within open period
- Posted JVs cannot be modified

---

### GL_JV_D - Journal Voucher Lines

| Field Name | Data Type | Length | Required | Validation | Description |
|------------|-----------|--------|----------|------------|-------------|
| **JvId** | INT | - | Yes | FK to GL_JV_H | JV header ID |
| **LineNo** | INT | - | Yes | Sequential | Line number |
| **AccountCode** | NVARCHAR | 20 | Yes | Must exist, allow posting | GL account code |
| **Description** | NVARCHAR | 500 | No | - | Line description |
| **DebitAmount** | DECIMAL | 18,2 | No | ≥ 0 | Debit amount (0 if credit) |
| **CreditAmount** | DECIMAL | 18,2 | No | ≥ 0 | Credit amount (0 if debit) |
| **DepartmentCode** | NVARCHAR | 10 | No | Must exist | Department |
| **ProjectCode** | NVARCHAR | 10 | No | Must exist | Project |

**Business Rules**:
- Either DebitAmount OR CreditAmount must be > 0 (not both)
- At least 2 lines required (one DR, one CR)

---

## Asset Management

### ASSET_REGISTER - Asset Register

| Field Name | Data Type | Length | Required | Validation | Description |
|------------|-----------|--------|----------|------------|-------------|
| **AssetCode** | NVARCHAR | 20 | Yes | Unique | Asset identifier |
| **AssetName** | NVARCHAR | 200 | Yes | - | Asset name |
| **AssetCategoryCode** | NVARCHAR | 20 | Yes | Must exist | Asset category |
| **AcquisitionDate** | DATE | - | Yes | ≤ Today | Purchase/acquisition date |
| **AcquisitionCost** | DECIMAL | 18,2 | Yes | > 0 | Original cost |
| **AccumulatedDepreciation** | DECIMAL | 18,2 | Yes | ≥ 0, ≤ AcquisitionCost | Total depreciation to date |
| **NetBookValue** | DECIMAL | 18,2 | Yes | Calculated | AcquisitionCost - AccumulatedDepreciation |
| **DepreciationMethod** | NVARCHAR | 20 | Yes | See DepreciationMethod enum | Straight-Line/Declining Balance |
| **UsefulLifeYears** | INT | - | Yes | > 0 | Useful life in years |
| **SalvageValue** | DECIMAL | 18,2 | No | ≥ 0 | Residual value |
| **DepartmentCode** | NVARCHAR | 10 | No | Must exist | Department |
| **LocationCode** | NVARCHAR | 10 | No | Must exist | Physical location |
| **SerialNumber** | NVARCHAR | 50 | No | - | Serial/model number |
| **Status** | NVARCHAR | 20 | Yes | See AssetStatus enum | Active/Disposed/Written Off |

---

## Master Data

### DEPARTMENT - Department Master

| Field Name | Data Type | Length | Required | Validation | Description |
|------------|-----------|--------|----------|------------|-------------|
| **DepartmentCode** | NVARCHAR | 10 | Yes | Unique | Department code |
| **DepartmentName** | NVARCHAR | 100 | Yes | - | Department name |
| **ManagerUserId** | INT | - | No | Must exist | Department manager |
| **IsActive** | BIT | - | Yes | Default: 1 | Active status |

---

### PROJECT - Project Master

| Field Name | Data Type | Length | Required | Validation | Description |
|------------|-----------|--------|----------|------------|-------------|
| **ProjectCode** | NVARCHAR | 10 | Yes | Unique | Project code |
| **ProjectName** | NVARCHAR | 100 | Yes | - | Project name |
| **StartDate** | DATE | - | Yes | - | Project start date |
| **EndDate** | DATE | - | No | ≥ StartDate | Project end date |
| **Budget** | DECIMAL | 18,2 | No | ≥ 0 | Project budget |
| **IsActive** | BIT | - | Yes | Default: 1 | Active status |

---

## Enumerations

### PaymentTerms
```csharp
public enum PaymentTerms
{
    NET15 = "NET 15",    // Payment due in 15 days
    NET30 = "NET 30",    // Payment due in 30 days
    NET60 = "NET 60",    // Payment due in 60 days
    NET90 = "NET 90",    // Payment due in 90 days
    COD = "COD",         // Cash on delivery
    Prepaid = "Prepaid"  // Payment before delivery
}
```

### PaymentMethod
```csharp
public enum PaymentMethod
{
    Cash = "Cash",
    Check = "Check",
    Wire = "Wire",         // Bank wire transfer
    ACH = "ACH",          // Electronic transfer
    CreditCard = "Credit Card"
}
```

### ApInvoiceStatus
```csharp
public enum ApInvoiceStatus
{
    Draft = 1,
    PendingApproval = 2,
    Approved = 3,
    Rejected = 4,
    Posted = 5,
    PartiallyPaid = 6,
    FullyPaid = 7,
    Cancelled = 8
}
```

### ArInvoiceStatus
```csharp
public enum ArInvoiceStatus
{
    Draft = 1,
    PendingApproval = 2,
    Approved = 3,
    Rejected = 4,
    Posted = 5,
    PartiallyPaid = 6,
    FullyPaid = 7,
    CreditNote = 8,
    Cancelled = 9
}
```

### PaymentStatus
```csharp
public enum PaymentStatus
{
    Draft = 1,
    PendingApproval = 2,
    Approved = 3,
    Rejected = 4,
    Posted = 5,
    Voided = 6
}
```

### ReceiptStatus
```csharp
public enum ReceiptStatus
{
    Draft = 1,
    PendingApproval = 2,
    Approved = 3,
    Posted = 4,
    Deposited = 5,
    Bounced = 6,       // Check bounced
    Reversed = 7
}
```

### JvStatus
```csharp
public enum JvStatus
{
    Draft = 1,
    PendingApproval = 2,
    Approved = 3,
    Rejected = 4,
    Posted = 5,
    Reversed = 6
}
```

### AccountType
```csharp
public enum AccountType
{
    Asset = "Asset",
    Liability = "Liability",
    Equity = "Equity",
    Revenue = "Revenue",
    Expense = "Expense"
}
```

### DepreciationMethod
```csharp
public enum DepreciationMethod
{
    StraightLine = "Straight-Line",
    DecliningBalance = "Declining Balance",
    SumOfYears = "Sum of Years Digits"
}
```

### AssetStatus
```csharp
public enum AssetStatus
{
    Active = "Active",
    UnderMaintenance = "Under Maintenance",
    Disposed = "Disposed",
    WrittenOff = "Written Off"
}
```

---

## Code Tables

### TAX_CODE - Tax Code Master

| Code | Description | Type | Rate | Account Code |
|------|-------------|------|------|--------------|
| VAT07 | VAT 7% Standard | VAT | 7.00% | 2130 (VAT Payable) |
| VAT00 | VAT 0% Zero-Rated | VAT | 0.00% | 2130 |
| VATEX | VAT Exempt | VAT | 0.00% | - |
| WHT03 | WHT 3% Services | WHT | 3.00% | 1150 (WHT Receivable) |
| WHT05 | WHT 5% Professional | WHT | 5.00% | 1150 |
| WHT10 | WHT 10% Dividends | WHT | 10.00% | 1150 |
| WHT15 | WHT 15% Interest | WHT | 15.00% | 1150 |

### CURRENCY - Currency Master

| Code | Name | Symbol | Exchange Rate | Decimal Places |
|------|------|--------|---------------|----------------|
| THB | Thai Baht | ฿ | 1.0000 | 2 |
| USD | US Dollar | $ | 35.5000 | 2 |
| EUR | Euro | € | 38.2000 | 2 |
| JPY | Japanese Yen | ¥ | 0.2400 | 0 |

---

## Validation Rules

### Field Validation

**Email Validation**:
```regex
^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$
```

**Thai Tax ID Validation**:
```regex
^\d-\d{4}-\d{5}-\d{2}-\d$
```
Example: `0-1234-56789-01-2`

**Phone Validation** (Thailand):
```regex
^(\+66|0)[0-9]{8,9}$
```
Example: `+66812345678` or `0812345678`

**Postal Code Validation** (Thailand):
```regex
^\d{5}$
```
Example: `10400`

### Business Validation

**Invoice Amount Validation**:
```
Amount > 0
TaxAmount >= 0
WhtAmount >= 0
TotalAmount = Amount + TaxAmount - WhtAmount
Sum(LineAmounts) = Amount
```

**Date Validation**:
```
InvoiceDate <= Today
DueDate >= InvoiceDate
PaymentDate >= InvoiceDate
```

**Credit Limit Validation**:
```
CustomerOutstanding + NewInvoiceAmount <= CustomerCreditLimit
```

**JV Balance Validation**:
```
TotalDebitAmount = TotalCreditAmount
```

---

## Data Integrity Rules

### Referential Integrity

**Foreign Key Relationships**:
- All foreign keys must reference existing records
- Deletion restrictions:
  - Cannot delete vendor with outstanding invoices
  - Cannot delete customer with outstanding receivables
  - Cannot delete GL account with posted transactions
  - Cannot delete department with assigned users/transactions
  - Cannot delete period if transactions exist

### Unique Constraints

**Within Tenant Scope**:
- Vendor code
- Customer code
- Invoice number (per vendor for AP, globally for AR)
- Payment number
- JV number
- Asset code
- Account code

### Check Constraints

**Amount Constraints**:
```sql
Amount > 0
TaxAmount >= 0
WhtAmount >= 0
CreditLimit >= 0
OutstandingBalance >= 0
```

**Date Constraints**:
```sql
InvoiceDate <= GETDATE()
DueDate >= InvoiceDate
EndDate >= StartDate (for projects/contracts)
```

---

## Data Retention Policy

| Data Type | Retention Period | Archive Strategy |
|-----------|------------------|------------------|
| **Transactions** | 7 years | Archive to cold storage after 2 years |
| **Master Data** | Indefinite | Soft delete only |
| **Audit Logs** | 7 years | Archive to separate database |
| **Financial Reports** | 10 years | PDF archive |
| **User Activity** | 1 year | Rolling deletion |

---

## Appendix: SQL Data Types

| Carmen Type | SQL Server | MySQL | PostgreSQL | Max Length |
|-------------|-----------|-------|------------|------------|
| String (short) | NVARCHAR | VARCHAR | VARCHAR | 50 |
| String (medium) | NVARCHAR | VARCHAR | VARCHAR | 200 |
| String (long) | NVARCHAR | VARCHAR | VARCHAR | 500 |
| Integer | INT | INT | INTEGER | - |
| Decimal (amount) | DECIMAL(18,2) | DECIMAL(18,2) | NUMERIC(18,2) | - |
| Decimal (rate) | DECIMAL(18,6) | DECIMAL(18,6) | NUMERIC(18,6) | - |
| Date | DATE | DATE | DATE | - |
| DateTime | DATETIME | DATETIME | TIMESTAMP | - |
| Boolean | BIT | TINYINT(1) | BOOLEAN | - |

---

**Document Owner**: Business Analyst + Database Architect
**Review Cycle**: Quarterly
**Last Updated**: 2025-10-06
**Next Review**: 2026-01-06
**Related Documents**:
- Functional Requirements: `/docs/requirements/functional-requirements.md`
- Database Schema: `/docs/database/schema-documentation.md`
- API Reference: `/docs/api/api-reference.md`
