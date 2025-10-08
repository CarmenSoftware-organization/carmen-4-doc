# Carmen.NET Module & Sub-Module Structure

## Summary Statistics

- **Total Controllers**: 101
- **Total Model Files**: 600+
- **View Models**: 120
- **Parameter Models**: 104
- **Interface Definitions**: 325
- **Enumerations**: 49
- **Major Modules**: 11
- **Sub-Modules**: 78+

---

## Module Hierarchy

### 1. **ACCOUNTS PAYABLE (AP) MODULE**
**Controller Order Range**: 200-209
**Total Sub-Modules**: 8

#### Core Sub-Modules:

**1.1 AP Invoice Management** (Order: 201)
- Controller: `ApInvoiceController`
- Models: `ApInvoice`, `ApInvoiceD`, `ApInvWht`, `ApInvWhtItem`
- Views: `ViewApInvoice`, `ViewApBank`
- Enums: `EnumApInvoiceStatus`, `EnumApTaxStatus`
- Features:
  - Invoice creation and management
  - Invoice detail line items
  - Multi-currency support
  - Tax handling integration

**1.2 AP Payment Processing** (Order: 202)
- Controller: `ApPaymentController`
- Models: `ApPaymentD`, `ApPayWht`, `ApPayWhtItem`
- Enums: `EnumApPaymentStatus`, `EnumApPaymentPostingBy`
- Features:
  - Payment voucher creation
  - Withholding tax on payments
  - Payment detail tracking
  - Multiple payment methods

**1.3 AP Payment Type** (Order: 203)
- Controller: `ApPaymentTypeController`
- Features:
  - Payment method configuration
  - Payment type categorization

**1.4 AP Withholding Tax (WHT)** (Order: 202)
- Controller: `ApWhtController`
- Models: `ApInvWht`, `ApInvWhtItem`, `ApPayWht`, `ApPayWhtItem`
- Enums: `EnumWhtSource`, `EnumShowWithholdingTaxAt`
- Features:
  - WHT calculation
  - Tax certificate generation
  - Tax credit tracking

**1.5 AP WHT Conditions** (Order: 106)
- Controller: `ApWhtConditionController`
- Views: `ViewApWhtCondition`
- Features:
  - Tax condition rules
  - Automated tax rate determination

**1.6 AP WHT Types** (Order: 202)
- Controller: `ApWhtTypeController`
- Features:
  - WHT type configuration
  - Tax type categorization

**1.7 AP WHT Reconciliation** (Order: 202)
- Controller: `ApWhtReconController`
- Features:
  - WHT reconciliation
  - Tax filing support

**1.8 AP Procedures** (Order: 205)
- Controller: `ApProcedureController`
- Features:
  - AP workflow management
  - Approval procedures

**Related Settings**:
- Controller: `SettingApController` (Order: 1001)
- Models: `ParamSettingAp`

**Related Workflow**:
- `EnumWorkflowModule`: AP_VENDOR, AP_INVOICE, AP_PAYMENT

---

### 2. **ACCOUNTS RECEIVABLE (AR) MODULE**
**Controller Order Range**: 100-105
**Total Sub-Modules**: 10

#### Core Sub-Modules:

**2.1 AR Contract Management** (Order: 100)
- Controller: `ArContractController`
- Models: `ArContractD`
- Enums: `EnumArContractStatus`
- Features:
  - Contract creation and tracking
  - Contract detail management
  - Contract status workflow

**2.2 AR Invoice** (Order: 101)
- Controller: `ArInvoiceController`
- Models: `ArInvoiceH`, `ArInvoiceD`
- Views: `ViewArInvoiceUnpaid`
- Enums: `EnumArInvoiceStatus`, `EnumArInvTaxType`
- Features:
  - Customer invoice generation
  - Invoice detail lines
  - Invoice aging tracking

**2.3 AR Profile** (Order: 102)
- Controller: `ArProfileController`
- Models: `ArProfile`
- Features:
  - Customer profile management
  - Billing configuration

