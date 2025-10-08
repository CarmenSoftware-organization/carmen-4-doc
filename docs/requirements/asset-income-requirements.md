# Asset Management and Income Module Functional Requirements

**Document Version**: 1.0
**Last Updated**: 2025-10-07
**Status**: Verified Against Source Code
**Target Audience**: Business Analysts, Product Owners, QA Team

---

## Asset Management

**Module Purpose**: Track fixed assets, depreciation, location changes, and disposal processes.

### FR-ASSET-001: Asset Registration

**User Story**: As an Asset Manager, I want to register fixed assets so that I can track asset value and depreciation.

**Functional Requirements**:

1. **Create Asset** (FR-ASSET-001.1)
   - System shall allow creating new asset records with required fields
   - System shall auto-generate asset code if not provided
   - System shall validate unique asset code within tenant
   - System shall support asset categories, departments, and locations
   - System shall record acquisition date, cost, and depreciation method

2. **Update Asset** (FR-ASSET-001.2)
   - System shall allow updating asset information
   - System shall maintain audit history of all changes
   - System shall recalculate depreciation upon asset value changes

3. **Asset Status** (FR-ASSET-001.3)
   - System shall support asset statuses: Active, In Use, Under Maintenance, Disposed
   - System shall prevent disposal of assets not marked for disposal
   - System shall track asset location changes

4. **Copy Asset** (FR-ASSET-001.4)
   - System shall allow copying existing asset records
   - System shall auto-generate new asset code for copied asset
   - System shall preserve asset category, department, and depreciation settings

**Acceptance Criteria**:
```gherkin
Given I am an Asset Manager with "Ast.Register" permission
When I submit a new asset with all required fields
Then the asset is created successfully
And the asset code is auto-generated if not provided
And depreciation history is initialized
```

**Business Rules**:
- BR-ASSET-001: Asset code must be unique within tenant
- BR-ASSET-002: Asset name is required (max 200 characters)
- BR-ASSET-003: Acquisition cost must be greater than 0
- BR-ASSET-004: Depreciation method: Straight-Line, Declining Balance, or None
- BR-ASSET-005: Asset category and department are required

**API Endpoints**:
```
POST   /api/assetRegister/search
GET    /api/assetRegister
GET    /api/assetRegister/{id}
GET    /api/assetRegister/remain/{id}/{date}
GET    /api/assetRegister/isDisposal/{id}
GET    /api/assetRegister/endDate/{id}/{no}
POST   /api/assetRegister
POST   /api/assetRegister/copy
PUT    /api/assetRegister/{id}
PUT    /api/assetRegister/changeLocation
DELETE /api/assetRegister/{id}
```

**Data Model**:
```typescript
interface AssetRegister {
  id: number;
  tenantCode: string;
  assetCode: string;
  assetName: string;
  categoryId: number;
  categoryCode: string;
  departmentId: number;
  locationId: number;
  acquisitionDate: Date;
  acquisitionCost: number;
  salvageValue: number;
  usefulLife: number;  // months
  depreciationMethod: 'SL' | 'DB' | 'NONE';  // Straight-Line, Declining Balance
  accumulatedDepreciation: number;
  netBookValue: number;
  status: 'Active' | 'InUse' | 'Maintenance' | 'Disposed';
  createdBy: string;
  createdDate: Date;
  modifiedBy: string;
  modifiedDate: Date;
}
```

---

### FR-ASSET-002: Asset Depreciation

**User Story**: As an Accountant, I want to calculate and post asset depreciation so that financial statements reflect accurate asset values.

**Functional Requirements**:

1. **Calculate Depreciation** (FR-ASSET-002.1)
   - System shall calculate monthly depreciation based on method
   - System shall support Straight-Line depreciation: (Cost - Salvage) / Life
   - System shall support Declining Balance depreciation
   - System shall not depreciate below salvage value

2. **Depreciation History** (FR-ASSET-002.2)
   - System shall maintain complete depreciation history
   - System shall track depreciation per period
   - System shall calculate accumulated depreciation
   - System shall calculate net book value (NBV)

3. **Period Close** (FR-ASSET-002.3)
   - System shall process depreciation for all active assets
   - System shall post depreciation journals to GL
   - System shall prevent duplicate depreciation for same period
   - System shall allow period close only once per period

**Acceptance Criteria**:
```gherkin
Given there are active assets with depreciation enabled
When the month-end close procedure runs
Then depreciation is calculated for all assets
And depreciation journals are posted to GL
And asset history is updated with current period depreciation
```

