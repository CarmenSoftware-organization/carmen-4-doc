#!/bin/bash
# Generate ERD diagrams for all modules
# Output: PlantUML ERD files in docs/database/

OUTPUT_DIR="docs/database"
mkdir -p "$OUTPUT_DIR"

echo "=== ERD Diagram Generator ==="
echo "Generating Entity Relationship Diagrams..."

# AP Module ERD
cat > "$OUTPUT_DIR/erd-ap-module.puml" << 'EOF'
@startuml
title Accounts Payable (AP) Module - Entity Relationship Diagram

entity "VENDOR" as vendor {
  * VnCode : varchar(20) <<PK>>
  --
  VnName : varchar(200)
  VnStatus : int
  VnCategory : varchar(50)
  VnTaxId : varchar(50)
  VnAddress : text
  VnCreditTerm : int
}

entity "AP_INVOICE_H" as ap_invoice {
  * InvhId : bigint <<PK>>
  * VnCode : varchar(20) <<FK>>
  --
  InvhDate : datetime
  InvhInvNo : varchar(50)
  InvhInvDate : datetime
  InvhDueDate : datetime
  InvhCredit : int
  CurCode : varchar(3)
  CurRate : decimal(18,6)
  InvhTaxT1 : int
  InvhStatus : int
}

entity "AP_INVOICE_D" as ap_invoice_d {
  * InvdId : bigint <<PK>>
  * InvhId : bigint <<FK>>
  --
  InvdSeq : int
  AccCode : varchar(50)
  InvdDesc : varchar(500)
  InvdAmt : decimal(18,2)
  InvdTaxAmt : decimal(18,2)
}

entity "AP_INV_WHT" as ap_inv_wht {
  * InvhId : bigint <<PK,FK>>
  --
  WhtTypeCode : varchar(20)
  WhtTotalAmt : decimal(18,2)
  WhtDeptCode : varchar(20)
  WhtNo : varchar(50)
  WhtTaxCr : varchar(50)
}

entity "AP_INV_WHT_ITEM" as ap_inv_wht_item {
  * WhtItemId : bigint <<PK>>
  * InvhId : bigint <<FK>>
  --
  WhtItemSeq : int
  WhtItemAmt : decimal(18,2)
  WhtItemRate : decimal(5,2)
  WhtItemTax : decimal(18,2)
}

entity "AP_PAYMENT_H" as ap_payment {
  * PayhId : bigint <<PK>>
  --
  PayhDate : datetime
  PayhNo : varchar(50)
  PayhType : varchar(20)
  PayhStatus : int
  BankCode : varchar(20)
  CurCode : varchar(3)
}

entity "AP_PAYMENT_D" as ap_payment_d {
  * PaydId : bigint <<PK>>
  * PayhId : bigint <<FK>>
  * InvhId : bigint <<FK>>
  --
  PaydSeq : int
  PaydAmt : decimal(18,2)
  PaydWhtAmt : decimal(18,2)
}

entity "AP_PAY_WHT" as ap_pay_wht {
  * PayhId : bigint <<PK,FK>>
  --
  WhtTypeCode : varchar(20)
  WhtTotalAmt : decimal(18,2)
  WhtNo : varchar(50)
}

entity "AP_WHT_CONDITION" as wht_condition {
  * WhtCondId : bigint <<PK>>
  --
  WhtTypeCode : varchar(20)
  WhtRate : decimal(5,2)
  WhtMinAmt : decimal(18,2)
  WhtMaxAmt : decimal(18,2)
}

