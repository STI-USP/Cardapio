# Data Model: Project Inventory

## Entities

### Module
- **Fields**: name, domain (menu/boleto/saldo/map/info/auth), keyFiles, dependencies, notes.
- **Relationships**: has many `Flow` (via domain); references `Dependency` entries used inside keyFiles.

### Flow
- **Fields**: name, domain, trigger (user action), servicesUsed, viewControllers, notificationsEmitted, risks.
- **Relationships**: consumes `ServiceEndpoint`; surfaces `Screen`; may emit `Risk`.

### ServiceEndpoint
- **Fields**: name, method (POST), path (e.g., consultarSaldo, pixgerar, pixlistar, pixverificar, boletosEmAberto), baseURL (BASE_URL / RUCARD_URL / OAUTH_SERVICE_URL / USER_URL_STRING), auth (token/hash/OAuth), contentType (json|form), requestSchema, responseSchema, errors.
- **Relationships**: belongs to `Flow`; linked to `Dependency` (networking lib) and `PersistedKey` (tokens/secrets).

### Screen
- **Fields**: name (ViewController), purpose, storyboard, navigationEntry (tab/menu), linkedFlows, platformTargets (iPhone/iPad), orientation.
- **Relationships**: participates in `Flow`; may display data from `ServiceEndpoint`.

### Dependency
- **Fields**: name, type (pod/vendor/framework), version/source, consumers (modules/files), risk (legacy/abandoned), notes.
- **Relationships**: used by `Module` and `ServiceEndpoint`.

### PersistedKey
- **Fields**: keyName (Info.plist or defaults), purpose, sensitivity (public|secret), owner (build setting/backend), fallbackBehavior.
- **Relationships**: required by `ServiceEndpoint` (e.g., BASE_URL, OAUTH_CONSUMER_SECRET) and `Flow`.

### Risk
- **Fields**: description, location (file/endpoint), impact, likelihood, mitigation.
- **Relationships**: attached to `Flow`, `Dependency`, or `PersistedKey`.

## Validation Rules
- Every `ServiceEndpoint` must specify auth method and baseURL source (FR-005, FR-003).
- Every `Flow` must enumerate screens and notifications emitted for observability.
- Every `Module` must list at least one key file and owning dependency (FR-001, FR-006).
- Every `PersistedKey` marked secret must note storage location (build setting vs Keychain) and absence of defaults.
- Risks must highlight hardcoded secrets (kHash), legacy libs (AFNetworking 2.x), and missing tests (FR-006, FR-008).

## State Notes
- Tokens (`wsuserid`) and hash (`rcuectairldq2017`) are required for boleto/PIX flows; lack of token triggers auth error handling.
- Network-only flows: no offline cache; failures surface via SVProgressHUD messages.
