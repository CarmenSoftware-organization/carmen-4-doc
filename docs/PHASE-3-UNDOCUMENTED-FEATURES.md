# Phase 3: Undocumented Features Report

**Report Date**: 2025-10-07
**Report Type**: Gap Analysis - Undocumented Features Inventory
**Source**: Carmen.NET ERP System (Carmen4)
**Status**: Phase 3.1 - Complete Inventory

---

## Executive Summary

**Total API Endpoints**: 433
**Documented Endpoints**: 4 (0.9%)
**Undocumented Endpoints**: 429 (99.1%)

**Documentation Crisis**: The system has a critical documentation gap affecting all modules except Authentication.

---

## Undocumented Features by Module

### 1. AP Module (Accounts Payable) - 33 Undocumented Routes

**Controllers**: 8 controllers
- ApInvoiceController.cs
- ApPaymentController.cs
- ApPaymentTypeController.cs
- ApProcedureController.cs
- ApWhtController.cs
- ApWhtConditionController.cs
- ApWhtReconController.cs
- ApWhtTypeController.cs

**Undocumented Features**:

#### 1.1 AP Invoice Management (7 routes)
```
api/apInvoice                          - Create/list AP invoices
api/apInvoice/search                   - Search invoices
api/apInvoice/status                   - Get invoice status
api/apInvoice/unpaid                   - List unpaid invoices
api/apInvoice/newunpaid                - List new unpaid invoices
api/apInvoice/{invhSeq}                - Get/update/delete invoice by ID
api/apInvoice/{invhSeq}/{invdSeq}      - Manage invoice line items
```

**Business Functionality**: Invoice creation, modification, status tracking, unpaid invoice queries

#### 1.2 AP Payment Processing (5 routes)
```
api/apPayment                          - Create/list payments
api/apPayment/search                   - Search payments
api/apPayment/getEmail/{id}            - Get payment notification email
api/apPayment/sendEmail/               - Send payment notification
api/apPayment/{pyhSeq}                 - Get/update/delete payment
```

**Business Functionality**: Payment processing, email notifications, payment queries

#### 1.3 Payment Type Configuration (3 routes)
```
api/apPaymentType                      - Create/list payment types
api/apPaymentType/search               - Search payment types
api/apPaymentType/{id}                 - Get/update/delete payment type
```

**Business Functionality**: Master data for payment methods (cash, check, wire transfer, etc.)

#### 1.4 Withholding Tax Management (15 routes)
```
api/apWht                              - Manage WHT records
api/apWht/search                       - Search WHT records
api/apWht/{id}                         - Get/update/delete WHT record

api/apWhtCondition                     - Manage WHT conditions
api/apWhtCondition/search              - Search WHT conditions
api/apWhtCondition/{id}                - Get/update/delete condition

api/apWhtRecon                         - WHT reconciliation
api/apWhtRecon/search                  - Search reconciliation records
api/apWhtRecon/import                  - Import WHT data
api/apWhtRecon/import/{year}/{month}   - Import by period
api/apWhtRecon/year                    - List available years
api/apWhtRecon/{id}                    - Get/update/delete reconciliation
api/apWhtRecon/{year}/{month}          - Get reconciliation by period

api/apWhtType                          - Manage WHT types
api/apWhtType/search                   - Search WHT types
api/apWhtType/{id}                     - Get/update/delete WHT type
```

**Business Functionality**: Thailand-specific withholding tax calculation, reconciliation, and government filing

#### 1.5 AP Procedures (2 routes)
```
api/apProcedure/closePeriod            - Close accounting period
api/apProcedure/isPostedFromInventory  - Check inventory integration
```

**Business Functionality**: Period-end closing, inventory integration validation

#### 1.6 Vendor Management (3 routes)
```
api/vendor                             - Create/list vendors
api/vendor/search                      - Search vendors
api/vendor/{id}                        - Get/update/delete vendor
```

**Business Functionality**: Vendor master data management

#### 1.7 Vendor Category (3 routes)
```
api/vendorCategory                     - Create/list categories
api/vendorCategory/search              - Search categories
api/vendorCategory/{id}                - Get/update/delete category
```

**Business Functionality**: Vendor classification and categorization

---

### 2. AR Module (Accounts Receivable) - 52 Undocumented Routes

**Controllers**: 11 controllers
- ArContractController.cs
- ArFolioController.cs
- ArInvoiceController.cs
- ArOwnerController.cs
- ArPaymentTypeController.cs
- ArProcedureController.cs
- ArProfileController.cs
- ArProjectController.cs
- ArReceiptController.cs
- ArTitleController.cs
- ArTypeController.cs

