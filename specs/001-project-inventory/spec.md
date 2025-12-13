# Feature Specification: Project Inventory

**Feature Branch**: `001-project-inventory`  
**Created**: 2025-12-12  
**Status**: Draft  
**Input**: "Criar inventário do projeto: listar módulos, fluxos críticos, integrações externas, principais telas, serviços REST, dependências, organizado por domínio/feature."

## Clarifications

### Session 2025-12-12
- Q: Quais campos mínimos registrar em cada serviço REST? → A: Método, path, autenticação, base URL e parâmetros/corpo de requisição (sem resposta/erros).
- Q: Qual nível de observabilidade registrar para endpoints críticos? → A: Logs estruturados + métricas de sucesso/erro e latência p95 + tracing distribuído (completo).

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Consultar inventário único (Priority: P1)
Equipe de engenharia consulta um inventário consolidado para entender módulos, fluxos críticos e integrações antes de alterar o código.

**Why this priority**: É a documentação central para decisões de arquitetura e mitigação de regressões.

**Independent Test**: Abrir o inventário e verificar se seções obrigatórias (módulos, fluxos, integrações, dependências, telas, serviços REST) estão presentes e preenchidas.

**Acceptance Scenarios**:
1. **Given** o repositório clonado, **When** abro `specs/001-project-inventory/spec.md`, **Then** encontro seções completas de módulos, fluxos críticos, integrações, dependências e telas.
2. **Given** um novo integrante do time, **When** ele lê o inventário, **Then** identifica domínios, serviços REST e principais integrações sem suporte adicional.

---

### User Story 2 - Rastrear integrações e serviços (Priority: P2)
Time de operações valida rapidamente endpoints, tokens e variáveis necessárias para subir o app.

**Why this priority**: Minimiza incidentes de configuração e acelera troubleshooting.

**Independent Test**: Conferir se a seção de serviços REST lista endpoints, métodos, parâmetros e autenticação (hash/token/OAuth) e variáveis Info.plist.

**Acceptance Scenarios**:
1. **Given** a necessidade de configurar ambiente, **When** consulto a tabela de serviços REST, **Then** encontro endpoints e parâmetros de autenticação requeridos.

---

### User Story 3 - Auditar riscos e dependências (Priority: P3)
Segurança e QA auditam riscos (hash hardcoded, libs legadas) e ausência de testes.

**Why this priority**: Antecipar vulnerabilidades e débito técnico que podem bloquear releases.

**Independent Test**: Verificar se a seção de riscos/gaps aponta hash hardcoded, AFNetworking legado e testes inexistentes.

**Acceptance Scenarios**:
1. **Given** uma revisão de segurança, **When** leio a seção de riscos, **Then** encontro hash hardcoded e bibliotecas legadas destacados.

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases
- Ambiente sem variáveis Info.plist (`BASE_URL`, `RUCARD_URL`, `OAUTH_*`, `USER_URL_STRING`).
- Usuário não autenticado: endpoints que exigem token devem estar rotulados.
- Falta de conectividade: inventário menciona ausência de cache/offline.
- Diferentes deploy targets (iPhone/iPad): telas listadas cobrem ambos.

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements
- **FR-001**: Inventário DEVE listar módulos/domínios com arquivos-chave (controllers, models, data access).
- **FR-002**: Inventário DEVE descrever fluxos críticos (menu, saldo, PIX, auth, boleto) com origem→serviço→notificação.
- **FR-003**: Inventário DEVE mapear integrações externas (Firebase, OAuth USP, STI API, RUCard API) com variáveis necessárias.
- **FR-004**: Inventário DEVE listar principais telas (ViewControllers) e organização de navegação.
- **FR-005**: Inventário DEVE listar serviços REST com método, endpoint, base URL, forma de autenticação e parâmetros/corpo de requisição.
- **FR-006**: Inventário DEVE registrar dependências (Pods + vendored) e riscos técnicos (hash hardcoded, libs legadas, falta de testes).
- **FR-007**: Inventário DEVE registrar persistência (NSUserDefaults/Keychain) e chaves utilizadas.
- **FR-008**: Inventário DEVE destacar gaps de testes e métricas disponíveis.
- **FR-009**: Inventário DEVE registrar o nível de observabilidade desejado para serviços críticos: logs estruturados, métricas de sucesso/erro e latência p95, e tracing distribuído quando aplicável.

