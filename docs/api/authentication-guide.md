# API Authentication Guide

## Overview

Carmen.NET uses JWT (JSON Web Token) based authentication for all API endpoints. This guide provides comprehensive information on authentication flows, token management, and security best practices.

## Authentication Architecture

```mermaid
sequenceDiagram
    participant Client
    participant API as Carmen.NET API
    participant Auth as Authentication Service
    participant DB as Database

    Client->>API: POST /api/account/login<br/>{username, password}
    API->>Auth: Validate Credentials
    Auth->>DB: Check User + Password Hash
    DB-->>Auth: User Record + Permissions
    Auth->>Auth: Generate JWT Token
    Auth-->>API: JWT Token + User Info
    API-->>Client: 200 OK<br/>{token, refreshToken, user}

    Note over Client: Store tokens securely

    Client->>API: GET /api/ap/invoice/list<br/>Authorization: Bearer {token}
    API->>API: Validate JWT
    API->>API: Check Permissions
    API->>DB: Query Data (with tenant filter)
    DB-->>API: Invoice Data
    API-->>Client: 200 OK<br/>{invoices}

    Note over Client: Token expires after 60 minutes

    Client->>API: POST /api/account/refresh-token<br/>{refreshToken}
    API->>Auth: Validate Refresh Token
    Auth->>Auth: Generate New JWT
    Auth-->>API: New JWT Token
    API-->>Client: 200 OK<br/>{token}
```

## Authentication Flow

### Step 1: User Login

**Endpoint**: `POST /api/account/login`

**Request**:
```json
{
  "userName": "john.doe@company.com",
  "password": "SecurePassword123!",
  "useTenant": "TENANT001"
}
```

**Response (Success - 200 OK)**:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "refresh_token_here",
  "tokenExpiration": "2025-10-06T11:30:00Z",
  "user": {
    "userId": "12345",
    "userName": "john.doe@company.com",
    "fullName": "John Doe",
    "email": "john.doe@company.com",
    "roles": ["AP.Manager", "AR.Clerk"],
    "tenantCode": "TENANT001",
    "tenantName": "ABC Corporation",
    "permissions": {
      "AP.Invoice.View": true,
      "AP.Invoice.Create": true,
      "AP.Invoice.Approve": true
    }
  }
}
```

**Response (Error - 401 Unauthorized)**:
```json
{
  "success": false,
  "code": "INVALID_CREDENTIALS",
  "message": "Invalid username or password",
  "timestamp": "2025-10-06T10:30:00Z"
}
```

### Step 2: Using Access Token

Include the JWT token in the `Authorization` header for all subsequent API requests:

```http
GET /api/ap/invoice/list HTTP/1.1
Host: api.carmen.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

### Step 3: Token Refresh

Tokens expire after 60 minutes. Use the refresh token to obtain a new access token without requiring the user to log in again.

**Endpoint**: `POST /api/account/refresh-token`

**Request**:
```json
{
  "refreshToken": "refresh_token_here"
}
```

**Response (Success - 200 OK)**:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenExpiration": "2025-10-06T12:30:00Z"
}
```

### Step 4: Logout

**Endpoint**: `POST /api/account/logout`

**Request**:
```http
POST /api/account/logout HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response (Success - 200 OK)**:
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

## JWT Token Structure

### Token Claims

Carmen.NET JWT tokens include the following claims:

```json
{
  "sub": "12345",
  "name": "John Doe",
  "email": "john.doe@company.com",
  "tenant": "TENANT001",
  "roles": ["AP.Manager", "AR.Clerk"],
  "permissions": [
    "AP.Invoice.View",
    "AP.Invoice.Create",
    "AP.Invoice.Approve"
  ],
  "iat": 1696596600,
  "exp": 1696600200,
  "iss": "Carmen.NET",
  "aud": "Carmen.API"
}
```

### Claim Descriptions

| Claim | Description | Example |
|-------|-------------|---------|
| **sub** | User ID (subject) | `"12345"` |
| **name** | Full name of user | `"John Doe"` |
| **email** | User email address | `"john.doe@company.com"` |
| **tenant** | Tenant code for multi-tenancy | `"TENANT001"` |
| **roles** | User roles array | `["AP.Manager"]` |
| **permissions** | User permissions array | `["AP.Invoice.View"]` |
| **iat** | Issued at (Unix timestamp) | `1696596600` |
| **exp** | Expiration time (Unix timestamp) | `1696600200` |
| **iss** | Token issuer | `"Carmen.NET"` |
| **aud** | Token audience | `"Carmen.API"` |