**Undocumented Features**:

#### 2.1 AR Contract Management (7 routes)
```
api/arContract                                    - Create/list contracts
api/arContract/search                             - Search contracts
api/arContract/applyContract                      - Apply contract to invoice
api/arContract/byArNo/{arno}                      - Get contracts by AR number
api/arContract/byDate/{frDate}/{toDate}           - Get contracts by date range
api/arContract/checkDuplicateContractNo/{*contractNo} - Validate contract number
api/arContract/{id}                               - Get/update/delete contract
```

**Business Functionality**: Recurring revenue contracts, subscription management, contract application to invoices

#### 2.2 AR Folio Management (5 routes)
```
api/arFolio                            - Create/list folios
api/arFolio/search                     - Search folios
api/arFolio/unpaid                     - List unpaid folios
api/arFolio/addOrUpdateBatch           - Bulk folio operations
api/arFolio/{id}                       - Get/update/delete folio
```

**Business Functionality**: Hotel/property folio management (hospitality-specific feature)

#### 2.3 AR Invoice Management (10 routes)
```
api/arInvoice                          - Create/list invoices
api/arInvoice/search                   - Search invoices
api/arInvoice/unpaid                   - List unpaid invoices
api/arInvoice/Invoice/{id}             - Get invoice with details
api/arInvoice/getEmail/{id}            - Get invoice email
api/arInvoice/sendEmail/               - Send invoice by email
api/arInvoice/comment                  - Add comment to invoice
api/arInvoice/commentById/{id}         - Get comments by invoice ID
api/arInvoice/{id}                     - Get/update/delete invoice
```

**Business Functionality**: Invoice generation, email delivery, commenting, unpaid tracking

#### 2.4 AR Receipt Processing (8 routes)
```
api/arReceipt                          - Create/list receipts
api/arReceipt/search                   - Search receipts
api/arReceipt/Receipt/{id}             - Get receipt with details
api/arReceipt/getEmail/{id}            - Get receipt email
api/arReceipt/sendEmail/               - Send receipt by email
api/arReceipt/comment                  - Add comment to receipt
api/arReceipt/comment/{id}             - Get comments by receipt ID
api/arReceipt/{id}                     - Get/update/delete receipt
```

**Business Functionality**: Payment receipt generation, email delivery, commenting

#### 2.5 AR Customer Profile (7 routes)
```
api/arProfile                          - Create/list customer profiles
api/arProfile/search                   - Search profiles
api/arProfile/fileAttach               - Upload file attachment
api/arProfile/fileAttach/{arNo}        - List files by AR number
api/arProfile/fileAttach/download/{id} - Download attachment
api/arProfile/fileAttach/{id}          - Delete attachment
api/arProfile/{id}                     - Get/update/delete profile
```

**Business Functionality**: Customer master data, document management, file attachments

#### 2.6 AR Owner Management (3 routes)
```
api/arOwner                            - Create/list owners
api/arOwner/search                     - Search owners
api/arOwner/{id}                       - Get/update/delete owner
```

**Business Functionality**: Property owner management (hospitality-specific)

#### 2.7 AR Project Management (3 routes)
```
api/arProject                          - Create/list projects
api/arProject/search                   - Search projects
api/arProject/{id}                     - Get/update/delete project
```

**Business Functionality**: Project-based billing and revenue tracking

#### 2.8 AR Configuration (12 routes)
```
api/arPaymentType                      - Payment type configuration
api/arPaymentType/search               - Search payment types
api/arPaymentType/{id}                 - Get/update/delete payment type

api/arTitle                            - Customer title configuration
api/arTitle/search                     - Search titles
api/arTitle/{id}                       - Get/update/delete title

api/arType                             - Customer type configuration
api/arType/search                      - Search customer types
api/arType/{id}                        - Get/update/delete customer type

api/arProcedure/closePeriod            - Close AR period
```

**Business Functionality**: Master data configuration, period-end processing

---

### 3. GL Module (General Ledger) - 34 Undocumented Routes

**Controllers**: 7 controllers
- GlJvController.cs
- GlJvFrController.cs
- GlPeriodController.cs
- GlPrefixController.cs
- GlProcedureController.cs
- AccountCodeController.cs
- AllocationJvController.cs

**Undocumented Features**:

