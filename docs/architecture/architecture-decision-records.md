# Architecture Decision Records (ADRs)

**Document Version**: 1.0
**Last Updated**: 2025-10-06
**Status**: Phase 5 - Solution Architect Documentation

---

## Overview

This document captures key architectural decisions made during the design and evolution of the Carmen.NET ERP system. Each ADR follows a structured format documenting the context, decision, consequences, and rationale.

**ADR Format**:
- **Title**: Short, descriptive name
- **Status**: Proposed | Accepted | Deprecated | Superseded
- **Date**: Decision date
- **Context**: Problem and constraints
- **Decision**: What was decided
- **Consequences**: Positive and negative outcomes
- **Alternatives Considered**: Other options evaluated

---

## ADR Index

| ADR # | Title | Status | Date |
|-------|-------|--------|------|
| ADR-001 | Multi-Tenant Architecture | ✅ Accepted | 2020-Q1 |
| ADR-002 | ASP.NET Web API Framework | ✅ Accepted | 2020-Q1 |
| ADR-003 | JWT Authentication | ✅ Accepted | 2020-Q2 |
| ADR-004 | Repository Pattern | ✅ Accepted | 2020-Q2 |
| ADR-005 | Entity Framework 6.x ORM | ✅ Accepted | 2020-Q2 |
| ADR-006 | Modular Monolith Architecture | ✅ Accepted | 2020-Q3 |
| ADR-007 | Database-First Approach | ✅ Accepted | 2020-Q3 |
| ADR-008 | State Machine Workflows | ✅ Accepted | 2020-Q4 |
| ADR-009 | Role-Based Access Control (RBAC) | ✅ Accepted | 2020-Q4 |
| ADR-010 | Synchronous API Design | ✅ Accepted | 2021-Q1 |
| ADR-011 | 10-Digit Chart of Accounts | ✅ Accepted | 2021-Q2 |
| ADR-012 | WHT & VAT Tax Engine | ✅ Accepted | 2021-Q2 |
| ADR-013 | Excel Integration Strategy | ✅ Accepted | 2021-Q3 |
| ADR-014 | File-Based Import/Export | ✅ Accepted | 2021-Q4 |
| ADR-015 | Centralized Error Handling | ✅ Accepted | 2022-Q1 |

---

## ADR-001: Multi-Tenant Architecture

**Status**: ✅ Accepted
**Date**: 2020-Q1
**Decision Maker**: Solution Architect

### Context

The Carmen.NET ERP system needed to support multiple independent organizations (tenants) using a single codebase and infrastructure, with complete data isolation and tenant-specific configuration.

**Requirements**:
- Complete data isolation between tenants
- Shared codebase for all tenants
- Tenant-specific customization support
- Cost-effective infrastructure utilization
- Scalability to 100+ tenants

### Decision

**Implement multi-tenant architecture with row-level tenant isolation using `TenantCode` discriminator.**

**Key Design**:
```csharp
public abstract class TenantEntity
{
    public string TenantCode { get; set; }
    // Other common properties
}

// Applied automatically via base service
public class FncBase
{
    protected void ApplyTenantIfUseTenant(IQueryable<T> query)
    {
        if (UseTenant)
            query = query.Where(x => x.TenantCode == CurrentTenantCode);
    }
}
```

**Tenant Identification**:
- JWT token contains `TenantCode` claim
- All database queries filtered by `TenantCode`
- Tenant context established at authentication

### Consequences

**Positive**:
- ✅ Single codebase reduces maintenance costs by 70%
- ✅ Efficient resource utilization (shared infrastructure)
- ✅ Easy tenant onboarding (add tenant record + data)
- ✅ Centralized updates benefit all tenants simultaneously
- ✅ Cost-effective scaling

**Negative**:
- ⚠️ Requires careful query filtering to prevent data leakage
- ⚠️ Performance impact from additional WHERE clause
- ⚠️ Complex backup/restore for single tenant
- ⚠️ "Noisy neighbor" risk (one tenant affects others)
- ⚠️ Limited tenant-specific customization

