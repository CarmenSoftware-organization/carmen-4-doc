#!/bin/bash
# Generate C4 Architecture Diagrams
# Output: PlantUML files in docs/architecture/

OUTPUT_DIR="docs/architecture"
mkdir -p "$OUTPUT_DIR"

echo "=== C4 Architecture Diagram Generator ==="
echo "Generating C4 diagrams..."

# C4 Context Diagram
cat > "$OUTPUT_DIR/c4-context.puml" << 'EOF'
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

LAYOUT_WITH_LEGEND()

title System Context Diagram - Carmen.NET ERP

Person(user, "Business User", "AP/AR/GL clerk, Manager, Accountant")
Person(admin, "System Administrator", "IT administrator, System configurator")

System(carmen, "Carmen.NET ERP", "Multi-tenant financial ERP system\n60 controllers, 351+ API endpoints\n11 core modules, 28 projects")

System_Ext(bank, "Banking System", "Payment file exchange\nBank statement import")
System_Ext(tax, "Tax Authority", "VAT/WHT filing\nTax reporting")
System_Ext(excel, "Microsoft Excel", "Excel add-in\nData import/export")
System_Ext(third_party, "Third-Party Systems", "External integrations\nWeb APIs")

Rel(user, carmen, "Uses", "HTTPS/Browser")
Rel(admin, carmen, "Configures & manages", "HTTPS")
Rel(carmen, bank, "Exchanges payment files", "File/SFTP")
Rel(carmen, tax, "Submits tax reports", "File/API")
Rel(excel, carmen, "Integrates with", "REST API")
Rel(carmen, third_party, "Integrates with", "REST API/Database")

SHOW_LEGEND()
@enduml
EOF

echo "  ✓ Created c4-context.puml"

# C4 Container Diagram
cat > "$OUTPUT_DIR/c4-container.puml" << 'EOF'
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml

LAYOUT_WITH_LEGEND()

title Container Diagram - Carmen.NET ERP

Person(user, "User", "Business user, Manager, Accountant")
Person(admin, "Administrator", "System admin")

System_Boundary(carmen, "Carmen.NET") {
    Container(webapp, "Web Application", "ASP.NET MVC", "User interface\nDashboards, Forms, Reports")
    Container(webapi, "Web API", "ASP.NET Web API", "REST API layer\n60 controllers\n351+ endpoints")
    Container(functions, "Business Logic", ".NET Class Libraries", "Business rules & workflows\nValidation, Calculations\nApproval processes")
    ContainerDb(db, "Database", "SQL Server", "Multi-tenant data storage\n597 business entities\nTransactional data")
    Container(licenseApi, "License API", "ASP.NET Web API", "License validation\nTenant management")
    Container(crypto, "Crypto Services", ".NET Library", "Encryption/Decryption\nData security")
}

System_Ext(excel, "Excel Add-in", "Office integration")

Rel(user, webapp, "Uses", "HTTPS")
Rel(user, excel, "Uses", "Office")
Rel(webapp, webapi, "Calls", "HTTPS/JSON")
Rel(excel, webapi, "Calls", "REST API/JSON")
Rel(admin, webapi, "Configures", "HTTPS/JSON")
Rel(webapi, functions, "Uses")
Rel(functions, db, "Reads/Writes", "ADO.NET/EF")
Rel(webapi, licenseApi, "Validates license", "HTTPS")
Rel(functions, crypto, "Encrypts/Decrypts", "In-process")

SHOW_LEGEND()
@enduml
EOF

echo "  ✓ Created c4-container.puml"

# C4 Component Diagram (API Layer)
cat > "$OUTPUT_DIR/c4-component-api.puml" << 'EOF'
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Component.puml

LAYOUT_WITH_LEGEND()

title Component Diagram - Carmen.NET Web API

Container(webapp, "Web Application", "ASP.NET MVC")
Container(excel, "Excel Add-in", "VSTO")

Container_Boundary(webapi, "Carmen.WebApi") {
    Component(auth, "Authentication", "Controllers", "Login, Token management\nUser authentication")
    Component(ap, "AP Module", "Controllers", "Invoice, Payment, WHT\n7 controllers")
    Component(ar, "AR Module", "Controllers", "Contract, Invoice, Receipt\n9 controllers")
    Component(gl, "GL Module", "Controllers", "Journal, Period, Amortize\n5 controllers")
    Component(asset, "Asset Module", "Controllers", "Register, Category, Disposal\n6 controllers")
    Component(income, "Income Module", "Controllers", "Invoice, Revenue\n5 controllers")
    Component(system, "System Admin", "Controllers", "User, Permission, Config\n15+ controllers")
    Component(base, "Base Controller", "BaseApiController", "Common utilities\nError handling\nJSON helpers")
}