#### 3.1 Journal Voucher Management (9 routes)
```
api/glJv                               - Create/list journal vouchers
api/glJv/search                        - Search journal vouchers
api/glJv/addBatch                      - Bulk JV creation
api/glJv/addBatchTempTable             - Bulk JV via temp table
api/glJv/addOrUpdateBatch              - Bulk upsert operations
api/glJv/addOrUpdateBatchTempTable     - Bulk upsert via temp table
api/glJv/delBatchTempTable             - Delete temp table batch
api/glJv/{jvhSeq}                      - Get/update/delete JV
api/glJv/{navigate}                    - Navigate between JVs
```

**Business Functionality**: Manual journal entries, batch imports, navigation

#### 3.2 Fixed Journal Vouchers (3 routes)
```
api/glJvFr                             - Create/list fixed JVs
api/glJvFr/search                      - Search fixed JVs
api/glJvFr/{fjvhSeq}                   - Get/update/delete fixed JV
```

**Business Functionality**: Recurring journal templates

#### 3.3 Amortization Management (4 routes)
```
api/amortizeStdJv                      - Standard amortization JVs
api/amortizeStdJv/search               - Search amortization JVs
api/amortizeStdJv/{fjvhSeq}            - Get/update/delete amortization
api/amortizeHistory/{fjvhSeq}          - Get amortization history
```

**Business Functionality**: Prepaid/deferred expense amortization

#### 3.4 Allocation Journal (3 routes)
```
api/allocationJv                       - Create/list allocation JVs
api/allocationJv/search                - Search allocation JVs
api/allocationJv/{jvhSeq}              - Get/update/delete allocation
```

**Business Functionality**: Cost allocation across departments/projects

#### 3.5 Chart of Accounts (4 routes)
```
api/accountCode                        - Create/list account codes
api/accountCode/search                 - Search account codes
api/accountCode/batch                  - Bulk account operations
api/accountCode/{id}                   - Get/update/delete account
```

**Business Functionality**: Chart of accounts management

#### 3.6 GL Periods (6 routes)
```
api/glPeriod                           - Create/list periods
api/glPeriod/search                    - Search periods
api/glPeriod/initial                   - Initialize first period
api/glPeriod/year/{year}               - Get periods by year
api/glPeriod/Anniversary/{anniversary} - Get anniversary periods
api/glPeriod/{id}                      - Get/update/delete period
```

**Business Functionality**: Accounting period management, calendar setup

#### 3.7 GL Prefix Configuration (3 routes)
```
api/glPrefix                           - Create/list prefixes
api/glPrefix/search                    - Search prefixes
api/glPrefix/{id}                      - Get/update/delete prefix
```

**Business Functionality**: Document numbering schemes

#### 3.8 GL Procedures (11 routes)
```
api/glProcedure/closePeriod            - Close accounting period
api/glProcedure/postAp                 - Post AP to GL
api/glProcedure/postAr                 - Post AR to GL
api/glProcedure/postAsset              - Post Asset transactions
api/glProcedure/postAssetDepre         - Post depreciation
api/glProcedure/postAssetDisposal      - Post asset disposal
api/glProcedure/applyStandardJv        - Apply standard JV
api/glProcedure/applyAmortizeJv        - Apply amortization
api/glProcedure/reCalPeriod            - Recalculate period
api/glProcedure/reCalPeriodNoWait      - Recalculate async
api/glProcedure/checkPostInvalid       - Validate posting
api/glProcedure/createGlHis            - Create GL history
api/glProcedure/verifyData             - Data integrity check
```

**Business Functionality**: Integration posting, period-end closing, data validation

---

### 4. Asset Module - 26 Undocumented Routes

**Controllers**: 7 controllers
- AssetRegisterController.cs
- AssetDisposalController.cs
- AssetDepartmentController.cs
- AssetLocationController.cs
- AssetHistoryController.cs
- AstCategoryController.cs
- PreassetController.cs

**Undocumented Features**:

#### 4.1 Asset Register Management (9 routes)
```
api/assetRegister                      - Create/list assets
api/assetRegister/search               - Search assets
api/assetRegister/copy                 - Copy asset record
api/assetRegister/changeLocation       - Transfer asset location
api/assetRegister/remain/{id}/{date}   - Calculate remaining value
api/assetRegister/isDisposal/{id}      - Check disposal status
api/assetRegister/endDate/{id}/{no}    - Update end date
api/assetRegister/{id}                 - Get/update/delete asset
```

**Business Functionality**: Fixed asset registration, transfers, valuation