vendor ||--o{ ap_invoice : "has"
ap_invoice ||--|| ap_inv_wht : "includes"
ap_invoice ||--|{ ap_invoice_d : "contains"
ap_inv_wht ||--|{ ap_inv_wht_item : "contains"
ap_invoice ||--o{ ap_payment_d : "paid by"
ap_payment ||--|{ ap_payment_d : "contains"
ap_payment ||--|| ap_pay_wht : "includes"

@enduml
EOF

echo "  ✓ Created erd-ap-module.puml"

# AR Module ERD
cat > "$OUTPUT_DIR/erd-ar-module.puml" << 'EOF'
@startuml
title Accounts Receivable (AR) Module - Entity Relationship Diagram

entity "AR_CONTRACT" as ar_contract {
  * ContractId : bigint <<PK>>
  --
  ContractNo : varchar(50)
  ContractDate : datetime
  CustomerCode : varchar(20)
  ContractStatus : int
  ContractAmt : decimal(18,2)
}

entity "AR_CONTRACT_D" as ar_contract_d {
  * ContractdId : bigint <<PK>>
  * ContractId : bigint <<FK>>
  --
  ContractdSeq : int
  ContractdDesc : varchar(500)
  ContractdAmt : decimal(18,2)
}

entity "AR_INVOICE_H" as ar_invoice {
  * InvhId : bigint <<PK>>
  * CustomerCode : varchar(20) <<FK>>
  --
  InvhNo : varchar(50)
  InvhDate : datetime
  InvhDueDate : datetime
  InvhStatus : int
  CurCode : varchar(3)
  CurRate : decimal(18,6)
  InvhTaxType : int
}

entity "AR_INVOICE_D" as ar_invoice_d {
  * InvdId : bigint <<PK>>
  * InvhId : bigint <<FK>>
  --
  InvdSeq : int
  AccCode : varchar(50)
  InvdDesc : varchar(500)
  InvdAmt : decimal(18,2)
  InvdTaxAmt : decimal(18,2)
}

entity "AR_RECEIPT_H" as ar_receipt {
  * RcpthId : bigint <<PK>>
  --
  RcpthNo : varchar(50)
  RcpthDate : datetime
  CustomerCode : varchar(20)
  RcpthStatus : int
  BankCode : varchar(20)
}

entity "AR_RECEIPT_D" as ar_receipt_d {
  * RcptdId : bigint <<PK>>
  * RcpthId : bigint <<FK>>
  * InvhId : bigint <<FK>>
  --
  RcptdSeq : int
  RcptdAmt : decimal(18,2)
}

entity "AR_FOLIO" as ar_folio {
  * FolioId : bigint <<PK>>
  * CustomerCode : varchar(20) <<FK>>
  --
  FolioNo : varchar(50)
  FolioStatus : int
  FolioBalance : decimal(18,2)
}

entity "AR_PROFILE" as ar_profile {
  * ProfileId : bigint <<PK>>
  * CustomerCode : varchar(20) <<FK>>
  --
  ProfileName : varchar(200)
  CreditLimit : decimal(18,2)
  CreditTerm : int
}

ar_contract ||--|{ ar_contract_d : "contains"
ar_invoice ||--|{ ar_invoice_d : "contains"
ar_receipt ||--|{ ar_receipt_d : "contains"
ar_invoice ||--o{ ar_receipt_d : "paid by"

@enduml
EOF

echo "  ✓ Created erd-ar-module.puml"

# GL Module ERD
cat > "$OUTPUT_DIR/erd-gl-module.puml" << 'EOF'
@startuml
title General Ledger (GL) Module - Entity Relationship Diagram

entity "ACCOUNT_CODE" as account {
  * AccCode : varchar(50) <<PK>>
  --
  AccName : varchar(200)
  AccType : int
  AccNature : int
  AccLevel : int
  ParentAccCode : varchar(50)
  IsActive : bit
}

entity "GL_JV_H" as gl_jv {
  * JvhId : bigint <<PK>>
  --
  JvhNo : varchar(50)
  JvhDate : datetime
  JvhDesc : varchar(500)
  JvhStatus : int
  JvhSource : varchar(50)
  JvhType : int
}

entity "GL_JV_D" as gl_jv_d {
  * JvdId : bigint <<PK>>
  * JvhId : bigint <<FK>>
  * AccCode : varchar(50) <<FK>>
  --
  JvdSeq : int
  JvdDesc : varchar(500)
  JvdDr : decimal(18,2)
  JvdCr : decimal(18,2)
  DeptCode : varchar(20)
  ProjectCode : varchar(20)
}

entity "GL_PERIOD" as gl_period {
  * PeriodId : bigint <<PK>>
  --
  PeriodYear : int
  PeriodMonth : int
  PeriodStatus : int
  StartDate : datetime
  EndDate : datetime
}

entity "GL_ALLOCATION_JV_H" as gl_alloc {
  * AllocId : bigint <<PK>>
  --
  AllocNo : varchar(50)
  AllocDate : datetime
  AllocDesc : varchar(500)
  AllocType : varchar(20)
}

entity "GL_ALLOCATION_JV_D" as gl_alloc_d {
  * AllocdId : bigint <<PK>>
  * AllocId : bigint <<FK>>
  * AccCode : varchar(50) <<FK>>
  --
  AllocdSeq : int
  AllocdRate : decimal(5,2)
  AllocdAmt : decimal(18,2)
}

entity "GL_AMORTIZE" as gl_amortize {
  * AmortizeId : bigint <<PK>>
  * AccCode : varchar(50) <<FK>>
  --
  AmortizeNo : varchar(50)
  AmortizeType : int
  StartDate : datetime
  EndDate : datetime
  TotalAmt : decimal(18,2)
  MonthlyAmt : decimal(18,2)
}

entity "GL_JV_FR_H" as gl_jv_fr {
  * JvFrId : bigint <<PK>>
  --
  JvFrNo : varchar(50)
  JvFrDate : datetime
  JvFrDesc : varchar(500)
}

account ||--o{ gl_jv_d : "posted to"
gl_jv ||--|{ gl_jv_d : "contains"
account ||--o{ gl_alloc_d : "allocated to"
gl_alloc ||--|{ gl_alloc_d : "contains"
account ||--o{ gl_amortize : "amortized"

@enduml
EOF

echo "  ✓ Created erd-gl-module.puml"

# Asset Module ERD
cat > "$OUTPUT_DIR/erd-asset-module.puml" << 'EOF'
@startuml
title Asset Management Module - Entity Relationship Diagram

entity "ASSET_REGISTER" as asset {
  * AssetId : bigint <<PK>>
  * CategoryId : bigint <<FK>>
  * LocationId : bigint <<FK>>
  * DeptId : bigint <<FK>>
  --
  AssetNo : varchar(50)
  AssetName : varchar(200)
  AssetDate : datetime
  PurchaseAmt : decimal(18,2)
  AccumDepre : decimal(18,2)
  BookValue : decimal(18,2)
  AssetStatus : int
  DepreMethod : varchar(20)
  UsefulLife : int
}

entity "ASSET_CATEGORY" as category {
  * CategoryId : bigint <<PK>>
  --
  CategoryCode : varchar(20)
  CategoryName : varchar(100)
  DepreRate : decimal(5,2)
  DepreMethod : varchar(20)
  AccCode_Asset : varchar(50)
  AccCode_Depre : varchar(50)
  AccCode_Accum : varchar(50)
}

entity "ASSET_LOCATION" as location {
  * LocationId : bigint <<PK>>
  --
  LocationCode : varchar(20)
  LocationName : varchar(100)
  LocationDesc : varchar(500)
}

entity "ASSET_DEPARTMENT" as department {
  * DeptId : bigint <<PK>>
  --
  DeptCode : varchar(20)
  DeptName : varchar(100)
}

entity "ASSET_HISTORY" as history {
  * HistoryId : bigint <<PK>>
  * AssetId : bigint <<FK>>
  --
  HistoryDate : datetime
  HistoryType : varchar(20)
  HistoryDesc : varchar(500)
  HistoryAmt : decimal(18,2)
  OldValue : decimal(18,2)
  NewValue : decimal(18,2)
}

entity "ASSET_DISPOSAL" as disposal {
  * DisposalId : bigint <<PK>>
  * AssetId : bigint <<FK>>
  --
  DisposalNo : varchar(50)
  DisposalDate : datetime
  DisposalType : int
  DisposalAmt : decimal(18,2)
  BookValue : decimal(18,2)
  GainLoss : decimal(18,2)
}

entity "PRE_ASSET" as pre_asset {
  * PreAssetId : bigint <<PK>>
  --
  PreAssetNo : varchar(50)
  PreAssetName : varchar(200)
  PreAssetStatus : int
  TotalAmt : decimal(18,2)
}

category ||--o{ asset : "classifies"
location ||--o{ asset : "located at"
department ||--o{ asset : "belongs to"
asset ||--o{ history : "has history"
asset ||--o| disposal : "disposed"

@enduml
EOF

echo "  ✓ Created erd-asset-module.puml"

# Income Module ERD
cat > "$OUTPUT_DIR/erd-income-module.puml" << 'EOF'
@startuml
title Income/Revenue Module - Entity Relationship Diagram

entity "INCOME_SOURCE" as source {
  * SourceId : bigint <<PK>>
  --
  SourceCode : varchar(20)
  SourceName : varchar(100)
  SourceType : varchar(50)
  AccCode : varchar(50)
}

entity "INCOME_CATEGORY" as category {
  * CategoryId : bigint <<PK>>
  * ParentCategoryId : bigint <<FK>>
  --
  CategoryCode : varchar(20)
  CategoryName : varchar(100)
  CategoryLevel : int
}

entity "INCOME_PRODUCT" as product {
  * ProductId : bigint <<PK>>
  * CategoryId : bigint <<FK>>
  --
  ProductCode : varchar(20)
  ProductName : varchar(200)
  ProductPrice : decimal(18,2)
  AccCode : varchar(50)
}

entity "INCOME_INVOICE_H" as invoice {
  * InvoiceId : bigint <<PK>>
  * SourceId : bigint <<FK>>
  --
  InvoiceNo : varchar(50)
  InvoiceDate : datetime
  InvoiceStatus : int
  TotalAmt : decimal(18,2)
  TaxAmt : decimal(18,2)
}

entity "INCOME_INVOICE_D" as invoice_d {
  * InvoicedId : bigint <<PK>>
  * InvoiceId : bigint <<FK>>
  * ProductId : bigint <<FK>>
  --
  InvoicedSeq : int
  InvoicedDesc : varchar(500)
  InvoicedQty : decimal(18,2)
  InvoicedPrice : decimal(18,2)
  InvoicedAmt : decimal(18,2)
}

entity "INCOME_REVENUE" as revenue {
  * RevenueId : bigint <<PK>>
  * SourceId : bigint <<FK>>
  --
  RevenueNo : varchar(50)
  RevenueDate : datetime
  RevenueAmt : decimal(18,2)
  AccCode : varchar(50)
}

entity "INCOME_PAY_CODE" as pay_code {
  * PayCodeId : bigint <<PK>>
  --
  PayCode : varchar(20)
  PayCodeName : varchar(100)
  AccCode : varchar(50)
}

entity "INCOME_PAY_TYPE" as pay_type {
  * PayTypeId : bigint <<PK>>
  --
  PayType : varchar(20)
  PayTypeName : varchar(100)
}

source ||--o{ invoice : "generates"
source ||--o{ revenue : "generates"
category ||--o{ product : "classifies"
invoice ||--|{ invoice_d : "contains"
product ||--o{ invoice_d : "sold in"

@enduml
EOF

echo "  ✓ Created erd-income-module.puml"

# Master ERD (simplified overview)
cat > "$OUTPUT_DIR/erd-master-overview.puml" << 'EOF'
@startuml
title Carmen.NET - Master Data Model Overview

package "Accounts Payable" {
  entity "VENDOR" as vendor
  entity "AP_INVOICE" as ap_inv
  entity "AP_PAYMENT" as ap_pay
  entity "AP_WHT" as ap_wht
}

package "Accounts Receivable" {
  entity "CUSTOMER" as customer
  entity "AR_INVOICE" as ar_inv
  entity "AR_RECEIPT" as ar_rcpt
  entity "AR_CONTRACT" as ar_contract
}

package "General Ledger" {
  entity "ACCOUNT_CODE" as account
  entity "GL_JV" as gl_jv
  entity "GL_PERIOD" as gl_period
  entity "GL_AMORTIZE" as gl_amort
}

package "Asset Management" {
  entity "ASSET_REGISTER" as asset
  entity "ASSET_CATEGORY" as asset_cat
  entity "ASSET_DISPOSAL" as asset_disp
}

package "Income/Revenue" {
  entity "INCOME_SOURCE" as inc_source
  entity "INCOME_INVOICE" as inc_inv
  entity "INCOME_PRODUCT" as inc_prod
}

package "Master Data" {
  entity "USER" as user
  entity "TENANT" as tenant
  entity "COMPANY" as company
  entity "DEPARTMENT" as dept
  entity "CURRENCY" as currency
}

package "System" {
  entity "PERMISSION" as perm
  entity "WORKFLOW" as workflow
  entity "DIMENSION" as dimension
}

' AP to GL
ap_inv --> gl_jv : "posts to"
ap_pay --> gl_jv : "posts to"

' AR to GL
ar_inv --> gl_jv : "posts to"
ar_rcpt --> gl_jv : "posts to"

' Asset to GL
asset --> gl_jv : "posts depreciation"
asset_disp --> gl_jv : "posts disposal"

' Income to GL
inc_inv --> gl_jv : "posts revenue"

' All to Account Code
gl_jv --> account : "uses"

' Multi-tenant
tenant --> company : "owns"
user --> tenant : "belongs to"

' Dimension allocation
dimension --> gl_jv : "allocates"
dimension --> dept : "references"

@enduml
EOF

echo "  ✓ Created erd-master-overview.puml"

echo ""
echo "=== Generation Complete ==="
echo "ERD diagrams created in: $OUTPUT_DIR"
echo ""
echo "Generated diagrams:"
echo "  - erd-ap-module.puml (Accounts Payable)"
echo "  - erd-ar-module.puml (Accounts Receivable)"
echo "  - erd-gl-module.puml (General Ledger)"
echo "  - erd-asset-module.puml (Asset Management)"
echo "  - erd-income-module.puml (Income/Revenue)"
echo "  - erd-master-overview.puml (System Overview)"
echo ""
echo "To render diagrams:"
echo "  plantuml $OUTPUT_DIR/*.puml"
