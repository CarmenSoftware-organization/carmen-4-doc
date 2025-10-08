# Income/Revenue Module - Entity Relationship Diagram

```mermaid
erDiagram
    %% Income Source Relationships
    INCOME_SOURCE ||--o{ INCOME_INVOICE_H : "generates"
    INCOME_SOURCE ||--o{ INCOME_REVENUE : "generates"

    %% Category Hierarchy
    INCOME_CATEGORY ||--o{ INCOME_CATEGORY : "parent category"
    INCOME_CATEGORY ||--o{ INCOME_PRODUCT : "classifies"

    %% Invoice Relationships
    INCOME_INVOICE_H ||--|{ INCOME_INVOICE_D : "contains"
    INCOME_PRODUCT ||--o{ INCOME_INVOICE_D : "sold in"

    %% GL Posting
    INCOME_INVOICE_H ||--o{ GL_JV_H : "posts to"
    INCOME_REVENUE ||--o{ GL_JV_H : "posts to"

    %% Lookups
    ACCOUNT_CODE ||--o{ INCOME_SOURCE : "revenue account"
    ACCOUNT_CODE ||--o{ INCOME_PRODUCT : "revenue account"
    ACCOUNT_CODE ||--o{ INCOME_PAY_CODE : "revenue account"
    INCOME_PAY_TYPE ||--o{ INCOME_INVOICE_H : "payment type"

    %% Entities
    INCOME_SOURCE {
        bigint SourceId PK
        varchar SourceCode "Source Code"
        varchar SourceName "Source Name"
        varchar SourceType "Source Type"
        varchar SourceDesc "Description"
        varchar AccCode FK "Revenue Account Code"
        bit IsActive "Active Status"
        bigint TenantId FK "Tenant ID"
        datetime CreatedDate "Created Date"
    }

    INCOME_CATEGORY {
        bigint CategoryId PK
        bigint ParentCategoryId FK "Parent Category"
        varchar CategoryCode "Category Code"
        varchar CategoryName "Category Name"
        int CategoryLevel "Hierarchy Level"
        varchar CategoryDesc "Description"
        bit IsActive "Active Status"
        bigint TenantId FK "Tenant ID"
    }

    INCOME_PRODUCT {
        bigint ProductId PK
        bigint CategoryId FK "Product Category"
        varchar ProductCode "Product Code"
        varchar ProductName "Product Name"
        varchar ProductDesc "Description"
        decimal ProductPrice "Standard Price"
        varchar UnitOfMeasure "Unit of Measure"
        varchar AccCode FK "Revenue Account Code"
        bit IsActive "Active Status"
        bigint TenantId FK "Tenant ID"
        datetime CreatedDate "Created Date"
    }

    INCOME_INVOICE_H {
        bigint InvoiceId PK
        varchar InvoiceNo "Invoice Number"
        datetime InvoiceDate "Invoice Date"
        datetime InvoiceDueDate "Due Date"
        bigint SourceId FK "Income Source ID"
        varchar CustomerRef "Customer Reference"
        varchar CustomerName "Customer Name"
        int InvoiceStatus "Status (0=Draft,1=Posted)"
        decimal TotalAmt "Total Amount"
        decimal TaxAmt "Tax Amount"
        decimal DiscountAmt "Discount Amount"
        decimal NetAmt "Net Amount"
        varchar PaymentTypeId FK "Payment Type"
        varchar InvoiceDesc "Description"
        bigint TenantId FK "Tenant ID"
        datetime CreatedDate "Created Date"
        bigint CreatedBy FK "Created By"
    }

    INCOME_INVOICE_D {
        bigint InvoicedId PK
        bigint InvoiceId FK "Invoice Header ID"
        bigint ProductId FK "Product ID"
        int InvoicedSeq "Line Sequence"
        varchar InvoicedDesc "Line Description"
        decimal InvoicedQty "Quantity"
        decimal InvoicedPrice "Unit Price"
        decimal InvoicedAmt "Line Amount"
        decimal InvoicedTax "Tax Amount"
        decimal InvoicedDiscount "Discount Amount"
        varchar AccCode FK "Revenue Account"
    }

    INCOME_REVENUE {
        bigint RevenueId PK
        varchar RevenueNo "Revenue Number"
        datetime RevenueDate "Revenue Date"
        bigint SourceId FK "Income Source ID"
        decimal RevenueAmt "Revenue Amount"
        varchar AccCode FK "Revenue Account Code"
        varchar RevenueType "Revenue Type"
        varchar RevenueDesc "Description"
        int RevenueStatus "Status"
        bigint TenantId FK "Tenant ID"
        datetime CreatedDate "Created Date"
    }

    INCOME_PAY_CODE {
        bigint PayCodeId PK
        varchar PayCode "Payment Code"
        varchar PayCodeName "Payment Code Name"
        varchar PayCodeDesc "Description"
        varchar AccCode FK "GL Account Code"
        bit IsActive "Active Status"
        bigint TenantId FK "Tenant ID"
    }

    INCOME_PAY_TYPE {
        bigint PayTypeId PK
        varchar PayType "Payment Type Code"
        varchar PayTypeName "Payment Type Name"
        varchar PayTypeDesc "Description"
        bit IsActive "Active Status"
        bigint TenantId FK "Tenant ID"
    }

    GL_JV_H {
        bigint JvhId PK
        varchar JvhNo "JV Number"
        datetime JvhDate "JV Date"
        varchar JvhSource "Source (Income)"
        bigint SourceId FK "Income Invoice/Revenue ID"
    }

    ACCOUNT_CODE {
        varchar AccCode PK
        varchar AccName "Account Name"
    }
```