#### 4.2 Asset Disposal (5 routes)
```
api/assetDisposal                      - Create/list disposals
api/assetDisposal/search               - Search disposals
api/assetDisposal/{id}                 - Get/update/delete disposal
api/assetDisposalAccuDepre             - Accumulated depreciation on disposal
api/assetDisposalQuery                 - Query disposal records
```

**Business Functionality**: Asset retirement, sale, write-off processing

#### 4.3 Asset Configuration (9 routes)
```
api/astCategory                        - Asset categories
api/astCategory/search                 - Search categories
api/astCategory/{id}                   - Get/update/delete category

api/assetDepartment                    - Department assignment
api/assetDepartment/search             - Search departments
api/assetDepartment/{id}               - Get/update/delete department

api/assetLocation                      - Location management
api/assetLocation/search               - Search locations
api/assetLocation/{id}                 - Get/update/delete location
```

**Business Functionality**: Asset classification, organizational structure

#### 4.4 Asset History & Tracking (3 routes)
```
api/assetHistory/                      - Asset transaction history
api/assetHistory/LocLog/               - Location change log
api/preasset/search                    - Search pre-assets
api/preasset/{id}                      - Manage pre-assets
```

**Business Functionality**: Audit trail, location tracking, asset acquisition workflow

#### 4.5 Asset Procedures (2 routes)
```
api/assetProcedure/closePeriod         - Close asset period
api/assetProcedure/postAp              - Post AP to asset
```

**Business Functionality**: Period-end processing, AP integration

---

### 5. Income Module - 23 Undocumented Routes

**Controllers**: 8 controllers
- IncomeCategoryController.cs
- IncomeInvoiceController.cs
- IncomePayCodeController.cs
- IncomePayTypeController.cs
- IncomeProductController.cs
- IncomeRevenueController.cs
- IncomeSourceController.cs
- IncomeProcedureController.cs

**Undocumented Features**:

#### 5.1 Income Invoice Management (3 routes)
```
api/incomeInvoice                      - Create/list income invoices
api/incomeInvoice/search               - Search invoices
api/incomeInvoice/{id}                 - Get/update/delete invoice
```

**Business Functionality**: Daily revenue capture from PMS/POS systems

#### 5.2 Income Revenue Recording (3 routes)
```
api/incomeRevenue                      - Create/list revenue records
api/incomeRevenue/search               - Search revenue
api/incomeRevenue/{id}                 - Get/update/delete revenue
```

**Business Functionality**: Revenue transaction recording and categorization

#### 5.3 Income Configuration (15 routes)
```
api/incomeCategory                     - Revenue categories
api/incomeCategory/search              - Search categories
api/incomeCategory/{id}                - Get/update/delete category

api/incomePayCode                      - Payment codes
api/incomePayCode/search               - Search payment codes
api/incomePayCode/{id}                 - Get/update/delete pay code

api/incomePayType                      - Payment types
api/incomePayType/search               - Search payment types
api/incomePayType/{id}                 - Get/update/delete pay type

api/incomeProduct                      - Product/service catalog
api/incomeProduct/search               - Search products
api/incomeProduct/{id}                 - Get/update/delete product

api/incomeSource                       - Revenue sources
api/incomeSource/search                - Search sources
api/incomeSource/{id}                  - Get/update/delete source
```

**Business Functionality**: Revenue classification, product catalog, payment methods

#### 5.4 Income Procedures (2 routes)
```
api/incomeProcedure/closePeriod        - Close income period
api/incomeProcedure/postHmsRevenue     - Post HMS revenue to GL
```

**Business Functionality**: Period-end closing, PMS integration

---

### 6. Tax Module - 16 Undocumented Routes

**Controllers**: 3 controllers
- TaxReconcileController.cs
- VatReconcileController.cs
- EditVatReconcileController.cs
- TaxProfileController.cs

**Undocumented Features**:

#### 6.1 Tax Reconciliation (8 routes)
```
api/TaxReconcile                       - Create/list tax reconciliations
api/TaxReconcile/search                - Search reconciliations
api/TaxReconcile/batch                 - Bulk reconciliation
api/TaxReconcile/{frDate}/{toDate}     - Reconcile by date range
api/TaxReconcile/export/{frDate}/{toDate}/{overWrite} - Export tax data
api/TaxReconcile/prefix                - Get available prefixes
api/TaxReconcile/prefix/{prefix}       - Filter by prefix
api/TaxReconcile/{id}                  - Get/update/delete reconciliation
```

**Business Functionality**: Tax calculation, reconciliation, government filing

