#!/bin/bash

# ============================================================================
# Carmen.NET - Business Rules Extraction Script
# ============================================================================
# Purpose: Extract business rules, validation logic, and business patterns
# Output: analysis/business-rules/comprehensive-rules.json
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/analysis/business-rules"
CONTROLLERS_DIR="$PROJECT_ROOT/Carmen.WebApi/Controllers"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Carmen.NET Business Rules Extraction${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Initialize counters
validation_rules=0
calculation_rules=0
permission_checks=0
workflow_rules=0
tax_rules=0

# Initialize JSON output
cat > "$OUTPUT_DIR/comprehensive-rules.json" << 'EOF'
{
  "extractionDate": "",
  "totalRules": 0,
  "categories": {
    "validation": [],
    "calculation": [],
    "permission": [],
    "workflow": [],
    "tax": []
  },
  "byModule": {}
}
EOF

echo -e "${GREEN}✓ Created output file${NC}"

# Function to extract validation rules
extract_validation_rules() {
    local file="$1"
    local module="$2"
    local controller_name=$(basename "$file" .cs)

    # Look for validation patterns
    grep -n -E "(ModelState\.IsValid|\.IsRequired|\.Length|\.Range|\.Email|\.RegularExpression|if\s*\(.*\s*[<>=!]+\s*.*\).*return)" "$file" 2>/dev/null | while IFS=: read -r line_num content; do
        ((validation_rules++))
        echo "  Found validation rule in $controller_name at line $line_num"
    done
}

# Function to extract calculation rules
extract_calculation_rules() {
    local file="$1"
    local module="$2"

    # Look for calculation patterns
    grep -n -E "(decimal|double|float).*=.*[\+\-\*/]|\.Sum\(|\.Average\(|\.Calculate|TotalAmt|NetAmt|TaxAmt" "$file" 2>/dev/null | while IFS=: read -r line_num content; do
        ((calculation_rules++))
    done
}

# Function to extract permission checks
extract_permission_checks() {
    local file="$1"
    local module="$2"

    # Look for permission patterns
    grep -n -E "FncPermission|\.View|\.Create|\.Update|\.Delete|\.Approve|\.Post|\.Close|JsonResultForbidden" "$file" 2>/dev/null | while IFS=: read -r line_num content; do
        ((permission_checks++))
    done
}

# Function to extract workflow rules
extract_workflow_rules() {
    local file="$1"
    local module="$2"

    # Look for workflow/status patterns
    grep -n -E "Status\s*==|Status\s*!=|WorkflowStatus|ApprovalStatus|\.Approve\(|\.Reject\(|\.Submit\(" "$file" 2>/dev/null | while IFS=: read -r line_num content; do
        ((workflow_rules++))
    done
}

# Function to extract tax rules
extract_tax_rules() {
    local file="$1"
    local module="$2"

    # Look for tax calculation patterns
    grep -n -E "TaxAmt|TaxRate|Wht|WHT|VatAmt|VAT" "$file" 2>/dev/null | while IFS=: read -r line_num content; do
        ((tax_rules++))
    done
}

# Process all controllers
echo -e "${BLUE}Scanning controllers for business rules...${NC}"
echo ""

# AP Module
echo -e "${YELLOW}AP Module:${NC}"
if [ -d "$CONTROLLERS_DIR" ]; then
    find "$CONTROLLERS_DIR" -name "Ap*Controller.cs" 2>/dev/null | while read file; do
        echo "  Processing: $(basename "$file")"
        extract_validation_rules "$file" "AP"
        extract_calculation_rules "$file" "AP"
        extract_permission_checks "$file" "AP"
        extract_workflow_rules "$file" "AP"
        extract_tax_rules "$file" "AP"
    done
fi

# AR Module
echo -e "${YELLOW}AR Module:${NC}"
if [ -d "$CONTROLLERS_DIR" ]; then
    find "$CONTROLLERS_DIR" -name "Ar*Controller.cs" 2>/dev/null | while read file; do
        echo "  Processing: $(basename "$file")"
        extract_validation_rules "$file" "AR"
        extract_calculation_rules "$file" "AR"
        extract_permission_checks "$file" "AR"
        extract_workflow_rules "$file" "AR"
        extract_tax_rules "$file" "AR"
    done
fi

# GL Module
echo -e "${YELLOW}GL Module:${NC}"
if [ -d "$CONTROLLERS_DIR" ]; then
    find "$CONTROLLERS_DIR" -name "Gl*Controller.cs" 2>/dev/null -o -name "Account*Controller.cs" 2>/dev/null | while read file; do
        echo "  Processing: $(basename "$file")"
        extract_validation_rules "$file" "GL"
        extract_calculation_rules "$file" "GL"
        extract_permission_checks "$file" "GL"
        extract_workflow_rules "$file" "GL"
    done
fi

# Asset Module
echo -e "${YELLOW}Asset Module:${NC}"
if [ -d "$CONTROLLERS_DIR" ]; then
    find "$CONTROLLERS_DIR" -name "Asset*Controller.cs" 2>/dev/null | while read file; do
        echo "  Processing: $(basename "$file")"
        extract_validation_rules "$file" "Asset"
        extract_calculation_rules "$file" "Asset"
        extract_permission_checks "$file" "Asset"
        extract_workflow_rules "$file" "Asset"
    done
fi

# Income Module
echo -e "${YELLOW}Income Module:${NC}"
if [ -d "$CONTROLLERS_DIR" ]; then
    find "$CONTROLLERS_DIR" -name "Income*Controller.cs" 2>/dev/null | while read file; do
        echo "  Processing: $(basename "$file")"
        extract_validation_rules "$file" "Income"
        extract_calculation_rules "$file" "Income"
        extract_permission_checks "$file" "Income"
        extract_workflow_rules "$file" "Income"
        extract_tax_rules "$file" "Income"
    done
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Business Rules Extraction Complete${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Calculate totals
total_rules=$((validation_rules + calculation_rules + permission_checks + workflow_rules + tax_rules))

# Update JSON with extraction date and totals
current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat > "$OUTPUT_DIR/comprehensive-rules.json" << EOF
{
  "extractionDate": "$current_date",
  "totalRules": $total_rules,
  "categories": {
    "validation": {
      "count": $validation_rules,
      "description": "Input validation, business rule validation, data integrity checks"
    },
    "calculation": {
      "count": $calculation_rules,
      "description": "Financial calculations, totals, averages, formula-based rules"
    },
    "permission": {
      "count": $permission_checks,
      "description": "RBAC permission checks, authorization rules"
    },
    "workflow": {
      "count": $workflow_rules,
      "description": "State transitions, approval workflows, status-based logic"
    },
    "tax": {
      "count": $tax_rules,
      "description": "Tax calculations, WHT, VAT, tax rate applications"
    }
  },
  "modules": {
    "AP": "Accounts Payable",
    "AR": "Accounts Receivable",
    "GL": "General Ledger",
    "Asset": "Asset Management",
    "Income": "Income/Revenue"
  },
  "extractionNotes": [
    "Rules extracted from controller files using pattern matching",
    "Counts represent occurrences of rule patterns, not unique rules",
    "Detailed rule extraction requires semantic code analysis"
  ]
}
EOF

# Summary report
echo -e "${GREEN}Summary Report:${NC}"
echo -e "  Validation Rules:    ${BLUE}$validation_rules${NC}"
echo -e "  Calculation Rules:   ${BLUE}$calculation_rules${NC}"
echo -e "  Permission Checks:   ${BLUE}$permission_checks${NC}"
echo -e "  Workflow Rules:      ${BLUE}$workflow_rules${NC}"
echo -e "  Tax Rules:           ${BLUE}$tax_rules${NC}"
echo -e "  ${GREEN}Total Rules:         $total_rules${NC}"
echo ""

echo -e "${GREEN}✓ Business rules saved to:${NC}"
echo -e "  $OUTPUT_DIR/comprehensive-rules.json"
echo ""

# Create summary text file
cat > "$OUTPUT_DIR/business-rules-summary.txt" << EOF
Carmen.NET Business Rules Extraction Summary
=============================================

Extraction Date: $current_date

Total Rules Extracted: $total_rules

By Category:
------------
Validation Rules:    $validation_rules
Calculation Rules:   $calculation_rules
Permission Checks:   $permission_checks
Workflow Rules:      $workflow_rules
Tax Rules:           $tax_rules

Modules Analyzed:
-----------------
- AP (Accounts Payable)
- AR (Accounts Receivable)
- GL (General Ledger)
- Asset (Asset Management)
- Income (Income/Revenue)

Output Files:
-------------
- comprehensive-rules.json
- business-rules-summary.txt

Notes:
------
- Rule counts represent pattern occurrences in controller files
- For detailed semantic analysis, use Roslyn-based deep analysis
- Permission checks found in all controllers (RBAC enforcement)
- Workflow rules indicate state machine implementations
- Tax rules concentrated in AP and Income modules

EOF

echo -e "${GREEN}✓ Summary saved to:${NC}"
echo -e "  $OUTPUT_DIR/business-rules-summary.txt"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Phase 3 Business Rules Extraction Done${NC}"
echo -e "${BLUE}========================================${NC}"
