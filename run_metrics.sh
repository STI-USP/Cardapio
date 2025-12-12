#!/bin/bash

# =====================================
# iOS Metrics Collection Script
# =====================================
# Version: 1.0
# Author: Vagner Machado
# Date: December 2025
# =====================================

# Configurações
PROJECT_DIR="/Users/vagner/Library/CloudStorage/Dropbox/_MBA Esalq/_TCC/Projeto/iOS"
WORKSPACE="Cardapio USP.xcworkspace"
SCHEME="Cardapio USP"
OUTPUT_DIR="./metrics-reports"
SIMULATOR="platform=iOS Simulator,name=iPhone 14"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Navegiar para o diretório do projeto
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

# Função para log
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
# Step 2: Run Tests with Coverage
# =====================================
log_step "[2/10] Running tests with code coverage..."
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
# Step 3: Generate Coverage Reports
# =====================================
log_step "[3/10] Generating code coverage reports..."

# Tentar encontrar slather
SLATHER_CMD=$(which slather 2>/dev/null || echo "$HOME/.gem/ruby/3.4.0/bin/slather")

if [ -x "$SLATHER_CMD" ] || command -v slather &> /dev/null; then
    # Slather - Cobertura XML
    $SLATHER_CMD coverage \
        --cobertura-xml \
        --output-directory "$OUTPUT_DIR" \
        --scheme "$SCHEME" \
        --workspace "$WORKSPACE" \
        > "$OUTPUT_DIR/slather.log" 2>&1

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Cobertura XML generated"
    else
        log_warning "Slather XML failed. Check $OUTPUT_DIR/slather.log"
    fi

    # Slather - HTML Report
    $SLATHER_CMD coverage \
        --html \
        --output-directory "$OUTPUT_DIR/coverage-html" \
        --scheme "$SCHEME" \
        --workspace "$WORKSPACE" \
        > "$OUTPUT_DIR/slather-html.log" 2>&1

    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} HTML coverage report generated"
        echo -e "     View at: $OUTPUT_DIR/coverage-html/index.html"
    fi
else
    log_warning "Slather not found. Skipping coverage report generation."
    echo "  Install with: gem install --user-install slather"
fi

# =====================================
# Step 4: Build for OCLint
# =====================================
log_step "[4/10] Building for OCLint analysis..."

xcodebuild \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration Debug \
    -destination "$SIMULATOR" \
    2>&1 | tee "$OUTPUT_DIR/xcodebuild-oclint.log"

if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Build successful"
else
    log_error "Build failed. Check $OUTPUT_DIR/xcodebuild-oclint.log"
fi

# =====================================
# Step 5: Run OCLint
# =====================================
log_step "[5/10] Running OCLint (code quality analysis)..."

if command -v oclint-xcodebuild &> /dev/null; then
    # Gerar compile_commands.json
    oclint-xcodebuild "$OUTPUT_DIR/xcodebuild-oclint.log" > /dev/null 2>&1

    if [ -f "compile_commands.json" ]; then
        echo -e "  ${GREEN}✓${NC} compile_commands.json generated"
        
        # Executar OCLint - HTML
        oclint-json-compilation-database \
            -e Pods \
            -- \
            -report-type html \
            -o "$OUTPUT_DIR/oclint-report.html" \
            > "$OUTPUT_DIR/oclint-html.log" 2>&1
        
        # Executar OCLint - XML (PMD format)
        oclint-json-compilation-database \
            -e Pods \
            -- \
            -report-type pmd \
            -o "$OUTPUT_DIR/oclint-report.xml" \
            > "$OUTPUT_DIR/oclint-xml.log" 2>&1
        
        # Executar OCLint - JSON
        oclint-json-compilation-database \
            -e Pods \
            -- \
            -report-type json \
            -o "$OUTPUT_DIR/oclint-report.json" \
            > "$OUTPUT_DIR/oclint-json.log" 2>&1
        
        echo -e "  ${GREEN}✓${NC} OCLint reports generated (HTML, XML, JSON)"
    else
        log_warning "compile_commands.json not generated"
    fi
else
    log_warning "OCLint not found. Skipping code quality analysis."
    echo "  Install OCLint manually (see METRICS_GUIDE.md)"
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
        
        # Extrair métricas principais
        AVG_COMPLEXITY=$(grep "Average" "$OUTPUT_DIR/lizard-complexity.txt" | awk '{print $NF}')
        echo -e "     Average Complexity: $AVG_COMPLEXITY"
    fi
else
    log_warning "Lizard not found. Skipping complexity analysis."
    echo "  Install with: pip3 install lizard"
fi

# =====================================
# Step 7: Lines of Code Analysis
# =====================================
log_step "[7/10] Analyzing lines of code (cloc)..."

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
    
    # Mostrar resumo
    echo "  ----------------"
    grep -A 5 "Language" "$OUTPUT_DIR/cloc-report.txt" | head -7