#### 6.2 VAT Reconciliation (4 routes)
```
api/VatReconcile/batch                 - Bulk VAT reconciliation
api/VatReconcile/{frDate}/{toDate}     - Reconcile VAT by period
api/VatReconcile/export/{frDate}/{toDate}/{overWrite} - Export VAT data
api/editVatReconcile                   - Edit VAT records
api/editVatReconcile/search            - Search VAT edits
api/editVatReconcile/prefix            - Get prefixes
api/editVatReconcile/prefix/{prefix}   - Filter by prefix
api/editVatReconcile/{id}              - Get/update/delete VAT edit
```

**Business Functionality**: VAT calculation, filing, corrections

#### 6.3 Tax Profile (3 routes)
```
api/taxProfile                         - Create/list tax profiles
api/taxProfile/search                  - Search tax profiles
api/taxProfile/{id}                    - Get/update/delete profile
```

**Business Functionality**: Tax configuration, company tax settings

---

### 7. Bank Module - 1 Undocumented Route

**Controllers**: 2 controllers
- ChequeReconcileController.cs
- GblFilefromBankController.cs

**Undocumented Features**:

#### 7.1 Cheque Reconciliation (3 routes)
```
api/chequeReconcile                    - Create/list reconciliations
api/chequeReconcile/search             - Search reconciliations
api/chequeReconcile/fileFromBank       - Import bank statement
```

**Business Functionality**: Bank reconciliation, cheque clearing

#### 7.2 Bank File Import (3 routes)
```
api/gblfilefrombank                    - Create/list bank files
api/gblfilefrombank/search             - Search bank files
api/gblfilefrombank/{id}               - Get/update/delete file
```

**Business Functionality**: Electronic bank statement import

---

### 8. Master Data & Configuration - 84 Undocumented Routes

**Controllers**: Multiple shared controllers

**Undocumented Features**:

#### 8.1 Company Configuration (4 routes)
```
api/company                            - Get/update company info
api/company/country                    - Get company country
api/company/license                    - Get license info
api/company/numberofuser               - Get user count
```

#### 8.2 Currency Management (9 routes)
```
api/currency                           - Create/list currencies
api/currency/search                    - Search currencies
api/currency/active                    - List active currencies
api/currency/{id}                      - Get/update/delete currency

api/currencyexchange                   - Exchange rate management
api/currencyexchange/search            - Search rates
api/currencyexchange/addBatch          - Bulk rate import
api/currencyexchange/bycurrency        - Rates by currency
api/currencyexchange/bycurrencydate    - Rates by currency & date
api/currencyexchange/bydate            - Rates by date
api/currencyexchange/{id}              - Get/update/delete rate
api/currencyexchange/{provider}/{base_Currency}/{currency} - External rates
```

#### 8.3 Department & Dimension (8 routes)
```
api/department                         - Create/list departments
api/department/search                  - Search departments
api/department/FromAcCode/{accCode}/{currentDeptCode} - By account code
api/department/{id}                    - Get/update/delete department

api/dimension                          - Create/list dimensions
api/dimension/search                   - Search dimensions
api/dimension/module                   - Get modules
api/dimension/byEnum/{module}          - Dimensions by module
api/dimension/FilterOper               - Filter operators
api/dimension/{id}                     - Get/update/delete dimension
```

#### 8.4 Workflow System (7 routes)
```
api/Workflow                           - Create/list workflows
api/Workflow/{code}                    - Get/update/delete workflow
api/Workflow/Approve/{code}            - Approve workflow step
api/Workflow/ApproveBatch/{code}       - Bulk approval
api/Workflow/Detail/{code}             - Get workflow details
api/Workflow/History/{code}/{id}       - Get approval history
api/Workflow/Steps/{code}              - Get workflow steps
api/Workflow/StepsByCurrentUser/{code} - Get user's pending steps
api/Workflow/SetActive/{code}          - Activate workflow
```