### Key Entities *(include if feature involves data)*
- **Inventory Document**: seções obrigatórias (módulos, fluxos, integrações, telas, serviços REST, dependências, riscos, persistência, testes).
- **Service Endpoint Entry**: método, caminho, base URL (RUCard/STI/OAuth/UserURLString), autenticação (hash/token/OAuth), consumidor (VC/manager).

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes
- **SC-001**: Inventário contém 100% das seções definidas em FR-001..FR-008 (checagem manual).
- **SC-002**: Onboarding técnico reduzido para <30 minutos usando apenas o inventário (autoavaliação do time).
- **SC-003**: Todos os endpoints REST usados no app listados com método e autenticação (validação cruzada com `DataAccess`/`DataModel`).
- **SC-004**: Riscos principais documentados (hash hardcoded, AFNetworking legado, ausência de testes) e apontados na seção de gaps.

## Inventário (módulos, fluxos, serviços, riscos)

### Domínios e módulos (FR-001, FR-004, FR-006)
| Domínio | Controllers / Views | Models / Helpers | Rede / Dependências | Notas |
|---------|---------------------|------------------|----------------------|-------|
| Navegação / Shell | `MainViewController`, `CreditsNavigationViewController`, `FrostedViewController`, `SelectorViewController`, `WebViewController`, `REFrostedViewController`* | — | `SWRevealViewController`, `REFrostedViewController` (vendored) | Menu lateral + navegação principal. |
| Auth / Sessão | `LoginWebViewController` (OAuth web), `AppDelegate` (bootstrap) | `OAuthUSP`, `Constants` | `NSURLSession`, `kOAuthServiceURL`, `kOAuthURL`, `kOAuthConsumerSecret`, Firebase Crashlytics/Performance | Tokens salvos em `NSUserDefaults` (`oauthToken`, `oauthTokenSecret`, `userData`). |
| Cardápio / Restaurantes | `MenuViewController`, `RestaurantDetailTableViewController`, `InfoViewController`, `MapViewController` | `DataModel`, `Menu`, `Period`, `Items` | `AFHTTPRequestOperationManager` (AFNetworking 2.x), `kBaseRUCardURL`, hash `kToken` (hardcoded) | Fluxos de listagem de restaurantes e menus diários. |
| Pagamentos / Créditos | `BoletoViewController`, `BoletoFormViewController`, `BoletosPendentesTableViewController`, `PixViewController`, `CreditsViewController` | `BoletoDataModel`, `CheckoutDataModel`, `CarrierDataModel`, `DataAccess` | `NSURLSession` + Firebase Perf/Crashlytics, `kBaseSTIURL`, hash `kHash` hardcoded, tokens `wsuserid` | Fluxos boleto/PIX/saldo dependem de token do OAuth e hash. |
| Mapa / Info | `MapViewController`, `InfoViewController`, `WebViewController` | `PlaceAnnotation`, `MenuDataModel` | MapKit, WebKit, SWReveal | Mapa apenas abre e lista pontos (sem rota externa). |
| Utilidades / UI | Cells (`DetailCell`, `ImageCell`, `PreferredCell`, `BoletoTableViewCell`), categorias `CALayer+XibConfiguration` | — | SVProgressHUD | Componentes de UI e loading. |

