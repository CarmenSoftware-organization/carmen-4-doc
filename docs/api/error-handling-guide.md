# API Error Handling Guide

## Overview

Carmen.NET API uses standardized error responses across all endpoints, providing consistent error codes, detailed messages, and troubleshooting guidance.

## Error Response Format

### Standard Error Response

All error responses follow this consistent structure:

```json
{
  "success": false,
  "code": "ERROR_CODE",
  "message": "Human-readable error description",
  "details": "Additional error details or validation messages",
  "field": "fieldName",
  "timestamp": "2025-10-06T10:30:00Z",
  "traceId": "unique-request-trace-id",
  "path": "/api/ap/invoice/create"
}
```

### Field Descriptions

| Field | Type | Description | Always Present |
|-------|------|-------------|----------------|
| **success** | boolean | Always `false` for errors | ✅ Yes |
| **code** | string | Machine-readable error code | ✅ Yes |
| **message** | string | Human-readable error message | ✅ Yes |
| **details** | string/object | Additional error information | ❌ Optional |
| **field** | string | Field name causing validation error | ❌ Optional |
| **timestamp** | string (ISO 8601) | When error occurred | ✅ Yes |
| **traceId** | string | Request trace ID for debugging | ✅ Yes |
| **path** | string | API endpoint path | ✅ Yes |

## HTTP Status Codes

### Success Codes (2xx)

| Status Code | Description | Use Case |
|-------------|-------------|----------|
| **200 OK** | Request successful | GET, PUT, DELETE operations |
| **201 Created** | Resource created successfully | POST operations creating new resources |
| **204 No Content** | Successful with no response body | DELETE operations |

### Client Error Codes (4xx)

| Status Code | Description | Common Causes |
|-------------|-------------|---------------|
| **400 Bad Request** | Invalid request format or data | Validation errors, malformed JSON, missing required fields |
| **401 Unauthorized** | Authentication required or failed | Missing/invalid token, expired token |
| **403 Forbidden** | User lacks required permission | Insufficient permissions, tenant mismatch |
| **404 Not Found** | Resource does not exist | Invalid ID, deleted resource |
| **409 Conflict** | Request conflicts with current state | Duplicate entry, concurrent modification |
| **422 Unprocessable Entity** | Validation error | Business rule violation |
| **429 Too Many Requests** | Rate limit exceeded | Too many requests in time window |

### Server Error Codes (5xx)

| Status Code | Description | Common Causes |
|-------------|-------------|---------------|
| **500 Internal Server Error** | Unexpected server error | Unhandled exception, database error |
| **503 Service Unavailable** | Service temporarily unavailable | Maintenance, overload |

## Error Code Catalog

### Authentication & Authorization Errors (AUTH-xxx)

| Error Code | HTTP Status | Message | Cause | Resolution |
|------------|-------------|---------|-------|------------|
| **AUTH-001** | 401 | Invalid credentials | Wrong username/password | Verify credentials |
| **AUTH-002** | 401 | Token expired | JWT token expired | Refresh token or re-login |
| **AUTH-003** | 401 | Invalid token | Malformed or tampered token | Obtain new token |
| **AUTH-004** | 401 | Token missing | No Authorization header | Include Bearer token |
| **AUTH-005** | 403 | Insufficient permissions | User lacks required permission | Request permission from admin |
| **AUTH-006** | 403 | Tenant mismatch | Resource belongs to different tenant | Switch tenant or verify access |
| **AUTH-007** | 401 | Account locked | Too many failed login attempts | Contact administrator |
| **AUTH-008** | 401 | Account disabled | User account is disabled | Contact administrator |
| **AUTH-009** | 401 | Invalid refresh token | Refresh token expired or invalid | Re-login required |

**Example Response**:
```json
{
  "success": false,
  "code": "AUTH-005",
  "message": "Insufficient permissions to perform this action",
  "details": "Required permission: AP.Invoice.Approve",
  "requiredPermission": "AP.Invoice.Approve",
  "userPermissions": ["AP.Invoice.View", "AP.Invoice.Create"],
  "timestamp": "2025-10-06T10:30:00Z",
  "traceId": "abc-123-def-456",
  "path": "/api/ap/invoice/approve/12345"
}
```

### Validation Errors (VAL-xxx)

