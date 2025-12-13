# Plano de Execução – Pesquisa Aplicada (Cardapio USP)

## Visão Geral
- **Escopo**: Aplicar Fases 1–6 do estudo em app iOS legado (Objective-C, iOS 13+).
- **Referência**: `research-project-spec.md` (objetivos, métricas, artefatos) e `plan.md` (contexto do inventário).
- **Entrega principal**: Playbook replicável + baseline/avaliação antes/depois.

## Fase 1 — Baseline operacional mínimo (M1)
- **Atividades**
  - Inventário módulos/fluxos críticos e integrações (reusar `spec.md`, `data-model.md`).
  - Leitura estática: complexidade, duplicação, smells, cobertura (via `scripts/metrics/run.sh`).
  - Coletar histórico: releases, severidade de bugs, MTTR/MTTF (git tags, issues, Crashlytics se houver).
  - Formalizar checklists: "Pronto para testar" e "Pronto para lançar"; smoke/regressão mínima (`checklists/smoke-regressao-minima.md`).
- **Saídas**: baseline “antes”, relatórios métricas, checklists publicados.

## Fase 2 — Desenho inicial do processo (M2)
- **Atividades**
  - Definir papéis mínimos (Dev, QA, Produto, Design) e responsabilidades.
  - Criar modelo de requisito com critérios testáveis; matriz req ↔ teste ↔ resultado.
  - Política de code review (qualidade, testabilidade, riscos).
  - Estratégia V&V proporcional: o que automatizar vs. manter manual; plano de testes exploratórios por iteração.
- **Saídas**: modelos (requisito, caso de teste, rastreabilidade), política de revisão, estratégia V&V.

## Fase 3 — Implantação incremental I (M3)
- **Atividades**
  - Testes de caracterização em fluxos críticos antes de alterar código.
  - Automação inicial: unitários + integração nos fluxos (saldo, PIX, boleto, auth) com dados/mocks determinísticos.
  - Refatorações de testabilidade (injeção de dependências, quebrar métodos longos, remover código morto) validadas por caracterização.
  - Execução recorrente local/CI com coleta de cobertura/pass-fail.
- **Saídas**: suite inicial automatizada, refatorações seguras, execução periódica em CI local/PR.

## Fase 4 — Implantação incremental II (M4)
- **Atividades**
  - Expandir cobertura e E2E/UI em jornadas essenciais no simulador estável.
  - Mitigar flakiness: sincronização explícita, mocks/stubs, dados determinísticos.
  - CI em PR/build (GitLab CI) + análise estática por commit/regressão.
- **Saídas**: E2E/UI estáveis, pipeline CI com gates mínimos (testes + estática).

## Fase 5 — Avaliação (M5)
- **Atividades**
  - Medir antes vs. depois: qualidade interna, cobertura, bugs pós-release (severidade), lead time, frequência de release, estabilidade execução.
  - Coletar percepção da equipe (entrevistas/questionário Likert).
  - Comparar eficiência de detecção (exploratórios vs. baseados em caso).
- **Saídas**: relatório de avaliação com métricas e feedback, gaps/remediações propostas.

## Fase 6 — Consolidação (M6)
- **Atividades**
  - Compilar playbook final: checklists, modelos, padrões de código, estratégia V&V, métricas e cadência, lições aprendidas.
  - Plano de continuidade para dívida técnica remanescente; roteiro de replicação para apps similares.
- **Saídas**: playbook e plano de continuidade/replicação.

## Encaixe com Checklists
- Smoke/Regressão mínima: `checklists/smoke-regressao-minima.md` (rodar em PRs de fluxos críticos e semanal).
- Avaliação por fase: `checklists/research-evaluation.md` (inclui gates e validação de aplicação do smoke).

## Métricas e Ferramentas
- Métricas principais: complexidade, duplicação, smells, cobertura, pass/fail, flakiness, lead time, frequência de release, densidade de bugs, MTTR/MTTF, satisfação equipe.
- Ferramentas: `scripts/metrics/run.sh` + `metrics/metrics.env`; Sonar/OCLint/Slather/Lizard/cloc; XCTest (unit/integration/UI), GitLab CI.