**2.4 AR Receipt** (Order: 103)
- Controller: `ArReceiptController`
- Models: `ArReceiptD`
- Views: `ViewArReceipt`
- Enums: `EnumArReceiptStatus`
- Features:
  - Payment receipt processing
  - Receipt allocation
  - Receipt detail tracking

**2.5 AR Type** (Order: 104)
- Controller: `ArTypeController`
- Models: `ArType`
- Features:
  - AR document type classification

**2.6 AR Project** (Order: 104)
- Controller: `ArProjectController`
- Features:
  - Project-based billing
  - Project tracking

**2.7 AR Owner** (Order: 105)
- Controller: `ArOwnerController`
- Features:
  - Property owner management (for rental/property management)

**2.8 AR Title** (Order: 105)
- Controller: `ArTitleController`
- Features:
  - Title/deed management

**2.9 AR Folio** (Order: N/A)
- Controller: `ArFolioController`
- Models: `ArFolio`
- Enums: `EnumArFolioStatus`
- Features:
  - Folio/ledger management
  - Account folio tracking

**2.10 AR Payment Type** (Order: 203)
- Controller: `ArPaymentTypeController`
- Features:
  - Receipt payment method configuration

**2.11 AR Procedures** (Order: N/A)
- Controller: `ArProcedureController`
- Features:
  - AR workflow management
  - Approval procedures

**Related Settings**:
- Controller: `SettingArController` (Order: 1001)
- Models: `ParamSettingAr`

**Related Workflow**:
- `EnumWorkflowModule`: AR_INVOICE, AR_RECEIPT

---

### 3. **GENERAL LEDGER (GL) MODULE**
**Controller Order Range**: 500-503
**Total Sub-Modules**: 8

#### Core Sub-Modules:

**3.1 GL Journal Voucher (JV)** (Order: 500)
- Controller: `GlJvController`
- Models: `GlJvH`, `GlJvD`
- Features:
  - Manual journal entry creation
  - JV posting and approval
  - Multi-dimensional posting

**3.2 GL Allocation Journal** (Order: 501)
- Controller: `GlAllocationJvController`
- Models: `GlAJvH`, `GlAllocationJvD`
- Features:
  - Automated allocation entries
  - Cost allocation
  - Recurring allocations

**3.3 GL Period Management** (Order: 501)
- Controller: `GlPeriodController`
- Enums: `EnumGlPeriodStatus`
- Features:
  - Fiscal period setup
  - Period opening/closing
  - Year-end processing

**3.4 GL Prefix Configuration** (Order: 502)
- Controller: `GlPrefixController`
- Models: `IGlPrefix`
- Features:
  - Document numbering setup
  - Prefix configuration

**3.5 GL JV from Financial Report (JvFr)** (Order: 502)
- Controller: `GlJvFrController`
- Models: `GlFrD`
- Views: `ViewGlFr`, `ViewGlFrH`
- Features:
  - JV generation from financial reports
  - Automated entry creation

**3.6 GL Amortization** (Order: 503)
- Controller: `GlAmortizeController`
- Models: `GlAmorizeHis`
- Enums: `EnumTypeOfAmortize`
- Features:
  - Prepaid expense amortization
  - Deferred revenue recognition
  - Automated amortization schedules

**3.7 GL Procedures** (Order: 501)
- Controller: `GlProcedureController`
- Features:
  - GL workflow management
  - Posting procedures

**3.8 Account Code (Chart of Accounts)** (Order: 12)
- Controller: `AccountCodeController`
- Views: `ViewCostAccountCode`
- Enums:
  - `EnumAccountNature`
  - `EnumAccountType`
  - `EnumGlStandardType`
  - `EnumGlCrOrDr`
  - `EnumGlStatus`
- Features:
  - Chart of accounts maintenance
  - Account hierarchy
  - Account classification

**Related Settings**:
- Controller: `SettingGlController` (Order: 1003)

