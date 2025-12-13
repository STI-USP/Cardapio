# Cobertura de Requisitos e Sucesso → Tasks

## Functional Requirements (FR)
- FR-001 módulos/fluxos/telas: T001, T005, T027
- FR-002 fluxos críticos origem→serviço→notificação: T001, T005, T012, T013, T016
- FR-003 integrações externas + variáveis: T001, T003, T027
- FR-004 telas/navegação: T001, T016
- FR-005 serviços REST (método/endpoint/base/auth/parâmetros): T001, T005, T012, T013
- FR-006 dependências e riscos (hash, libs legadas, falta de testes): T001, T003, T015, T027
- FR-007 persistência (NSUserDefaults/Keychain) e chaves: T001, T003, T027
- FR-008 gaps de testes e métricas: T002, T014, T017, T020, T023, T027
- FR-009 observabilidade (logs, métricas sucesso/erro, latência p95, tracing): T002, T017, T027

## Success Criteria (SC)
- SC-001 seções FR-001..FR-008 completas: T001, T002, T003, T005, T027
- SC-002 onboarding <30 min com inventário: T001, T005, T027, T028, T029
- SC-003 todos endpoints listados com método e auth: T001, T005, T012, T013, T027
- SC-004 riscos (hash, AFNetworking legado, ausência de testes) documentados: T001, T003, T015, T027

## Observabilidade (FR-009) — apontadores
- Registrar nível: logs estruturados + métricas sucesso/erro + p95 + tracing quando aplicável.
- Tarefas: T002 (coleta métrica), T017 (flakiness/esperas/mocks), T027 (verificação final de cobertura), T028 (links), T029 (clarifications).

## Notes
- Mantenha este arquivo sincronizado ao criar novos FR/SC ou tasks.
- T028/T029 são guarda-chuva para garantir links e clarificações ficam atualizados.