## Riscos-chave e Contingências
- Histórico incompleto → registrar lacunas e usar fontes alternativas (git, issues, Crashlytics).
- Flakiness UI → dados determinísticos, mocks/stubs, waits explícitos.
- Tooling pesado → permitir execução parcial/local; mover análises pesadas para runner dedicado.
- Adoção de processo → checklists curtos e obrigatórios; revisar na consolidação.

## Política de Code Review (Fase 2)
- **Escopo mínimo**: toda mudança em fluxos críticos (auth/saldo/PIX/boleto/menu) e em libs de rede/observabilidade deve passar por review.
- **Checklist do reviewer**:
  - Testabilidade: pontos de injeção de dependência, facilidade de mock; nenhum aumento de acoplamento desnecessário.
  - Observabilidade: logs estruturados ou métricas em fluxos críticos; notificações/eventos preservados.
  - Riscos conhecidos: não introduzir novos hashes secretos em código; evitar duplicar dependências; evitar APIs deprecated de AFNetworking.
  - Regressão: smoke/regressão mínima impactada? se sim, atualizar caso/checklist e evidência esperada.
  - Segurança/privacidade: tokens/segredos fora do repositório; nada novo em texto claro.
- **Gate**: aprovar apenas com evidência proporcional (ex.: captura de teste manual para smoke; link para caso automatizado quando existir). Se não houver teste, registrar motivo e plano (F3/F4).

## Estratégia V&V (Fase 2)
- **Princípio**: esforço proporcional ao risco. Fluxos críticos priorizam caracterização/integração (F3) e UI determinística (F4); demais fluxos ficam em smoke manual.
- **Mapa por fluxo**:
  - Auth/login: caracterização integração com mock de OAuth; UI com webview determinística (launch args) em F4.
  - Saldo/PIX/Boletos: integração com stubs de rede em F3; UI feliz/erro em F4.
  - Menu/Restaurantes: integração com respostas fixas RUCard; UI navegação básica.
- **Exploratórios**: 1h por iteração focando mudanças recentes; registrar defeitos/hora e riscos.
- **Dados/mocks**: usar tokens/hash de teste e payloads fixos; preferir stubs locais a dependências externas em F3/F4.
- **Rastreabilidade**: requisitos ↔ casos (template `test-case.md`) ↔ evidências; atualizar matriz quando casos forem materializados.
- **Saída esperada por fase**:
  - F2: política definida (este documento) e matriz planejada (rascunho de casos já incluso).
  - F3: suite de caracterização (integração/unit) rodando local/CI para fluxos críticos.
  - F4: UI/E2E determinísticos com mitigação de flakiness; smoke automatizado opcional.

## Plano de Testes (visão por fase)
- **Objetivo**: garantir caracterização e regressão mínima dos fluxos críticos (auth, saldo, PIX, boleto, menu) com aumento gradual de automação.
- **Fase 1 (agora)**: smoke manual curto (já definido em `checklists/smoke-regressao-minima.md`); sem automação planejada.
- **Fase 2**: preparar modelos/matriz req↔teste; não executar automação ainda.
- **Fase 3**: testes de caracterização (unit/integration) para saldo/PIX/boletos/auth com dados determinísticos.
- **Fase 4**: UI/E2E determinísticos para jornadas essenciais (login→saldo, login→PIX gerar/listar/verificar, login→menu→detalhe restaurante), mitigar flakiness.
- **Fase 5**: comparar antes/depois (pass/fail, cobertura, defeitos, flakiness) e coletar percepção.

### Seleção de fluxos críticos para caracterização (T012)
- **Auth/Login (OAuthUSP)**: dependência para os demais fluxos; requer `wsuserid` persistido; riscos de falha silenciosa.
- **Saldo (consultarSaldo)**: usa token do OAuth; impacto direto ao usuário; já instrumentado com Firebase Perf.
- **PIX (pixgerar, pixlistar, pixverificar)**: combina hash hardcoded e token; múltiplos estados; sensível a regressões.
- **Restaurantes/Cardápio (restaurants, menu/{id})**: hash `kToken` e RUCard; risco moderado, mas alta visibilidade.

