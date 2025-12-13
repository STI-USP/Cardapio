# Pesquisa Aplicada: Qualidade e Processo no App Cardapio USP

**Foco**: elevar qualidade e previsibilidade em app iOS legado (Objective-C, iOS 13+) via baseline, processo mínimo e implantação incremental.
**Horizonte**: Fases 1–6; piloto no app Cardapio USP; replicável a apps similares.

## Objetivos
- Estabelecer baseline operacional de qualidade/entrega (antes/depois).
- Introduzir processo leve com papéis mínimos (Dev, QA, Produto, Design) e checklists de baixo atrito.
- Implantar V&V incremental (testes de caracterização, automação unit/integration, depois E2E/UI) com métricas contínuas.
- Avaliar impacto (métricas internas, entrega, defeitos, percepção da equipe) e consolidar playbook replicável.

## Escopo e Limites
- Inclui: app iOS Cardapio USP; fluxos críticos (menu, saldo, boleto/PIX, auth); métricas de código e processo; CI local/PR; Sonar/oclint/slather/lizard/cloc.
- Exclui: refatoração ampla de arquitetura, migração de backend, redesign de UX completo, suporte offline.
- Piloto único; replicação em outros apps apenas após Fase 6 (playbook).

## Fases e Entregas

### Fase 1 — Baseline operacional mínimo
- Inventário de módulos/fluxos críticos; avaliação de artefatos existentes (tests, checklists).
- Leitura estática: complexidade, duplicação, smells, cobertura (se existir).
- Histórico: releases, severidade de bugs, tempo até correção/restauração.
- Baseline formal de qualidade/entrega (referência "antes").
- Seleção do app piloto e delimitação de escopo.
- Checklists de baixo atrito: "Pronto para testar" e "Pronto para lançar".

### Fase 2 — Desenho inicial do processo
- Papéis mínimos: Dev, QA, Produto, Design (usabilidade/aceitação).
- Artefatos: requisitos com critérios testáveis, casos de teste por requisito, rastreamento de bugs.
- Revisão de código focada em qualidade.
- Estratégia V&V proporcional: o que automatizar vs. manter manual; testes exploratórios por iteração.
- Rastreabilidade básica: requisito ↔ evidência/resultado de teste.

### Fase 3 — Implantação incremental I
- Testes de caracterização antes de alterar áreas críticas.
- Primeira automação: unitários e integração em fluxos críticos.
- Refatorações para testabilidade (injeção de dependências, quebrar métodos longos, remover código morto) validadas pelos testes de caracterização.
- Execução recorrente local/CI; coleta de métricas (cobertura, pass/fail).

### Fase 4 — Implantação incremental II
- Ampliar cobertura e E2E de UI em jornadas essenciais em simuladores estáveis.
- Tratar instabilidades: sincronização explícita, mocks/stubs de externos, dados determinísticos.
- CI em PR/build (GitLab CI) + análise estática por commit e regressão.

### Fase 5 — Avaliação
- Comparar antes vs. depois: qualidade interna, cobertura, bugs pós-release (severidade), lead time, frequência de releases, estabilidade de execução.
- Percepção da equipe (entrevistas/questionários).
- Eficiência de detecção: testes documentados vs. exploratórios (quantidade/tempo) para ajustar estratégia.

### Fase 6 — Consolidação
- Playbook com checkpoints de qualidade, papéis, ferramentas, padrões de código, modelos (caso de teste, checklist), métricas + periodicidade, lições aprendidas.
- Plano de continuidade: tratar dívida técnica remanescente, manter/elevar maturidade, replicar em apps similares.

## Checklists de Baixo Atrito
- **Pronto para testar**: critérios de aceitação claros; dados de teste definidos; dependências/mocks configurados; riscos conhecidos anotados.
- **Pronto para lançar**: testes críticos passam; regressão mínima executada; métricas-chave revisadas; rollback/feature flags (se houver) definidos; notas de release e riscos documentados.

## Papéis e Responsabilidades (mínimos)
- **Dev**: implementar e manter testabilidade; garantir observabilidade mínima (logs, métricas, notificações) nos fluxos que tocar; escrever/atualizar casos de teste automatizados; participar de revisão de código com foco em riscos e testabilidade; manter rastreabilidade requisito→teste.
- **QA**: definir/rodar casos de teste e exploratórios; medir flakiness; operar smoke/regressão mínima; monitorar métricas de execução; registrar evidências e status; validar critérios de aceitação.
- **Produto**: garantir requisitos com critérios testáveis; priorizar riscos/fluxos críticos; aceitar entregas com base em evidências; manter backlog de riscos e decisões.
- **Design**: validar usabilidade/aceitação nos fluxos chave; fornecer critérios observáveis e restrições de UX; revisar impacto em fluxo.
- **Revisor Técnico (pode ser Dev diferente)**: aplicar política de code review (ver `research-project-plan.md`), incluindo checklist de testabilidade/observabilidade e riscos conhecidos (hashes, AFNetworking).