## Multi-Tenant Authentication

### Tenant Selection

Carmen.NET supports multi-tenant architecture. Users may have access to multiple tenants.

**Login with Tenant**:
```json
{
  "userName": "john.doe@company.com",
  "password": "SecurePassword123!",
  "useTenant": "TENANT001"
}
```

**Get Available Tenants**:

**Endpoint**: `GET /api/account/tenants`

**Response**:
```json
{
  "success": true,
  "tenants": [
    {
      "tenantCode": "TENANT001",
      "tenantName": "ABC Corporation",
      "isActive": true
    },
    {
      "tenantCode": "TENANT002",
      "tenantName": "XYZ Limited",
      "isActive": true
    }
  ]
}
```

**Switch Tenant**:

**Endpoint**: `POST /api/account/switch-tenant`

**Request**:
```json
{
  "tenantCode": "TENANT002"
}
```

**Response**:
```json
{
  "success": true,
  "token": "new_jwt_token_here",
  "tenant": {
    "tenantCode": "TENANT002",
    "tenantName": "XYZ Limited"
  }
}
```

## Permission-Based Authorization

### Permission Model

Every API endpoint is protected by specific permissions. The JWT token includes all user permissions.

**Permission Naming Convention**: `{Module}.{Entity}.{Action}`

Examples:
- `AP.Invoice.View`
- `AP.Invoice.Create`
- `AP.Invoice.Update`
- `AP.Invoice.Delete`
- `AP.Invoice.Approve`
- `AP.Invoice.Post`

### Permission Check Flow

```mermaid
flowchart TD
    Request[API Request] --> ValidateToken{Valid JWT<br/>Token?}
    ValidateToken -->|No| Unauthorized[401 Unauthorized]
    ValidateToken -->|Yes| CheckExpired{Token<br/>Expired?}

    CheckExpired -->|Yes| Unauthorized
    CheckExpired -->|No| ExtractPermissions[Extract Permissions<br/>from Token]

    ExtractPermissions --> CheckPermission{Has Required<br/>Permission?}
    CheckPermission -->|No| Forbidden[403 Forbidden]
    CheckPermission -->|Yes| CheckTenant{Tenant<br/>Match?}

    CheckTenant -->|No| Forbidden
    CheckTenant -->|Yes| AllowRequest[Process Request]
```

### Common Permission Patterns

| Action | Required Permission | Example Endpoint |
|--------|---------------------|------------------|
| **View List** | `{Module}.{Entity}.View` | `GET /api/ap/invoice/list` |
| **View Details** | `{Module}.{Entity}.View` | `GET /api/ap/invoice/{id}` |
| **Create** | `{Module}.{Entity}.Create` | `POST /api/ap/invoice/create` |
| **Update** | `{Module}.{Entity}.Update` | `PUT /api/ap/invoice/update` |
| **Delete** | `{Module}.{Entity}.Delete` | `DELETE /api/ap/invoice/{id}` |
| **Approve** | `{Module}.{Entity}.Approve` | `POST /api/ap/invoice/approve/{id}` |
| **Post to GL** | `{Module}.{Entity}.Post` | `POST /api/ap/invoice/post/{id}` |

## Error Responses

### 401 Unauthorized

**Causes**:
- Missing `Authorization` header
- Invalid JWT token
- Expired JWT token
- Malformed token

**Response**:
```json
{
  "success": false,
  "code": "UNAUTHORIZED",
  "message": "Authentication required. Please provide a valid token.",
  "timestamp": "2025-10-06T10:30:00Z"
}
```

### 403 Forbidden

**Causes**:
- User lacks required permission
- Tenant mismatch
- Account locked or disabled

**Response**:
```json
{
  "success": false,
  "code": "FORBIDDEN",
  "message": "You do not have permission to perform this action. Required permission: AP.Invoice.Approve",
  "requiredPermission": "AP.Invoice.Approve",
  "timestamp": "2025-10-06T10:30:00Z"
}
```

## Security Best Practices

### Token Storage

**Web Applications**:
- Store access token in memory (not localStorage)
- Store refresh token in httpOnly cookie
- Implement token refresh on page load

**Mobile Applications**:
- Use secure storage (Keychain on iOS, Keystore on Android)
- Never store tokens in plain text
- Clear tokens on logout

**Desktop Applications**:
- Use OS credential storage
- Encrypt tokens before storage
- Clear tokens on application exit

