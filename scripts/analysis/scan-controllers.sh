#!/bin/bash
# Recursively scan all controllers
# Output: analysis/controllers/controller-inventory.json

CONTROLLERS_PATH="Carmen.WebApi/Controllers"
AREAS_PATH="Carmen.WebApi/Areas"
OUTPUT_FILE="analysis/controllers/controller-inventory.json"

echo "=== Controller Scanner ==="
echo "Scanning controllers..."

# Create output directory
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Initialize counters
TOTAL_CONTROLLERS=0
TOTAL_ENDPOINTS=0
TOTAL_LINES=0

# Initialize JSON output
echo "{" > "$OUTPUT_FILE"
echo '  "Summary": {' >> "$OUTPUT_FILE"

# Scan main controllers
if [ -d "$CONTROLLERS_PATH" ]; then
    echo "Scanning main controllers..."
    CONTROLLER_FILES=$(find "$CONTROLLERS_PATH" -name "*Controller.cs" 2>/dev/null)

    for file in $CONTROLLER_FILES; do
        TOTAL_CONTROLLERS=$((TOTAL_CONTROLLERS + 1))
        LINES=$(wc -l < "$file" 2>/dev/null || echo 0)
        TOTAL_LINES=$((TOTAL_LINES + LINES))

        # Count endpoints (public async Task methods)
        ENDPOINTS=$(grep -c "public.*Task<.*>" "$file" 2>/dev/null || echo 0)
        TOTAL_ENDPOINTS=$((TOTAL_ENDPOINTS + ENDPOINTS))

        FILENAME=$(basename "$file")
        echo "  [$TOTAL_CONTROLLERS] $FILENAME - $ENDPOINTS endpoints, $LINES lines"
    done
fi

# Scan area controllers
if [ -d "$AREAS_PATH" ]; then
    echo ""
    echo "Scanning area controllers..."
    AREA_CONTROLLER_FILES=$(find "$AREAS_PATH" -name "*Controller.cs" 2>/dev/null)

    for file in $AREA_CONTROLLER_FILES; do
        TOTAL_CONTROLLERS=$((TOTAL_CONTROLLERS + 1))
        LINES=$(wc -l < "$file" 2>/dev/null || echo 0)
        TOTAL_LINES=$((TOTAL_LINES + LINES))

        ENDPOINTS=$(grep -c "public.*Task<.*>" "$file" 2>/dev/null || echo 0)
        TOTAL_ENDPOINTS=$((TOTAL_ENDPOINTS + ENDPOINTS))

        FILENAME=$(basename "$file")
        echo "  [$TOTAL_CONTROLLERS] $FILENAME - $ENDPOINTS endpoints, $LINES lines"
    done
fi

# Write summary to JSON
cat >> "$OUTPUT_FILE" << EOF
    "TotalControllers": $TOTAL_CONTROLLERS,
    "TotalEndpoints": $TOTAL_ENDPOINTS,
    "TotalLines": $TOTAL_LINES,
    "ScanDate": "$(date '+%Y-%m-%d %H:%M:%S')"
  },
  "Controllers": []
}
EOF

echo ""
echo "=== Scan Complete ==="
echo "Total Controllers: $TOTAL_CONTROLLERS"
echo "Total Endpoints: $TOTAL_ENDPOINTS"
echo "Total Lines: $TOTAL_LINES"
echo ""
echo "Output saved to: $OUTPUT_FILE"
