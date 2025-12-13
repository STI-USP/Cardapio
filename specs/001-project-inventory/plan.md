# Implementation Plan: Project Inventory

**Branch**: `001-project-inventory` | **Date**: 2025-12-12 | **Spec**: `/specs/001-project-inventory/spec.md`
**Input**: Feature specification from `/specs/001-project-inventory/spec.md`

**Note**: Generated via `/speckit.plan` workflow.

## Summary

Documentar o inventário técnico do app iOS Cardapio USP (Objective-C, iOS 13) cobrindo módulos, fluxos críticos, integrações externas, principais telas, serviços REST, dependências, persistência e riscos. Entregável é documentação navegável (spec/research/data-model/contracts/quickstart) para onboarding e auditoria.

## Technical Context

**Language/Version**: Objective-C (iOS deployment target 13.0; legacy assets mention iOS 7.1 launch images).  
**Primary Dependencies**: AFNetworking (vendored 2.x), Firebase Core/Crashlytics/Analytics/Performance, SVProgressHUD, SWRevealViewController, Crashlytics/Fabric frameworks.  
**Storage**: Info.plist-configured URLs; likely `NSUserDefaults`/Keychain for tokens (to confirm during inventory); no CoreData.  
**Testing**: XCTest target exists (`Cardapio USPTests`) but no tests populated; current feature is documentation-only, so validation is manual review.  
**Target Platform**: iOS 13+ (Podfile), iPhone/iPad (Info.plist orientation entries).  
**Project Type**: Mobile iOS app with CocoaPods-managed dependencies plus vendored frameworks.  
**Performance Goals**: Documentation completeness (100% FR-001..FR-008 coverage) and onboarding <30 min; no runtime perf changes.  
**Constraints**: Security-sensitive secrets (`OAUTH_CONSUMER_SECRET`) in build settings; network-only flows (no offline cache).  
**Scale/Scope**: Dozens of controllers (menu, boleto, saldo, map, info); single app target + test target.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Constitution file is a placeholder with no ratified principles. Interim gate: ensure stories remain independently testable and that documentation artifacts map to FR-001..FR-008. No additional constraints detected; proceed with caution noting governance is undefined.

## Project Structure

### Documentation (this feature)

```text
specs/001-project-inventory/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
Cardapio USP/
├── Controllers & Views: MainViewController, MenuViewController, BoletoViewController, MapViewController, InfoViewController, CreditsNavigationViewController, DKScrollingTabController, FrostedViewController, etc.
├── Models: Menu*, Items, Cash, CarrierDataModel, CheckoutDataModel, DataModel, DataAccess.
├── Networking: AFNetworking vendored sources, OAuth hashes, RUCard/STI clients, Google/Firebase plist configs.
├── Resources: *.plist configs (Carriers, central), storyboards (Main_iPhone), assets.
├── AppDelegate, Prefix.pch, main.m, Categories (CALayer+XibConfiguration), custom cells.
├── Frameworks: Crashlytics.framework, Fabric.framework.
└── Tests: Cardapio USPTests/ (empty scaffold).

Pods/
├── Firebase*, SVProgressHUD, SWRevealViewController, and generated pods project.

specs/001-project-inventory/   # current feature docs
```

**Structure Decision**: Single mobile app (`Cardapio USP`) with CocoaPods; documentation lives under `specs/001-project-inventory`. No separate backend/API in repo.

## Complexity Tracking

No constitution violations identified; no additional complexity to justify.

## Related Documents

- Pesquisa aplicada (Fases 1–6): `specs/001-project-inventory/research-project-spec.md`
- Plano de execução da pesquisa: `specs/001-project-inventory/research-project-plan.md`
- Métricas reutilizáveis: `scripts/metrics/run.sh`, configs em `metrics/metrics.env.example`
- Smoke/Regressão mínima (fluxos críticos): `specs/001-project-inventory/checklists/smoke-regressao-minima.md`
- Checklists operacionais: `specs/001-project-inventory/checklists/pronto-para-testar.md`, `specs/001-project-inventory/checklists/pronto-para-lancar.md`
- Templates: `specs/001-project-inventory/templates/requisito.md`, `specs/001-project-inventory/templates/test-case.md`
- Cobertura FR/SC → tasks: `specs/001-project-inventory/coverage.md`