**Mitigation**:
- Enforce `TenantCode` filtering at base service level
- Database indexes on `TenantCode` for performance
- Resource quotas per tenant
- Tenant-specific configuration tables

### Alternatives Considered

**1. Database-per-Tenant**
- ❌ Rejected: High infrastructure costs, complex updates
- ✅ Benefit: Complete isolation, easier backup/restore
- Decision: Cost outweighs benefits for target market (SMBs)

**2. Schema-per-Tenant**
- ❌ Rejected: Database schema proliferation, update complexity
- ✅ Benefit: Better isolation than row-level
- Decision: Adds complexity without significant benefit

**3. Separate Application Instances**
- ❌ Rejected: Highest cost, no code sharing
- ✅ Benefit: Complete isolation, tenant-specific customization
- Decision: Not cost-effective for target market

---

## ADR-002: ASP.NET Web API Framework

**Status**: ✅ Accepted
**Date**: 2020-Q1
**Decision Maker**: Solution Architect

### Context

Need to select a web framework for building RESTful API backend that supports:
- High performance and scalability
- Strong typing and compile-time safety
- Mature ecosystem and community support
- Integration with Microsoft SQL Server
- Long-term vendor support

### Decision

**Use ASP.NET Web API (.NET Framework 4.x) as the primary backend framework.**

**Rationale**:
- Mature, proven framework with 10+ years of production use
- Excellent performance (10,000+ requests/second)
- Strong typing with C# language
- Native SQL Server integration
- Large developer talent pool in Thailand
- Microsoft long-term support

### Consequences

**Positive**:
- ✅ Excellent performance and scalability
- ✅ Strong typing prevents runtime errors
- ✅ Mature ecosystem (NuGet packages)
- ✅ Easy to find ASP.NET developers
- ✅ Comprehensive documentation

**Negative**:
- ⚠️ Windows-only deployment (.NET Framework)
- ⚠️ Monolithic architecture (not microservices-friendly)
- ⚠️ Larger memory footprint than alternatives
- ⚠️ Vendor lock-in to Microsoft stack

**Mitigation**:
- Plan migration to .NET Core/.NET 8 for cross-platform support
- Use modular monolith pattern for future microservices extraction
- Containerization for deployment flexibility

### Alternatives Considered

**1. Node.js + Express**
- ❌ Rejected: Weaker typing, less mature for enterprise
- ✅ Benefit: Cross-platform, JavaScript ecosystem
- Decision: Type safety critical for financial ERP

**2. Java Spring Boot**
- ❌ Rejected: Smaller developer pool in Thailand
- ✅ Benefit: Cross-platform, mature ecosystem
- Decision: .NET expertise more available locally

**3. Python Django/Flask**
- ❌ Rejected: Performance concerns for high-volume transactions
- ✅ Benefit: Rapid development, good for data processing
- Decision: Performance critical for real-time ERP

---

## ADR-003: JWT Authentication

**Status**: ✅ Accepted
**Date**: 2020-Q2
**Decision Maker**: Security Architect

### Context

Need secure, stateless authentication mechanism for:
- RESTful API (stateless)
- Mobile clients (token-based)
- Third-party integrations
- Multi-tenant environment
- Session management across load-balanced servers

### Decision

**Implement JWT (JSON Web Tokens) for authentication with Bearer token scheme.**

**Token Structure**:
```json
{
  "sub": "user123",
  "email": "user@tenant.com",
  "tenantCode": "TENANT001",
  "roles": ["AP.Manager", "AR.Clerk"],
  "exp": 1735689600,
  "iat": 1735603200
}
```

**Flow**:
1. User logs in with email/password
2. Server validates and returns JWT access token (15 min) + refresh token (7 days)
3. Client includes token in `Authorization: Bearer {token}` header
4. Server validates token signature and expiration
5. Server extracts claims (user, tenant, roles) for authorization

### Consequences

**Positive**:
- ✅ Stateless (no server-side session storage)
- ✅ Scalable (works with load balancers)
- ✅ Mobile-friendly (token-based)
- ✅ Self-contained (all info in token)
- ✅ Industry standard (widespread support)

