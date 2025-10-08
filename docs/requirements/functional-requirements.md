# Carmen.NET Functional Requirements

**Document Version**: 2.0 (Corrected)
**Last Updated**: 2025-10-06
**Status**: Phase 5 - Business Analyst Documentation (Verified Against Source Code)
**Target Audience**: Business Analysts, Product Owners, QA Team

> **IMPORTANT NOTICE**: This document has been corrected to reflect the actual implementation in the source code. The AP module does NOT implement Purchase Order Management, Goods Receiving, or Three-Way Matching functionality. These features were removed from this version to accurately represent the current system capabilities.

---

## Overview

This document defines the functional requirements for the Carmen.NET ERP system, organized by module. Each requirement includes user stories, acceptance criteria, business rules, and API endpoints.

**System Scope**: Multi-tenant financial ERP with 11 core modules serving small to medium businesses in Thailand.

## System Implementation Screenshots

### Licensed Modules
![GL Module](/screenshots/gl/01-gl-menu.png)
*General Ledger: JV, Chart of Accounts (1,030 accounts), Procedure, Reports (10 reports)*

![AR Module](/screenshots/ar/01-ar-menu.png)
*Accounts Receivable: Profile (186 customers), Invoice (51 invoices), Receipt (67 receipts), Reports (16 reports)*

![Asset Module](/screenshots/asset/01-asset-menu.png)
*Asset Management: Vendor (531 vendors), Asset Register (457 assets), Disposal (5 disposed), Reports (11 reports)*

---

## Table of Contents