### Fluxos críticos (FR-002, FR-004)
- **Login/OAuth**: `OAuthUSP.login` abre `LoginWebViewController` → recebe `oauthToken`/`oauthTokenSecret` → armazena em `NSUserDefaults` → `OAuthUSP.registrarToken` envia POST `/registrar` (JSON) para `kOAuthServiceURL` com `wsuserid`.
- **Saldo**: trigger em `BoletoViewController`/`CreditsViewController` → `DataAccess.consultarSaldo` POST `consultarSaldo` (JSON) em `kBaseSTIURL` com token `wsuserid` → notificação `DidReceiveCredits` → HUD fecha.
- **PIX gerar**: `PixViewController` chama `DataAccess.createPix` → POST `pixgerar` (form) com `hash`, `token`, `valor`, `tipoapp=APP` → se sucesso, guarda em `boletoDataModel.pix` → notifica `DidCreatePix`.
- **PIX listar/verificar**: `DataAccess.getLastPix` POST `pixlistar` (form) com `hash`, `token` → seta pix e notifica `DidReceiveLastPix`; `checkPix` POST `pixverificar` (form) com `hash`, `idfpix` → notifica `DidPaidPix` quando concluído.
- **Boletos pendentes**: `DataAccess.getBoletos` POST `boletosEmAberto` (JSON) com `token` → popula `boletoDataModel.boletosPendentes` → notifica `DidReceiveBills`.
- **Restaurantes**: `DataModel.getRestaurantList` POST `restaurants` (form) em `kBaseRUCardURL` com hash `kToken` → guarda lista em defaults → notifica `DidReceiveRestaurants`.
- **Cardápio diário**: `DataModel.getMenu` POST `menu/{restaurantId}` (form) em `kBaseRUCardURL` com hash `kToken` → preenche `menuArray` → notifica `DidReceiveMenu`.
- **Logout**: `OAuthUSP.invalidarToken` POST `/sair` em `kOAuthServiceURL` com `token`/`tokenNotificacao` → limpa credenciais locais.

### Serviços REST (FR-003, FR-005)
| Nome | Método / Content-Type | Path | Base URL (Info.plist) | Auth / Params | Consome | Notificações / Resultado |
|------|-----------------------|------|-----------------------|---------------|---------|--------------------------|
| consultarSaldo | POST `application/json` | `consultarSaldo` | `BASE_URL` (`kBaseSTIURL`) | Body JSON `{ token: wsuserid }` | `DataAccess.consultarSaldo` | `DidReceiveCredits`; HUD fecha; em erro mostra mensagem. |
| pixgerar | POST `application/x-www-form-urlencoded` | `pixgerar` | `BASE_URL` | Form `{ hash, token, valor, tipoapp=APP }` | `DataAccess.createPix` | `DidCreatePix`; HUD via controller. |
| pixlistar | POST `application/x-www-form-urlencoded` | `pixlistar` | `BASE_URL` | Form `{ hash, token }` | `DataAccess.getLastPix` | `DidReceiveLastPix` (usa primeiro item se array). |
| pixverificar | POST `application/x-www-form-urlencoded` | `pixverificar` | `BASE_URL` | Form `{ hash, idfpix }` | `DataAccess.checkPix` | `DidPaidPix` se `situacao=CONCLUIDA`. |
| boletosEmAberto | POST `application/json` | `boletosEmAberto` | `BASE_URL` | Body JSON `{ token }` | `DataAccess.getBoletos` | `DidReceiveBills`; exibe `mensagemErro` em erro lógico. |
| restaurants | POST `application/x-www-form-urlencoded` | `restaurants` | `RUCARD_URL` (`kBaseRUCardURL`) | Form `{ hash: kToken }` | `DataModel.getRestaurantList` | `DidReceiveRestaurants`; fallback defaults. |
| menu/{id} | POST `application/x-www-form-urlencoded` | `menu/{restaurantId}` | `RUCARD_URL` | Form `{ hash: kToken }` | `DataModel.getMenu` | `DidReceiveMenu`; HUD fecha ou erro amigável. |
| registrar | POST `application/json` | `/registrar` | `OAUTH_SERVICE_URL` | Body `{ token: wsuserid, app: "AppCardapi", tokenNotificacao?, ambiente?:"I" }` | `OAuthUSP.registrarToken` | `DidRegisterUser` em sucesso.
| sair | POST `application/json` | `/sair` | `OAUTH_SERVICE_URL` | Body `{ token: wsuserid, tokenNotificacao?, ambiente?:"I" }` | `OAuthUSP.invalidarToken` | Limpa credenciais locais. |
| consultar | POST `application/json` | `/consultar` | `OAUTH_SERVICE_URL` | Body `{ token: wsuserid }` | `OAuthUSP.consultarToken` | Apenas loga retorno (não notifica). |

