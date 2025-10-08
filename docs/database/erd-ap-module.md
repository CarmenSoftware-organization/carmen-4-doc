# Accounts Payable (AP) Module - Entity Relationship Diagram

```mermaid
erDiagram
    %% Vendor Master
    VENDOR ||--o{ AP_INVOICE_H : "generates"
    VENDOR ||--o{ AP_PAYMENT : "receives payment"

    %% Invoice Relationships
    AP_INVOICE_H ||--|{ AP_INVOICE_D : "contains"
    AP_INVOICE_H ||--o{ AP_PAYMENT : "paid by"
    AP_INVOICE_H ||--o{ AP_WHT : "withholds tax"

    %% Purchase Order Flow
    AP_REQUISITION ||--o{ AP_PO_H : "creates"
    AP_PO_H ||--|{ AP_PO_D : "contains"
    AP_PO_H ||--o{ AP_RECEIVING : "received"
    AP_RECEIVING ||--o{ AP_INVOICE_H : "invoiced"

    %% GL Posting
    AP_INVOICE_H ||--o{ GL_JV_H : "posts to"
    AP_PAYMENT ||--o{ GL_JV_H : "posts to"

    %% Lookups
    ACCOUNT_CODE ||--o{ AP_INVOICE_D : "expense account"
    DEPARTMENT ||--o{ AP_INVOICE_H : "department"

    %% Entities
    VENDOR {
        bigint VnCode PK
        varchar VnName "Vendor Name"
        varchar VnNameEn "Vendor Name English"
        varchar VnTaxId "Tax ID"
        varchar VnAddress "Address"
        varchar VnPhone "Phone"
        varchar VnEmail "Email"
        varchar VnContactPerson "Contact Person"
        varchar VnPaymentTerms "Payment Terms"
        bit VnIsActive "Active Status"
        datetime CreatedDate "Created Date"
        bigint CreatedBy FK "Created By User"
        bigint TenantId FK "Tenant ID"
    }

    AP_INVOICE_H {
        bigint InvhId PK
        varchar InvhNo "Invoice Number"
        datetime InvhDate "Invoice Date"
        datetime InvhDueDate "Due Date"
        varchar VnCode FK "Vendor Code"
        varchar InvhInvNo "Vendor Invoice No"
        decimal InvhAmt "Invoice Amount"
        decimal InvhTaxAmt "Tax Amount"
        decimal InvhWhtAmt "WHT Amount"
        decimal InvhNetAmt "Net Amount"
        int InvhStatus "Status (0=Draft,1=Posted)"
        varchar InvhDesc "Description"
        varchar DeptCode FK "Department"
        varchar ProjectCode "Project Code"
        bigint TenantId FK "Tenant ID"
        datetime CreatedDate "Created Date"
        bigint CreatedBy FK "Created By"
    }

    AP_INVOICE_D {
        bigint InvdId PK
        bigint InvhId FK "Invoice Header ID"
        int InvdSeq "Line Sequence"
        varchar InvdDesc "Line Description"
        decimal InvdQty "Quantity"
        decimal InvdPrice "Unit Price"
        decimal InvdAmt "Line Amount"
        varchar AccCode FK "Account Code"
        varchar DeptCode FK "Department"
        varchar ProjectCode "Project"
    }

    AP_PAYMENT {
        bigint PaymentId PK
        varchar PaymentNo "Payment Number"
        datetime PaymentDate "Payment Date"
        varchar VnCode FK "Vendor Code"
        decimal PaymentAmt "Payment Amount"
        varchar PaymentMethod "Payment Method"
        varchar BankAccount "Bank Account"
        varchar ChequeNo "Cheque Number"
        int PaymentStatus "Status"
        varchar PaymentDesc "Description"
        bigint TenantId FK "Tenant ID"
        datetime CreatedDate "Created Date"
    }

    AP_WHT {
        bigint WhtId PK
        bigint InvhId FK "Invoice ID"
        varchar WhtNo "WHT Number"
        datetime WhtDate "WHT Date"
        varchar VnCode FK "Vendor Code"
        varchar VnTaxId "Vendor Tax ID"
        decimal WhtAmt "WHT Amount"
        decimal WhtRate "WHT Rate %"
        varchar WhtType "WHT Type"
        varchar IncomeType "Income Type"
        varchar AccCode FK "WHT Account"
        bigint TenantId FK "Tenant ID"
    }

    AP_REQUISITION {
        bigint ReqId PK
        varchar ReqNo "Requisition Number"
        datetime ReqDate "Requisition Date"
        varchar ReqBy "Requested By"
        varchar DeptCode FK "Department"
        int ReqStatus "Status"
        varchar ReqDesc "Description"
        bigint TenantId FK "Tenant ID"
    }

    AP_PO_H {
        bigint PoId PK
        varchar PoNo "PO Number"
        datetime PoDate "PO Date"
        varchar VnCode FK "Vendor Code"
        decimal PoAmt "PO Amount"
        int PoStatus "Status"
        varchar PoTerms "Terms & Conditions"
        bigint ReqId FK "Requisition ID"
        bigint TenantId FK "Tenant ID"
    }

    AP_PO_D {
        bigint PodId PK
        bigint PoId FK "PO Header ID"
        int PodSeq "Line Sequence"
        varchar PodDesc "Item Description"
        decimal PodQty "Quantity"
        decimal PodPrice "Unit Price"
        decimal PodAmt "Line Amount"
        varchar AccCode FK "Account Code"
    }

    AP_RECEIVING {
        bigint RcvId PK
        varchar RcvNo "Receiving Number"
        datetime RcvDate "Receiving Date"
        bigint PoId FK "PO ID"
        varchar VnCode FK "Vendor Code"
        int RcvStatus "Status"
        varchar RcvNote "Receiving Note"
        bigint TenantId FK "Tenant ID"
    }

    GL_JV_H {
        bigint JvhId PK
        varchar JvhNo "JV Number"
        datetime JvhDate "JV Date"
        varchar JvhSource "Source (AP)"
        bigint SourceId FK "AP Invoice/Payment ID"
    }

    ACCOUNT_CODE {
        varchar AccCode PK
        varchar AccName "Account Name"
        int AccType "Account Type"
    }

    DEPARTMENT {
        varchar DeptCode PK
        varchar DeptName "Department Name"
    }
```