### Token Transmission

- Always use HTTPS for API communication
- Never log tokens in console or logs
- Never include tokens in URL query parameters
- Use `Authorization` header for all requests

### Token Lifecycle

```mermaid
flowchart LR
    Login[Login] --> Issued[Token Issued<br/>60 min lifetime]
    Issued --> Use[Use Token<br/>in API calls]
    Use --> CheckExpiry{Token<br/>Expiring Soon?}

    CheckExpiry -->|< 5 min| Refresh[Refresh Token]
    CheckExpiry -->|> 5 min| Use

    Refresh --> Issued

    Use --> Logout[Logout]
    Logout --> Revoked[Token Revoked]
```

**Token Expiration**:
- Access token: 60 minutes
- Refresh token: 7 days
- Implement proactive token refresh (5 minutes before expiry)

**Token Revocation**:
- Logout revokes both access and refresh tokens
- Password change revokes all user tokens
- Account disable revokes all user tokens

## Code Examples

### C# / .NET

```csharp
using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

public class CarmenApiClient
{
    private readonly HttpClient _httpClient;
    private string _accessToken;
    private string _refreshToken;

    public CarmenApiClient(string baseUrl)
    {
        _httpClient = new HttpClient { BaseAddress = new Uri(baseUrl) };
    }

    public async Task<bool> LoginAsync(string userName, string password, string tenantCode)
    {
        var loginRequest = new
        {
            userName,
            password,
            useTenant = tenantCode
        };

        var content = new StringContent(
            JsonSerializer.Serialize(loginRequest),
            Encoding.UTF8,
            "application/json"
        );

        var response = await _httpClient.PostAsync("/api/account/login", content);

        if (response.IsSuccessStatusCode)
        {
            var result = await JsonSerializer.DeserializeAsync<LoginResponse>(
                await response.Content.ReadAsStreamAsync()
            );

            _accessToken = result.Token;
            _refreshToken = result.RefreshToken;

            // Set default authorization header
            _httpClient.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", _accessToken);

            return true;
        }

        return false;
    }

    public async Task<T> GetAsync<T>(string endpoint)
    {
        var response = await _httpClient.GetAsync(endpoint);

        if (response.StatusCode == System.Net.HttpStatusCode.Unauthorized)
        {
            // Token expired, try to refresh
            if (await RefreshTokenAsync())
            {
                // Retry request with new token
                response = await _httpClient.GetAsync(endpoint);
            }
        }

        response.EnsureSuccessStatusCode();

        return await JsonSerializer.DeserializeAsync<T>(
            await response.Content.ReadAsStreamAsync()
        );
    }

    private async Task<bool> RefreshTokenAsync()
    {
        var refreshRequest = new { refreshToken = _refreshToken };
        var content = new StringContent(
            JsonSerializer.Serialize(refreshRequest),
            Encoding.UTF8,
            "application/json"
        );

        var response = await _httpClient.PostAsync("/api/account/refresh-token", content);

        if (response.IsSuccessStatusCode)
        {
            var result = await JsonSerializer.DeserializeAsync<RefreshResponse>(
                await response.Content.ReadAsStreamAsync()
            );

            _accessToken = result.Token;
            _httpClient.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", _accessToken);

            return true;
        }

        return false;
    }
}

// Usage
var client = new CarmenApiClient("https://api.carmen.com");
await client.LoginAsync("john.doe@company.com", "password", "TENANT001");

var invoices = await client.GetAsync<InvoiceListResponse>("/api/ap/invoice/list");
```

### JavaScript / TypeScript