### Telas e navegação (FR-004)
- **Root**: `MainViewController` com menu lateral (`SWRevealViewController`) → navega para Boleto/PIX/Mapa/Info.
- **Autenticação**: `LoginWebViewController` (web view OAuth), `AppDelegate` inicializa sessão e Firebase.
- **Pagamentos**: `BoletoViewController`, `BoletoFormViewController`, `BoletosPendentesTableViewController`, `PixViewController`, `CreditsViewController` (HUD + tabelas/cells).
- **Cardápio**: `MenuViewController`, `RestaurantDetailTableViewController`, `InfoViewController` (tabs/tabelas de refeições) + cells auxiliares.
- **Mapa/Info**: `MapViewController`, `InfoViewController`, `WebViewController` para links.
- **Shell/UI util**: `FrostedViewController`, `SelectorViewController`, categorias de UI (`CALayer+XibConfiguration`).

### Dependências (FR-006)
- **Pods**: Firebase/Core, Firebase/Crashlytics, Firebase/Analytics, Firebase/Performance, SVProgressHUD, SWRevealViewController (`Podfile`, iOS 13, modular headers).
- **Vendored**: AFNetworking 2.x (fontes na pasta do app), Crashlytics.framework/Fabric.framework (legado), REFrostedViewController sources.
- **Sistemas**: `NSURLSession`, MapKit, WebKit, NSNotificationCenter.
- **Risks**: AFNetworking 2.x legado sem patches recentes; frameworks Crashlytics/Fabric duplicam Crashlytics do pod; hash hardcoded; ausência de testes automatizados no target `Cardapio USPTests`.

### Config vars e persistência (FR-003, FR-007)
| Chave | Fonte | Uso | Sensibilidade |
|-------|-------|-----|---------------|
| `BASE_URL` | Info.plist/Build Settings → `Constants.m` (`kBaseSTIURL`) | Endpoints saldo/PIX/boletos | Alta (ambiente). |
| `RUCARD_URL` | Info.plist → `kBaseRUCardURL` | Endpoints restaurantes/menu | Média. |
| `OAUTH_SERVICE_URL` | Info.plist → `kOAuthServiceURL` | `/registrar`, `/sair`, `/consultar` | Alta. |
| `OAUTH_URL` | Info.plist → `kOAuthURL` | Web login base | Alta. |
| `OAUTH_CONSUMER_SECRET` | Info.plist → `kOAuthConsumerSecret` | OAuth handshake | Secreta. |
| `USER_URL_STRING` | Info.plist → `UserURLString` | Consulta de usuário/WS | Alta. |
| `kHash` | Código (`DataAccess.m`) | Hash STI para PIX/boleto | Secreta (hardcoded). |
| `kToken` | Código (`DataModel.m`) | Hash RUCard para restaurantes/menu | Secreta (hardcoded). |
| `oauthToken` / `oauthTokenSecret` / `userData` | `NSUserDefaults` | Sessão OAuth + JSON do usuário (inclui `wsuserid`) | Sensível; sem criptografia. |
| `Restaurants`, `preferredRestaurant` | `NSUserDefaults` | Cache de listas e preferência | Baixa. |

### Observabilidade (FR-008, FR-009)
- **Já instrumentado**: Firebase Performance para cada POST em `DataAccess` (trace `POST_<path>` e métricas de `NSURLSessionTaskMetrics`), Crashlytics loga status, URL, trechos de resposta e atributos por endpoint; SVProgressHUD para feedback de usuário.
- **Lacunas**: `DataModel` rotas RUCard não têm tracing/metadados; nenhuma métrica de sucesso/erro agregada por fluxo; ausência de logs estruturados para login e cardápio; notificações não são rastreadas.
- **Desejado (FR-009)**: registrar sucesso/erro/latência p95 por serviço; logs estruturados com endpoint, status, token presente?; tracing distribuído opcional via Firebase Trace names coerentes; cobertura de RUCard.

### Riscos / gaps (FR-006, FR-008)
- Hashes e tokens hardcoded (`kHash`, `kToken`) em código fonte; sem mecanismo de rotação.
- `NSUserDefaults` armazena `oauthToken`/`userData` sem criptografia; ausência de Keychain.
- AFNetworking 2.x legado sem patches recentes; duplicidade Crashlytics (pods + frameworks) pode conflitar.
- Ausência de testes em `Cardapio USPTests`; nenhuma suíte UI/integração para fluxos críticos.
- Falta de cache/offline; falhas de rede mostram HUD genérico.
