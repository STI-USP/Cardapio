# Metrics Pipeline (Reusable)

Use these artifacts to run the iOS metrics suite locally and replicate it in other projects.

## Files
- `metrics.env.example`: Template with knobs (workspace, scheme, simulator, Sonar host/key, exclusions). Copy to `metrics.env` and adjust.
- `scripts/metrics/run.sh`: Generic runner. Reads `metrics.env` (or path passed as arg) and executes metrics end-to-end.

## Quickstart (this repo)
```bash
cp metrics/metrics.env.example metrics/metrics.env
# edit metrics/metrics.env if you change scheme/workspace/output
./scripts/metrics/run.sh
```
Outputs land in `metrics-reports/`.

## Running elsewhere
1) Copy `metrics/` and `scripts/metrics/` into the target repo.
2) Update `PROJECT_DIR`, `WORKSPACE`, `SCHEME`, `EXCLUDE_DIRS`, `SONAR_*` in `metrics.env`.
3) Ensure tools installed (Homebrew: `swiftlint oclint sonar-scanner cloc sourcekitten openjdk@11 sonarqube`, `pip3 install lizard`, `gem install slather`).
4) Run `./scripts/metrics/run.sh`.

## Notes
- SonarQube step is optional and auto-skips if host/scanner/key missing.
- Slather, OCLint, Lizard, cloc, SourceKitten, Periphery each auto-skip if not installed.
- Result bundle name can be changed via `RESULT_BUNDLE_NAME` in `metrics.env`.