**Related Enums**:
- `EnumApplicationModule`: GL
- `EnumPostingSeparator`

---

### 4. **ASSET MANAGEMENT MODULE**
**Controller Order Range**: 401-406
**Total Sub-Modules**: 7

#### Core Sub-Modules:

**4.1 Asset Category** (Order: 401)
- Controller: `AssetCategoryController`
- Models: `ParamAstCategory`
- Views: `ViewAstCategory`
- Features:
  - Asset type classification
  - Category-specific depreciation rules

**4.2 Asset Department** (Order: 402)
- Controller: `AssetDepartmentController`
- Models: `ParamAstDepHis`
- Features:
  - Department asset allocation
  - Inter-department transfers

**4.3 Asset Disposal** (Order: 403)
- Controller: `AssetDisposalController`
- Enums:
  - `EnumDisposalType`
  - `EnumDisposalAtDate`
- Features:
  - Asset sale/disposal processing
  - Gain/loss calculation
  - Disposal documentation

**4.4 Asset History** (Order: 404)
- Controller: `AssetHistoryController`
- Enums: `EnumAssetDeleteHisAt`
- Features:
  - Asset transaction history
  - Audit trail
  - Historical reporting

**4.5 Asset Location** (Order: 405)
- Controller: `AssetLocationController`
- Features:
  - Physical location tracking
  - Location transfers

**4.6 Asset Procedures** (Order: 405)
- Controller: `AssetProcedureController`
- Features:
  - Asset workflow management
  - Approval procedures

**4.7 Asset Register** (Order: 406)
- Controller: `AssetRegisterController`
- Models: `AssetDepreModel`
- Enums:
  - `EnumAssetAutoIdFormat`
  - `EnumPreAssetStatus`
- Features:
  - Fixed asset registration
  - Depreciation calculation
  - Asset master data

**Related Sub-Module**:

**4.8 Pre-Asset Management**
- Controller: `PreAssetController`
- Enums: `EnumPreAssetStatus`
- Features:
  - Asset acquisition tracking
  - Pre-capitalization items
  - Asset-in-progress

**Related Settings**:
- Controller: `SettingAssetController` (Order: 1002)

**Related Utilities**:
- `AssetCalculation`: Depreciation formulas

**Related Enums**:
- `EnumApplicationModule`: ASSET

---

### 5. **INCOME/REVENUE MODULE**
**Controller Order Range**: 600-611
**Total Sub-Modules**: 7

#### Core Sub-Modules:

**5.1 Income Source** (Order: 600)
- Controller: `IncomeSourceController`
- Features:
  - Revenue source categorization
  - Income stream tracking

**5.2 Income Revenue** (Order: 601)
- Controller: `IncomeRevenueController`
- Features:
  - Revenue recognition
  - Income posting

**5.3 Income Category** (Order: 602)
- Controller: `IncomeCategoryController`
- Views: `ViewIncSubCat`
- Features:
  - Income categorization
  - Sub-category management

**5.4 Income Product** (Order: 603)
- Controller: `IncomeProductController`
- Features:
  - Product/service catalog
  - Revenue item master

**5.5 Income Payment Type** (Order: 603)
- Controller: `IncomePayTypeController`
- Features:
  - Payment method configuration

**5.6 Income Payment Code** (Order: 604)
- Controller: `IncomePayCodeController`
- Features:
  - Payment code setup
  - Revenue coding

**5.7 Income Procedures** (Order: 610)
- Controller: `IncomeProcedureController`
- Features:
  - Income workflow management

**5.8 Income Invoice** (Order: 611)
- Controller: `IncomeInvoiceController`
- Enums: `EnumIncomeStatus`
- Features:
  - Income invoice generation
  - Revenue billing

**Related Settings**:
- Controller: `SettingIncomeController` (Order: 1004)

---

### 6. **TAX & RECONCILIATION MODULE**
**Controller Order Range**: 14, 106, 202, 700
**Total Sub-Modules**: 5

#### Core Sub-Modules:

