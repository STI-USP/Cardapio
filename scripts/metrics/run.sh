#!/usr/bin/env bash
set -euo pipefail

# Generic iOS metrics runner. Uses metrics.env (or path provided as arg) for config.
# Designed to be portable across projects (Objective-C/Swift, CocoaPods, Xcode schemes).

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
ENV_FILE=${1:-"$ROOT_DIR/metrics/metrics.env"}

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
else
  echo "[warn] ENV file not found at $ENV_FILE; using defaults from metrics.env.example"
  # shellcheck disable=SC1090
  source "$ROOT_DIR/metrics/metrics.env.example"
fi

PROJECT_DIR=${PROJECT_DIR:-$ROOT_DIR}
WORKSPACE=${WORKSPACE:-""}
SCHEME=${SCHEME:-""}
OUTPUT_DIR=${OUTPUT_DIR:-"$PROJECT_DIR/metrics-reports"}
SIMULATOR=${SIMULATOR:-"platform=iOS Simulator,name=iPhone 14"}
SONAR_HOST_URL=${SONAR_HOST_URL:-"http://localhost:9000"}
SONAR_PROJECT_KEY=${SONAR_PROJECT_KEY:-""}
SONAR_LOGIN=${SONAR_LOGIN:-""}
EXCLUDE_DIRS=${EXCLUDE_DIRS:-"Pods,Index,Build"}
LIZARD_LANGUAGE=${LIZARD_LANGUAGE:-"objectivec"}
ENABLE_CODE_COVERAGE=${ENABLE_CODE_COVERAGE:-"YES"}
RESULT_BUNDLE_NAME=${RESULT_BUNDLE_NAME:-"TestResults.xcresult"}
METRICS_TAG=${METRICS_TAG:-"local"}