#### 8.5 User & Permission Management (20 routes)
```
api/user                               - Create/list users
api/user/search                        - Search users
api/user/changePassword/{userId}       - Change password
api/user/forgotPassword/{username}     - Password reset
api/user/resetPassword/                - Reset password
api/user/{userId}                      - Get/update/delete user

api/permission                         - Get/set permissions
api/permission/Template                - Permission templates
api/permission/TemplateByLicense       - Templates by license
api/permission/TemplateByName/{*permissionName} - Template by name
api/permission/license/{tenant}/{userName} - License permissions
api/permission/setAdmin                - Set admin permissions
api/permission/{permissionName}        - Get permission
api/permission/{tenant}/{userName}     - User permissions

api/userTenant                         - Tenant assignments
api/userTenant/UserName/{userName}     - By username
api/userTenant/addOrDelete             - Add/remove tenant
api/userTenant/setDefault              - Set default tenant
api/userTenant/tenantList/{adminToken} - List tenants
api/userTenant/tenantListIn/{adminToken}/{userName} - User's tenants
api/userTenant/tenantListNotIn/{adminToken}/{userName} - Available tenants
api/userTenant/tenantName/{tenant}     - Get tenant name
api/userTenant/updateToActive          - Activate user-tenant
api/userTenant/updateToInActive        - Deactivate user-tenant
api/userTenant/userNameListBy/{tenant} - Users by tenant
api/userTenant/{userTenantId}          - Get/update/delete assignment
```

#### 8.6 Reporting & Analytics (7 routes)
```
api/report                             - Create/list reports
api/report/search                      - Search reports
api/report/Connection                  - Report connection
api/report/pdf                         - Generate PDF report
api/report/web                         - Web report viewer
api/report/{id}                        - Get/update/delete report

api/financialreport/BS/                - Balance Sheet report
api/financialreport/PL/                - P&L report
api/financialreport/reportlist/        - List financial reports
api/financialreport/setting/{id}       - Report settings
```

#### 8.7 System Configuration (30+ routes)
```
api/setting/all                        - All system settings
api/setting/closePeriod                - Period close settings
api/settingAp                          - AP settings
api/settingAr                          - AR settings
api/settingAsset                       - Asset settings
api/settingGl                          - GL settings
api/settingIncome                      - Income settings
api/settingPolicy                      - Policy settings
api/settingSystem                      - System settings
api/settingBudgetXls                   - Budget Excel template

api/gblParams                          - Global parameters
api/gblParams/search                   - Search parameters
api/gblParams/{section}/{key}          - Get/set parameter

api/budget                             - Budget management
api/budget/search                      - Search budgets
api/budget/addBatch                    - Bulk budget import
api/budget/{id}                        - Get/update/delete budget

api/paymentType                        - Payment types
api/paymentType/search                 - Search payment types
api/paymentType/{id}                   - Get/update/delete type

api/country                            - Country master
api/country/search                     - Search countries
api/country/{id}                       - Get/update/delete country

api/unit                               - Unit of measure
api/unit/search                        - Search units
api/unit/{id}                          - Get/update/delete unit
```

#### 8.8 Database & System Utilities (15+ routes)
```
api/database/connectionString/admin    - Admin DB connection
api/database/connectionString/carmen   - Carmen DB connection
api/database/showTable/{tableName}     - Show table structure

api/dataDic                            - Data dictionary
api/dataDic/{dataDicName}              - Get data dictionary entry

api/callStoreProc                      - Execute stored procedure
api/callStoreProc/ds                   - Execute SP with dataset
api/callStoreProc/ds/{*spName}         - Execute SP by name
api/callStoreProc/dsH                  - Execute SP with headers
api/callStoreProc/dsH/{*spName}        - Execute SP by name with headers
api/callStoreProc/{*sql}               - Execute raw SQL

api/storedProc                         - Manage stored procedures
api/storedProc/search                  - Search procedures
api/storedProc/resync                  - Resync procedures
api/storedProc/{id}                    - Get/update/delete procedure

api/migrate/admin                      - Migrate admin DB
api/migrate/carmen                     - Migrate Carmen DB
api/migrate/backupAdmin                - Backup admin DB
api/migrate/backupCarmen               - Backup Carmen DB
api/migrate/fixAssetHistory            - Fix asset history data

api/setup/createBlankDB                - Create blank database
api/setup/createCompany                - Create new company
api/setup/createOrUpdate/admin         - Setup admin DB
api/setup/createOrUpdate/carmen        - Setup Carmen DB
api/setup/createOrUpdate/backOffice    - Setup back office
api/setup/createOrUpdate/carmenAndBackoffice - Setup both
api/setup/ImportPreConfig              - Import configuration
api/setup/initialPeriod                - Initialize periods
api/setup/adminInfo                    - Get admin info
```

#### 8.9 Tenant & Multi-Tenancy (5 routes)
```
api/tenant                             - Create/list tenants
api/tenant/search                      - Search tenants
api/tenant/adminToken/{adminToken}     - Get tenant by admin token
api/tenant/{tenant}                    - Get/update/delete tenant

api/Headquarter/HqList/{adminToken}    - List headquarters
```

