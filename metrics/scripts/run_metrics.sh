#!/bin/bash

# =====================================
# iOS Metrics Collection Script
# =====================================
# Version: 1.1
# Author: Vagner Machado
# Date: December 2025
# =====================================

# Configurações
PROJECT_DIR="/Users/vagner/Library/CloudStorage/Dropbox/_MBA Esalq/_TCC/Projeto/iOS"
WORKSPACE="Cardapio USP.xcworkspace"
SCHEME="Cardapio USP"
OUTPUT_DIR="./metrics/reports"
SIMULATOR="platform=iOS Simulator,name=iPhone 15"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Navegar para o diretório do projeto
cd "$PROJECT_DIR" || exit 1

# Criar diretório de output
mkdir -p "$OUTPUT_DIR"

# Header
echo ""
echo "======================================"
echo "  iOS Metrics Collection"
echo "======================================"
echo -e "${BLUE}Branch:${NC} $(git branch --show-current)"
echo -e "${BLUE}Commit:${NC} $(git rev-parse --short HEAD) - $(git log -1 --pretty=%B | head -1)"
echo -e "${BLUE}Date:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${BLUE}Output:${NC} $OUTPUT_DIR"
echo "======================================"
echo ""

# Funções de log
log_step() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# =====================================
# Step 1: Clean Build
# =====================================
log_step "[1/10] Cleaning project..."
xcodebuild clean \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    > "$OUTPUT_DIR/clean.log" 2>&1

if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Clean successful"
else
    log_error "Clean failed. Check $OUTPUT_DIR/clean.log"
fi

# =====================================
# Step 2: Build for compile_commands.json (xcpretty)
# =====================================
log_step "[2/10] Building project and generating compile_commands.json..."

if command -v xcpretty &> /dev/null; then
    xcodebuild \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -configuration Debug \
        -sdk iphonesimulator \
        clean build \
    | xcpretty --report json-compilation-database --output compile_commands.json \
        2>&1 | tee "$OUTPUT_DIR/xcodebuild-compile-commands.log"

    if [ -f "compile_commands.json" ]; then
        echo -e "  ${GREEN}✓${NC} compile_commands.json generated"
    else
        log_warning "compile_commands.json was not generated. Check $OUTPUT_DIR/xcodebuild-compile-commands.log"
    fi
else
    log_warning "xcpretty not found. Install with: gem install xcpretty"
    log_warning "Skipping compile_commands.json generation. SonarCloud CFamily analysis might fail."
fi

# =====================================
# Step 3: Fix compile_commands.json for CFamily
# =====================================
log_step "[3/10] Fixing compile_commands.json for CFamily..."

if [ -f "compile_commands.json" ] && [ -f "metrics/scripts/fix_compile_commands.py" ]; then
    python3 metrics/scripts/fix_compile_commands.py > "$OUTPUT_DIR/fix_compile_commands.log" 2>&1
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} compile_commands.fixed.json generated"
    else
        log_warning "fix_compile_commands.py failed. Check $OUTPUT_DIR/fix_compile_commands.log"
    fi
else
    log_warning "compile_commands.json or fix_compile_commands.py not found. Skipping CFamily fix step."
fi

# =====================================
# Step 4: Run Tests with Coverage
# =====================================
log_step "[4/10] Running tests with code coverage..."
echo "  This may take several minutes..."

xcodebuild test \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -destination "$SIMULATOR" \
    -enableCodeCoverage YES \
    -resultBundlePath "$OUTPUT_DIR/TestResults.xcresult" \
    2>&1 | tee "$OUTPUT_DIR/xcodebuild-test.log"

TEST_EXIT_CODE=${PIPESTATUS[0]}

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Tests passed"
else
    log_warning "Some tests failed. Check $OUTPUT_DIR/xcodebuild-test.log"
fi

# =====================================
# Step 5: Generate Generic Coverage Report (Sonar)
# =====================================
log_step "[5/10] Generating generic code coverage report for Sonar..."

