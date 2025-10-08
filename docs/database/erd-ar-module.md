# Accounts Receivable (AR) Module - Entity Relationship Diagram

```mermaid
erDiagram
    %% Customer Master
    CUSTOMER ||--o{ AR_CONTRACT : "has contract"
    CUSTOMER ||--o{ AR_INVOICE_H : "generates"
    CUSTOMER ||--o{ AR_RECEIPT : "makes payment"
    CUSTOMER ||--o{ AR_DEPOSIT : "makes deposit"
    CUSTOMER ||--o{ AR_FOLIO : "has folio"

    %% Invoice Relationships
    AR_CONTRACT ||--o{ AR_INVOICE_H : "generates"
    AR_INVOICE_H ||--|{ AR_INVOICE_D : "contains"
    AR_INVOICE_H ||--o{ AR_RECEIPT : "paid by"
    AR_FOLIO ||--o{ AR_INVOICE_H : "groups"

    %% Credit/Debit Notes
    AR_INVOICE_H ||--o{ AR_CREDIT_NOTE : "credited by"
    AR_INVOICE_H ||--o{ AR_DEBIT_NOTE : "debited by"

    %% Write-off
    AR_INVOICE_H ||--o{ AR_WRITE_OFF : "written off"

    %% GL Posting
    AR_INVOICE_H ||--o{ GL_JV_H : "posts to"
    AR_RECEIPT ||--o{ GL_JV_H : "posts to"

    %% Lookups
    ACCOUNT_CODE ||--o{ AR_INVOICE_D : "revenue account"
    DEPARTMENT ||--o{ AR_INVOICE_H : "department"

    %% Entities
    CUSTOMER {
        bigint CustCode PK
        varchar CustName "Customer Name"
        varchar CustNameEn "Customer Name English"
        varchar CustTaxId "Tax ID"
        varchar CustAddress "Address"
        varchar CustPhone "Phone"
        varchar CustEmail "Email"
        varchar CustContactPerson "Contact Person"
        varchar CustCreditTerms "Credit Terms"
        decimal CustCreditLimit "Credit Limit"
        bit CustIsActive "Active Status"
        datetime CreatedDate "Created Date"
        bigint CreatedBy FK "Created By User"
        bigint TenantId FK "Tenant ID"
    }

    AR_CONTRACT {
        bigint ContractId PK
        varchar ContractNo "Contract Number"
        datetime ContractDate "Contract Date"
        varchar CustCode FK "Customer Code"
        datetime StartDate "Start Date"
        datetime EndDate "End Date"
        decimal ContractAmt "Contract Amount"
        varchar ContractType "Contract Type"
        int ContractStatus "Status"
        varchar ContractTerms "Terms & Conditions"
        bigint TenantId FK "Tenant ID"
        datetime CreatedDate "Created Date"
    }

    AR_FOLIO {
        bigint FolioId PK
        varchar FolioNo "Folio Number"
        varchar CustCode FK "Customer Code"
        varchar FolioType "Folio Type"
        datetime FolioDate "Folio Date"
        int FolioStatus "Status"
        bigint TenantId FK "Tenant ID"
    }

    AR_INVOICE_H {
        bigint InvhId PK
        varchar InvhNo "Invoice Number"
        datetime InvhDate "Invoice Date"
        datetime InvhDueDate "Due Date"
        varchar CustCode FK "Customer Code"
        bigint ContractId FK "Contract ID"
        bigint FolioId FK "Folio ID"
        decimal InvhAmt "Invoice Amount"
        decimal InvhTaxAmt "Tax Amount"
        decimal InvhDiscAmt "Discount Amount"
        decimal InvhNetAmt "Net Amount"
        int InvhStatus "Status (0=Draft,1=Posted)"
        varchar InvhDesc "Description"
        varchar DeptCode FK "Department"
        varchar ProjectCode "Project Code"
        bigint TenantId FK "Tenant ID"
        datetime CreatedDate "Created Date"
        bigint CreatedBy FK "Created By"
    }

    AR_INVOICE_D {
        bigint InvdId PK
        bigint InvhId FK "Invoice Header ID"
        int InvdSeq "Line Sequence"
        varchar InvdDesc "Line Description"
        decimal InvdQty "Quantity"
        decimal InvdPrice "Unit Price"
        decimal InvdAmt "Line Amount"
        varchar AccCode FK "Revenue Account Code"
        varchar DeptCode FK "Department"
        varchar ProjectCode "Project"
    }

    AR_RECEIPT {
        bigint ReceiptId PK
        varchar ReceiptNo "Receipt Number"
        datetime ReceiptDate "Receipt Date"
        varchar CustCode FK "Customer Code"
        bigint InvhId FK "Invoice ID"
        decimal ReceiptAmt "Receipt Amount"
        varchar ReceiptMethod "Receipt Method"
        varchar BankAccount "Bank Account"
        varchar ChequeNo "Cheque Number"
        int ReceiptStatus "Status"
        varchar ReceiptDesc "Description"
        bigint TenantId FK "Tenant ID"
        datetime CreatedDate "Created Date"
    }

    AR_DEPOSIT {
        bigint DepositId PK
        varchar DepositNo "Deposit Number"
        datetime DepositDate "Deposit Date"
        varchar CustCode FK "Customer Code"
        decimal DepositAmt "Deposit Amount"
        int DepositStatus "Status"
        varchar DepositDesc "Description"
        bigint TenantId FK "Tenant ID"
    }

    AR_CREDIT_NOTE {
        bigint CnId PK
        varchar CnNo "Credit Note Number"
        datetime CnDate "Credit Note Date"
        bigint InvhId FK "Original Invoice ID"
        varchar CustCode FK "Customer Code"
        decimal CnAmt "Credit Amount"
        varchar CnReason "Credit Reason"
        int CnStatus "Status"
        bigint TenantId FK "Tenant ID"
    }

    AR_DEBIT_NOTE {
        bigint DnId PK
        varchar DnNo "Debit Note Number"
        datetime DnDate "Debit Note Date"
        bigint InvhId FK "Original Invoice ID"
        varchar CustCode FK "Customer Code"
        decimal DnAmt "Debit Amount"
        varchar DnReason "Debit Reason"
        int DnStatus "Status"
        bigint TenantId FK "Tenant ID"
    }

    AR_WRITE_OFF {
        bigint WriteOffId PK
        varchar WriteOffNo "Write-off Number"
        datetime WriteOffDate "Write-off Date"
        bigint InvhId FK "Invoice ID"
        varchar CustCode FK "Customer Code"
        decimal WriteOffAmt "Write-off Amount"
        varchar WriteOffReason "Write-off Reason"
        int WriteOffStatus "Status"
        bigint TenantId FK "Tenant ID"
    }

    GL_JV_H {
        bigint JvhId PK
        varchar JvhNo "JV Number"
        datetime JvhDate "JV Date"
        varchar JvhSource "Source (AR)"
        bigint SourceId FK "AR Invoice/Receipt ID"
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

## AR Module Workflow

### 1. Contract Flow (Optional)
```
Contract Created → Approved → Active → Generate Invoices
```

### 2. Invoice Flow
```
Invoice Created → Validated → Approved → Posted to GL
```

### 3. Receipt Flow
```
Payment Received → Receipt Created → Applied to Invoice → Posted to GL
```

### 4. Credit/Debit Note Flow
```
Issue Identified → Credit/Debit Note Created → Approved → Posted to GL
```

### 5. Write-off Flow
```
Bad Debt Identified → Write-off Approved → Posted to GL
```

## GL Posting Examples

### Invoice Posting
```
DR: AR Receivable                                $1070
CR: Revenue Account (from AR_INVOICE_D.AccCode)  $1000
CR: Tax Payable                                  $  70
```

### Receipt Posting
```
DR: Bank/Cash Account                            $1070
CR: AR Receivable                                $1070
```

### Credit Note Posting
```
DR: Revenue Account                              $ 100
CR: AR Receivable                                $ 100
```

### Debit Note Posting
```
DR: AR Receivable                                $ 100
CR: Revenue Account                              $ 100
```

### Write-off Posting
```
DR: Bad Debt Expense                             $ 500
CR: AR Receivable                                $ 500
```

## Key Tables

**CUSTOMER**: Master customer list with credit limit, terms
**AR_CONTRACT**: Long-term contracts for recurring invoicing
**AR_FOLIO**: Grouping of related invoices (e.g., monthly billing)
**AR_INVOICE_H/D**: Invoice header and line items
**AR_RECEIPT**: Payment receipts with bank/cheque details
**AR_DEPOSIT**: Customer deposits (advance payments)
**AR_CREDIT_NOTE**: Credit memos for returns/adjustments
**AR_DEBIT_NOTE**: Additional charges
**AR_WRITE_OFF**: Bad debt write-offs

## Status Codes (typical values)

**Invoice Status** (`InvhStatus`):
- 0 = Draft
- 1 = Posted to GL
- 2 = Pending Approval
- 3 = Approved
- 4 = Partially Paid
- 5 = Fully Paid
- 9 = Cancelled

**Receipt Status** (`ReceiptStatus`):
- 0 = Draft
- 1 = Posted
- 2 = Cleared
- 3 = Bounced
- 9 = Void

**Contract Status** (`ContractStatus`):
- 0 = Draft
- 1 = Active
- 2 = Suspended
- 3 = Expired
- 9 = Terminated

## Multi-Tenant

All tables include `TenantId` for data isolation.
Enforced via `FncBase.ApplyTenantIfUseTenant(useTenant)` in all controllers.

## Aging & Collections

AR Module supports:
- **Aging Reports**: 0-30, 31-60, 61-90, 90+ days
- **Credit Limit Management**: Prevent over-credit sales
- **Collection Management**: Track overdue invoices
- **Statement Generation**: Customer statements