| Error Code | HTTP Status | Message | Cause | Resolution |
|------------|-------------|---------|-------|------------|
| **VAL-001** | 400 | Required field missing | Required field not provided | Provide required field |
| **VAL-002** | 422 | Invalid field value | Field value doesn't meet criteria | Correct field value |
| **VAL-003** | 422 | Invalid date range | Date range invalid | Correct date range |
| **VAL-004** | 422 | Amount exceeds limit | Amount exceeds maximum | Reduce amount or request approval |
| **VAL-005** | 422 | Duplicate entry | Record already exists | Use different identifier |
| **VAL-006** | 422 | Invalid format | Field format incorrect | Use correct format (e.g., email, phone) |
| **VAL-007** | 422 | Value out of range | Numeric value out of acceptable range | Provide value within range |
| **VAL-008** | 422 | Invalid reference | Referenced entity doesn't exist | Verify referenced ID |

**Example Response**:
```json
{
  "success": false,
  "code": "VAL-001",
  "message": "Validation failed: Required fields are missing",
  "details": {
    "errors": [
      {
        "field": "invoiceNumber",
        "message": "Invoice number is required",
        "code": "REQUIRED"
      },
      {
        "field": "invoiceDate",
        "message": "Invoice date is required",
        "code": "REQUIRED"
      },
      {
        "field": "vendorCode",
        "message": "Vendor code is required",
        "code": "REQUIRED"
      }
    ]
  },
  "timestamp": "2025-10-06T10:30:00Z",
  "traceId": "abc-123-def-456",
  "path": "/api/ap/invoice/create"
}
```

### Business Rule Errors (BUS-xxx)

| Error Code | HTTP Status | Message | Cause | Resolution |
|------------|-------------|---------|-------|------------|
| **BUS-001** | 422 | Period closed | GL period is closed | Change date or reopen period |
| **BUS-002** | 422 | Insufficient balance | Insufficient funds or budget | Increase budget or reduce amount |
| **BUS-003** | 422 | Credit limit exceeded | Customer credit limit exceeded | Increase limit or split transaction |
| **BUS-004** | 422 | Invoice already paid | Invoice status doesn't allow action | Verify invoice status |
| **BUS-005** | 422 | Duplicate invoice number | Invoice number already exists | Use different invoice number |
| **BUS-006** | 422 | Approval required | Transaction requires approval | Submit for approval first |
| **BUS-007** | 422 | Invalid status transition | Status change not allowed | Verify workflow rules |
| **BUS-008** | 422 | Outstanding items exist | Cannot proceed with outstanding items | Resolve outstanding items first |
| **BUS-009** | 422 | Vendor inactive | Vendor is not active | Activate vendor or select different vendor |
| **BUS-010** | 422 | Asset not found | Asset doesn't exist or disposed | Verify asset code |

**Example Response**:
```json
{
  "success": false,
  "code": "BUS-001",
  "message": "Cannot post transaction: GL period is closed",
  "details": "Period 2025-09 is closed. Please change transaction date to current period or request period reopening.",
  "periodCode": "2025-09",
  "periodStatus": "Closed",
  "closedDate": "2025-10-05T18:00:00Z",
  "currentPeriod": "2025-10",
  "timestamp": "2025-10-06T10:30:00Z",
  "traceId": "abc-123-def-456",
  "path": "/api/ap/invoice/post/12345"
}
```

### Resource Errors (RES-xxx)

| Error Code | HTTP Status | Message | Cause | Resolution |
|------------|-------------|---------|-------|------------|
| **RES-001** | 404 | Resource not found | ID doesn't exist | Verify ID is correct |
| **RES-002** | 404 | Endpoint not found | Invalid URL path | Check API documentation |
| **RES-003** | 409 | Resource already exists | Duplicate creation attempt | Update existing resource |
| **RES-004** | 409 | Concurrent modification | Resource modified by another user | Refresh and retry |
| **RES-005** | 410 | Resource deleted | Resource was soft/hard deleted | Cannot be recovered |

**Example Response**:
```json
{
  "success": false,
  "code": "RES-001",
  "message": "Invoice not found",
  "details": "Invoice with ID 99999 does not exist or you don't have permission to access it",
  "requestedId": "99999",
  "timestamp": "2025-10-06T10:30:00Z",
  "traceId": "abc-123-def-456",
  "path": "/api/ap/invoice/99999"
}
```