if [ -d "$OUTPUT_DIR/TestResults.xcresult" ]; then
    # Primeiro verifica se há cobertura no bundle
    if xcrun xccov view --report "$OUTPUT_DIR/TestResults.xcresult" > /dev/null 2>&1; then
        if [ -x "./metrics/scripts/xccov-to-sonarqube-generic.sh" ]; then
            ./metrics/scripts/xccov-to-sonarqube-generic.sh "$OUTPUT_DIR/TestResults.xcresult" \
                > "$OUTPUT_DIR/sonar-generic-coverage.xml" 2>"$OUTPUT_DIR/xccov-to-sonar.log"

            if [ $? -eq 0 ]; then
                echo -e "  ${GREEN}✓${NC} sonar-generic-coverage.xml generated"
            else
                log_warning "Failed to generate sonar-generic-coverage.xml. Check $OUTPUT_DIR/xccov-to-sonar.log"
            fi
        else
            log_warning "xccov-to-sonarqube-generic.sh not found or not executable."
            echo "  Place the script in metrics/scripts/ and run: chmod +x metrics/scripts/xccov-to-sonarqube-generic.sh"
        fi
    else
        log_warning "No coverage data in TestResults.xcresult (XCCovErrorDomain). Skipping coverage export."
    fi
else
    log_warning "TestResults.xcresult not found. Skipping coverage export."
fi

# =====================================
# Step 6: Cyclomatic Complexity (Lizard)
# =====================================
log_step "[6/10] Analyzing cyclomatic complexity (Lizard)..."

if command -v lizard &> /dev/null; then
    lizard "Cardapio USP" \
        -l objectivec \
        --exclude "*/Pods/*" \
        --exclude "*/Index/*" \
        --exclude "*.framework/*" \
        --html > "$OUTPUT_DIR/lizard-complexity.html"

    lizard "Cardapio USP" \
        -l objectivec \
        --exclude "*/Pods/*" \
        --exclude "*/Index/*" \
        --exclude "*.framework/*" \
        --csv > "$OUTPUT_DIR/lizard-complexity.csv"

    lizard "Cardapio USP" \
        -l objectivec \
        --exclude "*/Pods/*" \
        --exclude "*/Index/*" \
        --exclude "*.framework/*" \
        > "$OUTPUT_DIR/lizard-complexity.txt"

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Lizard analysis complete"
        AVG_COMPLEXITY=$(grep "Average" "$OUTPUT_DIR/lizard-complexity.txt" | awk '{print $NF}')
        if [ -n "$AVG_COMPLEXITY" ]; then
            echo -e "     Average Complexity: $AVG_COMPLEXITY"
        fi
    fi
else
    log_warning "Lizard not found. Skipping complexity analysis."
    echo "  Install with: pip3 install lizard"
fi

# =====================================
# Step 7: Lines of Code Analysis (cloc)
# =====================================
log_step "[7/10] Analyzing lines of code (cloc)..."

if command -v cloc &> /dev/null; then
    cloc "Cardapio USP" \
        --exclude-dir=Pods,Index,Build \
        --json \
        --out="$OUTPUT_DIR/cloc-report.json"

    cloc "Cardapio USP" \
        --exclude-dir=Pods,Index,Build \
        --csv \
        --out="$OUTPUT_DIR/cloc-report.csv"

    cloc "Cardapio USP" \
        --exclude-dir=Pods,Index,Build \
        > "$OUTPUT_DIR/cloc-report.txt"

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Lines of code analysis complete"
        echo "  ----------------"
        grep -A 5 "Language" "$OUTPUT_DIR/cloc-report.txt" | head -7
    fi
else
    log_warning "cloc not found. Install with: brew install cloc"
fi

# =====================================
# Step 8: Architecture Analysis
# =====================================
log_step "[8/10] Running architecture analysis..."

echo "  Analyzing with SourceKitten..."
if command -v sourcekitten &> /dev/null; then
    find "Cardapio USP" -name "*.m" -not -path "*/Pods/*" -not -path "*/AF*" | \
        head -20 | \
        while read file; do
            sourcekitten structure --file "$file" 2>/dev/null
        done > "$OUTPUT_DIR/sourcekitten-structure.json"

    if [ -s "$OUTPUT_DIR/sourcekitten-structure.json" ]; then
        echo -e "  ${GREEN}✓${NC} SourceKitten analysis complete"
    else
        log_warning "SourceKitten produced an empty structure file."
    fi
else
    log_warning "SourceKitten not found. Skipping SourceKitten analysis."
fi