**Business Rules**:
- BR-ASSET-006: Depreciation starts in month following acquisition
- BR-ASSET-007: Depreciation continues until NBV = Salvage Value
- BR-ASSET-008: Disposed assets do not depreciate
- BR-ASSET-009: Depreciation expense posts to category-specific GL account
- BR-ASSET-010: Period close requires "Ast.Procedure" permission

**API Endpoints**:
```
POST   /api/assetProcedure/closePeriod
POST   /api/assetProcedure/postAp
GET    /api/assetHistory/
GET    /api/assetHistory/LocLog/
```

---

### FR-ASSET-003: Asset Disposal

**User Story**: As an Asset Manager, I want to record asset disposal so that disposed assets are removed from active tracking.

**Functional Requirements**:

1. **Create Disposal** (FR-ASSET-003.1)
   - System shall allow creating disposal records for registered assets
   - System shall validate asset exists and is not already disposed
   - System shall record disposal date, method, and proceeds
   - System shall calculate gain/loss on disposal

2. **Disposal Methods** (FR-ASSET-003.2)
   - System shall support disposal methods: Sale, Scrap, Trade-In, Donation, Lost
   - System shall require approval for disposals above threshold
   - System shall generate GL journals for disposal transactions

3. **Disposal Query** (FR-ASSET-003.3)
   - System shall provide disposal information lookup by asset
   - System shall calculate accumulated depreciation at disposal date
   - System shall show NBV at disposal date

**Acceptance Criteria**:
```gherkin
Given I have an active asset
When I create a disposal record with valid data
Then the disposal is recorded successfully
And the asset status changes to "Disposed"
And gain/loss on disposal is calculated
And GL journals are generated for disposal
```

**Business Rules**:
- BR-ASSET-011: Disposal date must be >= acquisition date
- BR-ASSET-012: Gain/Loss = Proceeds - (Cost - Accumulated Depreciation)
- BR-ASSET-013: Disposed assets cannot be updated or reactivated
- BR-ASSET-014: Disposal requires "Ast.Disposal" permission
- BR-ASSET-015: Disposal above 50,000 THB requires approval

**API Endpoints**:
```
POST   /api/assetDisposal/search
GET    /api/assetDisposal
GET    /api/assetDisposal/{id}
POST   /api/assetDisposalQuery
POST   /api/assetDisposalAccuDepre
POST   /api/assetDisposal
PUT    /api/assetDisposal/{id}
DELETE /api/assetDisposal/{id}
```

**Data Model**:
```typescript
interface AssetDisposal {
  id: number;
  tenantCode: string;
  assetRegisterId: number;
  disposalDate: Date;
  disposalMethod: 'Sale' | 'Scrap' | 'TradeIn' | 'Donation' | 'Lost';
  proceeds: number;
  originalCost: number;
  accumulatedDepreciation: number;
  netBookValue: number;
  gainLoss: number;  // Proceeds - NBV
  reason: string;
  approvedBy: string;
  approvedDate: Date;
  glJournalId: number;
  createdBy: string;
  createdDate: Date;
}
```

---

### FR-ASSET-004: Asset Master Data

**User Story**: As a System Administrator, I want to maintain asset master data so that assets can be properly categorized and tracked.

**Functional Requirements**:

1. **Asset Categories** (FR-ASSET-004.1)
   - System shall allow managing asset categories
   - System shall assign GL accounts per category
   - System shall support hierarchical category structure
   - System shall validate unique category codes

2. **Asset Departments** (FR-ASSET-004.2)
   - System shall allow managing departments
   - System shall assign cost centers per department
   - System shall validate unique department codes

3. **Asset Locations** (FR-ASSET-004.3)
   - System shall allow managing physical locations
   - System shall track asset location history
   - System shall support location transfers
   - System shall validate unique location codes

**API Endpoints**:
```
# Categories
POST   /api/assetCategory/search
GET    /api/assetCategory
GET    /api/assetCategory/{id}
POST   /api/assetCategory
PUT    /api/assetCategory/{id}
DELETE /api/assetCategory/{id}

# Departments
POST   /api/assetDepartment/search
GET    /api/assetDepartment
GET    /api/assetDepartment/{id}
POST   /api/assetDepartment
PUT    /api/assetDepartment/{id}
DELETE /api/assetDepartment/{id}

# Locations
POST   /api/assetLocation/search
GET    /api/assetLocation
GET    /api/assetLocation/{id}
POST   /api/assetLocation
PUT    /api/assetLocation/{id}
DELETE /api/assetLocation/{id}
```

