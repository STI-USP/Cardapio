# Implementation Plan: M3 Test Coverage

**Branch**: `003-m3-tests` | **Date**: 2025-12-12 | **Spec**: `specs/003-m3-tests/spec.md`
**Input**: Feature specification for expanding characterization tests on payment and menu flows.

## Summary

Add deterministic XCTest coverage for `DataAccess` (saldo + PIX) and `DataModel` (restaurants/menus) using stubbed networking so payment/menu behavior is validated without real HTTP. Ensure notifications and state changes align with runtime expectations.

## Technical Context

**Language/Version**: Objective-C (iOS), XCTest
**Primary Dependencies**: AFNetworking (DataModel), NSURLSession + custom URLProtocol (DataAccess), CheckoutDataModel, OAuthUSP
**Storage**: In-memory model state
**Testing**: XCTest, MockURLProtocol stubs
**Target Platform**: iOS
**Project Type**: Mobile app
**Performance Goals**: Deterministic, fast unit tests
**Constraints**: No real network; maintain existing singletons; tests must run under `Cardapio USPTests` target
**Scale/Scope**: Test additions only

## Constitution Check

No blockers detected; proceed with test-focused changes.

## Project Structure

### Documentation (this feature)

```text
specs/003-m3-tests/
├── plan.md
├── spec.md
├── tasks.md
```

### Source/Test Structure (actual)

```text
Cardapio USP/
├── DataAccess.m
├── DataModel.m
├── CheckoutDataModel.m
└── Constants.m

Cardapio USPTests/
├── DataAccessTests.m
└── Cardapio_USPTests.m
```

**Structure Decision**: Work within existing `Cardapio USPTests` target; extend tests for DataAccess/DataModel; no new modules.

## Implementation Strategy

- Keep singletons but control network via `MockURLProtocol`/AFNetworking stubs.
- Add fixtures inline for clarity; avoid external files unless needed.
- Keep UI notifications asserted to ensure parity with app behavior.

## Notes

- Prioritize tests before any refactors. Add minimal helper code only if testability blocks arise.