# Periphery (se houver código Swift)
if find "Cardapio USP" -name "*.swift" -not -path "*/Pods/*" | grep -q .; then
    if command -v periphery &> /dev/null; then
        echo "  Analyzing with Periphery..."
        periphery scan \
            --workspace "$WORKSPACE" \
            --schemes "$SCHEME" \
            --format json \
            > "$OUTPUT_DIR/periphery-report.json" 2>/dev/null

        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}✓${NC} Periphery analysis complete"
        else
            log_warning "Periphery scan failed. Check periphery configuration."
        fi
    else
        log_warning "Periphery not found. Skipping unused code analysis."
    fi
else
    log_warning "No Swift files found, skipping Periphery."
fi

# =====================================
# Step 9: Extract Test Metrics
# =====================================
log_step "[9/10] Extracting test metrics..."

if [ -d "$OUTPUT_DIR/TestResults.xcresult" ]; then
    xcrun xcresulttool get \
        --path "$OUTPUT_DIR/TestResults.xcresult" \
        --format json \
        > "$OUTPUT_DIR/test-results-raw.json" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Test results extracted"

        if command -v jq &> /dev/null; then
            TOTAL_TESTS=$(jq -r '.metrics.testsCount.value // "N/A"' "$OUTPUT_DIR/test-results-raw.json" 2>/dev/null)
            FAILED_TESTS=$(jq -r '.metrics.testsFailedCount.value // "0"' "$OUTPUT_DIR/test-results-raw.json" 2>/dev/null)
            echo -e "     Total Tests: $TOTAL_TESTS"
            echo -e "     Failed Tests: $FAILED_TESTS"
        fi
    else
        log_warning "Failed to extract test results with xcresulttool."
    fi
else
    log_warning "TestResults.xcresult not found. Skipping test metrics extraction."
fi

# =====================================
# Step 10: SonarCloud Analysis
# =====================================
log_step "[10/10] Running SonarCloud analysis..."

if ! command -v sonar-scanner &> /dev/null; then
    log_warning "sonar-scanner not found. Install with: brew install sonar-scanner"
elif [ -z "$SONAR_TOKEN" ]; then
    log_warning "SONAR_TOKEN environment variable not set. Export your SonarCloud token before running this script."
    echo "  Example: export SONAR_TOKEN=your_token_here"
else
    sonar-scanner \
        -Dsonar.organization=sti-usp \
        -Dsonar.projectKey=STI-USP_Cardapio \
        -Dsonar.host.url=https://sonarcloud.io \
        -Dsonar.token="$SONAR_TOKEN" \
        -Dsonar.coverageReportPaths="$OUTPUT_DIR/sonar-generic-coverage.xml" \
        > "$OUTPUT_DIR/sonar-scanner.log" 2>&1

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} SonarCloud analysis complete"
        echo -e "     Dashboard: https://sonarcloud.io/project/overview?id=STI-USP_Cardapio"
    else
        log_warning "SonarCloud analysis failed. Check $OUTPUT_DIR/sonar-scanner.log"
    fi
fi

# =====================================
# Summary
# =====================================
echo ""
echo "======================================"
echo "  Metrics Collection Complete!"
echo "======================================"
echo ""
echo "Reports generated in: $OUTPUT_DIR"
echo ""
echo "Available Reports:"
echo "  • Generic Coverage (XML): $OUTPUT_DIR/sonar-generic-coverage.xml"
echo "  • Lizard (HTML):          $OUTPUT_DIR/lizard-complexity.html"
echo "  • Lizard (CSV):           $OUTPUT_DIR/lizard-complexity.csv"
echo "  • CLOC (JSON):            $OUTPUT_DIR/cloc-report.json"
echo "  • CLOC (CSV):             $OUTPUT_DIR/cloc-report.csv"
echo "  • Test Results (raw):     $OUTPUT_DIR/test-results-raw.json"
echo "  • SourceKitten:           $OUTPUT_DIR/sourcekitten-structure.json"
echo "  • Periphery (JSON):       $OUTPUT_DIR/periphery-report.json"
echo "  • SonarCloud Dashboard:   https://sonarcloud.io/project/overview?id=STI-USP_Cardapio"
echo ""

echo "Generated files:"
ls -lh "$OUTPUT_DIR" 2>/dev/null | grep -v "^total" | awk '{printf "  • %-40s %8s\n", $9, $5}'
echo ""
echo "======================================"
echo ""