**Negative**:
- ⚠️ Cannot revoke tokens before expiration
- ⚠️ Token size larger than session ID
- ⚠️ Sensitive data in token (needs encryption)
- ⚠️ XSS vulnerability if stored in localStorage

**Mitigation**:
- Short token expiration (15 minutes)
- Refresh token rotation for security
- Store tokens in httpOnly cookies (web) or secure storage (mobile)
- Token blacklist for critical revocations

### Alternatives Considered

**1. Session-Based Authentication**
- ❌ Rejected: Requires sticky sessions or shared session store
- ✅ Benefit: Easy revocation, smaller overhead
- Decision: Scalability concerns with load balancing

**2. OAuth 2.0 with External Provider**
- ❌ Rejected: Adds external dependency, complexity
- ✅ Benefit: Delegated authentication, SSO
- Decision: Internal users don't require external OAuth

**3. API Keys**
- ❌ Rejected: No user context, difficult to rotate
- ✅ Benefit: Simple, long-lived
- Decision: Need user-level permissions, not just API access

---

## ADR-004: Repository Pattern

**Status**: ✅ Accepted
**Date**: 2020-Q2
**Decision Maker**: Lead Developer

### Context

Need consistent data access layer that:
- Abstracts database implementation
- Provides testability (mock repositories)
- Centralizes query logic
- Supports multiple data sources
- Maintains clean separation of concerns

### Decision

**Implement Repository Pattern with generic base repository and entity-specific repositories.**

**Pattern**:
```csharp
// Generic base repository
public class Repository<T> : IRepository<T> where T : class
{
    protected DbContext Context { get; }

    public virtual IQueryable<T> GetAll() => Context.Set<T>();
    public virtual T GetById(int id) => Context.Set<T>().Find(id);
    public virtual void Add(T entity) => Context.Set<T>().Add(entity);
    // ... other CRUD operations
}

// Entity-specific repository
public class ApInvoiceRepository : Repository<ApInvoiceHeader>
{
    public IQueryable<ApInvoiceHeader> GetPendingApproval()
    {
        return GetAll().Where(x => x.Status == "PendingApproval");
    }
}
```

### Consequences

**Positive**:
- ✅ Clean separation: Controllers → Services → Repositories → Database
- ✅ Testability: Easy to mock repositories
- ✅ Reusability: Generic base repository
- ✅ Flexibility: Can switch data sources
- ✅ Encapsulation: Business queries in repositories

**Negative**:
- ⚠️ Additional abstraction layer (complexity)
- ⚠️ Potential performance overhead
- ⚠️ Risk of "leaky abstraction" (IQueryable exposure)
- ⚠️ More code to maintain

**Mitigation**:
- Use IQueryable for flexibility, but encapsulate complex queries
- Performance testing to identify bottlenecks
- Clear repository interface contracts

### Alternatives Considered

**1. Direct DbContext Usage**
- ❌ Rejected: Tight coupling, difficult to test
- ✅ Benefit: Simpler, less abstraction
- Decision: Testability and separation of concerns critical

**2. CQRS with Separate Read/Write Models**
- ❌ Rejected: Over-engineering for current scale
- ✅ Benefit: Optimized reads and writes
- Decision: Complexity not justified yet (future consideration)

---

## ADR-005: Entity Framework 6.x ORM

**Status**: ✅ Accepted
**Date**: 2020-Q2
**Decision Maker**: Database Architect

### Context

Need Object-Relational Mapping (ORM) tool for:
- Type-safe database queries (LINQ)
- Automatic change tracking
- Database schema management
- Reduced SQL boilerplate
- Integration with ASP.NET Web API

### Decision

**Use Entity Framework 6.x as the ORM layer.**

**Approach**:
- Database-First (generate models from existing database)
- DbContext per module (ApContext, ArContext, etc.)
- Lazy loading disabled (explicit eager loading)
- Query optimization with Include/AsNoTracking

### Consequences

**Positive**:
- ✅ Type-safe LINQ queries (compile-time checking)
- ✅ Automatic change tracking (no manual SQL updates)
- ✅ Reduced boilerplate code (80% less SQL)
- ✅ Migration support (code-first when needed)
- ✅ Strong Microsoft support