#### 8.10 Comments & Attachments (5 routes)
```
api/comment                            - Create comment
api/comment/{module}/{moduleId}        - Get comments by module
api/comment/download/{id}              - Download attachment
api/comment/{id}                       - Get/update/delete comment
```

#### 8.11 License & Plugins (10 routes)
```
api/license/                           - Get license info
api/licenseInfo/                       - Get detailed license info

api/licenseInterface                   - License interface
api/licenseInterface/license           - Get license
api/licenseInterface/interfaceList/{licenseType} - Interface list
api/licenseInterface/activeModule/     - Active modules
api/licenseInterface/activeModule/{licenseType} - Modules by type
api/licenseInterface/batch             - Bulk license operations
api/licenseInterface/updatelicense/    - Update license
api/licenseInterface/{id}              - Get/update/delete
api/licenseInterface/{showError}       - Show errors

api/interface/addlicense               - Add license
api/interface/updatelicense            - Update license

api/plugins                            - Plugin management
```

#### 8.12 Lookup & Enums (40+ routes)
```
api/lookup/currency/                   - Currency lookup
api/lookup/lastModified/{lookupType}   - Last modified
api/lookup/{lookupType}                - Get lookup data

api/enum/EnumAccountNature             - Account nature enum
api/enum/EnumAccountType               - Account type enum
api/enum/EnumActionMode                - Action mode enum
api/enum/EnumAddOrDelete               - Add/delete enum
api/enum/EnumAndOr                     - And/Or operator enum
api/enum/EnumApAgingPeriodDateBy       - AP aging enum
api/enum/EnumApInvoiceStatus           - AP invoice status
api/enum/EnumApPaymentPostingBy        - AP payment posting
api/enum/EnumApPaymentStatus           - AP payment status
api/enum/EnumApTaxStatus               - AP tax status
api/enum/EnumAssetAutoIdFormat         - Asset ID format
api/enum/EnumAssetDeleteHisAt          - Asset delete history
api/enum/EnumConnectionProvider        - Connection provider
api/enum/EnumDimensionType             - Dimension type
api/enum/EnumDisposalAtDate            - Disposal date
api/enum/EnumDisposalType              - Disposal type
api/enum/EnumFieldType                 - Field type
api/enum/EnumGlCrOrDr                  - Debit/Credit
api/enum/EnumGlPeriodStatus            - Period status
api/enum/EnumGlStandardType            - Standard type
api/enum/EnumGlStatus                  - GL status
api/enum/EnumIncomeStatus              - Income status
api/enum/EnumLicenseType               - License type
api/enum/EnumLogAction                 - Log action
api/enum/EnumLookup                    - Lookup type
api/enum/EnumModule                    - Module enum
api/enum/EnumNavigate                  - Navigation enum
api/enum/EnumShowWithholdingTaxAt      - WHT display
api/enum/EnumTaxType                   - Tax type
api/enum/EnumVatSource                 - VAT source
api/enum/EnumWhtSource                 - WHT source
api/enum/EnumWorkflowModule            - Workflow module
```

#### 8.13 Process Logging (2 routes)
```
api/processLog                         - Create/list process logs
api/processLog/search                  - Search process logs
```

#### 8.14 System Info & Version (7 routes)
```
api/systemInfo/                        - Get system information

api/version                            - Get version info
api/version/Compare/{serverVersion}/{clientVersion} - Compare versions
api/version/History                    - Version history
api/version/compareServer/{version}    - Compare server version

api/token/{jwtToken}                   - Validate JWT token
```

#### 8.15 Home & Updater (8 routes)
```
Home/index                             - Home page
Home/swagger                           - Swagger documentation
Home/download                          - Download installer
Home/DownloadExcelReg32                - Download Excel add-in (32-bit)
Home/DownloadExcelReg64                - Download Excel add-in (64-bit)
Home/DownloadReg                       - Download registry

Updater/Changelog                      - Application changelog
Updater/ChangelogAddIn                 - Add-in changelog
Updater/Versions                       - Application versions
Updater/VersionsAddIn                  - Add-in versions
Updater/update                         - Update application
Updater/updateAddIn32                  - Update add-in (32-bit)
Updater/updateAddIn64                  - Update add-in (64-bit)
Updater/appExe                         - Application executable
Updater/appAddIn32                     - Add-in (32-bit)
Updater/appAddIn64                     - Add-in (64-bit)
```

