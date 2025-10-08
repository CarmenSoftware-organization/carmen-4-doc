# Asset Management Module - Entity Relationship Diagram

```mermaid
erDiagram
    %% Asset Master Relationships
    ASSET_CATEGORY ||--o{ ASSET_REGISTER : "classifies"
    ASSET_LOCATION ||--o{ ASSET_REGISTER : "located at"
    ASSET_DEPARTMENT ||--o{ ASSET_REGISTER : "assigned to"

    %% Asset History & Disposal
    ASSET_REGISTER ||--o{ ASSET_HISTORY : "tracks history"
    ASSET_REGISTER ||--o| ASSET_DISPOSAL : "disposed"

    %% Pre-Asset
    PRE_ASSET ||--o| ASSET_REGISTER : "converted to"

    %% GL Posting
    ASSET_REGISTER ||--o{ GL_JV_H : "posts depreciation"
    ASSET_DISPOSAL ||--o{ GL_JV_H : "posts disposal"

    %% Lookups
    ACCOUNT_CODE ||--o{ ASSET_CATEGORY : "asset accounts"

    %% Entities
    ASSET_REGISTER {
        bigint AssetId PK
        varchar AssetNo "Asset Number"
        varchar AssetName "Asset Name"
        varchar AssetDesc "Description"
        datetime AssetDate "Acquisition Date"
        bigint CategoryId FK "Asset Category"
        bigint LocationId FK "Asset Location"
        bigint DeptId FK "Asset Department"
        decimal PurchaseAmt "Purchase Amount"
        decimal SalvageValue "Salvage Value"
        decimal AccumDepre "Accumulated Depreciation"
        decimal BookValue "Book Value"
        int AssetStatus "Status"
        varchar DepreMethod "Depreciation Method"
        int UsefulLife "Useful Life (Years)"
        decimal DepreRate "Depreciation Rate %"
        varchar SerialNo "Serial Number"
        varchar Model "Model"
        varchar Manufacturer "Manufacturer"
        varchar WarrantyExpiry "Warranty Expiry"
        bigint TenantId FK "Tenant ID"
        datetime CreatedDate "Created Date"
        bigint CreatedBy FK "Created By"
    }

    ASSET_CATEGORY {
        bigint CategoryId PK
        varchar CategoryCode "Category Code"
        varchar CategoryName "Category Name"
        varchar CategoryDesc "Description"
        decimal DepreRate "Standard Depreciation Rate %"
        varchar DepreMethod "Standard Depreciation Method"
        int StandardUsefulLife "Standard Useful Life"
        varchar AccCode_Asset FK "Asset Account Code"
        varchar AccCode_Depre FK "Depreciation Expense Account"
        varchar AccCode_Accum FK "Accumulated Depreciation Account"
        bit IsActive "Active Status"
        bigint TenantId FK "Tenant ID"
    }

    ASSET_LOCATION {
        bigint LocationId PK
        varchar LocationCode "Location Code"
        varchar LocationName "Location Name"
        varchar LocationDesc "Location Description"
        varchar Address "Address"
        varchar ContactPerson "Contact Person"
        varchar Phone "Phone"
        bit IsActive "Active Status"
        bigint TenantId FK "Tenant ID"
    }

    ASSET_DEPARTMENT {
        bigint DeptId PK
        varchar DeptCode "Department Code"
        varchar DeptName "Department Name"
        varchar DeptManager "Department Manager"
        bit IsActive "Active Status"
        bigint TenantId FK "Tenant ID"
    }

    ASSET_HISTORY {
        bigint HistoryId PK
        bigint AssetId FK "Asset ID"
        datetime HistoryDate "History Date"
        varchar HistoryType "History Type"
        varchar HistoryDesc "Description"
        decimal HistoryAmt "Amount"
        decimal OldValue "Old Value"
        decimal NewValue "New Value"
        varchar OldLocation FK "Old Location"
        varchar NewLocation FK "New Location"
        varchar OldDept FK "Old Department"
        varchar NewDept FK "New Department"
        bigint UpdatedBy FK "Updated By"
        bigint TenantId FK "Tenant ID"
    }

    ASSET_DISPOSAL {
        bigint DisposalId PK
        bigint AssetId FK "Asset ID"
        varchar DisposalNo "Disposal Number"
        datetime DisposalDate "Disposal Date"
        int DisposalType "Disposal Type"
        decimal DisposalAmt "Disposal Amount"
        decimal BookValue "Book Value at Disposal"
        decimal GainLoss "Gain/Loss on Disposal"
        varchar DisposalReason "Disposal Reason"
        varchar DisposalTo "Disposed To"
        int DisposalStatus "Status"
        bigint TenantId FK "Tenant ID"
        datetime CreatedDate "Created Date"
    }

    PRE_ASSET {
        bigint PreAssetId PK
        varchar PreAssetNo "Pre-Asset Number"
        varchar PreAssetName "Pre-Asset Name"
        varchar PreAssetDesc "Description"
        int PreAssetStatus "Status"
        decimal TotalAmt "Total Amount"
        datetime StartDate "Start Date"
        datetime ExpectedCompleteDate "Expected Complete Date"
        datetime ActualCompleteDate "Actual Complete Date"
        bigint AssetId FK "Converted Asset ID"
        bigint TenantId FK "Tenant ID"
    }

    GL_JV_H {
        bigint JvhId PK
        varchar JvhNo "JV Number"
        datetime JvhDate "JV Date"
        varchar JvhSource "Source (Asset)"
        bigint SourceId FK "Asset/Disposal ID"
    }

    ACCOUNT_CODE {
        varchar AccCode PK
        varchar AccName "Account Name"
    }
```