**Negative**:
- ⚠️ Performance overhead vs. raw SQL (10-20%)
- ⚠️ N+1 query problem if not careful
- ⚠️ Complex queries can be slower than stored procedures
- ⚠️ Learning curve for optimization

**Mitigation**:
- Profiling and query optimization
- Use AsNoTracking for read-only queries
- Explicit Include for eager loading
- Stored procedures for complex reports

### Alternatives Considered

**1. Dapper (Micro-ORM)**
- ❌ Rejected: Less productivity, more manual mapping
- ✅ Benefit: Better performance, lightweight
- Decision: Productivity more important than marginal performance

**2. Raw ADO.NET**
- ❌ Rejected: Too much boilerplate, error-prone
- ✅ Benefit: Maximum performance control
- Decision: Maintainability concerns

**3. NHibernate**
- ❌ Rejected: Smaller community, complex configuration
- ✅ Benefit: More mature, feature-rich
- Decision: EF better Microsoft ecosystem integration

---

## ADR-006: Modular Monolith Architecture

**Status**: ✅ Accepted
**Date**: 2020-Q3
**Decision Maker**: Solution Architect

### Context

Need architectural style that:
- Supports 11 distinct business modules
- Allows independent module development
- Maintains single deployment unit
- Provides clear module boundaries
- Enables future microservices extraction

### Decision

**Adopt Modular Monolith architecture with clear module boundaries.**

**Structure**:
```
Carmen.NET.sln
├── Carmen.Ap/          (AP Module)
│   ├── Controllers/
│   ├── Services/
│   ├── Repositories/
│   └── Models/
├── Carmen.Ar/          (AR Module)
├── Carmen.Gl/          (GL Module)
├── Carmen.Asset/       (Asset Module)
├── Carmen.Common/      (Shared utilities)
└── Carmen.Api/         (API host)
```

**Module Isolation**:
- Each module has own namespace
- No cross-module direct dependencies
- Communication via shared interfaces or events
- Shared entities in Common module

### Consequences

**Positive**:
- ✅ Clear module boundaries (maintainability)
- ✅ Independent module development
- ✅ Single deployment (simplicity)
- ✅ Shared infrastructure (cost-effective)
- ✅ Easy to extract modules later (microservices path)

**Negative**:
- ⚠️ Risk of tight coupling if not disciplined
- ⚠️ Single database (not ideal for microservices)
- ⚠️ All modules scale together
- ⚠️ One module failure can affect others

**Mitigation**:
- Strict module dependency rules
- Shared kernel pattern for common code
- Health checks per module
- Plan for future microservices extraction

### Alternatives Considered

**1. Microservices Architecture**
- ❌ Rejected: Over-engineering for current scale
- ✅ Benefit: Independent scaling, fault isolation
- Decision: Complexity not justified (10 modules, single team)

**2. Layered Monolith**
- ❌ Rejected: Poor module boundaries
- ✅ Benefit: Simpler, traditional approach
- Decision: Module independence important for future

---

## ADR-007: Database-First Approach

**Status**: ✅ Accepted
**Date**: 2020-Q3
**Decision Maker**: Database Architect

### Context

Need to decide between Code-First vs. Database-First for Entity Framework:
- Database design experience in team
- Complex financial schema requirements
- Need for database-level constraints
- Performance optimization needs

### Decision

**Use Database-First approach with T4 templates for model generation.**

**Workflow**:
1. Design database schema in SQL Server Management Studio
2. Apply migrations via SQL scripts
3. Generate EF models using T4 templates
4. Customize models with partial classes

### Consequences

**Positive**:
- ✅ DBA-friendly (visual database design)
- ✅ Database constraints at DB level (triggers, check constraints)
- ✅ Performance optimization (indexes, partitions)
- ✅ Schema version control (SQL scripts)
- ✅ Model generation automation

**Negative**:
- ⚠️ Manual synchronization (schema → models)
- ⚠️ Risk of model regeneration overwriting customizations
- ⚠️ Migrations not automatic (manual SQL scripts)
- ⚠️ Less C#-centric workflow