#### 8.16 Support & Admin (3 routes)
```
api/supportLogin                       - Support login
api/supportLogin/captha/{adminToken}   - Get captcha
api/supportLogin/{adminToken}          - Login with admin token
```

---

## Summary by Category

### Feature Categories

| Category | Routes | % of Total |
|----------|--------|------------|
| **Core Transactions** | 120 | 28% |
| - AP Invoices & Payments | 33 | 8% |
| - AR Invoices & Receipts | 52 | 12% |
| - GL Journal Vouchers | 35 | 8% |
| **Master Data** | 85 | 20% |
| - Vendors & Customers | 15 | 3% |
| - Chart of Accounts | 4 | 1% |
| - Currencies & Exchange | 9 | 2% |
| - Departments & Dimensions | 8 | 2% |
| - Other Master Data | 49 | 11% |
| **Asset Management** | 26 | 6% |
| **Tax & Compliance** | 31 | 7% |
| - Thailand WHT | 15 | 3% |
| - VAT Reconciliation | 8 | 2% |
| - Tax Profiles | 8 | 2% |
| **Income/Revenue** | 23 | 5% |
| **Bank Reconciliation** | 6 | 1% |
| **System Administration** | 70 | 16% |
| - User & Permissions | 20 | 5% |
| - Settings & Configuration | 30 | 7% |
| - Database & Migration | 15 | 3% |
| - Licensing | 5 | 1% |
| **Reporting** | 10 | 2% |
| **Workflow Engine** | 7 | 2% |
| **Utilities & Support** | 51 | 12% |
| - Enums & Lookups | 35 | 8% |
| - Versioning & Updates | 8 | 2% |
| - Support & Admin | 8 | 2% |
| **TOTAL** | **429** | **99.1%** |

---

## Critical Observations

### 1. **Complete Module Blackout**
Every functional module (AP, AR, GL, Asset, Income, Tax, Bank) has 0% API documentation except for 4 authentication endpoints.

### 2. **High-Value Undocumented Features**
- **Workflow Engine**: 7-step approval workflow system completely undocumented
- **Multi-Currency**: 12 routes for currency and exchange rate management
- **Tax Compliance**: Thailand-specific WHT and VAT systems (critical for compliance)
- **Asset Management**: Full fixed asset lifecycle (acquisition to disposal)
- **Multi-Tenancy**: Sophisticated tenant isolation and management

### 3. **Integration Endpoints**
- **HMS/PMS Integration**: Income module with hospitality-specific features (folios, owners)
- **Excel Add-In**: Download and update endpoints for Office integration
- **Bank Import**: Electronic bank statement processing
- **Stored Procedures**: Direct database procedure execution

### 4. **Business-Critical Procedures**
- Period closing procedures for all modules (AP, AR, GL, Asset, Income)
- Cross-module posting (AP→GL, AR→GL, Asset→GL)
- Data migration and database setup utilities
- Backup and restore functionality

---

## Recommendations

### Immediate Actions (Week 1)

1. **Acknowledge Documentation Debt**
   - Update api-reference.md to remove false "351 endpoints" claim
   - Add clear note: "API documentation is currently incomplete"
   - Link to this gap analysis report

2. **Prioritize Core Modules**
   - Document authentication endpoints (already done ✅)
   - Document AP Invoice & Payment (12 routes)
   - Document AR Invoice & Receipt (18 routes)
   - Document GL Journal Vouchers (9 routes)

### Short-Term Plan (Month 1)

3. **Document Critical Features**
   - Tax & Compliance endpoints (31 routes) - regulatory requirement
   - User & Permission management (20 routes) - security requirement
   - Master data endpoints (85 routes) - foundation for all operations

### Long-Term Plan (Quarter 1)

4. **Complete Documentation**
   - Asset Management (26 routes)
   - Income Module (23 routes)
   - Bank Reconciliation (6 routes)
   - System utilities (51 routes)
   - Workflow engine (7 routes)

5. **Establish Documentation Standards**
   - API specification format (OpenAPI/Swagger)
   - Request/response examples
   - Business logic documentation
   - Error handling documentation

---

## Next Steps

1. ✅ **Phase 3.1 Complete**: Undocumented features identified (429 routes)
2. 🔄 **Phase 3.2**: Compile fictional content report
3. 🔄 **Phase 3.3**: Calculate documentation coverage metrics
4. 🔄 **Phase 3.4**: Categorize issues by severity
5. 🔄 **Phase 3.5**: Create correction priority matrix

---

**Report Status**: Complete
**Next Phase**: Step 3.2 - Fictional Content Compilation
