# Checklist — Pronto para Testar

- [ ] Requisitos têm critérios de aceitação claros e testáveis.
- [ ] Dados de teste definidos (contas, tokens, payloads) ou mocks/stubs configurados.
- [ ] Dependências externas identificadas; plano de fallback/mock se indisponíveis.
- [ ] Riscos conhecidos listados (performance, flakiness, integrações).
- [ ] Observabilidade mínima pronta: logs estruturados ativos, coleta de sucesso/erro e latência p95 no fluxo.
- [ ] Ambientes/config vars revisados (`BASE_URL`, `RUCARD_URL`, `OAUTH_*`, `USER_URL_STRING`).
- [ ] Critérios de bloqueio combinados (o que falha o build/PR).
- [ ] Smoke/regressão mínima revisada para o fluxo afetado.