**Mitigation**:
- Partial classes for customizations
- T4 template customization
- Migration script versioning
- Clear sync process documentation

### Alternatives Considered

**1. Code-First Migrations**
- ❌ Rejected: Team prefers database design tools
- ✅ Benefit: Automatic migrations, version control
- Decision: DBA expertise better utilized with DB-first

**2. Hybrid (Code-First for new, DB-First for existing)**
- ❌ Rejected: Inconsistent approach, confusion
- ✅ Benefit: Best of both worlds
- Decision: Consistency more important

---

## ADR-008: State Machine Workflows

**Status**: ✅ Accepted
**Date**: 2020-Q4
**Decision Maker**: Business Analyst + Architect

### Context

Business processes (invoice approval, payment processing, period close) require:
- Clear state transitions
- Approval workflows
- Audit trail
- Status validation
- Rollback capabilities

### Decision

**Implement state machine pattern for core workflows with status enums and validation.**

**Pattern**:
```csharp
public enum ApInvoiceStatus
{
    Draft = 1,
    PendingApproval = 2,
    Approved = 3,
    Rejected = 4,
    Posted = 5,
    PartiallyPaid = 6,
    FullyPaid = 7,
    Cancelled = 8
}

// Allowed transitions
Dictionary<ApInvoiceStatus, List<ApInvoiceStatus>> transitions = new()
{
    { Draft, new() { PendingApproval, Cancelled } },
    { PendingApproval, new() { Approved, Rejected } },
    { Approved, new() { Posted, Cancelled } },
    // ...
};
```

### Consequences

**Positive**:
- ✅ Clear business process visibility
- ✅ Prevents invalid state transitions
- ✅ Audit trail (status history)
- ✅ Easy to understand and maintain
- ✅ Supports complex approval workflows

**Negative**:
- ⚠️ Rigidity (difficult to change states)
- ⚠️ Complex transition logic for multi-path workflows
- ⚠️ Status proliferation (many statuses)

**Mitigation**:
- Centralized state transition validation
- Status history table for audit
- Clear documentation of allowed transitions

### Alternatives Considered

**1. Workflow Engine (Windows Workflow Foundation)**
- ❌ Rejected: Over-engineering, complex configuration
- ✅ Benefit: Visual workflow designer, complex routing
- Decision: Simple state machines sufficient

**2. Boolean Flags (IsApproved, IsPosted, etc.)**
- ❌ Rejected: Unclear state, no workflow
- ✅ Benefit: Flexible
- Decision: Lack of clarity, difficult to maintain

---

## ADR-009: Role-Based Access Control (RBAC)

**Status**: ✅ Accepted
**Date**: 2020-Q4
**Decision Maker**: Security Architect

### Context

Need fine-grained access control for:
- 11 modules with different permissions
- Multiple user roles (clerk, manager, controller, admin)
- CRUD operations per entity
- Special permissions (approve, post, close)
- Multi-tenant environment

### Decision

**Implement RBAC with module.entity.action permission naming convention.**

**Permission Format**: `{Module}.{Entity}.{Action}`

**Examples**:
- `AP.Invoice.View`
- `AP.Invoice.Create`
- `AP.Invoice.Approve`
- `AR.Receipt.Post`
- `GL.Period.Close`

**Implementation**:
```csharp
[Authorize]
[Permission("AP.Invoice.Approve")]
public async Task<IActionResult> ApproveInvoice(int id)
{
    // Permission checked via custom authorization filter
}
```

### Consequences

**Positive**:
- ✅ Granular permissions (100+ permissions)
- ✅ Clear naming convention
- ✅ Role composition (roles contain permissions)
- ✅ Easy to understand and audit
- ✅ Supports multi-tenant (permissions per tenant)

**Negative**:
- ⚠️ Permission proliferation (management complexity)
- ⚠️ No dynamic permissions (code-based)
- ⚠️ Performance (permission check on each request)

**Mitigation**:
- Permission caching in JWT token
- Admin UI for role/permission management
- Permission grouping by role templates

### Alternatives Considered

**1. Claims-Based Authorization**
- ❌ Rejected: Less structured, harder to manage
- ✅ Benefit: Flexible, built-in .NET support
- Decision: Structure needed for audit and management

