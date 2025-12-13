# Tasks: M3 Test Coverage

**Input**: Spec/plan in `specs/003-m3-tests/`
**Prerequisites**: plan.md, spec.md

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [ ] T001 Verify `Cardapio USPTests` target runs via `xcodebuild` (destination, bundle id).
- [ ] T002 [P] Ensure `MockURLProtocol` registration/teardown is isolated per test to avoid bleed-over.

## Phase 2: Tests

- [X] T101 [P] [US1] Add saldo happy-path and no-token guard tests in `Cardapio USPTests/DataAccessTests.m`.
- [X] T102 [P] [US1] Add PIX gerar/listar/verificar characterization tests asserting notifications and `CheckoutDataModel` state.
- [X] T103 [P] [US2] Add restaurants fetch parsing success test for `DataModel` with stubbed AFNetworking response.
- [X] T104 [P] [US2] Add menu/error handling tests for `DataModel` to ensure no crash and expected notifications.
- [ ] T105 [P] Add shared fixtures/helpers for JSON stubs if duplication appears.

## Phase 3: Integration

- [ ] T201 Wire CI/local script to run `Cardapio USPTests` (update `run_metrics.sh` or add docs if needed).

## Phase 4: Polish

- [ ] T301 Update documentation/checklists with new test coverage and any deviations.