**6.1 Tax Profile** (Order: 202)
- Controller: `TaxProfileController`
- Models: `TaxProfile`
- Enums: `EnumTaxType`
- Features:
  - Tax rate configuration
  - Tax authority setup
  - Tax calculation rules

**6.2 VAT Reconciliation** (Order: 14)
- Controller: `VatReconcileController`
- Enums: `EnumVatSource`
- Features:
  - VAT input/output reconciliation
  - Tax reporting
  - Filing preparation

**6.3 Edit VAT Reconciliation** (Order: 14)
- Controller: `EditVatReconcileController`
- Features:
  - VAT adjustment entries
  - Reconciliation corrections

**6.4 Tax Reconciliation** (Order: 14)
- Controller: `TaxReconcileController`
- Features:
  - General tax reconciliation
  - Tax liability tracking

**6.5 Cheque Reconciliation** (Order: 700)
- Controller: `ChequeReconcileController`
- Features:
  - Bank reconciliation
  - Cheque clearing tracking
  - Outstanding items

---

### 7. **FINANCIAL REPORTING MODULE**
**Controller Order Range**: 9, 100
**Total Sub-Modules**: 3

#### Core Sub-Modules:

**7.1 Financial Reports** (Order: 100)
- Controller: `FinancialController`
- Models: `FinReportAcc`
- Features:
  - Balance sheet
  - Income statement
  - Cash flow
  - Trial balance

**7.2 Report Generator** (Order: 9)
- Controller: `ReportController`
- Features:
  - Custom report generation
  - Report templates
  - Export capabilities

**7.3 Budget Management** (Order: 11)
- Controller: `BudgetController`
- Features:
  - Budget preparation
  - Budget vs. actual analysis
  - Variance reporting

**Related Settings**:
- Controller: `SettingBudgetXlsController` (Order: 1006)

---

### 8. **VENDOR & CUSTOMER MASTER MODULE**
**Controller Order Range**: 14
**Total Sub-Modules**: 3

#### Core Sub-Modules:

**8.1 Vendor Master** (Order: 14)
- Controller: `VendorController`
- Enums: `EnumApVendorStatus`
- Features:
  - Vendor registration
  - Vendor profile management
  - Credit terms setup

**8.2 Vendor Category** (Order: 14)
- Controller: `VendorCategoryController`
- Views: `ViewParamVendorCate`
- Features:
  - Vendor classification
  - Category-specific terms

**8.3 Payment Type** (Order: 203)
- Controller: `PaymentTypeController`
- Features:
  - Shared payment method configuration
  - Used by AP, AR, Income modules

---

### 9. **SYSTEM ADMINISTRATION MODULE**
**Controller Order Range**: 0-15, 1000-2000
**Total Sub-Modules**: 20+

#### Core Sub-Modules:

**9.1 Authentication & Authorization**
- **Login** (Order: 0): `LoginController`
- **Token** (Order: 4): `TokenController`
- **User** (Order: 6): `UserController`
  - Views: `ViewUserNoPassword`
- **Permission** (Order: 6): `PermissionController`
  - Models: `IPermission`, `ParamPermissionInfo`
  - Features: Role-based access control

**9.2 Multi-Tenant Management**
- **Tenant** (Order: 5): `tenantController`
  - Models: `ParamTenant`, `ITenantUser`
  - Views: `ViewTenantUser`
- **User Tenant** (Order: 6): `UserTenantController`
  - Features: User-tenant assignment

**9.3 Company & Organization**
- **Company** (Order: 7): `CompanyController`
- **Headquarter** (Order: 5): `HeadquarterController`
- **Department** (Order: 11): `DepartmentController`
  - Models: `ParamDepartment`

**9.4 Master Data Management**
- **Country** (Order: 104): `CountryController`
- **Currency** (Order: 10): `CurrencyController`
- **Currency Exchange** (Order: 10): `CurrencyExchangeController`
  - Enums: `EnumExchageRateType`
- **Unit** (Order: 13): `UnitController`
  - Models: `IUnitCode`