**2. Attribute-Based Access Control (ABAC)**
- ❌ Rejected: Too complex for current needs
- ✅ Benefit: Policy-based, very flexible
- Decision: RBAC sufficient for current requirements

---

## ADR-010: Synchronous API Design

**Status**: ✅ Accepted
**Date**: 2021-Q1
**Decision Maker**: Lead Developer

### Context

Need to decide between synchronous vs. asynchronous API design:
- Most operations complete in <2 seconds
- Clients expect immediate response
- Database operations are primary bottleneck
- Limited long-running operations

### Decision

**Use synchronous API design with async/await for I/O operations.**

**Pattern**:
```csharp
[HttpPost]
public async Task<IActionResult> CreateInvoice([FromBody] ApInvoiceRequest request)
{
    // Async for I/O (database, external calls)
    var invoice = await _service.CreateInvoiceAsync(request);
    return Ok(invoice);
}
```

### Consequences

**Positive**:
- ✅ Simple request/response pattern
- ✅ Immediate feedback to user
- ✅ Easy error handling
- ✅ Client-side simplicity
- ✅ Async/await for I/O scalability

**Negative**:
- ⚠️ Client waits for long operations
- ⚠️ Not suitable for batch processing
- ⚠️ Timeout issues for slow operations

**Mitigation**:
- Background jobs for batch processing (e.g., period close)
- Polling for long-running operations
- Timeout configuration (30-60 seconds)

### Alternatives Considered

**1. Asynchronous (Job Queue) API**
- ❌ Rejected: Adds complexity for most operations
- ✅ Benefit: Better for long-running tasks
- Decision: Use for specific long-running operations only

**2. GraphQL**
- ❌ Rejected: Learning curve, over-engineering
- ✅ Benefit: Flexible queries, reduce over-fetching
- Decision: REST sufficient for current needs

---

## ADR-011: 10-Digit Chart of Accounts

**Status**: ✅ Accepted
**Date**: 2021-Q2
**Decision Maker**: CFO + Business Analyst

### Context

Need flexible chart of accounts structure that supports:
- Account hierarchy (Assets, Liabilities, Equity, Revenue, Expenses)
- Sub-account categorization
- Department/cost center tracking
- Project tracking
- Future extensibility

### Decision

**Implement 10-digit chart of accounts: AAAA-BB-CC-DD**

**Structure**:
- **AAAA** (4 digits): Main Account (1000-9999)
- **BB** (2 digits): Sub-Account (01-99)
- **CC** (2 digits): Department/Cost Center (01-99)
- **DD** (2 digits): Project/Segment (01-99)

**Examples**:
- `1100-00-00-00`: Cash in Bank
- `1100-01-00-00`: Cash in Bank - Checking
- `1100-01-10-00`: Cash in Bank - Checking - IT Department
- `5100-00-15-20`: Consulting Expense - Marketing Dept - Project Alpha

### Consequences

**Positive**:
- ✅ Flexible reporting (by account, dept, project)
- ✅ Multi-dimensional analysis
- ✅ Hierarchical structure (roll-ups)
- ✅ Supports future growth
- ✅ Industry-standard approach

**Negative**:
- ⚠️ Complex account code (10 digits)
- ⚠️ User training required
- ⚠️ Potential for misuse (wrong dimensions)

**Mitigation**:
- Account code validation
- Dropdown selectors (not free text)
- Default values for common scenarios
- Training documentation

### Alternatives Considered

**1. Simple 4-Digit Accounts**
- ❌ Rejected: Insufficient for multi-dimensional reporting
- ✅ Benefit: Simple, easy to use
- Decision: Flexibility needed for growing businesses

**2. Tag-Based Accounting**
- ❌ Rejected: Non-standard, difficult migration
- ✅ Benefit: Unlimited dimensions
- Decision: Traditional structure preferred by accountants

---

## ADR-012: WHT & VAT Tax Engine

**Status**: ✅ Accepted
**Date**: 2021-Q2
**Decision Maker**: Tax Compliance Officer + Architect

### Context