### Rate Limiting Errors (RATE-xxx)

| Error Code | HTTP Status | Message | Cause | Resolution |
|------------|-------------|---------|-------|------------|
| **RATE-001** | 429 | Rate limit exceeded | Too many requests | Wait before retrying |
| **RATE-002** | 429 | Quota exceeded | Daily/monthly quota exceeded | Wait for quota reset |

**Example Response**:
```json
{
  "success": false,
  "code": "RATE-001",
  "message": "Rate limit exceeded. Please try again later.",
  "details": "You have exceeded the rate limit of 100 requests per minute",
  "rateLimit": {
    "limit": 100,
    "remaining": 0,
    "resetTime": "2025-10-06T10:31:00Z"
  },
  "timestamp": "2025-10-06T10:30:00Z",
  "traceId": "abc-123-def-456",
  "path": "/api/ap/invoice/list"
}
```

### Server Errors (SRV-xxx)

| Error Code | HTTP Status | Message | Cause | Resolution |
|------------|-------------|---------|-------|------------|
| **SRV-001** | 500 | Internal server error | Unhandled exception | Contact support with traceId |
| **SRV-002** | 503 | Service unavailable | System maintenance | Retry after maintenance window |
| **SRV-003** | 500 | Database error | Database connection or query error | Contact support |
| **SRV-004** | 500 | External service error | Third-party service failure | Retry or contact support |

**Example Response**:
```json
{
  "success": false,
  "code": "SRV-001",
  "message": "An unexpected error occurred. Please contact support.",
  "details": "Error ID: abc-123-def-456",
  "traceId": "abc-123-def-456",
  "timestamp": "2025-10-06T10:30:00Z",
  "path": "/api/ap/invoice/create"
}
```

## Error Handling Best Practices

### Client-Side Error Handling

```typescript
async function createInvoice(invoiceData: Invoice): Promise<Invoice> {
    try {
        const response = await fetch('/api/ap/invoice/create', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify(invoiceData)
        });

        // Check HTTP status
        if (!response.ok) {
            const error = await response.json();

            // Handle different error codes
            switch (error.code) {
                case 'AUTH-002': // Token expired
                    await refreshToken();
                    return createInvoice(invoiceData); // Retry

                case 'AUTH-005': // Insufficient permissions
                    throw new PermissionError(error.message, error.requiredPermission);

                case 'VAL-001': // Validation error
                    throw new ValidationError(error.details.errors);

                case 'BUS-001': // Period closed
                    throw new BusinessRuleError(error.message, error.details);

                case 'RES-004': // Concurrent modification
                    const retry = confirm('Data has changed. Refresh and retry?');
                    if (retry) {
                        // Reload data and retry
                        const latestData = await getInvoice(invoiceData.id);
                        return createInvoice({ ...latestData, ...invoiceData });
                    }
                    throw new ConcurrentModificationError(error.message);

                case 'RATE-001': // Rate limit
                    const resetTime = new Date(error.rateLimit.resetTime);
                    const waitMs = resetTime.getTime() - Date.now();
                    await new Promise(resolve => setTimeout(resolve, waitMs));
                    return createInvoice(invoiceData); // Retry after wait

                default:
                    throw new ApiError(error.code, error.message);
            }
        }

        return await response.json();

    } catch (error) {
        if (error instanceof NetworkError) {
            // Network connectivity issue
            console.error('Network error:', error);
            throw new Error('Network connection failed. Please check your internet connection.');
        }

        throw error;
    }
}
```

### Retry Logic

```typescript
async function retryWithBackoff<T>(
    fn: () => Promise<T>,
    maxRetries: number = 3,
    initialDelay: number = 1000
): Promise<T> {
    let lastError: Error;

    for (let attempt = 0; attempt < maxRetries; attempt++) {
        try {
            return await fn();
        } catch (error) {
            lastError = error;

            // Don't retry on client errors (4xx) except 429
            if (error.statusCode >= 400 && error.statusCode < 500 && error.statusCode !== 429) {
                throw error;
            }

            // Exponential backoff
            const delay = initialDelay * Math.pow(2, attempt);
            console.log(`Retry attempt ${attempt + 1} after ${delay}ms`);
            await new Promise(resolve => setTimeout(resolve, delay));
        }
    }

    throw lastError;
}

// Usage
const invoice = await retryWithBackoff(() => createInvoice(invoiceData));
```