### Responsabilidade mínima por tipo de mudança (RACI simplificado)
- **Mudança em fluxo crítico (saldo/PIX/boleto/auth/menu)**: Dev (R), QA (A para testes/smoke), Produto (C para critérios), Revisor Técnico (A para review), Design (C se UX afetar).
- **Infra/tooling (metrics/CI)**: Dev (R), QA (C), Revisor Técnico (A), Produto (I), Design (I).
- **Doc/processo**: Dev/QA (R), Produto (A), Design (I), Revisor Técnico (C se impactar riscos/observabilidade).

## Artefatos Esperados
- Inventário de módulos/fluxos e integrações (baseline).
- Histórico de releases/bugs (datas, severidade, MTTR/MTTF).
- Métricas estáticas e dinâmicas (complexidade, duplicação, smells, cobertura, pass/fail, flakiness).
- Casos de teste por requisito + matriz de rastreabilidade (req ↔ teste ↔ resultado).
- Playbook final (checklists, modelos, políticas de revisão, estratégia V&V, métricas e cadência).

## Métricas de Sucesso
- **Qualidade interna**: complexidade média módulos críticos ↓; duplicação ↓; code smells ↓; cobertura ↑ nas partes prioritárias; índice de manutenibilidade ↑ (Sonar/TQI).
- **Entrega/estabilidade**: lead time ↓; frequência de releases ↑; taxa de sucesso das builds ↑; flaky tests ↓ e tempo de correção ↓; MTTR de build quebrado ↓.
- **Defeitos**: densidade de bugs pós-release ↓; % releases sem incidentes graves ↑; reabertura de bugs ↓; MTTR de incidente ↓; MTTF ↑ (quando aplicável).
- **Eficiência/Produtividade**: defeitos/hora em teste exploratório vs. baseado em caso; horas de automação vs. redução de regressão manual; satisfação da equipe (Likert) ↑; retrabalho (tarefas devolvidas pelo QA) ↓.

## Baseline “antes” (Fase 1)
- **Execução de métricas (2025-12-12)**: `scripts/metrics/run.sh metrics/metrics.env.example` gerou relatórios em `metrics-reports/`.
	- `cloc`: 187 arquivos, ~18.5k linhas de código (Objective-C ~11.2k LOC; headers ~1.1k LOC).
	- `xcodebuild test`: falhou — scheme `Cardapio USP` não configurado para ação de testes; cobertura indisponível. **Planejado**: Fase 1 não inclui automação; testes serão adicionados a partir das Fases 3–4, então a falha atual é esperada.
	- `Slather/OCLint/Lizard/Sonar`: não executados ou falharam por falta de ferramenta/artefato (vide logs `xcodebuild-oclint.log`, `lizard-complexity.*`).
- **Histórico de releases/bugs**: não há issues ou changelog no repositório; Crashlytics histórico não coletado ainda. Lacuna registrada; precisa consulta externa.
- **Riscos para baseline**: ausência de suíte de testes impede métricas de qualidade; dependência de ferramentas locais não instaladas; múltiplos simuladores listados sem destino configurado.

## Cronograma (marcos M1–M6)
- M1: Baseline operacional mínimo (Fase 1)
- M2: Desenho inicial do processo (Fase 2)
- M3: Implantação incremental I (Fase 3)
- M4: Implantação incremental II (Fase 4)
- M5: Avaliação (Fase 5)
- M6: Consolidação (Fase 6)

## Riscos e Mitigações
- Tempo insuficiente para coleta de histórico: priorizar fontes acessíveis (git tags, issues, Crashlytics) e documentar lacunas.
- Flakiness alta em UI tests: usar dados determinísticos, mocks/stubs e sincronização explícita.
- Tooling pesado (Sonar/OCLint) em máquinas lentas: permitir execução parcial; rodar em runner dedicado quando possível.
- Falta de adesão a papéis/checklists: manter checklists curtos e obrigatórios; revisitar na consolidação.

## Replicabilidade
- Scripts de métricas (`scripts/metrics/run.sh`) e env (`metrics/metrics.env.example`) são reutilizáveis em outros apps; ajustar WORKSPACE/SCHEME e exclusões.
- Playbook final (Fase 6) servirá como modelo de expansão para demais produtos.