Thai tax regulations require:
- Withholding Tax (WHT): 3%, 5%, 10%, 15% based on transaction type
- Value Added Tax (VAT): 7% standard rate
- Tax exemptions and special cases
- Monthly tax filing
- Audit trail

### Decision

**Build custom tax engine with configurable tax codes and calculation rules.**

**Tax Code Structure**:
```csharp
public class TaxCode
{
    public string Code { get; set; }          // WHT05, VAT07
    public string Type { get; set; }          // WHT, VAT
    public decimal Rate { get; set; }         // 0.05, 0.07
    public string TransactionType { get; set; } // Service, Interest, Dividend
}
```

**Calculation Engine**:
```csharp
public class TaxCalculator
{
    public TaxResult Calculate(decimal amount, string taxCode)
    {
        var tax = _taxCodes[taxCode];
        var taxAmount = amount * tax.Rate;

        return new TaxResult
        {
            TaxableAmount = amount,
            TaxRate = tax.Rate,
            TaxAmount = taxAmount,
            NetAmount = amount - taxAmount  // For WHT
        };
    }
}
```

### Consequences

**Positive**:
- ✅ Compliant with Thai tax regulations
- ✅ Configurable tax codes (no code changes)
- ✅ Accurate calculations
- ✅ Audit trail (tax history)
- ✅ Monthly tax reports

**Negative**:
- ⚠️ Complex tax rules (multiple scenarios)
- ⚠️ Regulation changes require configuration updates
- ⚠️ Testing complexity

**Mitigation**:
- Tax code configuration UI
- Comprehensive test scenarios
- Regular compliance reviews

### Alternatives Considered

**1. Third-Party Tax Service**
- ❌ Rejected: Thai market specificity, cost
- ✅ Benefit: Automatic updates, less maintenance
- Decision: Custom solution more cost-effective

**2. Hardcoded Tax Rates**
- ❌ Rejected: Inflexible, requires code changes
- ✅ Benefit: Simple
- Decision: Configuration needed for rate changes

---

## ADR-013: Excel Integration Strategy

**Status**: ✅ Accepted
**Date**: 2021-Q3
**Decision Maker**: Product Owner + Architect

### Context

Users need:
- Bulk data entry (100+ invoices)
- Excel-based reporting
- Data export for analysis
- Familiar interface (Excel)
- Integration with existing Excel workflows

### Decision

**Support Excel integration via three approaches:**

1. **Template-Based Import**: Download Excel templates, fill data, upload
2. **Direct Export**: Export data to Excel format (XLSX)
3. **Excel Add-in** (future): Real-time Excel ↔ API integration

**Import Flow**:
```
1. Download Excel template (predefined columns)
2. User fills data in Excel
3. Upload file to API
4. Server validates and imports
5. Return error file for failed rows
```

### Consequences

**Positive**:
- ✅ Familiar interface (Excel)
- ✅ Bulk operations (100+ records)
- ✅ Offline data entry
- ✅ Power users productivity
- ✅ Ad-hoc reporting

**Negative**:
- ⚠️ Data validation complexity (Excel vs. API)
- ⚠️ Error handling (partial success)
- ⚠️ Version control (template changes)
- ⚠️ File size limitations

**Mitigation**:
- Clear validation rules in templates
- Error file with row-level errors
- Template versioning
- File size limits (100 MB, 100K rows)

### Alternatives Considered

**1. CSV Only**
- ❌ Rejected: Less user-friendly, no formulas
- ✅ Benefit: Simple, universal format
- Decision: Excel provides better UX

**2. Web-Based Bulk Entry**
- ❌ Rejected: Less efficient than Excel for power users
- ✅ Benefit: No file upload, instant validation
- Decision: Both approaches supported (web + Excel)

---

## ADR-014: File-Based Import/Export

**Status**: ✅ Accepted
**Date**: 2021-Q4
**Decision Maker**: Integration Specialist

### Context

Integration with external systems requires:
- Bank statement import (MT940, CSV)
- Tax filing export (TXT, XML)
- Third-party system integration
- Batch processing
- Scheduled imports

### Decision

**Support multiple file formats with standardized import/export API.**

