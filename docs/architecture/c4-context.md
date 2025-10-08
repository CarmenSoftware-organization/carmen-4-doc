# Carmen.NET - System Context Diagram (C4 Level 1)

```mermaid
graph TB
    subgraph "External Systems"
        BANK[Banking System<br/>Payment Processing]
        TAX[Tax Authority<br/>WHT Submission]
        EMAIL[Email Service<br/>Notifications]
        REPORT[Reporting Service<br/>BI & Analytics]
        OFFICE[Office/Excel<br/>Data Import/Export]
    end

    subgraph "Carmen.NET ERP System"
        CARMEN[Carmen.NET<br/>Multi-Tenant Financial ERP<br/>.NET Framework, ASP.NET Web API]
    end

    subgraph "Users"
        ACC[Accountants<br/>Daily Operations]
        FM[Finance Managers<br/>Reporting & Analysis]
        ADMIN[System Administrators<br/>Configuration]
        AUDIT[Auditors<br/>Compliance Review]
    end

    %% User interactions
    ACC -->|Manages transactions| CARMEN
    FM -->|Views reports| CARMEN
    ADMIN -->|Configures system| CARMEN
    AUDIT -->|Reviews audit trail| CARMEN

    %% External system interactions
    CARMEN -->|Generates payment files| BANK
    BANK -->|Sends bank statements| CARMEN
    CARMEN -->|Submits WHT files| TAX
    CARMEN -->|Sends notifications| EMAIL
    CARMEN -->|Provides data| REPORT
    CARMEN <-->|Imports/Exports data| OFFICE

    classDef system fill:#1168bd,stroke:#0b4884,color:#ffffff
    classDef external fill:#999999,stroke:#666666,color:#ffffff
    classDef user fill:#08427b,stroke:#052e56,color:#ffffff

    class CARMEN system
    class BANK,TAX,EMAIL,REPORT,OFFICE external
    class ACC,FM,ADMIN,AUDIT user
```

## System Context

**Carmen.NET** is a comprehensive multi-tenant financial ERP system that serves multiple user types and integrates with various external systems.

### Users

- **Accountants**: Daily transaction management (AP, AR, GL entries)
- **Finance Managers**: Financial reporting, analysis, and decision support
- **System Administrators**: User management, permissions, system configuration
- **Auditors**: Compliance review, audit trail examination

### External Systems

- **Banking System**: Payment file generation, bank statement reconciliation
- **Tax Authority**: WHT (Withholding Tax) file submission, tax compliance
- **Email Service**: Notifications, alerts, workflow notifications
- **Reporting Service**: Business intelligence, advanced analytics
- **Office/Excel**: Batch data import/export, template-based entry

### Key Capabilities

- Multi-tenant operations with complete data isolation
- 11 core financial modules (AP, AR, GL, Asset, Income, Tax, etc.)
- 351+ REST API endpoints
- Role-based access control
- Comprehensive audit trail