---

## Income Module

**Module Purpose**: Manage income recognition, revenue codes, and hotel/hospitality-specific income tracking (PMS integration).

### FR-INCOME-001: Income Invoice Management

**User Story**: As a Revenue Clerk, I want to create income invoices so that revenue is properly recorded and tracked.

**Functional Requirements**:

1. **Create Income Invoice** (FR-INCOME-001.1)
   - System shall allow creating income invoices with line items
   - System shall auto-generate invoice numbers
   - System shall validate unique invoice numbers within tenant
   - System shall support multiple revenue codes per invoice
   - System shall calculate totals, taxes, and discounts

2. **Update Income Invoice** (FR-INCOME-001.2)
   - System shall allow updating invoice information
   - System shall maintain audit history of all changes
   - System shall prevent changes to posted invoices

3. **Invoice Status** (FR-INCOME-001.3)
   - System shall support invoice statuses: Draft, Posted, Void
   - System shall prevent deletion of posted invoices
   - System shall allow voiding posted invoices with reason

**Acceptance Criteria**:
```gherkin
Given I am a Revenue Clerk with "Inc.Invoice" permission
When I submit a new income invoice with all required fields
Then the invoice is created successfully
And the invoice number is auto-generated
And invoice status is set to "Draft"
```

**Business Rules**:
- BR-INCOME-001: Invoice number must be unique within tenant
- BR-INCOME-002: Invoice date is required and must be within open period
- BR-INCOME-003: At least one line item is required
- BR-INCOME-004: Total amount must equal sum of line items
- BR-INCOME-005: Posted invoices cannot be edited, only voided

**API Endpoints**:
```
POST   /api/incomeInvoice/search
GET    /api/incomeInvoice
GET    /api/incomeInvoice/{id}
POST   /api/incomeInvoice
PUT    /api/incomeInvoice/{id}
DELETE /api/incomeInvoice/{id}
```

**Data Model**:
```typescript
interface IncomeInvoice {
  id: number;
  tenantCode: string;
  invoiceNo: string;
  invoiceDate: Date;
  customerId: number;
  customerName: string;
  sourceId: number;  // Income source (HMS, PMS, Manual)
  categoryId: number;
  subtotal: number;
  vatAmount: number;
  totalAmount: number;
  status: 'Draft' | 'Posted' | 'Void';
  postedBy: string;
  postedDate: Date;
  voidReason: string;
  glJournalId: number;
  lineItems: IncomeInvoiceLine[];
  createdBy: string;
  createdDate: Date;
  modifiedBy: string;
  modifiedDate: Date;
}

interface IncomeInvoiceLine {
  id: number;
  incomeInvoiceId: number;
  lineNo: number;
  revenueCodeId: number;
  productId: number;
  description: string;
  quantity: number;
  unitPrice: number;
  amount: number;
  vatRate: number;
  vatAmount: number;
}
```

---

### FR-INCOME-002: Revenue Code Management

**User Story**: As a Finance Manager, I want to maintain revenue codes so that income is classified correctly for reporting.

**Functional Requirements**:

1. **Create Revenue Code** (FR-INCOME-002.1)
   - System shall allow creating revenue codes
   - System shall assign GL accounts per revenue code
   - System shall validate unique revenue codes
   - System shall support active/inactive status

2. **Revenue Code Mapping** (FR-INCOME-002.2)
   - System shall map revenue codes to GL accounts
   - System shall support department-specific revenue codes
   - System shall validate GL account exists before mapping

**API Endpoints**:
```
POST   /api/incomeRevenue/search
GET    /api/incomeRevenue
GET    /api/incomeRevenue/{id}
POST   /api/incomeRevenue
PUT    /api/incomeRevenue/{id}
DELETE /api/incomeRevenue/{id}
```

---

### FR-INCOME-003: Income Master Data

**User Story**: As a System Administrator, I want to maintain income master data so that income transactions can be properly categorized.

**Functional Requirements**:

1. **Income Categories** (FR-INCOME-003.1)
   - System shall allow managing income categories
   - System shall validate unique category codes
   - System shall support hierarchical category structure

2. **Income Sources** (FR-INCOME-003.2)
   - System shall allow managing income sources (HMS, PMS, Manual, API)
   - System shall track income by source for reconciliation
   - System shall validate unique source codes

3. **Payment Codes** (FR-INCOME-003.3)
   - System shall allow managing payment codes
   - System shall map payment codes to bank accounts
   - System shall validate unique payment codes