mkdir -p "$OUTPUT_DIR"
cd "$PROJECT_DIR"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log() { echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err() { echo -e "${RED}[ERROR]${NC} $*"; }

if [[ -z "$WORKSPACE" || -z "$SCHEME" ]]; then
  err "WORKSPACE and SCHEME must be set (see metrics.env.example)"; exit 1;
fi

log "Branch: $(git branch --show-current 2>/dev/null || echo n/a)"
log "Commit: $(git rev-parse --short HEAD 2>/dev/null || echo n/a)"
log "Output: $OUTPUT_DIR"

# Step 1: Clean
log "[1/10] Clean build"
xcodebuild clean -workspace "$WORKSPACE" -scheme "$SCHEME" > "$OUTPUT_DIR/clean.log" 2>&1 || warn "Clean failed (see clean.log)"

# Step 2: Tests with coverage
log "[2/10] Tests with coverage"
xcodebuild test \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -destination "$SIMULATOR" \
  -enableCodeCoverage "$ENABLE_CODE_COVERAGE" \
  -resultBundlePath "$OUTPUT_DIR/$RESULT_BUNDLE_NAME" \
  > "$OUTPUT_DIR/xcodebuild-test.log" 2>&1 || warn "Tests failed (see xcodebuild-test.log)"

# Step 3: Coverage reports (Slather if available)
if command -v slather >/dev/null 2>&1; then
  log "[3/10] Coverage via Slather"
  slather coverage --cobertura-xml --output-directory "$OUTPUT_DIR" --scheme "$SCHEME" --workspace "$WORKSPACE" > "$OUTPUT_DIR/slather.log" 2>&1 || warn "Slather XML failed"
  slather coverage --html --output-directory "$OUTPUT_DIR/coverage-html" --scheme "$SCHEME" --workspace "$WORKSPACE" > "$OUTPUT_DIR/slather-html.log" 2>&1 || warn "Slather HTML failed"
else
  warn "Slather not found; skipping coverage reports"
fi

# Step 4: Build for OCLint
log "[4/10] Build for OCLint"
xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration Debug -destination "$SIMULATOR" > "$OUTPUT_DIR/xcodebuild-oclint.log" 2>&1 || warn "Build for OCLint failed"

# Step 5: OCLint (if available)
if command -v oclint-xcodebuild >/dev/null 2>&1; then
  log "[5/10] OCLint analysis"
  oclint-xcodebuild "$OUTPUT_DIR/xcodebuild-oclint.log" > /dev/null 2>&1 || warn "oclint-xcodebuild failed"
  if [[ -f compile_commands.json ]]; then
    IFS=',' read -ra EXC <<< "$EXCLUDE_DIRS"
    EXCLUDE_ARGS=()
    for e in "${EXC[@]}"; do EXCLUDE_ARGS+=( -e "$e" ); done
    oclint-json-compilation-database "${EXCLUDE_ARGS[@]}" -- -report-type html -o "$OUTPUT_DIR/oclint-report.html" > "$OUTPUT_DIR/oclint-html.log" 2>&1 || warn "OCLint HTML failed"
    oclint-json-compilation-database "${EXCLUDE_ARGS[@]}" -- -report-type pmd -o "$OUTPUT_DIR/oclint-report.xml" > "$OUTPUT_DIR/oclint-xml.log" 2>&1 || warn "OCLint XML failed"
    oclint-json-compilation-database "${EXCLUDE_ARGS[@]}" -- -report-type json -o "$OUTPUT_DIR/oclint-report.json" > "$OUTPUT_DIR/oclint-json.log" 2>&1 || warn "OCLint JSON failed"
  else
    warn "compile_commands.json not generated"
  fi
else
  warn "OCLint not found; skipping"
fi

# Step 6: Cyclomatic complexity (Lizard)
if command -v lizard >/dev/null 2>&1; then
  log "[6/10] Lizard complexity"
  lizard "Cardapio USP" -l "$LIZARD_LANGUAGE" --exclude "*/Pods/*" --exclude "*/Index/*" --exclude "*.framework/*" --html > "$OUTPUT_DIR/lizard-complexity.html" || warn "Lizard HTML failed"
  lizard "Cardapio USP" -l "$LIZARD_LANGUAGE" --exclude "*/Pods/*" --exclude "*/Index/*" --exclude "*.framework/*" --csv > "$OUTPUT_DIR/lizard-complexity.csv" || warn "Lizard CSV failed"
  lizard "Cardapio USP" -l "$LIZARD_LANGUAGE" --exclude "*/Pods/*" --exclude "*/Index/*" --exclude "*.framework/*" > "$OUTPUT_DIR/lizard-complexity.txt" || warn "Lizard TXT failed"
else
  warn "Lizard not found; skipping"
fi

# Step 7: Lines of code (cloc)
if command -v cloc >/dev/null 2>&1; then
  log "[7/10] cloc"
  cloc "Cardapio USP" --exclude-dir="$EXCLUDE_DIRS" --json --out="$OUTPUT_DIR/cloc-report.json" || warn "cloc JSON failed"
  cloc "Cardapio USP" --exclude-dir="$EXCLUDE_DIRS" --csv --out="$OUTPUT_DIR/cloc-report.csv" || warn "cloc CSV failed"
  cloc "Cardapio USP" --exclude-dir="$EXCLUDE_DIRS" > "$OUTPUT_DIR/cloc-report.txt" || warn "cloc TXT failed"
else
  warn "cloc not found; skipping"
fi

# Step 8: Architecture sampling (SourceKitten / Periphery)
if command -v sourcekitten >/dev/null 2>&1; then
  log "[8/10] SourceKitten structure sample"
  find "Cardapio USP" -name "*.m" -not -path "*/Pods/*" -not -path "*/AF*" | head -20 | while read -r f; do
    sourcekitten structure --file "$f" || true
  done > "$OUTPUT_DIR/sourcekitten-structure.json"
else
  warn "SourceKitten not found; skipping"
fi

if find "Cardapio USP" -name "*.swift" -not -path "*/Pods/*" | grep -q . && command -v periphery >/dev/null 2>&1; then
  log "[8b/10] Periphery (Swift dead code)"
  periphery scan --workspace "$WORKSPACE" --schemes "$SCHEME" --format json > "$OUTPUT_DIR/periphery-report.json" 2>/dev/null || warn "Periphery failed"
fi

# Step 9: Test metrics extraction
if command -v xcrun >/dev/null 2>&1; then
  log "[9/10] Extracting test metrics"
  xcrun xcresulttool get --path "$OUTPUT_DIR/$RESULT_BUNDLE_NAME" --format json > "$OUTPUT_DIR/test-results-raw.json" 2>/dev/null || warn "xcresulttool extract failed"
fi

# Step 10: SonarQube (optional)
if command -v sonar-scanner >/dev/null 2>&1 && curl -s "$SONAR_HOST_URL" > /dev/null 2>&1 && [[ -n "$SONAR_PROJECT_KEY" ]]; then
  log "[10/10] SonarQube analysis"
  sonar-scanner \
    -Dsonar.projectKey="$SONAR_PROJECT_KEY" \
    -Dsonar.sources="Cardapio USP" \
    -Dsonar.tests="Cardapio USPTests" \
    -Dsonar.coverageReportPaths="$OUTPUT_DIR/cobertura.xml" \
    -Dsonar.objectivec.oclint.report="$OUTPUT_DIR/oclint-report.xml" \
    -Dsonar.host.url="$SONAR_HOST_URL" \
    ${SONAR_LOGIN:+-Dsonar.login="$SONAR_LOGIN"} \
    > "$OUTPUT_DIR/sonar-scanner.log" 2>&1 || warn "SonarQube analysis failed"
else
  warn "SonarQube skipped (scanner/host/key missing or host down)"
fi

log "Done. Reports in $OUTPUT_DIR"
