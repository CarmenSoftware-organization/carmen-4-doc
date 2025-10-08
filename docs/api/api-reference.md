# Carmen.NET API Reference

## Overview

This document provides a comprehensive reference for all Carmen.NET API endpoints, organized by module. All endpoints require authentication via JWT token unless otherwise specified.

**Base URL**: `https://api.carmen.com`

**API Version**: v1

**Authentication**: Bearer Token (JWT)

## Table of Contents

1. [Account & Authentication](#account--authentication)
2. [AP (Accounts Payable) Module](#ap-accounts-payable-module)
3. [AR (Accounts Receivable) Module](#ar-accounts-receivable-module)
4. [GL (General Ledger) Module](#gl-general-ledger-module)
5. [Asset Management Module](#asset-management-module)
6. [Income/Revenue Module](#income-revenue-module)
7. [Master Data](#master-data)

## Common Request Headers

```http
Authorization: Bearer {jwt_token}
Content-Type: application/json
Accept: application/json
X-Tenant: {tenant_code}
```

## Common Response Format

### Success Response

```json
{
  "success": true,
  "data": { /* response data */ },
  "message": "Operation completed successfully",
  "timestamp": "2025-10-06T10:30:00Z"
}
```

### Error Response

```json
{
  "success": false,
  "code": "ERROR_CODE",
  "message": "Error description",
  "details": "Additional error information",
  "timestamp": "2025-10-06T10:30:00Z",
  "traceId": "abc-123-def-456"
}
```

---

## Account & Authentication

### POST /api/account/login

**Description**: Authenticate user and obtain JWT token

**Permission**: Public (no authentication required)

**Request Body**:
```json
{
  "userName": "user@company.com",
  "password": "password",
  "useTenant": "TENANT001"
}
```

**Response**:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "refresh_token_here",
  "tokenExpiration": "2025-10-06T11:30:00Z",
  "user": {
    "userId": "12345",
    "userName": "user@company.com",
    "fullName": "John Doe",
    "roles": ["AP.Manager"],
    "tenantCode": "TENANT001",
    "permissions": {}
  }
}
```

### POST /api/account/refresh-token

**Description**: Refresh expired access token

**Permission**: Public (no authentication required)

**Request Body**:
```json
{
  "refreshToken": "refresh_token_here"
}
```

**Response**:
```json
{
  "success": true,
  "token": "new_jwt_token",
  "tokenExpiration": "2025-10-06T12:30:00Z"
}
```

### POST /api/account/logout

**Description**: Logout and invalidate tokens

**Permission**: Authenticated users

**Response**:
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

### GET /api/account/tenants

**Description**: Get list of tenants user has access to

**Permission**: Authenticated users

**Response**:
```json
{
  "success": true,
  "tenants": [
    {
      "tenantCode": "TENANT001",
      "tenantName": "ABC Corporation",
      "isActive": true
    }
  ]
}
```

---

## AP (Accounts Payable) Module

### AP Invoice Endpoints

#### GET /api/ap/invoice/list

**Description**: Get list of AP invoices with filtering and pagination

**Permission**: `AP.Invoice.View`

**Query Parameters**:
- `page` (integer): Page number (default: 1)
- `pageSize` (integer): Records per page (default: 50, max: 100)
- `status` (integer): Filter by status (0=Draft, 1=Posted, 2=Pending, 3=Approved, 4=Rejected, 5=Partially Paid, 6=Fully Paid, 9=Cancelled)
- `vendorCode` (string): Filter by vendor
- `fromDate` (date): Filter by invoice date from
- `toDate` (date): Filter by invoice date to
- `search` (string): Search in invoice number, description

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": "12345",
      "invoiceNumber": "INV-2025-001",
      "invoiceDate": "2025-10-06",
      "dueDate": "2025-11-05",
      "vendorCode": "V001",
      "vendorName": "ABC Supplier",
      "amount": 100000.00,
      "taxAmount": 7000.00,
      "whtAmount": 5000.00,
      "netAmount": 102000.00,
      "outstandingAmount": 102000.00,
      "status": 1,
      "statusName": "Posted",
      "createdBy": "user@company.com",
      "createdDate": "2025-10-06T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "pageSize": 50,
    "totalRecords": 150,
    "totalPages": 3
  }
}
```

#### GET /api/ap/invoice/{id}

**Description**: Get AP invoice details by ID

**Permission**: `AP.Invoice.View`

**Response**:
```json
{
  "success": true,
  "data": {
    "id": "12345",
    "invoiceNumber": "INV-2025-001",
    "invoiceDate": "2025-10-06",
    "dueDate": "2025-11-05",
    "vendorCode": "V001",
    "vendorName": "ABC Supplier",
    "description": "Professional Services",
    "amount": 100000.00,
    "taxAmount": 7000.00,
    "whtAmount": 5000.00,
    "netAmount": 102000.00,
    "status": 1,
    "statusName": "Posted",
    "lines": [
      {
        "lineNo": 1,
        "accountCode": "5100",
        "accountName": "Professional Expense",
        "description": "Consulting Services",
        "amount": 100000.00,
        "departmentCode": "IT"
      }
    ],
    "approvalHistory": [
      {
        "approvalDate": "2025-10-06T14:00:00Z",
        "approver": "manager@company.com",
        "action": "Approved",
        "comments": "Approved as per PO"
      }
    ]
  }
}
```

#### POST /api/ap/invoice/create

**Description**: Create new AP invoice

**Permission**: `AP.Invoice.Create`

**Request Body**:
```json
{
  "invoiceNumber": "INV-2025-001",
  "invoiceDate": "2025-10-06",
  "dueDate": "2025-11-05",
  "vendorCode": "V001",
  "description": "Professional Services",
  "amount": 100000.00,
  "taxAmount": 7000.00,
  "whtAmount": 5000.00,
  "lines": [
    {
      "lineNo": 1,
      "accountCode": "5100",
      "description": "Consulting Services",
      "amount": 100000.00,
      "departmentCode": "IT"
    }
  ]
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "id": "12345",
    "invoiceNumber": "INV-2025-001",
    "status": 0,
    "statusName": "Draft"
  },
  "message": "Invoice created successfully"
}
```

#### PUT /api/ap/invoice/update

**Description**: Update existing AP invoice (Draft status only)

**Permission**: `AP.Invoice.Update`

**Request Body**: Same as create, plus `id` field

#### DELETE /api/ap/invoice/{id}

**Description**: Delete AP invoice (Draft status only)

**Permission**: `AP.Invoice.Delete`

#### POST /api/ap/invoice/submit/{id}

**Description**: Submit invoice for approval

**Permission**: `AP.Invoice.Create`

**Response**:
```json
{
  "success": true,
  "data": {
    "id": "12345",
    "status": 2,
    "statusName": "Pending Approval",
    "assignedApprover": "manager@company.com"
  }
}
```

#### POST /api/ap/invoice/approve/{id}

**Description**: Approve invoice

**Permission**: `AP.Invoice.Approve`

**Request Body** (optional):
```json
{
  "comments": "Approved as per PO#12345"
}
```

#### POST /api/ap/invoice/reject/{id}

**Description**: Reject invoice

**Permission**: `AP.Invoice.Approve`

**Request Body**:
```json
{
  "reason": "Missing purchase order reference"
}
```

#### POST /api/ap/invoice/post/{id}

**Description**: Post invoice to GL

**Permission**: `AP.Invoice.Post`

**Response**:
```json
{
  "success": true,
  "data": {
    "id": "12345",
    "status": 1,
    "statusName": "Posted",
    "glJvNumber": "JV-2025-100",
    "postingDate": "2025-10-06T15:00:00Z"
  }
}
```

### AP Payment Endpoints

#### GET /api/ap/payment/list

**Description**: Get list of AP payments

**Permission**: `AP.Payment.View`

**Query Parameters**: Similar to invoice list (page, pageSize, status, vendorCode, fromDate, toDate)

#### GET /api/ap/payment/{id}

**Description**: Get payment details

**Permission**: `AP.Payment.View`

#### POST /api/ap/payment/create

**Description**: Create new payment

**Permission**: `AP.Payment.Create`

**Request Body**:
```json
{
  "paymentDate": "2025-10-06",
  "bankAccountCode": "BANK001",
  "paymentMethod": "Check",
  "checkNumber": "CHK-2025-100",
  "description": "Payment to vendor",
  "invoices": [
    {
      "invoiceId": "12345",
      "paymentAmount": 102000.00
    }
  ]
}
```

#### POST /api/ap/payment/post/{id}

**Description**: Post payment to GL

**Permission**: `AP.Payment.Post`

#### POST /api/ap/payment/void/{id}

**Description**: Void posted payment

**Permission**: `AP.Payment.Void`

---

## AR (Accounts Receivable) Module

### AR Invoice Endpoints

#### GET /api/ar/invoice/list

**Description**: Get list of AR invoices

**Permission**: `AR.Invoice.View`

**Query Parameters**: page, pageSize, status, customerCode, fromDate, toDate, search

#### POST /api/ar/invoice/create

**Description**: Create AR invoice

**Permission**: `AR.Invoice.Create`

**Request Body**:
```json
{
  "invoiceNumber": "AR-2025-001",
  "invoiceDate": "2025-10-06",
  "dueDate": "2025-11-05",
  "customerCode": "C001",
  "description": "Services rendered",
  "amount": 50000.00,
  "taxAmount": 3500.00,
  "lines": [
    {
      "lineNo": 1,
      "revenueAccountCode": "4100",
      "description": "Consulting Services",
      "amount": 50000.00
    }
  ]
}
```

#### POST /api/ar/invoice/generate-from-contract

**Description**: Generate invoice from AR contract

**Permission**: `AR.Invoice.Create`

**Request Body**:
```json
{
  "contractId": "67890",
  "invoiceDate": "2025-10-06",
  "description": "Monthly billing"
}
```

#### POST /api/ar/invoice/send/{id}

**Description**: Send invoice to customer

**Permission**: `AR.Invoice.View`

**Request Body**:
```json
{
  "method": "Email",
  "recipientEmail": "customer@company.com",
  "subject": "Invoice AR-2025-001",
  "message": "Please find attached invoice"
}
```

### AR Receipt Endpoints

#### GET /api/ar/receipt/list

**Description**: Get list of receipts

**Permission**: `AR.Receipt.View`

#### POST /api/ar/receipt/create

**Description**: Create receipt

**Permission**: `AR.Receipt.Create`

**Request Body**:
```json
{
  "receiptDate": "2025-10-06",
  "receiptNumber": "RCP-2025-001",
  "customerCode": "C001",
  "paymentMethod": "Check",
  "amount": 50000.00,
  "checkNumber": "123456",
  "bankAccountCode": "BANK001",
  "applications": [
    {
      "invoiceId": "67890",
      "appliedAmount": 50000.00
    }
  ]
}
```

#### POST /api/ar/receipt/deposit/{id}

**Description**: Mark receipt as deposited

**Permission**: `AR.Receipt.Deposit`

**Request Body**:
```json
{
  "depositDate": "2025-10-06",
  "depositSlipNumber": "DEP-2025-001"
}
```

---

## GL (General Ledger) Module

### GL Period Endpoints

#### GET /api/gl/period/list

**Description**: Get list of GL periods

**Permission**: `GL.Period.View`

#### GET /api/gl/period/current

**Description**: Get current open GL period

**Permission**: `GL.Period.View`

**Response**:
```json
{
  "success": true,
  "data": {
    "periodCode": "2025-10",
    "periodName": "October 2025",
    "startDate": "2025-10-01",
    "endDate": "2025-10-31",
    "status": "Open",
    "fiscalYear": "2025"
  }
}
```

#### POST /api/gl/period/validate/{periodCode}

**Description**: Run pre-close validation

**Permission**: `GL.Period.Close`

**Response**:
```json
{
  "success": true,
  "validationPassed": true,
  "validationResults": [
    {
      "category": "Unposted Transactions",
      "status": "Passed",
      "message": "All transactions posted"
    },
    {
      "category": "Bank Reconciliation",
      "status": "Passed",
      "message": "All bank accounts reconciled"
    }
  ]
}
```

#### POST /api/gl/period/execute-close/{periodCode}

**Description**: Execute period close

**Permission**: `GL.Period.Close`

#### POST /api/gl/period/reopen/{periodCode}

**Description**: Reopen closed period

**Permission**: `GL.Period.Reopen`

**Request Body**:
```json
{
  "reason": "Need to post adjusting entries",
  "approvalReference": "CFO-APPROVAL-001"
}
```

### GL Journal Voucher Endpoints

#### GET /api/gl/jv/list

**Description**: Get list of journal vouchers

**Permission**: `GL.JV.View`

#### POST /api/gl/jv/create

**Description**: Create journal voucher

**Permission**: `GL.JV.Create`

**Request Body**:
```json
{
  "jvDate": "2025-10-06",
  "jvNumber": "JV-2025-001",
  "description": "Accrual entry",
  "lines": [
    {
      "lineNo": 1,
      "accountCode": "1100",
      "debit": 10000.00,
      "credit": 0,
      "description": "Cash"
    },
    {
      "lineNo": 2,
      "accountCode": "4100",
      "debit": 0,
      "credit": 10000.00,
      "description": "Revenue"
    }
  ]
}
```

---

## Asset Management Module

### Asset Register Endpoints

#### GET /api/asset/register/list

**Description**: Get list of assets

**Permission**: `Asset.Register.View`

**Query Parameters**: page, pageSize, categoryCode, locationCode, status

#### POST /api/asset/register/create

**Description**: Create new asset

**Permission**: `Asset.Register.Create`

**Request Body**:
```json
{
  "assetCode": "AST-2025-001",
  "assetName": "Dell Laptop",
  "categoryCode": "IT-EQUIP",
  "acquisitionDate": "2025-10-06",
  "acquisitionCost": 50000.00,
  "depreciationMethod": "StraightLine",
  "usefulLife": 5,
  "salvageValue": 5000.00,
  "locationCode": "HQ-IT",
  "custodianCode": "EMP-001"
}
```

### Asset Disposal Endpoints

#### POST /api/asset/disposal/create

**Description**: Create asset disposal

**Permission**: `Asset.Disposal.Create`

**Request Body**:
```json
{
  "assetCode": "AST-2025-001",
  "disposalDate": "2025-10-06",
  "disposalMethod": "Sale",
  "salePrice": 15000.00,
  "disposalCost": 500.00,
  "reason": "Asset obsolete"
}
```

---

## Income/Revenue Module

### Income Invoice Endpoints

#### GET /api/income/invoice/list

**Description**: Get list of income invoices

**Permission**: `Income.Invoice.View`

#### POST /api/income/invoice/create

**Description**: Create income invoice

**Permission**: `Income.Invoice.Create`

---

## Master Data

### Vendor Endpoints

#### GET /api/master/vendor/list

**Description**: Get list of vendors

**Permission**: `Master.Vendor.View`

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "vendorCode": "V001",
      "vendorName": "ABC Supplier",
      "taxId": "1234567890",
      "isActive": true,
      "paymentTerms": "Net 30",
      "whtRate": 5.00,
      "contactEmail": "vendor@abc.com"
    }
  ]
}
```

#### GET /api/master/vendor/{code}

**Description**: Get vendor details

**Permission**: `Master.Vendor.View`

### Customer Endpoints

#### GET /api/master/customer/list

**Description**: Get list of customers

**Permission**: `Master.Customer.View`

#### GET /api/master/customer/{code}

**Description**: Get customer details

**Permission**: `Master.Customer.View`

### GL Account Endpoints

#### GET /api/gl/account/list

**Description**: Get chart of accounts

**Permission**: `GL.Account.View`

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "accountCode": "1100",
      "accountName": "Cash",
      "accountType": "Asset",
      "isActive": true,
      "allowPosting": true
    }
  ]
}
```

---

## Rate Limiting

**Rate Limits**:
- **Standard**: 100 requests per minute per user
- **Batch operations**: 10 requests per minute
- **File uploads**: 5 requests per minute

**Rate Limit Headers**:
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1696600200
```

## Versioning

API version is specified in the URL path: `/api/v1/...`

Current version: `v1`

## Pagination

All list endpoints support pagination:

**Query Parameters**:
- `page`: Page number (default: 1)
- `pageSize`: Records per page (default: 50, max: 100)

**Response includes**:
```json
{
  "pagination": {
    "page": 1,
    "pageSize": 50,
    "totalRecords": 150,
    "totalPages": 3,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
}
```

## Filtering & Sorting

**Common Filter Parameters**:
- `search`: Full-text search
- `fromDate`, `toDate`: Date range filtering
- `status`: Status filtering
- `orderBy`: Sort field
- `orderDirection`: `asc` or `desc`

**Example**:
```
GET /api/ap/invoice/list?status=1&fromDate=2025-10-01&toDate=2025-10-31&orderBy=invoiceDate&orderDirection=desc
```

---

**Document Version**: 1.0
**Last Updated**: 2025-10-06
**Status**: Phase 4 - API & Integration Documentation
