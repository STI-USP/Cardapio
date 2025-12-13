# Phase 0 Research

## Findings

### Decision: Inventário prioriza documentação das integrações e variáveis de ambiente
- **Rationale**: Constantes críticas (`BASE_URL`, `RUCARD_URL`, `OAUTH_SERVICE_URL`, `OAUTH_URL`, `OAUTH_CONSUMER_SECRET`, `USER_URL_STRING`) são carregadas via Info.plist/Build Settings (ver `Constants.m`). Sem esses valores o app falha silenciosamente ou registra erro genérico.
- **Alternatives considered**: Hardcode em código-fonte (já existe `kHash` e é um risco); usar arquivo `.env` separado (exigiria tooling novo). Manter via Info.plist é o caminho atual e será documentado.

### Decision: Endpoints STI/RU usam POST com hash/token e precisam ser listados
- **Rationale**: `DataAccess` define caminhos `consultarSaldo`, `pixgerar`, `pixlistar`, `pixverificar`, `boletosEmAberto` com `kBaseSTIURL` + POST. Autenticação mistura token (`wsuserid`) e hash hardcoded `rcuectairldq2017`. Inventário deve expor método, caminho, corpo e autenticação para cada.
- **Alternatives considered**: Migrar para OAuth bearer ou remover hash; fora do escopo do inventário (seria mudança de backend). Documentação clara é o mínimo.

### Decision: Dependências principais permanecem (AFNetworking vendorado + Firebase pods)
- **Rationale**: Código usa AFNetworking 2.x diretamente em controllers/managers; migrar exigiria refatoração ampla. Para o inventário basta catalogar pods (`Firebase/Core`, `Crashlytics`, `Analytics`, `Performance`, `SVProgressHUD`, `SWRevealViewController`) e frameworks Crashlytics/Fabric.
- **Alternatives considered**: Substituir AFNetworking por `NSURLSession` ou `URLSession` moderno; não cabe nesta entrega. Apenas registrar débito técnico.

### Decision: Escopo de persistência limitado a configurações e tokens
- **Rationale**: Não há CoreData; Info.plist e possivelmente `NSUserDefaults`/Keychain (tokens OAuth) são os únicos pontos persistentes. Inventário deve mapear chaves e uso de secrets no build.
- **Alternatives considered**: Adicionar cache offline/local DB; fora do escopo do inventário e não suportado hoje.

### Decision: Métrica de sucesso é cobertura documental, não performance
- **Rationale**: Feature é documentação. Sucesso medido por presença das seções FR-001..FR-008 e onboarding <30 min. Não há SLAs de latência a alterar.
- **Alternatives considered**: Definir metas de FPS ou latência; não aplicável sem mudança de código.

### Decision: Constituição ausente → aplicar gate mínimo
- **Rationale**: `constitution.md` é placeholder; não há princípios ratificados. Gate aplicado: histórias independentes e cobertura integral das FRs. Registrar ausência para governança futura.
- **Alternatives considered**: Bloquear avanço até redação da constituição; rejeitado para não atrasar entrega documental.

## Histórico e baseline “antes” (Fase 1)

- **Releases/bugs**: nenhuma fonte de histórico no repositório; sem issues ou changelog. Próximo passo: consultar Crashlytics dashboards históricos e git tags (inexistentes até aqui). Registrar lacuna como risco.
- **Métricas estáticas (2025-12-12, `scripts/metrics/run.sh metrics/metrics.env.example`)**:
	- `cloc`: 187 arquivos, 18.5k linhas de código (Objective-C ~11.2k LOC, headers ~1.1k LOC) em `metrics-reports/cloc-report.*`.
	- `xcodebuild test`: falhou porque o scheme `Cardapio USP` não está configurado para ação de testes (sem testes atribuídos ao target); cobertura indisponível. **Esperado nesta fase**: não há casos de teste planejados na Fase 1; automação será introduzida a partir das Fases 3/4 conforme o plano.
	- `Slather/OCLint/Lizard/xcresulttool/Sonar`: pulados ou falharam por falta de configuração/ferramentas (registrado nos logs em `metrics-reports/`).
- **Riscos observados**: ausência de suíte de testes impede cobertura; ferramentas de análise não instaladas no ambiente; múltiplos simuladores 18.x/26.x listados, mas nenhum configurado para testes; necessidade de definir scheme de teste ou criar target UI/integração.

## Próximos passos de baseline
- Criar/associar testes ao scheme `Cardapio USP` ou mover para `Cardapio USPTests` e habilitar ação *Test*.
- Provisionar ferramentas faltantes (Slather, OCLint, Lizard) ou ajustar pipeline para relatórios mínimos.
- Coletar histórico de incidentes via Crashlytics e repositórios de issues (se existirem); caso contrário, documentar como “dados não disponíveis”.