- **Lookup** (Order: 1009): `LookupController`
  - Enums: `EnumLookup`

**9.5 Configuration & Settings**
- **Setting All** (Order: 1000): `SettingAllController`
  - Models: `ISettingAll`, `ViewSettingSystem`
- **Setting System** (Order: 1005): `SettingSystemController`
- **Setting Policy** (Order: 1006): `SettingPolicyController`
  - Models: `ParamSettingPolicy`
- **Setup** (Order: 1): `SetupController`
  - Models: `IPreconfig`
- **Config Widget** (Order: 9): `ConfigWidgetController`
  - Models: `ParamWidget`

**9.6 Data Management**
- **Database** (Order: 2): `DatabaseController`
  - Models: `ParamMyConnectionBlankDb`
  - Enums: `EnumConnectionProvider`
- **Data Dictionary** (Order: 11): `DataDicController`
  - Enums: `EnumDataDicType`, `EnumFieldType`
- **Stored Procedures** (Order: 2): `StoredProcController`
  - Views: `ViewStoredProc`
- **Call Stored Proc** (Order: 2): `CallStoreProcController`

**9.7 System Utilities**
- **Enum** (Order: 15): `EnumController`
- **Migrate** (Order: 2): `MigrateController`
- **Mail** (Order: 1): `MailController`
  - Enums: `EnumMailProfile`
- **System Info** (Order: 2000): `SystemInfoController`
- **Version** (Order: 1): `VersionController`
- **Updater** (Order: N/A): `UpdaterController`

**9.8 Workflow & Process Management**
- **Workflow** (Order: 2): `WorkflowController`
  - Enums:
    - `EnumWorkflowModule`
    - `EnumWorkflowApproveCode`
- **Process Log** (Order: 1020): `ProcessLogController`
  - Enums: `EnumLogAction`

**9.9 Comments & Attachments**
- **Comment** (Order: 11): `CommentController`
  - Models: `ParamArComment`, `ArCommentItem`, `ArFileAttachItem`
  - Views: `ViewComment`
  - Enums: `EnumCommentModule`

**9.10 Dimension Management**
- **Dimension** (Order: 13): `DimensionController`
  - Models: `DimensionList`
  - Enums:
    - `EnumDimensionType`
    - `EnumDimensionModule`

**9.11 Dashboards & Analytics**
- **Dashboards** (Order: 8): `DashboardsController`
- **Global Parameters** (Order: 8): `GblParamsController`

**9.12 Banking Integration**
- **Global File from Bank** (Order: 104): `GblFileFromBankController`
  - Models: `ParamGblFileFromBank`
  - Views: `ViewGblFileFromBank`

**9.13 Licensing**
- **License** (Order: 1005): `LicenseController`
  - Enums: `EnumLicenseType`
- **License Interface** (Order: 1006): `LicenseInterfaceController`

**9.14 Home & Navigation**
- **Home** (Order: N/A): `HomeController`
  - Enums: `EnumNavigate`

**9.15 Plugins & Extensions**
- **Plugins** (Order: 10000): `PluginsController`

---

### 10. **INTEGRATION & INTERFACE MODULE**
**Total Sub-Modules**: 4

#### Interface Models & Configuration:

**10.1 Interface Base**
- Models: `IInterfaceBase`
- Enums:
  - `EnumInterfaceType`
  - `EnumInterfaceDocType`

**10.2 Interface Type: File**
- Models: `IInterfaceSettingTypeFile`
- Features:
  - File-based import/export
  - CSV/Excel integration

**10.3 Interface Type: Database**
- Models: `IInterfaceSettingTypeDatabase`
- Features:
  - Database-to-database sync
  - Direct table mapping

**10.4 Interface Type: Data Bank**
- Models: `IInterfaceSettingTypeDataBank`
- Features:
  - Banking system integration
  - Payment file generation

**10.5 Interface Type: Web API**
- Models: `IInterfaceSettingTypeWebApi`
- Features:
  - REST API integration
  - External system connectivity