## Income Module Workflow

### 1. Product Setup Flow
```
Define Category Hierarchy → Create Products → Set Prices → Assign Revenue Accounts
```

### 2. Invoice Flow
```
Create Invoice → Add Line Items (Products) → Calculate Tax → Approve → Post to GL
```

### 3. Revenue Recognition Flow
```
Revenue Event → Create Revenue Record → Post to GL
```

### 4. Payment Flow
```
Invoice Generated → Payment Received → Record Receipt → Post to GL
```

## Income Source Types

**Source Type Examples**:
- RENTAL = Rental income
- SERVICE = Service fees
- SUBSCRIPTION = Subscription revenue
- INTEREST = Interest income
- ROYALTY = Royalty income
- OTHER = Other income sources

## GL Posting Examples

### Income Invoice Posting
```
DR: Cash/AR Receivable                               $1070
CR: Revenue Account (from INCOME_INVOICE_D.AccCode)  $1000
CR: Tax Payable                                      $  70
```

### Revenue Recognition Posting
```
DR: Receivable/Unearned Revenue                      $1000
CR: Revenue Account (from INCOME_REVENUE.AccCode)    $1000
```

### Deferred Revenue (Subscription Example)
```
Initial Receipt:
DR: Cash                                             $1200
CR: Unearned Revenue                                 $1200

Monthly Recognition (12 months):
DR: Unearned Revenue                                 $ 100
CR: Revenue Account                                  $ 100
```

## Key Tables

**INCOME_SOURCE**: Revenue stream sources and categories
**INCOME_CATEGORY**: Hierarchical product/service categories
**INCOME_PRODUCT**: Product/service master with pricing
**INCOME_INVOICE_H/D**: Invoice header and line items
**INCOME_REVENUE**: Direct revenue recognition records
**INCOME_PAY_CODE**: Payment codes for revenue tracking
**INCOME_PAY_TYPE**: Payment type classification

## Status Codes

**Invoice Status** (`InvoiceStatus`):
- 0 = Draft
- 1 = Posted to GL
- 2 = Pending Approval
- 3 = Approved
- 4 = Paid
- 9 = Cancelled

**Revenue Status** (`RevenueStatus`):
- 0 = Draft
- 1 = Recognized (Posted)
- 2 = Deferred
- 3 = Accrued
- 9 = Reversed

## Revenue Recognition Patterns

### 1. Point-in-Time Recognition
```
Service Completed → Invoice Generated → Revenue Recognized Immediately
```

### 2. Over-Time Recognition
```
Contract Start → Monthly Recognition → Complete over Contract Period
```

### 3. Milestone-Based Recognition
```
Milestone 1 Complete (30%) → Recognize 30% Revenue
Milestone 2 Complete (40%) → Recognize 40% Revenue
Milestone 3 Complete (30%) → Recognize 30% Revenue
```

### 4. Subscription Revenue
```
Annual Payment Received → Recognize 1/12 Monthly for 12 Months
```

## Product Category Hierarchy

**Example Structure**:
```
Services (Level 1)
  ├─ Consulting (Level 2)
  │   ├─ IT Consulting (Level 3)
  │   └─ Management Consulting (Level 3)
  └─ Training (Level 2)
      ├─ Technical Training (Level 3)
      └─ Soft Skills Training (Level 3)

Products (Level 1)
  ├─ Software (Level 2)
  │   ├─ Licenses (Level 3)
  │   └─ Subscriptions (Level 3)
  └─ Hardware (Level 2)
```

## Income Reports

- **Revenue by Source**: Revenue breakdown by income source
- **Revenue by Product**: Revenue by product/service
- **Revenue by Category**: Hierarchical revenue analysis
- **Revenue Recognition Schedule**: Deferred revenue tracking
- **Invoice Aging**: Outstanding invoice analysis
- **Revenue Forecast**: Projected revenue based on contracts

## Multi-Tenant

All tables include `TenantId` for data isolation.
Enforced via `FncBase.ApplyTenantIfUseTenant(useTenant)` in all controllers.

## Use Cases

### 1. Rental Income
- **Income Source**: Property rentals
- **Products**: Unit A, Unit B, Parking Space
- **Invoicing**: Monthly rental invoices
- **Revenue Recognition**: Monthly over lease term

### 2. Subscription SaaS
- **Income Source**: Software subscriptions
- **Products**: Basic Plan, Pro Plan, Enterprise Plan
- **Invoicing**: Annual/monthly subscription invoices
- **Revenue Recognition**: Ratably over subscription period

### 3. Professional Services
- **Income Source**: Consulting services
- **Products**: Hourly consulting, Project-based consulting
- **Invoicing**: Time & materials or fixed-price invoices
- **Revenue Recognition**: Upon completion or milestone-based

### 4. Educational Institution
- **Income Source**: Tuition fees
- **Products**: Course A, Course B, Program C
- **Invoicing**: Semester invoices
- **Revenue Recognition**: Over academic term
