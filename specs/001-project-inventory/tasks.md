# Tasks — Pesquisa Aplicada (Cardapio USP)

Feature: Pesquisa aplicada / qualidade e processo (Fases 1–6)

## Dependencies (story order)
- Fase 1 → Fase 2 → Fase 3 → Fase 4 → Fase 5 → Fase 6

## Phase 1 — Baseline operacional mínimo
- Goal: Inventário e métricas "antes" + checklists de baixo atrito.
- Independent test: baseline contém inventário, histórico, métricas estáticas, checklists publicados.
- [X] T001 Inventariar módulos/fluxos críticos em `specs/001-project-inventory/spec.md` (atualizar se faltar itens)
- [X] T002 [P] Rodar métricas estáticas com `scripts/metrics/run.sh` e salvar em `metrics-reports/`
- [X] T003 Consolidar histórico de releases/bugs (datas, severidade, MTTR/MTTF) em `specs/001-project-inventory/research.md`
- [x] T004 Publicar checklists "Pronto para testar" e "Pronto para lançar" em `specs/001-project-inventory/checklists/`
- [X] T005 Publicar smoke/regressão mínima em `specs/001-project-inventory/checklists/smoke-regressao-minima.md`
- [X] T006 Registrar baseline "antes" em `specs/001-project-inventory/research-project-spec.md` (seção de avaliação)

## Phase 2 — Desenho inicial do processo
- Goal: Processo mínimo com papéis, artefatos testáveis e rastreabilidade.
- Independent test: modelos e políticas prontos; matriz req↔teste disponível.
- [X] T007 Definir papéis mínimos e responsabilidades em `specs/001-project-inventory/research-project-spec.md`
- [x] T008 Criar modelo de requisito com critérios testáveis em `specs/001-project-inventory/templates/requisito.md`
- [x] T009 Criar modelo de caso de teste e matriz req↔teste em `specs/001-project-inventory/templates/test-case.md`
- [X] T010 Especificar política de code review focada em qualidade/testabilidade em `specs/001-project-inventory/research-project-plan.md`
- [X] T011 Documentar estratégia V&V (o que automatizar vs. manual, testes exploratórios por iteração) em `research-project-plan.md`

## Phase 3 — Implantação incremental I
- Goal: Testes de caracterização + automação inicial e refatorações de testabilidade.
- Independent test: suite de caracterização e unit/integration cobre fluxos críticos; roda em CI/local.
- [X] T012 Selecionar fluxos críticos para caracterização (saldo, PIX, boleto, auth) e documentar em `research-project-plan.md`
- [ ] T013 Implementar testes de caracterização (unit/integration) em `Cardapio USPTests/` com dados/mocks determinísticos
- [ ] T014 Configurar execução recorrente local/CI dos testes de caracterização (atualizar `scripts/metrics/run.sh` se necessário)
- [ ] T015 Refatorar para testabilidade (injeção deps, quebrar métodos longos, remover código morto) e cobrir com testes de caracterização

## Phase 4 — Implantação incremental II
- Goal: E2E/UI estáveis nas jornadas essenciais + gates de CI/estática.
- Independent test: E2E/UI passam de forma estável; análise estática roda por commit/PR.
- [ ] T016 Implementar UI tests para jornadas essenciais em `Cardapio USPTests/` (simulador estável, dados determinísticos)
- [ ] T017 Mitigar flakiness (esperas explícitas, mocks/stubs externos, dados fixos) e registrar em `research-project-plan.md`
- [ ] T018 Integrar CI em PR/build (GitLab CI ou similar) com etapas: testes, cobertura, análise estática (oclint/sonar)
- [ ] T019 Ajustar `scripts/metrics/run.sh`/CI para rodar estática por commit/regressão

## Phase 5 — Avaliação
- Goal: Comparar antes vs. depois; coletar percepção e eficiência de detecção.
- Independent test: relatório antes/depois com métricas e feedback da equipe.
- [ ] T020 Coletar métricas pós-implementação (qualidade interna, cobertura, bugs pós-release, lead time, frequência release, estabilidade)
- [ ] T021 Conduzir entrevistas/questionário (Likert) e sumarizar em `research-project-spec.md`
- [ ] T022 Comparar eficiência de detecção (exploratórios vs. baseados em caso) e registrar ajustes em `research-project-plan.md`
- [ ] T023 Publicar relatório de avaliação em `specs/001-project-inventory/research.md`

## Phase 6 — Consolidação
- Goal: Playbook final e plano de continuidade/replicação.
- Independent test: playbook pronto e plano de continuidade documentado.
- [ ] T024 Compilar playbook final (checkpoints, padrões, modelos, métricas/cadência, lições) em `specs/001-project-inventory/playbook.md`
- [ ] T025 Definir plano de continuidade para dívida técnica remanescente em `playbook.md`
- [ ] T026 Definir roteiro de replicação para apps similares em `playbook.md`

## Cross-cutting / Polish
- [ ] T027 Validar que FR-001..FR-009 e SC-001..SC-004 estão cobertos nas entregas
- [ ] T028 Atualizar links em `plan.md`/`spec.md` para novos artefatos (templates, playbook, coverage)
- [ ] T029 Registrar decisões adicionais na seção Clarifications de `spec.md`