1. [Accounts Payable (AP)](#accounts-payable-ap)
2. [Accounts Receivable (AR)](#accounts-receivable-ar)
3. [General Ledger (GL)](#general-ledger-gl)
4. [Asset Management](#asset-management)
5. [Tax Management](#tax-management)
6. [Bank Management](#bank-management)
7. [Master Data Management](#master-data-management)

---

## Accounts Payable (AP)

**Module Purpose**: Manage vendor relationships, expense invoices, and payments.

![AP Module Menu](/screenshots/ap/ap-01-ap-menu.png)
*AP module navigation menu with 5 submenu items: Vendor, Invoice, Payment, Procedure, and Report*

![AP Vendor List](/screenshots/ap/ap-02-vendor-list.png)
*AP Vendor master list showing 8 vendors with vendor codes, names (Thai/English), TAX IDs, contact names, categories, emails, and active status*

![AP Invoice List](/screenshots/ap/ap-03-invoice-list.png)
*AP Invoice list displaying 54 invoices (15 shown) with sequence numbers, input dates, vendors, invoice numbers and dates, descriptions (Thai/English), currencies (THB/USD), amounts, unpaid amounts, source, and workflow status*

![AP Payment List](/screenshots/ap/ap-04-payment-list.png)
*AP Payment list showing 26 payments (15 displayed) with sequence numbers, payment dates, vendors, payment types (CHQ, BBL), cheque numbers and dates, descriptions, currencies (THB/USD), exchange rates, totals, and effective status*

![AP Procedure Screen](/screenshots/ap/ap-05-procedure.png)
*AP Procedure screen with automated postings including Posting from Receiving, Cheque Reconciliation (default clearing date 08/10/2025), Input Tax Reconciliation, Withholding Tax Reconciliation, and Close Period (Last Closed: 31/03/2023, Current: 30/04/2023)*

![AP Reports List](/screenshots/ap/ap-06-reports-list.png)
*Complete AP Reports menu displaying all 18 report types including Aging Detail/Summary, Cheque Reconciliation, Invoice/Payment Checklists, Expense Analysis, Vendor reports, and Withholding Tax reports*

### FR-AP-001: Vendor Management

**User Story**: As an AP Clerk, I want to maintain vendor master data so that I can process invoices and payments.

**Functional Requirements**:

1. **Create Vendor** (FR-AP-001.1)
   - System shall allow creating new vendors with required fields
   - System shall auto-generate vendor code if not provided
   - System shall validate unique vendor code within tenant
   - System shall support multiple contact persons per vendor
   - System shall record vendor credit terms (NET 30, NET 60, etc.)

2. **Update Vendor** (FR-AP-001.2)
   - System shall allow updating vendor information
   - System shall validate vendor code uniqueness on update
   - System shall maintain audit history of all changes

3. **Vendor Status** (FR-AP-001.3)
   - System shall support vendor statuses: Active, Inactive, Blocked
   - System shall prevent transactions with Inactive/Blocked vendors
   - System shall require approval for vendor reactivation

**Acceptance Criteria**:
```gherkin
Given I am an AP Clerk with "AP.Vendor.Create" permission
When I submit a new vendor with all required fields
Then the vendor is created successfully
And the vendor code is auto-generated if not provided
And the vendor status is set to "Pending Approval"
```

**Business Rules**:
- BR-AP-001: Vendor code must be unique within tenant
- BR-AP-002: Vendor name is required (max 200 characters)
- BR-AP-003: Tax ID is required for Thai vendors
- BR-AP-004: Payment terms default to NET 30 if not specified
- BR-AP-005: Blocked vendors cannot have new transactions

**API Endpoints**:
```
POST   /api/ap/vendor/create
GET    /api/ap/vendor/list
GET    /api/ap/vendor/{id}
PUT    /api/ap/vendor/{id}/update
DELETE /api/ap/ap/vendor/{id}
POST   /api/ap/vendor/{id}/approve
POST   /api/ap/vendor/{id}/block
```

**Data Model**:
```typescript
interface Vendor {
  id: number;
  tenantCode: string;
  vendorCode: string;
  vendorName: string;
  taxId: string;
  address: string;
  contactPerson: string;
  phone: string;
  email: string;
  paymentTerms: string;  // NET15, NET30, NET60, NET90
  creditLimit: number;
  status: 'Active' | 'Inactive' | 'Blocked';
}
```

---

### FR-AP-004: Invoice Processing

**User Story**: As an AP Clerk, I want to process vendor expense invoices so that payments are accurate and authorized.

**Functional Requirements**:

1. **Invoice Entry** (FR-AP-004.1)
   - System shall allow manual invoice entry
   - System shall allow invoice import from Excel/CSV
   - System shall auto-generate invoice number if not provided
   - System shall calculate tax amounts (VAT, WHT) automatically
   - System shall support direct expense invoices (non-PO based)
   - System shall validate vendor is Active before allowing invoice creation

2. **Tax Calculations** (FR-AP-004.2)
   - System shall calculate VAT at 7% (Thailand standard rate)
   - System shall support withholding tax (WHT) calculation:
     - 3% for services
     - 5% for professional fees
     - 10% for dividends
     - 15% for interest
   - System shall calculate net amount: Invoice Amount + VAT - WHT
   - System shall validate tax calculations before saving

3. **Invoice Approval Workflow** (FR-AP-004.3)
   - System shall route invoice based on amount:
     - $0-$1,000: Optional approval
     - $1,001-$10,000: Supervisor approval
     - $10,001-$50,000: Manager approval
     - $50,001-$250,000: Controller approval
     - $250,001+: Finance Director + CEO approval
   - System shall enforce approval before posting
   - System shall allow rejection with comments
   - System shall notify approvers via email

4. **Invoice Status** (FR-AP-004.4)
   - System shall support statuses:
     - Draft: Initial entry
     - Pending Approval: Awaiting approval
     - Approved: Approved for payment
     - Rejected: Rejected with reason
     - Posted: Posted to GL
     - Partially Paid: Some payment made
     - Fully Paid: Completely paid
     - Cancelled: Cancelled invoice
   - System shall prevent status changes that violate workflow rules
   - System shall update status automatically when payments applied

**Acceptance Criteria**:
```gherkin
Given I am an AP Clerk with "AP.Invoice.Create" permission
When I create a direct expense invoice for $15,000 with 7% VAT and 3% WHT
Then the system calculates VAT = $1,050
And calculates WHT = $450
And calculates net amount = $15,600 ($15,000 + $1,050 - $450)
And the invoice is created with status "Draft"
When I submit for approval
Then the invoice routes to AP Manager (amount $10K-$50K)
And when AP Manager approves
Then the status changes to "Approved"
```

**Business Rules**:
- BR-AP-030: Invoice number must be unique per vendor within tenant
- BR-AP-031: Invoice date cannot be in the future
- BR-AP-032: Due date must be ≥ invoice date
- BR-AP-033: Invoice amount must equal sum of line amounts + tax - WHT
- BR-AP-034: VAT rate is 7% (Thailand standard)
- BR-AP-035: WHT rates: 3% (services), 5% (professional), 10% (dividends), 15% (interest)
- BR-AP-036: Posted invoices cannot be modified
- BR-AP-037: Only approved invoices can be posted to GL
- BR-AP-038: Vendor must be Active to create invoices

**API Endpoints**:
```
POST   /api/ap/invoice/create
POST   /api/ap/invoice/import
GET    /api/ap/invoice/list
GET    /api/ap/invoice/{id}
PUT    /api/ap/invoice/{id}/update
POST   /api/ap/invoice/{id}/submit
POST   /api/ap/invoice/{id}/approve
POST   /api/ap/invoice/{id}/reject
POST   /api/ap/invoice/{id}/post
POST   /api/ap/invoice/{id}/cancel
```

**Data Model**:
```typescript
interface APInvoice {
  id: number;
  tenantCode: string;
  invoiceNumber: string;
  invoiceDate: Date;
  dueDate: Date;
  vendorId: number;
  vendorCode: string;
  vendorName: string;
  description: string;
  subtotal: number;
  vatAmount: number;
  vatRate: number;  // Default: 7%
  whtAmount: number;
  whtRate: number;  // 3%, 5%, 10%, 15%
  totalAmount: number;
  status: 'Draft' | 'Pending Approval' | 'Approved' | 'Rejected' | 'Posted' | 'Partially Paid' | 'Fully Paid' | 'Cancelled';
  createdBy: string;
  approvedBy: string;
  approvedDate: Date;
}
```

---

### FR-AP-005: Payment Processing

**User Story**: As an AP Clerk, I want to process vendor payments so that invoices are paid on time and cash flow is managed.

**Functional Requirements**:

1. **Payment Creation** (FR-AP-005.1)
   - System shall allow selecting invoices for payment
   - System shall filter invoices by due date, vendor, amount
   - System shall calculate payment amount (invoice - WHT)
   - System shall support payment methods:
     - Check: Physical check
     - Wire: Bank wire transfer
     - ACH: Electronic transfer
   - System shall auto-generate payment number (PAY-YYYY-NNNN)

2. **Payment Approval** (FR-AP-005.2)
   - System shall route payment for approval based on amount:
     - $0-$5,000: Supervisor approval
     - $5,001-$25,000: Manager approval
     - $25,001-$100,000: Controller approval
     - $100,001+: Finance Director approval
   - System shall require dual approval for >$100K

3. **Payment Posting** (FR-AP-005.3)
   - System shall post payment to GL when approved:
     - DR: Accounts Payable
     - CR: Cash/Bank
   - System shall update invoice status to Partially/Fully Paid
   - System shall create WHT certificate if applicable

**Acceptance Criteria**:
```gherkin
Given I have approved invoices totaling $30,000
When I create a payment for these invoices
Then the payment is created with status "Draft"
And the payment amount is calculated as invoice amount - WHT
When I submit for approval
Then the payment routes to Controller (amount $25K-$100K)
```

**Business Rules**:
- BR-AP-040: Payment can only be made for Approved or Posted invoices
- BR-AP-041: Payment date must be ≥ invoice date
- BR-AP-042: Payment amount cannot exceed outstanding invoice amount
- BR-AP-043: WHT is deducted from payment amount
- BR-AP-044: Posted payments cannot be deleted (only reversed)

**API Endpoints**:
```
POST   /api/ap/payment/create
GET    /api/ap/payment/list
GET    /api/ap/payment/{id}
PUT    /api/ap/payment/{id}/update
POST   /api/ap/payment/{id}/submit
POST   /api/ap/payment/{id}/approve
POST   /api/ap/payment/{id}/post
POST   /api/ap/payment/{id}/void
GET    /api/ap/payment/due-invoices
```

---

## Accounts Receivable (AR)

**Module Purpose**: Manage customer relationships, contracts, invoicing, receipts, and credit control.

### FR-AR-001: Customer Management

**User Story**: As an AR Clerk, I want to maintain customer master data so that I can process sales and receipts.

**Functional Requirements**:

1. **Create Customer** (FR-AR-001.1)
   - System shall allow creating customers with required fields
   - System shall auto-generate customer code if not provided
   - System shall support multiple billing/shipping addresses
   - System shall set credit limit and payment terms
   - System shall require credit approval for new customers

2. **Credit Management** (FR-AR-001.2)
   - System shall track customer credit limit
   - System shall track outstanding receivables
   - System shall calculate available credit (limit - outstanding)
   - System shall block orders exceeding credit limit
   - System shall alert when credit utilization >80%

**Acceptance Criteria**:
```gherkin
Given I am an AR Clerk with "AR.Customer.Create" permission
When I create a customer with credit limit $50,000
Then the customer is created with status "Pending Approval"
And the available credit is $50,000
```

**Business Rules**:
- BR-AR-001: Customer code must be unique within tenant
- BR-AR-002: Credit limit must be approved by AR Manager
- BR-AR-003: New invoices blocked if customer exceeds credit limit
- BR-AR-004: Payment terms default to NET 30

---

### FR-AR-002: Contract Management

**User Story**: As an AR Clerk, I want to create recurring billing contracts so that customers are invoiced automatically.

**Functional Requirements**:

1. **Create Contract** (FR-AR-002.1)
   - System shall allow creating contracts with:
     - Contract number (auto-generated)
     - Customer
     - Start and end dates
     - Billing frequency (Monthly, Quarterly, Annually)
     - Amount per period
     - Auto-renewal option
   - System shall validate contract dates

2. **Contract Activation** (FR-AR-002.2)
   - System shall require approval before activation
   - System shall validate customer credit limit
   - System shall schedule invoice generation dates

3. **Auto-Invoice Generation** (FR-AR-002.3)
   - System shall generate invoices automatically per schedule
   - System shall create draft invoice 5 days before due date
   - System shall notify AR Clerk of generated invoices
   - System shall handle pro-rata calculations for partial periods

**Acceptance Criteria**:
```gherkin
Given I have an active monthly contract for $10,000
When the billing date arrives
Then the system auto-generates an invoice
And the invoice status is "Draft"
And AR Clerk is notified via email
```

**Business Rules**:
- BR-AR-010: Contract number must be unique within tenant
- BR-AR-011: End date must be > start date
- BR-AR-012: Contract cannot be activated if customer credit exceeded
- BR-AR-013: Auto-generated invoices inherit contract terms

---

### FR-AR-003: Invoice Generation

**User Story**: As an AR Clerk, I want to generate customer invoices so that revenue is recognized and customers are billed.

**Functional Requirements**:

1. **Invoice Creation** (FR-AR-003.1)
   - System shall allow creating invoices:
     - From contract (auto-generated)
     - From sales order
     - Manual entry
   - System shall auto-generate invoice number (AR-YYYY-NNNN)
   - System shall calculate VAT (7%) automatically
   - System shall validate customer credit limit before saving

2. **Invoice Approval** (FR-AR-003.2)
   - System shall route invoices for approval:
     - $0-$5,000: Optional approval
     - $5,001-$25,000: Supervisor approval
     - $25,001-$100,000: Manager approval
     - $100,001+: Controller approval

3. **Invoice Posting** (FR-AR-003.3)
   - System shall post invoice to GL when approved:
     - DR: Accounts Receivable
     - CR: Revenue
     - CR: VAT Payable (if applicable)
   - System shall update customer outstanding balance

**Acceptance Criteria**:
```gherkin
Given I am an AR Clerk with "AR.Invoice.Create" permission
When I create an invoice for $20,000
Then the invoice is created with 7% VAT = $1,400
And total invoice amount is $21,400
And the invoice status is "Draft"
```

**Business Rules**:
- BR-AR-020: Invoice number must be unique within tenant
- BR-AR-021: Invoice date cannot be in the future
- BR-AR-022: Due date = invoice date + payment terms
- BR-AR-023: VAT rate is 7% (Thailand standard)
- BR-AR-024: Posted invoices cannot be modified
- BR-AR-025: Credit check performed before posting

---

### FR-AR-004: Receipt Processing

**User Story**: As an AR Clerk, I want to record customer payments so that outstanding receivables are updated and cash is tracked.

**Functional Requirements**:

1. **Receipt Entry** (FR-AR-004.1)
   - System shall allow recording receipts
   - System shall auto-generate receipt number (REC-YYYY-NNNN)
   - System shall support payment methods:
     - Cash
     - Check
     - Bank Transfer
     - Credit Card
   - System shall allow bank deposit recording

2. **Invoice Application** (FR-AR-004.2)
   - System shall apply receipts to outstanding invoices
   - System shall support:
     - Full payment: Entire invoice paid
     - Partial payment: Partial invoice paid
     - Overpayment: Payment > invoice (creates credit balance)
   - System shall apply FIFO (oldest invoice first) by default
   - System shall allow manual invoice selection

3. **Receipt Posting** (FR-AR-004.3)
   - System shall post receipt to GL:
     - DR: Cash/Bank
     - CR: Accounts Receivable
   - System shall update invoice status to Partially/Fully Paid
   - System shall update customer outstanding balance

**Acceptance Criteria**:
```gherkin
Given I have outstanding invoices: $10,000 (INV-001) and $5,000 (INV-002)
When I record a receipt for $12,000
Then the system applies $10,000 to INV-001 (fully paid)
And applies $2,000 to INV-002 (partially paid)
And INV-002 outstanding balance is $3,000
```

**Business Rules**:
- BR-AR-030: Receipt date must be ≥ invoice date
- BR-AR-031: Receipt amount must be > 0
- BR-AR-032: Default application is FIFO (oldest first)
- BR-AR-033: Overpayment creates customer credit balance
- BR-AR-034: Check bounce reverses receipt and invoice payment
- BR-AR-035: Posted receipts cannot be deleted (only reversed)

---

## General Ledger (GL)

**Module Purpose**: Central financial hub for all accounting transactions, chart of accounts, period management, and financial reporting.

### FR-GL-001: Chart of Accounts

**User Story**: As a GL Manager, I want to maintain the chart of accounts so that all financial transactions are properly classified.

**Functional Requirements**:

1. **Account Structure** (FR-GL-001.1)
   - System shall use 10-digit account code: AAAA-BB-CC-DD
     - AAAA: Main account (4 digits)
     - BB: Sub-account (2 digits)
     - CC: Department (2 digits)
     - DD: Project (2 digits)
   - System shall support account hierarchy:
     - Level 1: Account Type (Asset, Liability, Equity, Revenue, Expense)
     - Level 2: Main Account (1000-9999)
     - Level 3: Sub-account (01-99)
     - Level 4: Dimensions (Dept, Project)

2. **Account Properties** (FR-GL-001.2)
   - System shall define account properties:
     - Account code (unique identifier)
     - Account name
     - Account type (Asset, Liability, Equity, Revenue, Expense)
     - Normal balance (Debit or Credit)
     - Allow posting (Yes/No)
     - Active status (Active/Inactive)
   - System shall prevent posting to inactive accounts
   - System shall prevent posting to summary accounts

**Business Rules**:
- BR-GL-001: Account code must be unique within tenant
- BR-GL-002: Account type determines normal balance (Asset/Expense=DR, Liability/Equity/Revenue=CR)
- BR-GL-003: Summary accounts (parent) cannot accept postings
- BR-GL-004: Inactive accounts cannot accept new transactions

---

### FR-GL-002: Journal Voucher (JV)

**User Story**: As a GL Accountant, I want to create journal entries so that financial transactions are recorded in the general ledger.

**Functional Requirements**:

1. **JV Entry** (FR-GL-002.1)
   - System shall allow creating journal vouchers
   - System shall auto-generate JV number (JV-YYYY-NNNN)
   - System shall require:
     - JV date
     - Description
     - At least 2 lines (debit and credit)
   - System shall validate:
     - Total debits = total credits (balanced entry)
     - All accounts allow posting
     - Period is open

2. **JV Approval** (FR-GL-002.2)
   - System shall route JV for approval based on amount:
     - $0-$10,000: Supervisor approval
     - $10,001-$50,000: Manager approval
     - $50,001+: Controller approval
   - System shall allow rejection with comments

3. **JV Posting** (FR-GL-002.3)
   - System shall post approved JV to GL accounts
   - System shall update account balances
   - System shall prevent posting to closed periods
   - System shall create audit trail

**Acceptance Criteria**:
```gherkin
Given I am a GL Accountant with "GL.JV.Create" permission
When I create a JV with DR: 5100 $1,000 and CR: 1100 $1,000
Then the JV is balanced
And the status is "Draft"
When I submit for approval
Then the status changes to "Pending Approval"
```

**Business Rules**:
- BR-GL-010: JV must be balanced (total DR = total CR)
- BR-GL-011: JV date must be within open period
- BR-GL-012: Posted JVs cannot be modified (only reversed)
- BR-GL-013: Reversal JV must reference original JV

---

### FR-GL-003: Period Management

**User Story**: As a Controller, I want to manage accounting periods so that month-end close is controlled and financial reporting is accurate.

**Functional Requirements**:

1. **Period Definition** (FR-GL-003.1)
   - System shall define fiscal periods:
     - Fiscal year (e.g., 2025)
     - Period number (1-12 for monthly)
     - Period name (e.g., "January 2025")
     - Start and end dates
   - System shall support monthly and quarterly periods

2. **Period Status** (FR-GL-003.2)
   - System shall support period statuses:
     - Open: Transactions allowed
     - Closing: Month-end close in progress
     - Closed: No new transactions allowed
     - Reopened: Temporarily reopened for adjustments
   - System shall prevent posting to Closed periods (except with override)

3. **Period Close Process** (FR-GL-003.3)
   - System shall execute period close workflow:
     1. Validate all modules ready (AP, AR posted)
     2. Run depreciation (Asset module)
     3. Post allocation JVs
     4. Generate financial statements
     5. Close period
   - System shall create audit report of period close
   - System shall allow reopen with approval

**Acceptance Criteria**:
```gherkin
Given the current period is January 2025 (status: Open)
When I initiate period close
Then the system validates all transactions posted
And runs month-end processing
And changes period status to "Closed"
And February 2025 period opens automatically
```

**Business Rules**:
- BR-GL-020: Periods must be closed in sequential order
- BR-GL-021: Cannot close current period if prior period is open
- BR-GL-022: Period close requires Controller approval
- BR-GL-023: Reopen requires Finance Director approval
- BR-GL-024: Maximum 1 prior period can be reopened at a time

**API Endpoints**:
```
GET    /api/gl/period/list
GET    /api/gl/period/current
POST   /api/gl/period/{id}/close
POST   /api/gl/period/{id}/reopen
GET    /api/gl/period/{id}/close-status
```

---

## Asset Management

**Module Purpose**: Track fixed assets, depreciation, location changes, and disposal processes.

**Full Documentation**: See [Asset Management Functional Requirements](asset-income-requirements.md) for complete details.

### Overview

The Asset Management module provides comprehensive fixed asset tracking including:
- Asset registration and lifecycle management
- Automatic depreciation calculations (Straight-Line and Declining Balance methods)
- Asset disposal tracking with gain/loss calculations
- Location and department tracking
- Master data management (categories, departments, locations)

### Key Features (Summary)

**FR-ASSET-001: Asset Registration**
- Create, update, and track fixed assets
- Support for asset categories, departments, and locations
- Automatic asset code generation
- Copy existing assets
- Change asset locations

**FR-ASSET-002: Asset Depreciation**
- Monthly depreciation calculations
- Support for multiple depreciation methods
- Depreciation history tracking
- Period close procedures
- Automatic GL posting

**FR-ASSET-003: Asset Disposal**
- Record asset disposals (sale, scrap, trade-in, donation, lost)
- Calculate gain/loss on disposal
- Generate disposal journals
- Approval workflows for high-value disposals

**FR-ASSET-004: Asset Master Data**
- Manage asset categories with GL account mapping
- Manage departments with cost center assignment
- Manage physical locations
- Track location history

**Total API Endpoints**: 41
**Status**: ✅ 100% Implemented and Validated

---

## System-Wide Requirements

### FR-SYS-001: Multi-Tenant Support

**Functional Requirements**:

1. **Tenant Isolation** (FR-SYS-001.1)
   - System shall isolate data by tenant using TenantCode
   - System shall apply tenant filter to all queries automatically
   - System shall prevent cross-tenant data access
   - System shall include TenantCode in all database records

2. **Tenant Configuration** (FR-SYS-001.2)
   - System shall support tenant-specific configuration:
     - Company name and logo
     - Fiscal year settings
     - Tax rates (VAT, WHT)
     - Approval workflows
     - Number formats (invoice, PO, etc.)

**Business Rules**:
- BR-SYS-001: All transactions must have TenantCode
- BR-SYS-002: Users can only access their tenant's data
- BR-SYS-003: System admin can manage multiple tenants

---

### FR-SYS-002: Authentication & Authorization

**Functional Requirements**:

1. **User Authentication** (FR-SYS-002.1)
   - System shall authenticate users with email + password + tenant code
   - System shall issue JWT token with 15-minute expiration
   - System shall support token refresh (7-day refresh token)
   - System shall enforce password complexity:
     - Minimum 8 characters
     - At least 1 uppercase, 1 lowercase, 1 digit
     - At least 1 special character

2. **Authorization** (FR-SYS-002.2)
   - System shall check permissions before every operation
   - System shall use format: Module.Entity.Action (e.g., AP.Invoice.Approve)
   - System shall return 401 Unauthorized if token missing/invalid
   - System shall return 403 Forbidden if permission denied

**Business Rules**:
- BR-SYS-010: Failed login attempts > 5 = account lockout (30 min)
- BR-SYS-011: Password must be changed every 90 days
- BR-SYS-012: Cannot reuse last 5 passwords

---

### FR-SYS-003: Audit Trail

**Functional Requirements**:

1. **Transaction Audit** (FR-SYS-003.1)
   - System shall log all create/update/delete operations
   - System shall record:
     - User ID
     - Timestamp
     - Action (Create/Update/Delete)
     - Before/After values (for updates)
     - IP address
   - System shall store audit logs for 7 years

2. **Financial Transaction Audit** (FR-SYS-003.2)
   - System shall maintain complete audit trail for:
     - All GL postings
     - Invoice approvals
     - Payment approvals
     - Period close
   - System shall prevent audit log modification/deletion

**Business Rules**:
- BR-SYS-020: All financial transactions require audit trail
- BR-SYS-021: Audit logs cannot be deleted (retention: 7 years)
- BR-SYS-022: Audit reports available to auditors (read-only)

---

## Non-Functional Requirements

### NFR-001: Performance

1. API response time: P95 < 500ms for all endpoints
2. Page load time: < 2 seconds for list views
3. Report generation: < 5 seconds for standard reports
4. Concurrent users: Support 100 concurrent users per tenant

### NFR-002: Scalability

1. Horizontal scaling: Support 100+ tenants on single instance
2. Database: Handle 10M+ transactions per tenant
3. File import: Support files up to 100MB, 100K rows

### NFR-003: Reliability

1. Uptime: 99.9% availability (8.7 hours downtime/year)
2. Error rate: < 0.1% for all transactions
3. Data backup: Daily automated backups with 30-day retention
4. Disaster recovery: RTO < 4 hours, RPO < 15 minutes

### NFR-004: Security

1. Encryption: TLS 1.2+ for all API traffic
2. Authentication: JWT with 15-minute token expiration
3. Password: Bcrypt hashing with 12 rounds
4. SQL Injection: Parameterized queries only (no dynamic SQL)

### NFR-005: Usability

1. Mobile-responsive: Support mobile browsers
2. Browser support: Chrome, Firefox, Safari, Edge (latest 2 versions)
3. Language: English primary, Thai secondary
4. Accessibility: WCAG 2.1 AA compliance

---

## Traceability Matrix

| Requirement ID | Module | Priority | API Endpoints | Test Cases |
|----------------|--------|----------|---------------|------------|
| FR-AP-001 | AP | Critical | /api/ap/vendor/* | TC-AP-001 to TC-AP-005 |
| FR-AP-004 | AP | Critical | /api/ap/invoice/* | TC-AP-020 to TC-AP-030 |
| FR-AP-005 | AP | Critical | /api/ap/payment/* | TC-AP-040 to TC-AP-045 |
| FR-AR-001 | AR | Critical | /api/ar/customer/* | TC-AR-001 to TC-AR-005 |
| FR-AR-003 | AR | Critical | /api/ar/invoice/* | TC-AR-020 to TC-AR-030 |
| FR-AR-004 | AR | Critical | /api/ar/receipt/* | TC-AR-040 to TC-AR-045 |
| FR-GL-001 | GL | Critical | /api/gl/account/* | TC-GL-001 to TC-GL-005 |
| FR-GL-002 | GL | Critical | /api/gl/jv/* | TC-GL-010 to TC-GL-020 |
| FR-GL-003 | GL | Critical | /api/gl/period/* | TC-GL-030 to TC-GL-040 |
| FR-ASSET-001 | Asset | High | /api/assetRegister/* | TC-ASSET-001 to TC-ASSET-010 |
| FR-ASSET-002 | Asset | High | /api/assetProcedure/*, /api/assetHistory/* | TC-ASSET-020 to TC-ASSET-030 |
| FR-ASSET-003 | Asset | High | /api/assetDisposal/* | TC-ASSET-040 to TC-ASSET-050 |
| FR-ASSET-004 | Asset | Medium | /api/assetCategory/*, /api/assetDepartment/*, /api/assetLocation/* | TC-ASSET-060 to TC-ASSET-070 |
| FR-INCOME-001 | Income | High | /api/incomeInvoice/* | TC-INCOME-001 to TC-INCOME-010 |
| FR-INCOME-002 | Income | High | /api/incomeRevenue/* | TC-INCOME-020 to TC-INCOME-030 |
| FR-INCOME-003 | Income | Medium | /api/incomeCategory/*, /api/incomeSource/*, /api/incomePayCode/*, /api/incomePayType/*, /api/incomeProduct/* | TC-INCOME-040 to TC-INCOME-050 |
| FR-INCOME-004 | Income | High | /api/incomeProcedure/* | TC-INCOME-060 to TC-INCOME-070 |

---

## Glossary

**AP**: Accounts Payable
**AR**: Accounts Receivable
**GL**: General Ledger
**JV**: Journal Voucher
**WHT**: Withholding Tax
**VAT**: Value Added Tax
**O2C**: Order-to-Cash
**R2R**: Record-to-Report
**FIFO**: First In, First Out
**DR**: Debit
**CR**: Credit
**NBV**: Net Book Value
**HMS**: Hotel Management System
**PMS**: Property Management System

---

**Document Owner**: Business Analyst Team
**Review Cycle**: Quarterly
**Last Updated**: 2025-10-06
**Next Review**: 2026-01-06
**Related Documents**:
- API Reference: `/docs/api/api-reference.md`
- Permission Matrix: `/docs/requirements/permission-matrix.md`
- Data Dictionary: `/docs/requirements/data-dictionary.md`
