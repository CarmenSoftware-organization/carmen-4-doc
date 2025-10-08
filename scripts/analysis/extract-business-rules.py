#!/usr/bin/env python3

"""
Carmen.NET - Business Rules Extraction Script
==============================================
Purpose: Extract business rules, validation logic, and business patterns
Output: analysis/business-rules/comprehensive-rules.json
"""

import os
import re
import json
from datetime import datetime
from pathlib import Path
from collections import defaultdict

# Colors for terminal output
class Colors:
    BLUE = '\033[0;34m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    NC = '\033[0m'  # No Color

def print_header(text):
    print(f"{Colors.BLUE}========================================{Colors.NC}")
    print(f"{Colors.BLUE}{text}{Colors.NC}")
    print(f"{Colors.BLUE}========================================{Colors.NC}")
    print()

def print_success(text):
    print(f"{Colors.GREEN}{text}{Colors.NC}")

def print_module(text):
    print(f"{Colors.YELLOW}{text}{Colors.NC}")

# Initialize counters
rules = {
    'validation': [],
    'calculation': [],
    'permission': [],
    'workflow': [],
    'tax': [],
    'business_logic': []
}

by_module = defaultdict(lambda: defaultdict(list))

def extract_validation_rules(file_path, content, module):
    """Extract validation rules from controller"""
    validation_patterns = [
        (r'ModelState\.IsValid', 'Model validation check'),
        (r'\.IsRequired', 'Required field validation'),
        (r'\.Length\(', 'Length validation'),
        (r'\.Range\(', 'Range validation'),
        (r'\.Email', 'Email validation'),
        (r'\.RegularExpression', 'Regex validation'),
        (r'if\s*\([^)]*[<>=!]+[^)]*\)\s*return\s+this\.JsonResultBadRequest', 'Business rule validation'),
    ]

    for pattern, rule_type in validation_patterns:
        matches = re.finditer(pattern, content)
        for match in matches:
            line_num = content[:match.start()].count('\n') + 1
            rule = {
                'type': rule_type,
                'module': module,
                'file': os.path.basename(file_path),
                'line': line_num,
                'pattern': pattern
            }
            rules['validation'].append(rule)
            by_module[module]['validation'].append(rule)

def extract_calculation_rules(file_path, content, module):
    """Extract calculation rules from controller"""
    calculation_patterns = [
        (r'decimal\s+\w+\s*=.*[\+\-\*/]', 'Decimal calculation'),
        (r'TotalAmt\s*=', 'Total amount calculation'),
        (r'NetAmt\s*=', 'Net amount calculation'),
        (r'TaxAmt\s*=', 'Tax amount calculation'),
        (r'\.Sum\(', 'Sum aggregation'),
        (r'\.Average\(', 'Average calculation'),
        (r'\.Calculate', 'Custom calculation'),
    ]

    for pattern, rule_type in calculation_patterns:
        matches = re.finditer(pattern, content)
        for match in matches:
            line_num = content[:match.start()].count('\n') + 1
            rule = {
                'type': rule_type,
                'module': module,
                'file': os.path.basename(file_path),
                'line': line_num,
                'code_snippet': match.group(0)[:100]
            }
            rules['calculation'].append(rule)
            by_module[module]['calculation'].append(rule)

def extract_permission_checks(file_path, content, module):
    """Extract permission checks from controller"""
    permission_patterns = [
        (r'FncPermission\.GetPermissionInfoByPermissionNameAsync\(["\']([^"\']+)["\']\)', 'Permission check'),
        (r'permission\.View', 'View permission check'),
        (r'permission\.Create', 'Create permission check'),
        (r'permission\.Update', 'Update permission check'),
        (r'permission\.Delete', 'Delete permission check'),
        (r'permission\.Approve', 'Approve permission check'),
        (r'permission\.Post', 'Post permission check'),
        (r'permission\.Close', 'Close permission check'),
        (r'JsonResultForbidden', 'Forbidden response'),
    ]

    for pattern, rule_type in permission_patterns:
        matches = re.finditer(pattern, content)
        for match in matches:
            line_num = content[:match.start()].count('\n') + 1
            permission_name = match.group(1) if len(match.groups()) > 0 else None
            rule = {
                'type': rule_type,
                'module': module,
                'file': os.path.basename(file_path),
                'line': line_num,
                'permission': permission_name
            }
            rules['permission'].append(rule)
            by_module[module]['permission'].append(rule)

def extract_workflow_rules(file_path, content, module):
    """Extract workflow and status rules from controller"""
    workflow_patterns = [
        (r'\.Status\s*==\s*(\d+)', 'Status check'),
        (r'\.Status\s*!=\s*(\d+)', 'Status validation'),
        (r'WorkflowStatus', 'Workflow status'),
        (r'ApprovalStatus', 'Approval status'),
        (r'\.Approve\(', 'Approve action'),
        (r'\.Reject\(', 'Reject action'),
        (r'\.Submit\(', 'Submit action'),
    ]

    for pattern, rule_type in workflow_patterns:
        matches = re.finditer(pattern, content)
        for match in matches:
            line_num = content[:match.start()].count('\n') + 1
            rule = {
                'type': rule_type,
                'module': module,
                'file': os.path.basename(file_path),
                'line': line_num,
                'code_snippet': match.group(0)
            }
            rules['workflow'].append(rule)
            by_module[module]['workflow'].append(rule)

def extract_tax_rules(file_path, content, module):
    """Extract tax calculation rules from controller"""
    tax_patterns = [
        (r'TaxAmt', 'Tax amount'),
        (r'TaxRate', 'Tax rate'),
        (r'WhtAmt|WHT', 'Withholding tax'),
        (r'VatAmt|VAT', 'VAT'),
    ]

    for pattern, rule_type in tax_patterns:
        matches = re.finditer(pattern, content)
        for match in matches:
            line_num = content[:match.start()].count('\n') + 1
            rule = {
                'type': rule_type,
                'module': module,
                'file': os.path.basename(file_path),
                'line': line_num
            }
            rules['tax'].append(rule)
            by_module[module]['tax'].append(rule)

def extract_business_logic(file_path, content, module):
    """Extract business logic patterns"""
    business_patterns = [
        (r'FncBase\.ApplyTenantIfUseTenant', 'Multi-tenant isolation'),
        (r'LogHttpRequest', 'Request logging'),
        (r'LogHttpResult\.Error', 'Error logging'),
        (r'using\s*\(.*transaction.*\)', 'Transaction usage'),
    ]

    for pattern, rule_type in business_patterns:
        matches = re.finditer(pattern, content, re.IGNORECASE)
        for match in matches:
            line_num = content[:match.start()].count('\n') + 1
            rule = {
                'type': rule_type,
                'module': module,
                'file': os.path.basename(file_path),
                'line': line_num
            }
            rules['business_logic'].append(rule)
            by_module[module]['business_logic'].append(rule)

def process_controller_file(file_path, module):
    """Process a single controller file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        print(f"  Processing: {os.path.basename(file_path)}")

        extract_validation_rules(file_path, content, module)
        extract_calculation_rules(file_path, content, module)
        extract_permission_checks(file_path, content, module)
        extract_workflow_rules(file_path, content, module)
        extract_tax_rules(file_path, content, module)
        extract_business_logic(file_path, content, module)

    except Exception as e:
        print(f"  Error processing {file_path}: {e}")

def main():
    print_header("Carmen.NET Business Rules Extraction")

    # Paths
    project_root = Path(__file__).parent.parent.parent
    controllers_dir = project_root / "Carmen.WebApi" / "Controllers"
    output_dir = project_root / "analysis" / "business-rules"

    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)
    print_success("✓ Created output directory")

    # Module mappings
    modules = {
        'Ap*Controller.cs': 'AP',
        'Ar*Controller.cs': 'AR',
        'Gl*Controller.cs': 'GL',
        'Account*Controller.cs': 'GL',
        'Asset*Controller.cs': 'Asset',
        'Income*Controller.cs': 'Income',
    }

    # Process each module
    print("Scanning controllers for business rules...")
    print()

    for pattern, module in modules.items():
        print_module(f"{module} Module:")

        controller_files = list(controllers_dir.glob(pattern))
        for file_path in controller_files:
            process_controller_file(file_path, module)

        print()

    # Calculate totals
    total_rules = sum(len(rules[category]) for category in rules)

    # Create comprehensive output
    output = {
        'extractionDate': datetime.utcnow().isoformat() + 'Z',
        'totalRules': total_rules,
        'summary': {
            'validation': len(rules['validation']),
            'calculation': len(rules['calculation']),
            'permission': len(rules['permission']),
            'workflow': len(rules['workflow']),
            'tax': len(rules['tax']),
            'business_logic': len(rules['business_logic'])
        },
        'categories': {
            'validation': {
                'count': len(rules['validation']),
                'description': 'Input validation, business rule validation, data integrity checks',
                'rules': rules['validation'][:50]  # Limit to first 50 for file size
            },
            'calculation': {
                'count': len(rules['calculation']),
                'description': 'Financial calculations, totals, averages, formula-based rules',
                'rules': rules['calculation'][:50]
            },
            'permission': {
                'count': len(rules['permission']),
                'description': 'RBAC permission checks, authorization rules',
                'rules': rules['permission'][:50]
            },
            'workflow': {
                'count': len(rules['workflow']),
                'description': 'State transitions, approval workflows, status-based logic',
                'rules': rules['workflow'][:50]
            },
            'tax': {
                'count': len(rules['tax']),
                'description': 'Tax calculations, WHT, VAT, tax rate applications',
                'rules': rules['tax'][:50]
            },
            'business_logic': {
                'count': len(rules['business_logic']),
                'description': 'Multi-tenant isolation, logging, transactions',
                'rules': rules['business_logic'][:50]
            }
        },
        'byModule': {module: {
            'validation': len(by_module[module]['validation']),
            'calculation': len(by_module[module]['calculation']),
            'permission': len(by_module[module]['permission']),
            'workflow': len(by_module[module]['workflow']),
            'tax': len(by_module[module]['tax']),
            'business_logic': len(by_module[module]['business_logic']),
            'total': sum([
                len(by_module[module]['validation']),
                len(by_module[module]['calculation']),
                len(by_module[module]['permission']),
                len(by_module[module]['workflow']),
                len(by_module[module]['tax']),
                len(by_module[module]['business_logic'])
            ])
        } for module in by_module}
    }

    # Save JSON output
    json_file = output_dir / "comprehensive-rules.json"
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(output, f, indent=2)

    print_header("Business Rules Extraction Complete")

    # Print summary
    print_success("Summary Report:")
    print(f"  Validation Rules:    {Colors.BLUE}{len(rules['validation'])}{Colors.NC}")
    print(f"  Calculation Rules:   {Colors.BLUE}{len(rules['calculation'])}{Colors.NC}")
    print(f"  Permission Checks:   {Colors.BLUE}{len(rules['permission'])}{Colors.NC}")
    print(f"  Workflow Rules:      {Colors.BLUE}{len(rules['workflow'])}{Colors.NC}")
    print(f"  Tax Rules:           {Colors.BLUE}{len(rules['tax'])}{Colors.NC}")
    print(f"  Business Logic:      {Colors.BLUE}{len(rules['business_logic'])}{Colors.NC}")
    print(f"  {Colors.GREEN}Total Rules:         {total_rules}{Colors.NC}")
    print()

    # Create summary text file
    summary_file = output_dir / "business-rules-summary.txt"
    with open(summary_file, 'w') as f:
        f.write("Carmen.NET Business Rules Extraction Summary\n")
        f.write("=============================================\n\n")
        f.write(f"Extraction Date: {datetime.utcnow().isoformat()}Z\n\n")
        f.write(f"Total Rules Extracted: {total_rules}\n\n")
        f.write("By Category:\n")
        f.write("------------\n")
        f.write(f"Validation Rules:    {len(rules['validation'])}\n")
        f.write(f"Calculation Rules:   {len(rules['calculation'])}\n")
        f.write(f"Permission Checks:   {len(rules['permission'])}\n")
        f.write(f"Workflow Rules:      {len(rules['workflow'])}\n")
        f.write(f"Tax Rules:           {len(rules['tax'])}\n")
        f.write(f"Business Logic:      {len(rules['business_logic'])}\n\n")
        f.write("By Module:\n")
        f.write("----------\n")
        for module in sorted(by_module.keys()):
            total_module = output['byModule'][module]['total']
            f.write(f"{module}: {total_module} rules\n")

    print_success(f"✓ Business rules saved to:")
    print(f"  {json_file}")
    print()
    print_success(f"✓ Summary saved to:")
    print(f"  {summary_file}")
    print()

    print_header("Phase 3 Business Rules Extraction Done")

if __name__ == "__main__":
    main()
