# Carmen.NET - Container Diagram (C4 Level 2)

```mermaid
graph TB
    subgraph "Users & Clients"
        WEB_USER[Web Browser<br/>HTTPS]
        EXCEL_USER[Excel User<br/>Office Add-in]
        MOBILE_USER[Mobile User<br/>iOS/Android App]
        API_USER[API Client<br/>Third-party System]
    end

    subgraph "Carmen.NET ERP System"
        subgraph "Application Layer"
            WEBAPI[Web API Application<br/>ASP.NET Web API<br/>.NET Framework 4.x<br/>351+ REST Endpoints<br/>60 Controllers]
        end

        subgraph "Data Layer"
            DATABASE[(SQL Server Database<br/>Multi-tenant Data<br/>Encrypted Sensitive Fields<br/>Audit Trail Tables)]
        end

        subgraph "Integration Layer"
            EXCEL_ADDIN[Excel Add-in<br/>VSTO/Office API<br/>Import/Export]
            MOBILE_APP[Mobile App<br/>Xamarin/React Native<br/>REST Client]
        end

        subgraph "External Services"
            EMAIL_SVC[Email Service<br/>SMTP<br/>Notifications & Alerts]
        end
    end

    subgraph "External Systems"
        BANK_SYS[Banking System]
        TAX_SYS[Tax Authority]
    end

    %% User to application connections
    WEB_USER -->|HTTPS/JSON| WEBAPI
    EXCEL_USER -->|Uses| EXCEL_ADDIN
    MOBILE_USER -->|Uses| MOBILE_APP
    API_USER -->|HTTPS/JSON API| WEBAPI

    %% Integration layer to API
    EXCEL_ADDIN -->|REST API Calls| WEBAPI
    MOBILE_APP -->|REST API Calls| WEBAPI

    %% API to database
    WEBAPI -->|Entity Framework<br/>LINQ Queries| DATABASE

    %% API to external services
    WEBAPI -->|SMTP Protocol| EMAIL_SVC
    WEBAPI -->|Payment Files| BANK_SYS
    BANK_SYS -->|Bank Statements| WEBAPI
    WEBAPI -->|WHT Files| TAX_SYS

    %% Email service interactions
    EMAIL_SVC -->|Sends emails to| WEB_USER
    EMAIL_SVC -->|Sends notifications to| MOBILE_USER

    classDef container fill:#1168bd,stroke:#0b4884,color:#ffffff
    classDef database fill:#438dd5,stroke:#2e6295,color:#ffffff
    classDef external fill:#999999,stroke:#666666,color:#ffffff
    classDef user fill:#08427b,stroke:#052e56,color:#ffffff

    class WEBAPI,EXCEL_ADDIN,MOBILE_APP,EMAIL_SVC container
    class DATABASE database
    class BANK_SYS,TAX_SYS external
    class WEB_USER,EXCEL_USER,MOBILE_USER,API_USER user
```

## Container Overview

Carmen.NET consists of several containers that work together to provide comprehensive financial ERP functionality.

### Application Containers

**Web API Application**
- **Technology**: ASP.NET Web API, .NET Framework 4.x
- **Purpose**: Core business logic and REST API endpoints
- **Scale**: 351+ endpoints across 60 controllers
- **Features**:
  - Token-based authentication (JWT)
  - Role-based access control (RBAC)
  - Multi-tenant context management
  - Comprehensive error handling and logging

**Excel Add-in**
- **Technology**: VSTO (Visual Studio Tools for Office), Office JavaScript API
- **Purpose**: Batch data import/export via Excel
- **Features**:
  - Template-based data entry
  - Bulk upload capabilities
  - Data validation before import

**Mobile App**
- **Technology**: Xamarin or React Native (inferred)
- **Purpose**: Mobile access to core functionality
- **Features**:
  - Transaction approval workflows
  - Report viewing
  - Real-time notifications

### Data Container

**SQL Server Database**
- **Technology**: SQL Server 2014+
- **Purpose**: Multi-tenant data storage
- **Features**:
  - Tenant-isolated data
  - Encrypted sensitive fields
  - Complete audit trail
  - Transaction support (ACID)

### External Services

**Email Service**
- **Technology**: SMTP
- **Purpose**: Notifications and alerts
- **Features**:
  - Workflow notifications
  - System alerts
  - User communications

## Integration Patterns

- **Web Browser**: HTTPS/JSON REST API
- **Excel Add-in**: REST API via Office API
- **Mobile App**: REST API via native HTTP client
- **Third-party Systems**: REST API with token authentication
- **Database**: Entity Framework ORM with LINQ
- **Banking**: File-based integration (payment files, statements)
- **Tax Authority**: File-based WHT submissions