fi

# =====================================
# Step 8: Architecture Analysis
# =====================================
log_step "[8/10] Running architecture analysis..."

# SourceKitten - amostra de arquivos
echo "  Analyzing with SourceKitten..."
find "Cardapio USP" -name "*.m" -not -path "*/Pods/*" -not -path "*/AF*" | \
    head -20 | \
    while read file; do
        sourcekitten structure --file "$file" 2>/dev/null
    done > "$OUTPUT_DIR/sourcekitten-structure.json"

if [ -s "$OUTPUT_DIR/sourcekitten-structure.json" ]; then
    echo -e "  ${GREEN}✓${NC} SourceKitten analysis complete"
fi

# Periphery (se houver código Swift)
if find "Cardapio USP" -name "*.swift" -not -path "*/Pods/*" | grep -q .; then
    echo "  Analyzing with Periphery..."
    periphery scan \
        --workspace "$WORKSPACE" \
        --schemes "$SCHEME" \
        --format json \
        > "$OUTPUT_DIR/periphery-report.json" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Periphery analysis complete"
    fi
else
    log_warning "No Swift files found, skipping Periphery"
fi

# =====================================
# Step 9: Extract Test Metrics
# =====================================
log_step "[9/10] Extracting test metrics..."

xcrun xcresulttool get \
    --path "$OUTPUT_DIR/TestResults.xcresult" \
    --format json \
    > "$OUTPUT_DIR/test-results-raw.json" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Test results extracted"
    
    # Extrair estatísticas básicas
    if command -v jq &> /dev/null; then
        TOTAL_TESTS=$(jq -r '.metrics.testsCount.value // "N/A"' "$OUTPUT_DIR/test-results-raw.json" 2>/dev/null)
        FAILED_TESTS=$(jq -r '.metrics.testsFailedCount.value // "0"' "$OUTPUT_DIR/test-results-raw.json" 2>/dev/null)
        echo -e "     Total Tests: $TOTAL_TESTS"
        echo -e "     Failed Tests: $FAILED_TESTS"
    fi
fi

# =====================================
# Step 10: SonarQube Analysis
# =====================================
log_step "[10/10] Running SonarQube analysis..."

if curl -s http://localhost:9000 > /dev/null 2>&1; then
    if command -v sonar-scanner &> /dev/null; then
        echo "  SonarQube is running, starting analysis..."
        
        sonar-scanner \
            -Dsonar.projectKey=cardapio-usp-m1 \
            -Dsonar.sources="Cardapio USP" \
            -Dsonar.tests="Cardapio USPTests" \
            -Dsonar.coverageReportPaths="$OUTPUT_DIR/cobertura.xml" \
            -Dsonar.objectivec.oclint.report="$OUTPUT_DIR/oclint-report.xml" \
            -Dsonar.host.url=http://localhost:9000 \
            > "$OUTPUT_DIR/sonar-scanner.log" 2>&1
        
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}✓${NC} SonarQube analysis complete"
            echo -e "     Dashboard: http://localhost:9000/dashboard?id=cardapio-usp-m1"
        else
            log_warning "SonarQube analysis failed. Check $OUTPUT_DIR/sonar-scanner.log"
        fi
    else
        log_warning "sonar-scanner not found. Install with: brew install sonar-scanner"
    fi
else
    log_warning "SonarQube not running at localhost:9000"
    if command -v docker &> /dev/null; then
        if docker ps -a | grep -q sonarqube; then
            echo "  Start with: docker start sonarqube"
        else
            echo "  Start with: docker run -d --name sonarqube -p 9000:9000 sonarqube:latest"
        fi
    else
        echo "  Install Docker Desktop or download SonarQube manually"
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
echo "  • Code Coverage (HTML): $OUTPUT_DIR/coverage-html/index.html"
echo "  • Code Coverage (XML):  $OUTPUT_DIR/cobertura.xml"
echo "  • OCLint (HTML):        $OUTPUT_DIR/oclint-report.html"
echo "  • OCLint (JSON):        $OUTPUT_DIR/oclint-report.json"
echo "  • Lizard (HTML):        $OUTPUT_DIR/lizard-complexity.html"
echo "  • Lizard (CSV):         $OUTPUT_DIR/lizard-complexity.csv"
echo "  • CLOC (JSON):          $OUTPUT_DIR/cloc-report.json"
echo "  • Test Results:         $OUTPUT_DIR/test-results-raw.json"
echo "  • SonarQube:            http://localhost:9000"
echo ""

# Listar arquivos gerados
echo "Generated files:"
ls -lh "$OUTPUT_DIR" 2>/dev/null | grep -v "^total" | grep -v "^d" | awk '{printf "  • %-40s %8s\n", $9, $5}'
echo ""
echo "======================================"
echo ""
