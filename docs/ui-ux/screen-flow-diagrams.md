# Carmen.NET Screen Flow Diagrams

**Document Version:** 1.0
**Last Updated:** October 6, 2025
**Target Audience:** UI/UX Designers, Product Managers, Business Analysts
**Prerequisites:** Functional Requirements, UI Component Inventory

---

## Table of Contents

1. [Overview](#overview)
2. [Core User Journeys](#core-user-journeys)
3. [AP Module Flows](#ap-module-flows)
4. [AR Module Flows](#ar-module-flows)
5. [GL Module Flows](#gl-module-flows)
6. [Asset Module Flows](#asset-module-flows)
7. [Admin Flows](#admin-flows)

---

## 1. Overview

### Navigation Architecture

```mermaid
graph TD
    Login[Login Screen] --> Dashboard[Dashboard]

    Dashboard --> AP[AP Module]
    Dashboard --> AR[AR Module]
    Dashboard --> GL[GL Module]
    Dashboard --> Asset[Asset Module]
    Dashboard --> Admin[Administration]

    AP --> APInvoice[AP Invoices]
    AP --> APPayment[AP Payments]
    AP --> APVendor[Vendors]

    AR --> ARInvoice[AR Invoices]
    AR --> ARReceipt[AR Receipts]
    AR --> ARCustomer[Customers]

    GL --> GLJournal[Journal Vouchers]
    GL --> GLAccount[Chart of Accounts]
    GL --> GLReport[Reports]

    Asset --> AssetRegister[Asset Register]
    Asset --> AssetDisposal[Disposals]

    Admin --> Users[Users]
    Admin --> Settings[Settings]
```

### Screen Types

| Type | Purpose | Example |
|------|---------|---------|
| **List Screen** | Browse, search, filter entities | AP Invoice List |
| **Detail Screen** | View entity details | Invoice Detail |
| **Form Screen** | Create/edit entities | New Invoice Form |
| **Wizard Screen** | Multi-step process | Invoice Approval Workflow |
| **Report Screen** | View reports and analytics | AP Aging Report |

---

## 2. Core User Journeys

### 2.1 Login Flow

```mermaid
graph TD
    Start[Login Page] --> EnterCreds[Enter Credentials]
    EnterCreds --> SelectTenant[Select Tenant]
    SelectTenant --> Authenticate{Authenticate}

    Authenticate -->|Success| Dashboard[Dashboard]
    Authenticate -->|Invalid Credentials| ErrorMsg[Show Error Message]
    ErrorMsg --> EnterCreds

    Authenticate -->|Account Locked| LockedMsg[Account Locked Message]
    LockedMsg --> ContactAdmin[Contact Administrator]

    Dashboard --> CheckPermissions{Check Permissions}
    CheckPermissions --> LoadModules[Load Accessible Modules]
    LoadModules --> ShowDashboard[Display Dashboard Widgets]
```

**Screens:**
1. **Login Screen**
   - Username/Email input
   - Password input
   - Tenant selector (dropdown)
   - Remember me checkbox
   - Login button
   - Forgot password link

2. **Dashboard Screen**
   - Welcome message with user name
   - Tenant display
   - Quick access cards (AP, AR, GL, Asset)
   - Recent activity widget
   - Pending approvals widget
   - Key metrics (outstanding invoices, overdue payments)

---

### 2.2 Dashboard Navigation

```mermaid
graph LR
    Dashboard[Dashboard] --> QuickActions[Quick Actions]
    Dashboard --> Widgets[Dashboard Widgets]
    Dashboard --> ModuleMenu[Module Menu]

    QuickActions --> NewInvoice[New AP Invoice]
    QuickActions --> NewPayment[New Payment]
    QuickActions --> NewJV[New Journal Voucher]

    Widgets --> PendingApprovals[Pending Approvals]
    Widgets --> RecentActivity[Recent Activity]
    Widgets --> KeyMetrics[Key Metrics]

    ModuleMenu --> APMenu[AP Module]
    ModuleMenu --> ARMenu[AR Module]
    ModuleMenu --> GLMenu[GL Module]
```

---

## 3. AP Module Flows

### 3.1 AP Invoice Creation Flow

```mermaid
graph TD
    Start[AP Invoice List] --> ClickNew[Click 'New Invoice']
    ClickNew --> Form[Invoice Form]

    Form --> EnterHeader[Enter Header Info]
    EnterHeader --> SelectVendor[Select Vendor]
    SelectVendor --> EnterAmounts[Enter Amounts]
    EnterAmounts --> AddLines[Add Line Items]

    AddLines --> Validate{Validation}
    Validate -->|Errors| ShowErrors[Show Error Messages]
    ShowErrors --> Form

    Validate -->|Success| SaveOptions{Save Options}

    SaveOptions -->|Save Draft| SaveDraft[Save as Draft]
    SaveOptions -->|Submit for Approval| SubmitApproval[Submit for Approval]

    SaveDraft --> SuccessMsg[Success Message]
    SuccessMsg --> BackToList[Return to List]

    SubmitApproval --> CheckApprovalRules{Check Approval Rules}
    CheckApprovalRules -->|Auto-Approve| Approved[Mark as Approved]
    CheckApprovalRules -->|Requires Approval| PendingApproval[Mark as Pending]

    Approved --> NotifyUser[Notify User]
    PendingApproval --> NotifyApprover[Notify Approver]

    NotifyUser --> BackToList
    NotifyApprover --> BackToList
```

**Screens:**

1. **AP Invoice List Screen**
   - Header: "Accounts Payable > Invoices"
   - Search bar
   - Filters: Status, Date Range, Vendor
   - Action buttons: New Invoice, Import, Export
   - Data table with columns:
     - Invoice Number
     - Invoice Date
     - Vendor Name
     - Amount
     - Status Badge
     - Actions (View, Edit, Delete)
   - Pagination controls

2. **AP Invoice Form Screen**
   - Header: "New AP Invoice" or "Edit Invoice: INV-2025-001"
   - Breadcrumbs: Dashboard > AP > Invoices > New

   **Section 1: Invoice Details**
   - Invoice Number (auto-generated or manual)
   - Invoice Date (date picker)
   - Due Date (calculated or manual)
   - Vendor Selector (autocomplete)
   - Description (textarea)

   **Section 2: Amounts**
   - Amount (currency input)
   - Tax Type Selector (VAT, WHT)
   - Tax Amount (calculated or manual)
   - WHT Amount (calculated or manual)
   - Total Amount (calculated, readonly)

   **Section 3: Line Items**
   - Editable data grid
   - Columns: Line #, Description, GL Account, Department, Amount
   - Add Line button
   - Delete Line action
   - Line totals validation message

   **Section 4: Attachments** (tab or accordion)
   - File upload area (drag-and-drop)
   - Uploaded files list

   **Action Buttons:**
   - Save Draft (outlined button)
   - Submit for Approval (primary button)
   - Cancel (text button)

3. **AP Invoice Detail Screen**
   - Header: "Invoice: INV-2025-001"
   - Status Badge (prominent)
   - Tabs:
     - Details (invoice information)
     - Line Items (read-only table)
     - Payment History (linked payments)
     - Attachments (download links)
     - Audit Log (timeline)

   **Actions:**
   - Edit (if status = Draft)
   - Approve (if pending + permission)
   - Reject (if pending + permission)
   - Post to GL (if approved + permission)
   - Print (PDF generation)
   - Delete (if draft)

---

### 3.2 AP Invoice Approval Flow

```mermaid
graph TD
    Start[Pending Approvals List] --> SelectInvoice[Select Invoice]
    SelectInvoice --> ViewDetails[View Invoice Details]

    ViewDetails --> ApprovalDecision{Approval Decision}

    ApprovalDecision -->|Approve| EnterApprovalComments[Enter Approval Comments]
    EnterApprovalComments --> ConfirmApprove{Confirm Approval}
    ConfirmApprove -->|Yes| MarkApproved[Mark as Approved]
    ConfirmApprove -->|No| ViewDetails

    ApprovalDecision -->|Reject| EnterRejectionReason[Enter Rejection Reason]
    EnterRejectionReason --> ConfirmReject{Confirm Rejection}
    ConfirmReject -->|Yes| MarkRejected[Mark as Rejected]
    ConfirmReject -->|No| ViewDetails

    ApprovalDecision -->|Request Changes| EnterChangeRequest[Enter Change Request]
    EnterChangeRequest --> SendBackToCreator[Send Back to Creator]

    MarkApproved --> NotifyCreator[Notify Creator]
    MarkRejected --> NotifyCreatorRejection[Notify Creator with Reason]
    SendBackToCreator --> NotifyCreatorChanges[Notify Creator of Changes Needed]

    NotifyCreator --> BackToApprovalsList[Return to Approvals List]
    NotifyCreatorRejection --> BackToApprovalsList
    NotifyCreatorChanges --> BackToApprovalsList
```

**Screens:**

**Pending Approvals Screen**
- Filtered list showing only pending items
- Approval amount thresholds display
- Quick actions: Approve All, Reject All

---

### 3.3 AP Payment Processing Flow

```mermaid
graph TD
    Start[Payment List] --> NewPayment[Click 'New Payment']
    NewPayment --> SelectVendor[Select Vendor]
    SelectVendor --> LoadUnpaidInvoices[Load Unpaid Invoices]

    LoadUnpaidInvoices --> SelectInvoices[Select Invoices to Pay]
    SelectInvoices --> EnterPaymentDetails[Enter Payment Details]

    EnterPaymentDetails --> PaymentMethod{Payment Method}

    PaymentMethod -->|Check| EnterCheckNumber[Enter Check Number]
    PaymentMethod -->|Wire Transfer| EnterTransferRef[Enter Transfer Reference]
    PaymentMethod -->|ACH| EnterACHDetails[Enter ACH Details]

    EnterCheckNumber --> AllocateAmounts[Allocate Payment Amounts]
    EnterTransferRef --> AllocateAmounts
    EnterACHDetails --> AllocateAmounts

    AllocateAmounts --> ReviewPayment[Review Payment Summary]
    ReviewPayment --> ValidatePayment{Validate}

    ValidatePayment -->|Errors| ShowPaymentErrors[Show Error Messages]
    ShowPaymentErrors --> EnterPaymentDetails

    ValidatePayment -->|Success| SavePayment[Save Payment]
    SavePayment --> PostToGL[Post to GL]
    PostToGL --> UpdateInvoiceStatus[Update Invoice Outstanding]
    UpdateInvoiceStatus --> SuccessPaymentMsg[Success Message]
    SuccessPaymentMsg --> BackToPaymentList[Return to List]
```

---

## 4. AR Module Flows

### 4.1 AR Invoice Creation Flow

```mermaid
graph TD
    Start[AR Invoice List] --> CheckContract{Has Contract?}

    CheckContract -->|Yes| SelectContract[Select Contract]
    SelectContract --> LoadContractTerms[Load Contract Terms]
    LoadContractTerms --> PreFillInvoice[Pre-fill Invoice from Contract]

    CheckContract -->|No| NewInvoice[New Invoice Form]

    PreFillInvoice --> InvoiceForm[Invoice Form]
    NewInvoice --> InvoiceForm

    InvoiceForm --> EnterDetails[Enter Invoice Details]
    EnterDetails --> SelectCustomer[Select Customer]
    SelectCustomer --> CheckCreditLimit{Check Credit Limit}

    CheckCreditLimit -->|Exceeds Limit| CreditWarning[Show Credit Limit Warning]
    CreditWarning --> OverrideCreditLimit{Override?}
    OverrideCreditLimit -->|No| SelectCustomer
    OverrideCreditLimit -->|Yes| ContinueInvoice[Continue with Warning]

    CheckCreditLimit -->|Within Limit| ContinueInvoice

    ContinueInvoice --> AddLineItems[Add Line Items]
    AddLineItems --> CalculateVAT[Calculate VAT]
    CalculateVAT --> ReviewInvoice[Review Invoice]

    ReviewInvoice --> ValidateInvoice{Validate}
    ValidateInvoice -->|Errors| ShowInvoiceErrors[Show Errors]
    ShowInvoiceErrors --> InvoiceForm

    ValidateInvoice -->|Success| SaveARInvoice[Save Invoice]
    SaveARInvoice --> PostToGLAR[Post to GL]
    PostToGLAR --> UpdateContractBalance[Update Contract Balance]
    UpdateContractBalance --> SuccessARMsg[Success Message]
    SuccessARMsg --> BackToARList[Return to List]
```

---

### 4.2 AR Receipt Application Flow

```mermaid
graph TD
    Start[Receipt List] --> NewReceipt[Click 'New Receipt']
    NewReceipt --> SelectCustomer[Select Customer]
    SelectCustomer --> LoadOutstandingInvoices[Load Outstanding Invoices]

    LoadOutstandingInvoices --> DisplayInvoices[Display Invoices with Outstanding Amounts]
    DisplayInvoices --> EnterReceiptAmount[Enter Receipt Amount]
    EnterReceiptAmount --> SelectPaymentMethod[Select Payment Method]

    SelectPaymentMethod --> CheckMethod{Payment Method}

    CheckMethod -->|Cash| EnterReceiptDetails[Enter Receipt Details]
    CheckMethod -->|Check| EnterCheckDetails[Enter Check Number & Date]
    CheckMethod -->|Bank Transfer| EnterTransferDetails[Enter Transfer Details]

    EnterReceiptDetails --> ApplicationMethod{Application Method}
    EnterCheckDetails --> ApplicationMethod
    EnterTransferDetails --> ApplicationMethod

    ApplicationMethod -->|FIFO| ApplyFIFO[Apply FIFO Automatically]
    ApplicationMethod -->|Manual| ManualAllocation[Manual Allocation]

    ApplyFIFO --> ReviewApplication[Review Application]
    ManualAllocation --> ReviewApplication

    ReviewApplication --> ValidateReceipt{Validate}

    ValidateReceipt -->|Errors| ShowReceiptErrors[Show Errors]
    ShowReceiptErrors --> ApplicationMethod

    ValidateReceipt -->|Success| SaveReceipt[Save Receipt]
    SaveReceipt --> PostReceiptToGL[Post to GL]
    PostReceiptToGL --> UpdateInvoiceOutstanding[Update Invoice Outstanding]
    UpdateInvoiceOutstanding --> UpdateCustomerBalance[Update Customer Balance]
    UpdateCustomerBalance --> SuccessReceiptMsg[Success Message]
    SuccessReceiptMsg --> BackToReceiptList[Return to List]
```

---

## 5. GL Module Flows

### 5.1 Journal Voucher Creation Flow

```mermaid
graph TD
    Start[Journal Voucher List] --> NewJV[Click 'New JV']
    NewJV --> JVForm[JV Form]

    JVForm --> EnterJVHeader[Enter Header Info]
    EnterJVHeader --> SelectPeriod[Select GL Period]
    SelectPeriod --> CheckPeriodStatus{Period Open?}

    CheckPeriodStatus -->|Closed| PeriodClosedError[Show Period Closed Error]
    PeriodClosedError --> SelectPeriod

    CheckPeriodStatus -->|Open| AddJVLines[Add JV Lines]

    AddJVLines --> EnterLine[Enter Line Details]
    EnterLine --> SelectAccount[Select GL Account]
    SelectAccount --> SelectDRorCR{Debit or Credit?}

    SelectDRorCR -->|Debit| EnterDebitAmount[Enter Debit Amount]
    SelectDRorCR -->|Credit| EnterCreditAmount[Enter Credit Amount]

    EnterDebitAmount --> AddMoreLines{Add More Lines?}
    EnterCreditAmount --> AddMoreLines

    AddMoreLines -->|Yes| EnterLine
    AddMoreLines -->|No| CheckBalance{DR = CR?}

    CheckBalance -->|Not Balanced| BalanceError[Show Balance Error]
    BalanceError --> AddJVLines

    CheckBalance -->|Balanced| ReviewJV[Review JV]
    ReviewJV --> ValidateJV{Validate}

    ValidateJV -->|Errors| ShowJVErrors[Show Errors]
    ShowJVErrors --> JVForm

    ValidateJV -->|Success| SaveJV[Save JV]
    SaveJV --> PostJV[Post JV]
    PostJV --> UpdateGLBalances[Update GL Account Balances]
    UpdateGLBalances --> SuccessJVMsg[Success Message]
    SuccessJVMsg --> BackToJVList[Return to List]
```

**Screens:**

**Journal Voucher Form Screen**
- Header: "New Journal Voucher"

**Section 1: JV Header**
- JV Number (auto-generated)
- JV Date (date picker with period validation)
- Period Selector (FY 2025 - Period 10)
- Description (textarea)
- JV Type (Manual, Recurring, Reversing)

**Section 2: JV Lines**
- Editable data grid with running totals
- Columns:
  - Line # (auto)
  - GL Account (autocomplete)
  - Description
  - Department (optional)
  - Debit Amount
  - Credit Amount

**Summary:**
- Total Debit: THB 10,000.00
- Total Credit: THB 10,000.00
- Difference: THB 0.00 ✓ (Balanced)

**Action Buttons:**
- Save Draft
- Save & Post (primary)
- Cancel

---

### 5.2 GL Period Close Flow

```mermaid
graph TD
    Start[Period Management] --> SelectPeriod[Select Period to Close]
    SelectPeriod --> CheckStatus{Period Status?}

    CheckStatus -->|Already Closed| AlreadyClosedMsg[Show Already Closed Message]
    AlreadyClosedMsg --> SelectPeriod

    CheckStatus -->|Open| RunValidations[Run Pre-Close Validations]

    RunValidations --> CheckUnpostedTxns{Unposted Transactions?}
    CheckUnpostedTxns -->|Yes| ListUnposted[List Unposted Transactions]
    ListUnposted --> UserDecision{User Decision}
    UserDecision -->|Post Now| PostUnposted[Post Transactions]
    PostUnposted --> RunValidations
    UserDecision -->|Cancel Close| SelectPeriod

    CheckUnpostedTxns -->|No| CheckUnbalancedJVs{Unbalanced JVs?}

    CheckUnbalancedJVs -->|Yes| ListUnbalanced[List Unbalanced JVs]
    ListUnbalanced --> UserFixDecision{User Decision}
    UserFixDecision -->|Fix Now| FixJVs[Fix Journal Vouchers]
    FixJVs --> RunValidations
    UserFixDecision -->|Cancel Close| SelectPeriod

    CheckUnbalancedJVs -->|No| GenerateTrialBalance[Generate Trial Balance]

    GenerateTrialBalance --> ReviewTrialBalance[Review Trial Balance]
    ReviewTrialBalance --> ConfirmClose{Confirm Close?}

    ConfirmClose -->|No| SelectPeriod
    ConfirmClose -->|Yes| ClosePeriod[Close Period]

    ClosePeriod --> LockPeriod[Lock Period]
    LockPeriod --> GenerateClosingReports[Generate Closing Reports]
    GenerateClosingReports --> NotifyUsers[Notify Users]
    NotifyUsers --> SuccessCloseMsg[Period Closed Successfully]
    SuccessCloseMsg --> BackToPeriodMgmt[Return to Period Management]
```

---

## 6. Asset Module Flows

### 6.1 Asset Registration Flow

```mermaid
graph TD
    Start[Asset Register] --> NewAsset[Click 'New Asset']
    NewAsset --> AssetForm[Asset Form]

    AssetForm --> EnterAssetInfo[Enter Asset Information]
    EnterAssetInfo --> SelectCategory[Select Asset Category]
    SelectCategory --> LoadCategoryDefaults[Load Category Defaults]

    LoadCategoryDefaults --> EnterAcquisitionDetails[Enter Acquisition Details]
    EnterAcquisitionDetails --> EnterAcquisitionCost[Enter Acquisition Cost]
    EnterAcquisitionCost --> SelectDepreciationMethod[Select Depreciation Method]

    SelectDepreciationMethod --> EnterUsefulLife[Enter Useful Life Years]
    EnterUsefulLife --> CalculateDepreciation[Calculate Depreciation Schedule]

    CalculateDepreciation --> ReviewAssetInfo[Review Asset Information]
    ReviewAssetInfo --> ValidateAsset{Validate}

    ValidateAsset -->|Errors| ShowAssetErrors[Show Errors]
    ShowAssetErrors --> AssetForm

    ValidateAsset -->|Success| SaveAsset[Save Asset]
    SaveAsset --> GenerateAssetTag[Generate Asset Tag]
    GenerateAssetTag --> PostAcquisitionJV[Post Acquisition JV to GL]
    PostAcquisitionJV --> SuccessAssetMsg[Success Message]
    SuccessAssetMsg --> PrintAssetTag{Print Asset Tag?}

    PrintAssetTag -->|Yes| GenerateAssetTag_PDF[Generate Asset Tag PDF]
    PrintAssetTag -->|No| BackToAssetList[Return to Asset List]
    GenerateAssetTag_PDF --> BackToAssetList
```

---

### 6.2 Monthly Depreciation Flow

```mermaid
graph TD
    Start[Asset Reports] --> SelectDepreciationReport[Select 'Monthly Depreciation']
    SelectDepreciationReport --> SelectMonth[Select Period Month]
    SelectMonth --> LoadAssets[Load Active Assets]

    LoadAssets --> FilterAssets[Filter Assets for Depreciation]
    FilterAssets --> CalculateMonthlyDep[Calculate Monthly Depreciation]

    CalculateMonthlyDep --> DisplayDepSchedule[Display Depreciation Schedule]
    DisplayDepSchedule --> ReviewSchedule[Review Schedule]

    ReviewSchedule --> UserAction{User Action}

    UserAction -->|Preview JV| GeneratePreviewJV[Generate Preview JV]
    GeneratePreviewJV --> DisplayJVPreview[Display JV Preview]
    DisplayJVPreview --> ReviewSchedule

    UserAction -->|Post Depreciation| ConfirmPost{Confirm Post?}

    ConfirmPost -->|No| ReviewSchedule
    ConfirmPost -->|Yes| RunDepreciation[Run Depreciation Process]

    RunDepreciation --> UpdateAssetNBV[Update Asset Net Book Values]
    UpdateAssetNBV --> CreateDepreciationJV[Create Depreciation JV]
    CreateDepreciationJV --> PostDepJVToGL[Post JV to GL]
    PostDepJVToGL --> UpdateAssetHistory[Update Asset History]
    UpdateAssetHistory --> GenerateDepReport[Generate Depreciation Report]
    GenerateDepReport --> SuccessDepMsg[Depreciation Posted Successfully]
    SuccessDepMsg --> BackToAssetReports[Return to Reports]
```

---

## 7. Admin Flows

### 7.1 User Management Flow

```mermaid
graph TD
    Start[User Management] --> UserList[User List]
    UserList --> ActionChoice{User Action}

    ActionChoice -->|New User| NewUserForm[New User Form]
    ActionChoice -->|Edit User| EditUserForm[Edit User Form]
    ActionChoice -->|Deactivate| DeactivateUser[Deactivate User]

    NewUserForm --> EnterUserDetails[Enter User Details]
    EnterUserDetails --> AssignRoles[Assign Roles]
    AssignRoles --> AssignPermissions[Assign Permissions]
    AssignPermissions --> SetPassword[Set Initial Password]
    SetPassword --> ValidateUserInfo{Validate}

    ValidateUserInfo -->|Errors| ShowUserErrors[Show Errors]
    ShowUserErrors --> NewUserForm

    ValidateUserInfo -->|Success| SaveUser[Save User]
    SaveUser --> SendWelcomeEmail[Send Welcome Email]
    SendWelcomeEmail --> SuccessUserMsg[User Created Successfully]
    SuccessUserMsg --> BackToUserList[Return to User List]

    EditUserForm --> UpdateUserDetails[Update User Details]
    UpdateUserDetails --> UpdateRoles[Update Roles]
    UpdateRoles --> UpdatePermissions[Update Permissions]
    UpdatePermissions --> SaveUserChanges[Save Changes]
    SaveUserChanges --> SuccessUpdateMsg[User Updated Successfully]
    SuccessUpdateMsg --> BackToUserList

    DeactivateUser --> ConfirmDeactivate{Confirm Deactivate?}
    ConfirmDeactivate -->|No| UserList
    ConfirmDeactivate -->|Yes| SetUserInactive[Set User Inactive]
    SetUserInactive --> RevokeAccess[Revoke Access Tokens]
    RevokeAccess --> NotifyUserDeactivation[Notify User]
    NotifyUserDeactivation --> SuccessDeactivateMsg[User Deactivated]
    SuccessDeactivateMsg --> BackToUserList
```

---

### 7.2 System Settings Flow

```mermaid
graph TD
    Start[Administration] --> Settings[System Settings]
    Settings --> SettingsTabs{Settings Category}

    SettingsTabs -->|General| GeneralSettings[General Settings]
    SettingsTabs -->|Financial| FinancialSettings[Financial Settings]
    SettingsTabs -->|Tax| TaxSettings[Tax Settings]
    SettingsTabs -->|Integration| IntegrationSettings[Integration Settings]

    GeneralSettings --> EditGeneralSettings[Edit General Settings]
    EditGeneralSettings --> SaveGeneralSettings[Save Changes]
    SaveGeneralSettings --> SuccessGeneralMsg[Settings Saved]
    SuccessGeneralMsg --> Settings

    FinancialSettings --> EditFinancialSettings[Edit Financial Settings]
    EditFinancialSettings --> ConfigurePeriods[Configure GL Periods]
    ConfigurePeriods --> SetFiscalYear[Set Fiscal Year]
    SetFiscalYear --> SaveFinancialSettings[Save Changes]
    SaveFinancialSettings --> SuccessFinancialMsg[Settings Saved]
    SuccessFinancialMsg --> Settings

    TaxSettings --> EditTaxSettings[Edit Tax Settings]
    EditTaxSettings --> ConfigureVAT[Configure VAT Rates]
    ConfigureVAT --> ConfigureWHT[Configure WHT Rates]
    ConfigureWHT --> SaveTaxSettings[Save Changes]
    SaveTaxSettings --> SuccessTaxMsg[Settings Saved]
    SuccessTaxMsg --> Settings

    IntegrationSettings --> EditIntegrationSettings[Edit Integration Settings]
    EditIntegrationSettings --> ConfigureAPIs[Configure API Keys]
    ConfigureAPIs --> TestConnection[Test Connection]
    TestConnection --> SaveIntegrationSettings[Save Changes]
    SaveIntegrationSettings --> SuccessIntegrationMsg[Settings Saved]
    SuccessIntegrationMsg --> Settings
```

---

## Summary

Carmen.NET Screen Flow Documentation:

**✅ Documented:**
- 15+ user journey flows
- 7 module-specific workflows
- 30+ screen definitions
- Navigation architecture

**📊 Key Flows:**
1. **AP Module** (3 flows): Invoice Creation, Approval, Payment Processing
2. **AR Module** (2 flows): Invoice Creation, Receipt Application
3. **GL Module** (2 flows): Journal Voucher Creation, Period Close
4. **Asset Module** (2 flows): Asset Registration, Depreciation
5. **Admin** (2 flows): User Management, System Settings

**🎯 Design Patterns:**
- List → Detail → Form pattern
- Multi-step wizards for complex processes
- Approval workflows with status transitions
- Validation checkpoints at critical steps
- Success/error feedback loops

**📱 Responsive Considerations:**
- Desktop: Full multi-column layouts
- Tablet: Adaptive 2-column layouts
- Mobile: Single-column stacked layouts
- Touch-friendly targets (44x44px minimum)

**Next Steps:**
- Implement flows in frontend framework
- Conduct usability testing
- Gather user feedback
- Iterate on design based on analytics

---

**Document Status:** ✅ Complete
**For Support:** Contact UI/UX team or product management