**10.6 Interface Mapping**
- Models:
  - `IInterfaceMapping`
  - `IAccCodeFromTo`
  - `IInterfaceSettingDeptCodeAndAccCode`
  - `ExcelParam`
- Features:
  - Field mapping configuration
  - Account code conversion
  - Department code mapping

**Interface List Models**:
- `InterfaceItem`
- `InterfaceItemList`
- `InterfaceItemPermission`
- `InterfaceItemPermissionList`

---

### 11. **SPECIALIZED SUPPORT MODULES**

#### 11.1 Area-Based Controllers

**Management Area**:
- **Config Controller** (Management): Configuration management interface

**Support Area**:
- **Config Controller** (Support): Support configuration tools

---

## Cross-Module Features

### Shared Enumerations

**Action & Mode**:
- `EnumActionMode`: Add, Edit, Delete, View
- `EnumAddOrDelete`: Addition or deletion flags
- `EnumAndOr`: Logical operators

**Aging & Periods**:
- `EnumApAgingPeriodDateBy`: Aging calculation methods

### Parameter Models (Param*)

**Purpose**: DTOs for API requests and business logic
- 104 parameter model files
- Naming pattern: `Param[EntityName]`
- Examples:
  - `ParamApInvoice`
  - `ParamArContract`
  - `ParamGlJvD`
  - `ParamSettingPolicy`
  - `ParamWidget`

### View Models (View*)

**Purpose**: Optimized read models for UI and reporting
- 120 view model files
- Naming pattern: `View[EntityName]`
- Examples:
  - `ViewApInvoice`
  - `ViewArReceipt`
  - `ViewCostAccountCode`
  - `ViewGlFr`

### Interface Definitions (I*)

**Purpose**: Contracts for dependency injection and abstraction
- 325 interface files
- Naming patterns:
  - `I[EntityName]`: Business entity contracts
  - `IParam[EntityName]`: Parameter contracts
  - `IView[EntityName]`: View model contracts
- Examples:
  - `IApInvoice`
  - `IParamApInvoice`
  - `IViewComment`

---

## Module Dependencies

### Vertical Dependencies
```
Controllers (API Layer)
    ↓
Functions (Business Logic)
    ↓
Models (Data Layer)
    ↓
Database
```

### Horizontal Dependencies
```
AP ←→ GL (Posting integration)
AR ←→ GL (Posting integration)
Asset ←→ GL (Depreciation posting)
Income ←→ GL (Revenue posting)
All Modules → Tax Module
All Modules → Dimension Module
All Modules → Workflow Module
```

### Shared Services
- Authentication & Authorization
- Multi-tenant management
- Dimension allocation
- Comment & attachment
- Workflow & approval
- Currency & exchange rates
- Document numbering (Prefix)

---

## Summary by Category

### Transaction Processing Modules (5)
1. **AP**: 8 sub-modules
2. **AR**: 10 sub-modules
3. **GL**: 8 sub-modules
4. **Asset**: 7 sub-modules
5. **Income**: 7 sub-modules

### Support Modules (3)
6. **Tax & Reconciliation**: 5 sub-modules
7. **Financial Reporting**: 3 sub-modules
8. **Vendor & Customer**: 3 sub-modules

### Infrastructure Modules (3)
9. **System Administration**: 20+ sub-modules
10. **Integration & Interface**: 4+ sub-modules
11. **Specialized Support**: 2 areas

---

## Total Count Verification

### Controllers
- Main Controllers: 101
- Area Controllers: 2
- **Total**: 101 unique controller classes

### Models
- Core Models: ~170
- View Models: 120
- Parameter Models: 104
- Interface Definitions: 325
- **Total**: 600+ model files

### Enumerations
- Application Module Enums: 4 (AP, AR, GL, ASSET)
- Workflow Module Enums: 5 (AP_VENDOR, AP_INVOICE, AP_PAYMENT, AR_INVOICE, AR_RECEIPT)
- Supporting Enums: 49 total enum types