Container_Boundary(functions, "Business Logic") {
    Component(fnc_ap, "AP Functions", "FncApInvoice, etc.", "AP business logic")
    Component(fnc_ar, "AR Functions", "FncArInvoice, etc.", "AR business logic")
    Component(fnc_gl, "GL Functions", "FncGlJv, etc.", "GL business logic")
    Component(fnc_perm, "Permission Mgmt", "FncPermission", "RBAC logic")
    Component(workflow, "Workflow Engine", "Workflow", "Approval processes")
}

ContainerDb(db, "Database", "SQL Server")

Rel(webapp, auth, "Authenticates", "HTTPS")
Rel(webapp, ap, "AP operations", "HTTPS/JSON")
Rel(webapp, ar, "AR operations", "HTTPS/JSON")
Rel(excel, auth, "Authenticates", "REST API")
Rel(excel, system, "Bulk operations", "REST API")

Rel(ap, base, "Inherits from")
Rel(ar, base, "Inherits from")
Rel(gl, base, "Inherits from")

Rel(ap, fnc_ap, "Uses")
Rel(ar, fnc_ar, "Uses")
Rel(gl, fnc_gl, "Uses")
Rel(ap, fnc_perm, "Checks permissions")
Rel(ar, fnc_perm, "Checks permissions")
Rel(ap, workflow, "Triggers approvals")

Rel(fnc_ap, db, "CRUD", "ADO.NET")
Rel(fnc_ar, db, "CRUD", "ADO.NET")
Rel(fnc_gl, db, "CRUD", "ADO.NET")

SHOW_LEGEND()
@enduml
EOF

echo "  ✓ Created c4-component-api.puml"

# Deployment Diagram
cat > "$OUTPUT_DIR/deployment-diagram.puml" << 'EOF'
@startuml
!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Deployment.puml

title Deployment Diagram - Carmen.NET ERP

Deployment_Node(client, "Client Device", "Windows/Mac/Linux") {
    Container(browser, "Web Browser", "Chrome, Edge, Firefox")
    Container(excel_client, "Excel", "Microsoft Office")
}

Deployment_Node(web_tier, "Web Tier", "IIS/Windows Server") {
    Deployment_Node(iis, "IIS Application Server", "IIS 10+") {
        Container(webapp, "Web Application", "ASP.NET MVC")
        Container(webapi, "Web API", "ASP.NET Web API")
    }
}

Deployment_Node(app_tier, "Application Tier", "Windows Server") {
    Deployment_Node(app_server, "Application Server", ".NET Runtime") {
        Container(license_api, "License API", "ASP.NET Web API")
        Container(business_logic, "Business Logic", ".NET Libraries")
    }
}

Deployment_Node(data_tier, "Data Tier", "Database Server") {
    Deployment_Node(db_server, "SQL Server", "SQL Server 2016+") {
        ContainerDb(database, "Carmen Database", "SQL Server")
        ContainerDb(tenant_dbs, "Tenant Databases", "Multi-tenant DBs")
    }
}

Deployment_Node(file_server, "File Storage", "File Server/NAS") {
    Container(files, "Document Storage", "File System")
}

Rel(browser, webapp, "HTTPS", "443")
Rel(browser, webapi, "HTTPS/JSON", "443")
Rel(excel_client, webapi, "HTTPS/JSON", "443")
Rel(webapp, webapi, "Internal", "80/443")
Rel(webapi, business_logic, "In-process")
Rel(webapi, license_api, "HTTPS", "Internal")
Rel(business_logic, database, "SQL/TDS", "1433")
Rel(business_logic, tenant_dbs, "SQL/TDS", "1433")
Rel(business_logic, files, "File I/O", "SMB")

@enduml
EOF

echo "  ✓ Created deployment-diagram.puml"

echo ""
echo "=== Generation Complete ==="
echo "C4 diagrams created in: $OUTPUT_DIR"
echo ""
echo "To render diagrams:"
echo "  plantuml $OUTPUT_DIR/*.puml"
echo ""
echo "Or online at:"
echo "  http://www.plantuml.com/plantuml/uml/"
