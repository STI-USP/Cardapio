# Checklist de Avaliação da Pesquisa (Fases 1–6)

## Cobertura de Fase
- [ ] Fase 1: Baseline operacional mínimo concluída (inventário, histórico, leitura estática, checklists prontos)
- [ ] Fase 2: Processo inicial definido (papéis, artefatos testáveis, rastreabilidade mínima)
- [ ] Fase 3: Testes de caracterização + automação inicial rodando em CI/local
- [ ] Fase 4: E2E/UI estável em jornadas essenciais + mitigação de flakiness
- [ ] Fase 5: Comparação antes/depois com métricas coletadas e feedback da equipe
- [ ] Fase 6: Playbook consolidado (checklists, modelos, padrões, métricas, lições)
- [ ] Smoke/Regressão mínima executada e mantida (`checklists/smoke-regressao-minima.md`)

## Métricas e Baseline
- [ ] Baseline "antes" registrado: complexidade, duplicação, smells, cobertura, pass/fail
- [ ] Métricas de entrega: lead time, frequência de release, sucesso de build, flaky tests
- [ ] Métricas de defeitos: densidade pós-release, severidade, reabertura, MTTR/MTTF
- [ ] Eficiência de teste: defeitos/hora (exploratórios vs. caso), esforço automação vs. regressão
- [ ] Satisfação da equipe coletada (questionário Likert)

## Papéis e Artefatos
- [ ] Papéis mínimos ativos (Dev, QA, Produto, Design) com responsabilidades claras
- [ ] Critérios de aceitação testáveis para requisitos priorizados
- [ ] Casos de teste vinculados a requisitos (matriz req ↔ teste ↔ resultado)
- [ ] Rastreabilidade mínima mantida em cada iteração/release
- [ ] Revisão de código com foco em qualidade adotada nas mudanças do piloto

## Execução e Qualidade Técnica
- [ ] Testes de caracterização rodados antes de refatorar áreas críticas
- [ ] Automação unit/integration cobre fluxos críticos
- [ ] E2E/UI cobre jornadas essenciais em simulador estável
- [ ] Instabilidades tratadas (sincronização, mocks/stubs, dados determinísticos)
- [ ] Refatorações de testabilidade feitas e validadas por testes

## Checklists Operacionais
- [ ] "Pronto para testar" aplicado nas entregas do piloto
- [ ] "Pronto para lançar" aplicado antes de releases
- [ ] Rollback/feature flags considerados ou documentados
- [ ] Smoke/Regressão mínima aplicada a cada mudança em fluxos críticos (passos 1–8)

## Ferramental e Reuso
- [ ] Pipeline de métricas roda via `scripts/metrics/run.sh` com env ajustado
- [ ] Análise estática (oclint/sonar) roda pelo menos por commit/PR das áreas críticas
- [ ] Artefatos de métricas e playbook armazenados no repositório

## Riscos e Mitigações
- [ ] Lacunas de histórico documentadas e fontes alternativas usadas (git, issues, Crashlytics)
- [ ] Tooling pesado tem alternativa (execução parcial ou runner dedicado)
- [ ] Adoção de papéis/checklists monitorada; ações de ajuste planejadas

## Resultado Esperado
- [ ] Melhorias observáveis em >=2 eixos (qualidade interna, entrega/estabilidade, defeitos, eficiência)
- [ ] Playbook final pronto para replicação em apps similares