### Validation Error Display

```typescript
interface ValidationError {
    field: string;
    message: string;
    code: string;
}

function displayValidationErrors(errors: ValidationError[]) {
    errors.forEach(error => {
        // Find form field
        const field = document.querySelector(`[name="${error.field}"]`);

        if (field) {
            // Add error class
            field.classList.add('error');

            // Display error message
            const errorElement = document.createElement('span');
            errorElement.className = 'error-message';
            errorElement.textContent = error.message;
            field.parentElement.appendChild(errorElement);
        }
    });
}
```

## Debugging Errors

### Using Trace ID

Every error response includes a unique `traceId` that can be used to track the request in server logs.

**Support Request Template**:
```
Issue: Unable to create AP Invoice
Error Code: BUS-001
Trace ID: abc-123-def-456
Timestamp: 2025-10-06T10:30:00Z
User: john.doe@company.com
Tenant: TENANT001

Description: When attempting to create an invoice for October 5th,
I receive a "Period closed" error. The period close date was October 5th
at 6PM, but I'm trying to create an invoice dated October 5th at 2PM.

Expected: Invoice should be created as the invoice date is before period close.
Actual: Received error "Period closed".
```

### Enable Debug Mode

For development/testing environments:

```http
POST /api/ap/invoice/create HTTP/1.1
X-Debug: true
```

Response includes additional debugging information:
```json
{
  "success": false,
  "code": "BUS-001",
  "message": "Period closed",
  "debug": {
    "stackTrace": "...",
    "sqlQuery": "...",
    "executionTime": "125ms",
    "memoryUsage": "45MB"
  }
}
```

## Common Error Scenarios

### Scenario 1: Creating Invoice in Closed Period

**Request**:
```json
POST /api/ap/invoice/create
{
  "invoiceDate": "2025-09-30",
  "vendorCode": "V001",
  "amount": 1000
}
```

**Error Response**:
```json
{
  "success": false,
  "code": "BUS-001",
  "message": "Cannot create invoice: GL period 2025-09 is closed",
  "details": "Change invoice date to current period (2025-10) or request period reopening from your Controller",
  "periodCode": "2025-09",
  "periodStatus": "Closed",
  "currentPeriod": "2025-10"
}
```

**Resolution**: Change `invoiceDate` to "2025-10-01" or later

### Scenario 2: Duplicate Invoice Number

**Request**:
```json
POST /api/ap/invoice/create
{
  "invoiceNumber": "INV-2025-001",
  "vendorCode": "V001"
}
```

**Error Response**:
```json
{
  "success": false,
  "code": "BUS-005",
  "message": "Duplicate invoice number",
  "details": "Invoice number INV-2025-001 already exists for vendor V001",
  "existingInvoiceId": "12345",
  "field": "invoiceNumber"
}
```

**Resolution**: Use a different invoice number or verify the existing invoice

### Scenario 3: Insufficient Permissions

**Request**:
```http
POST /api/ap/invoice/approve/12345
```

**Error Response**:
```json
{
  "success": false,
  "code": "AUTH-005",
  "message": "Insufficient permissions",
  "details": "You need 'AP.Invoice.Approve' permission to approve invoices",
  "requiredPermission": "AP.Invoice.Approve",
  "userPermissions": ["AP.Invoice.View", "AP.Invoice.Create"]
}
```

**Resolution**: Request approval permission from administrator

## Error Monitoring

### Logging Errors

Log all API errors for monitoring and analysis:

```typescript
function logApiError(error: ApiError) {
    const logEntry = {
        timestamp: new Date().toISOString(),
        errorCode: error.code,
        message: error.message,
        traceId: error.traceId,
        path: error.path,
        user: getCurrentUser(),
        tenant: getCurrentTenant()
    };

    // Send to logging service
    logger.error('API Error', logEntry);

    // Send to analytics
    analytics.track('api_error', logEntry);
}
```

### Error Rate Monitoring

Monitor error rates to identify issues:
- Authentication errors spike → Possible token expiry issue
- Validation errors spike → UI validation issue
- Business rule errors → Training or process issue
- 500 errors → Server-side bug requiring investigation

---

**Document Version**: 1.0
**Last Updated**: 2025-10-06
**Status**: Phase 4 - API & Integration Documentation