4. **Payment Types** (FR-INCOME-003.4)
   - System shall allow managing payment types (Cash, Card, Transfer, Check)
   - System shall validate unique payment type codes

5. **Income Products** (FR-INCOME-003.5)
   - System shall allow managing income products/services
   - System shall assign default revenue codes per product
   - System shall support product pricing

**API Endpoints**:
```
# Categories
POST   /api/incomeCategory/search
GET    /api/incomeCategory
GET    /api/incomeCategory/{id}
POST   /api/incomeCategory
PUT    /api/incomeCategory/{id}
DELETE /api/incomeCategory/{id}

# Sources
POST   /api/incomeSource/search
GET    /api/incomeSource
GET    /api/incomeSource/{id}
POST   /api/incomeSource
PUT    /api/incomeSource/{id}
DELETE /api/incomeSource/{id}

# Payment Codes
POST   /api/incomePayCode/search
GET    /api/incomePayCode
GET    /api/incomePayCode/{id}
POST   /api/incomePayCode
PUT    /api/incomePayCode/{id}
DELETE /api/incomePayCode/{id}

# Payment Types
POST   /api/incomePayType/search
GET    /api/incomePayType
GET    /api/incomePayType/{id}
POST   /api/incomePayType
PUT    /api/incomePayType/{id}
DELETE /api/incomePayType/{id}

# Products
POST   /api/incomeProduct/search
GET    /api/incomeProduct
GET    /api/incomeProduct/{id}
POST   /api/incomeProduct
PUT    /api/incomeProduct/{id}
DELETE /api/incomeProduct/{id}
```

---

### FR-INCOME-004: Income Period Close

**User Story**: As an Accountant, I want to close income periods so that revenue is properly posted to the general ledger.

**Functional Requirements**:

1. **Period Close** (FR-INCOME-004.1)
   - System shall process all posted income invoices for the period
   - System shall generate GL journals for revenue recognition
   - System shall post revenue to appropriate GL accounts
   - System shall prevent duplicate posting for same period

2. **HMS/PMS Integration** (FR-INCOME-004.2)
   - System shall integrate with Hotel Management System (HMS)
   - System shall post HMS revenue to income module
   - System shall reconcile HMS transactions with income records

**Acceptance Criteria**:
```gherkin
Given there are posted income invoices for the period
When the period close procedure runs
Then all income is posted to GL
And revenue is recognized per revenue code
And period status changes to "Closed"
```

**Business Rules**:
- BR-INCOME-006: Period close requires "Inc.Procedure" permission
- BR-INCOME-007: All invoices must be in "Posted" status before close
- BR-INCOME-008: Closed periods cannot be reopened without approval
- BR-INCOME-009: HMS revenue posts daily, manual invoices post at period close

**API Endpoints**:
```
POST   /api/incomeProcedure/closePeriod
POST   /api/incomeProcedure/postHmsRevenue
```

---

## Validation Summary

### Asset Management Module

| Feature | Status | API Endpoints | Evidence |
|---------|--------|---------------|----------|
| Asset Registration | ✅ Implemented | 11 endpoints | AssetRegisterController.cs |
| Asset Depreciation | ✅ Implemented | 4 endpoints | AssetProcedureController.cs, AssetHistoryController.cs |
| Asset Disposal | ✅ Implemented | 8 endpoints | AssetDisposalController.cs |
| Master Data | ✅ Implemented | 18 endpoints | Category, Department, Location Controllers |

**Total API Endpoints**: 41
**Overall Status**: ✅ 100% Implemented

### Income Module

| Feature | Status | API Endpoints | Evidence |
|---------|--------|---------------|----------|
| Income Invoices | ✅ Implemented | 6 endpoints | IncomeInvoiceController.cs |
| Revenue Codes | ✅ Implemented | 6 endpoints | IncomeRevenueController.cs |
| Master Data | ✅ Implemented | 30 endpoints | Category, Source, PayCode, PayType, Product Controllers |
| Period Close | ✅ Implemented | 2 endpoints | IncomeProcedureController.cs |

**Total API Endpoints**: 44
**Overall Status**: ✅ 100% Implemented

---

**Document Owner**: Business Analyst Team
**Review Cycle**: Quarterly
**Last Updated**: 2025-10-07
**Next Review**: 2026-01-07
**Related Documents**:
- Main Functional Requirements: `/docs/requirements/functional-requirements.md`
- API Reference: `/docs/api/api-reference.md`
- Permission Matrix: `/docs/requirements/permission-matrix.md`
- Data Dictionary: `/docs/requirements/data-dictionary.md`