**Exclusões**: mapa/links informativos (baixa criticidade, ficam só no smoke manual); **Boletos (boletosEmAberto)** desativado pela equipe, portanto removido do escopo de testes/automação.

### Conjuntos e tipos
- **Smoke manual**: passos 1–8 do checklist; alvo <15 min; simulador iPhone 14 iOS 13.
- **Caracterização (F3)**: unit/integration (NSURLSession/AFNetworking stubs) para `consultarSaldo`, `pixgerar`, `pixlistar`, `pixverificar`, `boletosEmAberto`.
- **UI/E2E (F4)**: XCTest UI com launch args apontando mocks; sincronização explícita e dados fixos.
- **Exploratórios**: 1h por iteração em áreas recentes, registrando defeitos/hora.

### Casos de teste planejados (rascunho)
| ID | Fluxo | Tipo | Descrição curta | Dados | Observabilidade |
|----|-------|------|-----------------|-------|-----------------|
| TC-AUTH-001 | Auth/login | UI | Login via webview; obtém `wsuserid` e salva em defaults | Credencial de teste | Log sucesso/erro, duração, presença de `wsuserid` | 
| TC-SALDO-001 | Saldo | Integration | POST `consultarSaldo` com token válido → crédito exibido | token válido | Status HTTP, corpo JSON, trace Firebase, notification `DidReceiveCredits` |
| TC-SALDO-002 | Saldo erro auth | Integration | Token ausente → erro amigável e HUD fecha | token ausente | HUD mensagem, sem crash, log de erro |
| TC-PIX-001 | PIX gerar | Integration | POST `pixgerar` com valor válido → payload armazenado e `DidCreatePix` | token + valor 10.00 | Status, JSON, notification, HUD |
| TC-PIX-002 | PIX listar | Integration | POST `pixlistar` → retorna último PIX, `DidReceiveLastPix` | token | Status, JSON shape, notification |
| TC-PIX-003 | PIX verificar | Integration | POST `pixverificar` com id válido → `DidPaidPix` quando CONCLUIDA | idfpix válido | Status, situacao, notification |
| TC-MENU-001 | Restaurantes | Integration | POST `restaurants` (RUCard) com hash → lista salva e `DidReceiveRestaurants` | hash `kToken` | Status, JSON, notification |
| TC-MENU-002 | Cardápio diário | Integration | POST `menu/{id}` → popula `menuArray`, `DidReceiveMenu` | hash `kToken`, restaurantId | Status, JSON, notification |
| TC-UI-001 | Jornada saldo | UI/E2E | Login → navegar saldo → saldo visível, sem crash | Credencial de teste | Logs, duração, HUD não bloqueia >10s |
| TC-UI-002 | Jornada PIX gerar/verificar | UI/E2E | Login → gerar PIX → listar → verificar status | Credencial + valor teste | Logs, notificações, HUD |
| TC-UI-004 | Jornada menu/mapa | UI/E2E | Login → abrir menu → cardápio → mapa | Credencial | Logs, métricas carregamento |

### Dados e ambientes
- Simulador alvo: iPhone 14 (iOS 13+). Ajustar destino se o simulador não existir (evitar erros 18.x/26.x listados pelo Xcode 16/17).
- Dados determinísticos: token de teste (`wsuserid`), hash fixo (`kHash`, `kToken`), valores de PIX e restaurantId fixos; preferir mocks/stubs em F3/F4.

### Evidência e registro
- Formato: usar template `templates/test-case.md`; evidências em `metrics-reports/` ou anexos da pipeline.
- Métricas por caso: sucesso/erro, latência (se aplicável), flakiness observada.

### Critérios de bloqueio
- Smoke falha (crash, HUD >10s, payload incoerente) bloqueia release.
- Falha em casos de integração dos fluxos críticos bloqueia merge até correção ou justificativa documentada.