### Sub-Modules
- **Minimum Count**: 78+ distinct sub-modules
- **With variations**: 85+ functional areas

---

## Module Order Groupings (by SwaggerControllerOrder)

### Authentication (0-6)
- Login (0), Setup (1), Token (4), Tenant (5), Headquarter (5), User (6), Permission (6), UserTenant (6), Company (7)

### Core Master Data (8-15)
- GblParams (8), Dashboards (8), ConfigWidget (9), Report (9), Currency (10), CurrencyExchange (10), Budget (11), Comment (11), DataDic (11), Department (11), AccountCode (12), Unit (13), Dimension (13), Vendor (14), VendorCategory (14), VatReconcile (14), TaxReconcile (14), EditVatReconcile (14), Enum (15)

### AR Module (100-105)
- ArContract (100), Financial (100), ArInvoice (101), ArProfile (102), ArReceipt (103), Country (104), ArType (104), ArProject (104), GblFileFromBank (104), ArOwner (105), ArTitle (105), ApWhtCondition (106)

### AP Module (201-205)
- ApInvoice (201), ApPayment (202), ApWht (202), ApWhtRecon (202), ApWhtType (202), TaxProfile (202), ApPaymentType (203), ArPaymentType (203), PaymentType (203), ApProcedure (205)

### GL Module (500-503)
- GlJv (500), GlAllocationJv (501), GlPeriod (501), GlProcedure (501), GlJvFr (502), GlPrefix (502), GlAmortize (503)

### Asset Module (401-406)
- AssetCategory (401), AssetDepartment (402), AssetDisposal (403), AssetHistory (404), AssetLocation (405), AssetProcedure (405), AssetRegister (406)

### Income Module (600-611)
- IncomeSource (600), IncomeRevenue (601), IncomeCategory (602), IncomePayType (603), IncomeProduct (603), IncomePayCode (604), IncomeProcedure (610), IncomeInvoice (611)

### Cheque/Banking (700)
- ChequeReconcile (700)

### System Settings (1000-1020)
- SettingAll (1000), SettingAp (1001), SettingAr (1001), SettingAsset (1002), SettingGl (1003), SettingIncome (1004), SettingSystem (1005), License (1005), LicenseInterface (1006), SettingBudgetXls (1006), SettingPolicy (1006), Lookup (1009), ProcessLog (1020)

### System Info (2000)
- SystemInfo (2000)

### Extensions (10000)
- Plugins (10000)

---

## Naming Conventions

### Controllers
- Pattern: `[Entity]Controller.cs`
- Base: `BaseApiController`
- Route: `api/[entity]/[action]`

### Models
- Core entities: `[EntityName].cs` (e.g., `ApInvoice`)
- Detail/child: `[EntityName]D.cs` (e.g., `ApInvoiceD`)
- Header: `[EntityName]H.cs` (e.g., `ArInvoiceH`)
- View models: `View[EntityName].cs`
- Parameters: `Param[EntityName].cs`
- Interfaces: `I[EntityName].cs`

### Enumerations
- Pattern: `Enum[Category][Attribute].cs`
- Examples: `EnumApInvoiceStatus`, `EnumTaxType`

---

## Architecture Notes

### Module Organization Philosophy
1. **Functional Segregation**: Modules organized by business function (AP, AR, GL, etc.)
2. **Layered Architecture**: Clear separation between API, business logic, and data
3. **Shared Services**: Cross-cutting concerns handled by infrastructure modules
4. **Multi-Tenant Design**: Tenant isolation at all layers
5. **Workflow Integration**: Approval workflows integrated across transaction modules

### API Design Patterns
1. **RESTful**: Standard HTTP verbs and resource-based routing
2. **Async/Await**: All I/O operations use async patterns
3. **Swagger Documentation**: Complete API documentation with examples
4. **Authorization**: Permission-based access control on all endpoints
5. **Tenant Isolation**: Tenant context in all API calls