```typescript
class CarmenApiClient {
    private baseUrl: string;
    private accessToken: string | null = null;
    private refreshToken: string | null = null;

    constructor(baseUrl: string) {
        this.baseUrl = baseUrl;
    }

    async login(userName: string, password: string, tenantCode: string): Promise<boolean> {
        const response = await fetch(`${this.baseUrl}/api/account/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                userName,
                password,
                useTenant: tenantCode,
            }),
        });

        if (response.ok) {
            const result = await response.json();
            this.accessToken = result.token;
            this.refreshToken = result.refreshToken;

            // Store refresh token securely
            this.storeRefreshToken(result.refreshToken);

            return true;
        }

        return false;
    }

    async get<T>(endpoint: string): Promise<T> {
        let response = await fetch(`${this.baseUrl}${endpoint}`, {
            headers: {
                'Authorization': `Bearer ${this.accessToken}`,
                'Content-Type': 'application/json',
            },
        });

        if (response.status === 401) {
            // Token expired, try to refresh
            if (await this.refreshAccessToken()) {
                // Retry request with new token
                response = await fetch(`${this.baseUrl}${endpoint}`, {
                    headers: {
                        'Authorization': `Bearer ${this.accessToken}`,
                        'Content-Type': 'application/json',
                    },
                });
            }
        }

        if (!response.ok) {
            throw new Error(`API error: ${response.statusText}`);
        }

        return await response.json();
    }

    private async refreshAccessToken(): Promise<boolean> {
        const response = await fetch(`${this.baseUrl}/api/account/refresh-token`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                refreshToken: this.refreshToken,
            }),
        });

        if (response.ok) {
            const result = await response.json();
            this.accessToken = result.token;
            return true;
        }

        return false;
    }

    private storeRefreshToken(token: string): void {
        // Store in httpOnly cookie or secure storage
        // Never store in localStorage
        document.cookie = `refreshToken=${token}; Secure; HttpOnly; SameSite=Strict; Max-Age=604800`;
    }
}

// Usage
const client = new CarmenApiClient('https://api.carmen.com');
await client.login('john.doe@company.com', 'password', 'TENANT001');

const invoices = await client.get('/api/ap/invoice/list');
```

### Python

```python
import requests
from typing import Optional, Dict, Any
from datetime import datetime, timedelta

class CarmenApiClient:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.access_token: Optional[str] = None
        self.refresh_token: Optional[str] = None
        self.token_expiry: Optional[datetime] = None

    def login(self, user_name: str, password: str, tenant_code: str) -> bool:
        response = requests.post(
            f"{self.base_url}/api/account/login",
            json={
                "userName": user_name,
                "password": password,
                "useTenant": tenant_code
            }
        )

        if response.status_code == 200:
            result = response.json()
            self.access_token = result['token']
            self.refresh_token = result['refreshToken']
            self.token_expiry = datetime.fromisoformat(
                result['tokenExpiration'].replace('Z', '+00:00')
            )
            return True

        return False

    def get(self, endpoint: str) -> Dict[str, Any]:
        # Check if token needs refresh
        if self.token_expiry and datetime.now() >= self.token_expiry - timedelta(minutes=5):
            self._refresh_token()

        headers = {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/json"
        }

        response = requests.get(f"{self.base_url}{endpoint}", headers=headers)

        if response.status_code == 401:
            # Token expired, try to refresh
            if self._refresh_token():
                # Retry request with new token
                headers["Authorization"] = f"Bearer {self.access_token}"
                response = requests.get(f"{self.base_url}{endpoint}", headers=headers)

        response.raise_for_status()
        return response.json()

    def _refresh_token(self) -> bool:
        response = requests.post(
            f"{self.base_url}/api/account/refresh-token",
            json={"refreshToken": self.refresh_token}
        )

        if response.status_code == 200:
            result = response.json()
            self.access_token = result['token']
            self.token_expiry = datetime.fromisoformat(
                result['tokenExpiration'].replace('Z', '+00:00')
            )
            return True

        return False

# Usage
client = CarmenApiClient('https://api.carmen.com')
client.login('john.doe@company.com', 'password', 'TENANT001')

invoices = client.get('/api/ap/invoice/list')
```

## Troubleshooting

### Common Issues

| Issue | Symptom | Solution |
|-------|---------|----------|
| **Token Expired** | 401 Unauthorized | Use refresh token to obtain new access token |
| **Invalid Signature** | 401 Unauthorized | Token tampered, obtain new token via login |
| **Permission Denied** | 403 Forbidden | Contact administrator to grant required permission |
| **Tenant Mismatch** | 403 Forbidden | Login with correct tenant or switch tenant |
| **Token Missing** | 401 Unauthorized | Include `Authorization: Bearer {token}` header |

### Testing Authentication

Use Postman or curl to test authentication:

```bash
# Login
curl -X POST https://api.carmen.com/api/account/login \
  -H "Content-Type: application/json" \
  -d '{
    "userName": "john.doe@company.com",
    "password": "password",
    "useTenant": "TENANT001"
  }'

# Use token
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X GET https://api.carmen.com/api/ap/invoice/list \
  -H "Authorization: Bearer $TOKEN"
```

---

**Document Version**: 1.0
**Last Updated**: 2025-10-06
**Status**: Phase 4 - API & Integration Documentation