**Supported Formats**:
- **CSV**: General data import/export
- **Excel (XLSX)**: User-friendly bulk entry
- **JSON**: API integration
- **XML**: Legacy system integration
- **MT940**: Bank statement import
- **PDF**: Document generation

**Import API**:
```http
POST /api/import/{module}/{entity}
Content-Type: multipart/form-data

file: <uploaded file>
options: {
  "validateOnly": false,
  "skipErrors": true,
  "batchSize": 100
}
```

### Consequences

**Positive**:
- ✅ Multiple format support
- ✅ Batch processing (1000+ records)
- ✅ Error handling (skip/fail fast)
- ✅ Validation before import
- ✅ Audit trail

**Negative**:
- ⚠️ Format parsing complexity
- ⚠️ Large file memory usage
- ⚠️ Validation complexity
- ⚠️ Error reporting

**Mitigation**:
- Streaming parsers for large files
- Row-by-row processing
- Comprehensive error messages
- File size limits (100 MB)

### Alternatives Considered

**1. API-Only Integration**
- ❌ Rejected: Requires technical expertise
- ✅ Benefit: Real-time, no file handling
- Decision: File-based needed for legacy systems

**2. Message Queue (RabbitMQ, Kafka)**
- ❌ Rejected: Over-engineering for current needs
- ✅ Benefit: Asynchronous, scalable
- Decision: File-based simpler for current requirements

---

## ADR-015: Centralized Error Handling

**Status**: ✅ Accepted
**Date**: 2022-Q1
**Decision Maker**: Lead Developer

### Context

Need consistent error handling across:
- 351+ API endpoints
- Validation errors
- Business rule violations
- System exceptions
- User-friendly error messages

### Decision

**Implement centralized error handling with standardized error codes and responses.**

**Error Response Format**:
```json
{
  "success": false,
  "code": "VAL-001",
  "message": "Validation failed",
  "errors": [
    {
      "field": "invoiceDate",
      "message": "Invoice date cannot be in the future"
    }
  ],
  "timestamp": "2025-10-06T10:30:00Z",
  "traceId": "abc-123-def-456"
}
```

**Error Categories**:
- **AUTH**: Authentication/authorization errors (AUTH-001 to AUTH-009)
- **VAL**: Validation errors (VAL-001 to VAL-008)
- **BUS**: Business rule violations (BUS-001 to BUS-010)
- **RES**: Resource errors (RES-001 to RES-005)
- **RATE**: Rate limiting (RATE-001 to RATE-002)
- **SRV**: Server errors (SRV-001 to SRV-004)

### Consequences

**Positive**:
- ✅ Consistent error responses
- ✅ Machine-readable error codes
- ✅ User-friendly messages
- ✅ Debugging support (traceId)
- ✅ Client error handling

**Negative**:
- ⚠️ Error code maintenance
- ⚠️ Localization complexity
- ⚠️ Documentation overhead

**Mitigation**:
- Error code catalog documentation
- i18n support for messages
- Automated error code validation

---

## Summary

These 15 ADRs capture the foundational architectural decisions that shaped the Carmen.NET ERP system. They provide context for current design choices and guide future evolution.

**Key Architectural Principles**:
1. **Multi-Tenancy**: Single codebase, row-level isolation
2. **Modularity**: Modular monolith with clear boundaries
3. **Security**: JWT + RBAC with fine-grained permissions
4. **Statelessness**: RESTful API with stateless authentication
5. **Flexibility**: Configurable tax codes, workflows, chart of accounts
6. **Integration**: Multiple formats (Excel, CSV, JSON, XML, MT940)
7. **Consistency**: Centralized error handling, standardized responses

**Future ADRs** (Recommended):
- ADR-016: .NET 8 Migration Strategy
- ADR-017: Cloud Deployment Architecture
- ADR-018: Microservices Extraction Criteria
- ADR-019: AI/ML Integration Approach
- ADR-020: Mobile Application Architecture

---

**Document Owner**: Solution Architect
**Review Cycle**: Quarterly (add new ADRs as decisions made)
**Last Updated**: 2025-10-06
**Next Review**: 2026-01-06