## Asset Management Workflow

### 1. Asset Acquisition Flow
```
Purchase Request → PO → Receiving → Pre-Asset (if WIP) → Asset Register
```

### 2. Depreciation Flow
```
Monthly Process → Calculate Depreciation → Generate JV → Post to GL
```

### 3. Transfer Flow
```
Transfer Request → Approval → Update Location/Department → Record History
```

### 4. Disposal Flow
```
Disposal Request → Approval → Calculate Gain/Loss → Post to GL → Update Status
```

## Depreciation Methods

**Straight Line**:
```
Annual Depreciation = (Cost - Salvage Value) / Useful Life
Monthly Depreciation = Annual Depreciation / 12
```

**Declining Balance**:
```
Annual Depreciation = Book Value × Depreciation Rate
```

**Sum of Years Digits**:
```
Annual Depreciation = (Cost - Salvage Value) × (Remaining Life / Sum of Years)
```

**Units of Production**:
```
Depreciation per Unit = (Cost - Salvage Value) / Total Units
Period Depreciation = Units Produced × Depreciation per Unit
```

## GL Posting Examples

### Asset Acquisition
```
DR: Asset Account (from ASSET_CATEGORY.AccCode_Asset)  $10,000
CR: Cash/AP Account                                    $10,000
```

### Monthly Depreciation
```
DR: Depreciation Expense (AccCode_Depre)               $   100
CR: Accumulated Depreciation (AccCode_Accum)           $   100
```

### Asset Disposal (Gain)
```
DR: Cash/Receivable                                    $ 6,000
DR: Accumulated Depreciation                           $ 5,000
CR: Asset Account                                      $10,000
CR: Gain on Disposal                                   $ 1,000
```

### Asset Disposal (Loss)
```
DR: Cash/Receivable                                    $ 3,000
DR: Accumulated Depreciation                           $ 5,000
DR: Loss on Disposal                                   $ 2,000
CR: Asset Account                                      $10,000
```

## Key Tables

**ASSET_REGISTER**: Master asset list with depreciation details
**ASSET_CATEGORY**: Asset categories with default depreciation settings
**ASSET_LOCATION**: Physical locations of assets
**ASSET_DEPARTMENT**: Department assignments for assets
**ASSET_HISTORY**: Complete audit trail of asset changes
**ASSET_DISPOSAL**: Asset disposal records with gain/loss
**PRE_ASSET**: Work-in-progress assets (construction, software development)

## Asset Status

**Asset Status** (`AssetStatus`):
- 0 = In Use
- 1 = Idle
- 2 = Under Maintenance
- 3 = Disposed
- 4 = Sold
- 5 = Scrapped
- 9 = Written Off

**Pre-Asset Status** (`PreAssetStatus`):
- 0 = Planning
- 1 = In Progress
- 2 = Completed (converted to Asset)
- 9 = Cancelled

**Disposal Type** (`DisposalType`):
- 1 = Sale
- 2 = Scrap
- 3 = Trade-in
- 4 = Donation
- 5 = Transfer
- 9 = Write-off

## Asset History Types

**History Type** (`HistoryType`):
- ACQUIRE = Asset Acquisition
- DEPRECIATE = Depreciation Posting
- TRANSFER = Location/Department Transfer
- REVALUE = Revaluation
- IMPAIR = Impairment
- DISPOSE = Disposal
- MAINTAIN = Maintenance Record

## Asset Reports

- **Asset Register Report**: Complete asset listing
- **Depreciation Schedule**: Current and projected depreciation
- **Asset Valuation Report**: Book value by category/location/department
- **Disposal Report**: Gain/loss on disposals
- **Asset Movement Report**: Transfers and changes
- **Maintenance History**: Asset maintenance tracking
- **Asset Age Analysis**: Asset age distribution

## Multi-Tenant

All tables include `TenantId` for data isolation.
Enforced via `FncBase.ApplyTenantIfUseTenant(useTenant)` in all controllers.

## Pre-Asset (Work in Progress)

**Use Cases**:
- Building construction
- Software development
- Machine assembly
- Custom equipment fabrication

**Process**:
1. Create Pre-Asset record
2. Accumulate costs (labor, materials, overhead)
3. When complete, convert to Asset Register
4. Start depreciation from in-service date
