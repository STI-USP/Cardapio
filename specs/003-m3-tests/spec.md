# Feature Specification: M3 Test Coverage

**Feature Branch**: `003-m3-tests`  
**Created**: 2025-12-12  
**Status**: Draft  
**Input**: User description: "create a m3 feature"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Guard RU card balance APIs (Priority: P1)

Verify balance/PIX calls behave correctly with and without auth, and raise the expected notifications so UI/state stays consistent.

**Why this priority**: Prevents regressions in payment flows and keeps wallet state accurate.

**Independent Test**: Drive `DataAccess` with stubbed networking and assert notifications + state mutations without hitting the network.

**Acceptance Scenarios**:
1. **Given** a valid token, **When** saldo or PIX endpoints respond 200, **Then** notifications fire and checkout state stores the PIX payload.
2. **Given** no token, **When** saldo is requested, **Then** no network call occurs.
3. **Given** a concluded PIX status, **When** verifying PIX, **Then** paid notification fires.

---

### User Story 2 - Menu fetch stays resilient (Priority: P2)

Ensure restaurant/menu fetches parse correctly and handle empty/error responses without crashing.

**Why this priority**: Menu availability is core to the app; must fail safe and surface usable data.

**Independent Test**: Stub AFNetworking responses for `DataModel` and assert parsed models + notifications without real HTTP.

**Acceptance Scenarios**:
1. **Given** a valid JSON list, **When** fetching restaurants, **Then** notification fires with parsed entries.
2. **Given** an error or empty payload, **When** fetching menu/restaurants, **Then** errors are handled and no crash occurs.

### Edge Cases

- Missing token should short-circuit balance calls.
- PIX list returning arrays vs objects should still update checkout state.
- Empty/invalid menu JSON should not crash and should not emit stale data.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Must cover saldo flow with token and without token.
- **FR-002**: Must cover PIX gerar/listar/verificar happy paths and state storage in `CheckoutDataModel`.
- **FR-003**: Must cover menu/restaurant fetch parsing and error handling without network.
- **FR-004**: Tests must rely on stubbed networking (no real HTTP).
- **FR-005**: Notifications expected by UI must be asserted in tests.

### Key Entities

- **DataAccess**: Performs saldo/PIX calls and posts notifications.
- **CheckoutDataModel**: Stores PIX dictionaries.
- **DataModel**: Fetches restaurants/menus and posts notifications.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: New XCTest cases cover saldo and PIX flows with deterministic stubs.
- **SC-002**: New XCTest cases cover restaurant/menu parsing and error paths without real network.
- **SC-003**: Test suite runs green via xcodebuild for `Cardapio USPTests` target.
- **SC-004**: Coverage of DataAccess/DataModel increases and no regressions in existing tests.