## AP Module Workflow

### 1. Purchase Requisition Flow (Optional)
```
Requisition Created → Approved → Converted to PO
```

### 2. Purchase Order Flow
```
PO Created → PO Approved → Goods Received → Invoice Matched
```

### 3. Invoice Flow
```
Invoice Entered → Validated → Approved → Posted to GL
```

### 4. Payment Flow
```
Invoice Due → Payment Created → Approved → Posted to GL
```

### 5. WHT Flow
```
Invoice with WHT → WHT Record Created → WHT File Generated
```

## GL Posting Examples

### Invoice Posting
```
DR: Expense Account (from AP_INVOICE_D.AccCode)  $1000
DR: WHT Receivable                               $  30
CR: AP Payable                                   $1030
```

### Payment Posting
```
DR: AP Payable                                   $1030
CR: Bank/Cash Account                            $1030
```

### WHT Posting (included in invoice posting)
```
DR: Expense Account                              $1000
DR: WHT Receivable (tax credit)                  $  30
CR: AP Payable (net amount)                      $1030
```

## Key Tables

**VENDOR**: Master vendor list with tax ID, payment terms
**AP_INVOICE_H/D**: Invoice header and line items
**AP_PAYMENT**: Payment records with bank/cheque details
**AP_WHT**: Withholding tax records for tax reporting
**AP_REQUISITION**: Purchase requisitions (pre-PO)
**AP_PO_H/D**: Purchase orders
**AP_RECEIVING**: Goods receiving records

## Status Codes (typical values)

**Invoice Status** (`InvhStatus`):
- 0 = Draft
- 1 = Posted to GL
- 2 = Pending Approval
- 3 = Approved
- 9 = Cancelled

**Payment Status** (`PaymentStatus`):
- 0 = Draft
- 1 = Posted
- 2 = Cleared
- 9 = Void

## Multi-Tenant

All tables include `TenantId` for data isolation.
Enforced via `FncBase.ApplyTenantIfUseTenant(useTenant)` in all controllers.
