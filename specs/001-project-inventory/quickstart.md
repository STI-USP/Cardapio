# Quickstart: Project Inventory

## Purpose
Use this guide to read the project inventory for Cardapio USP without running the app.

## Steps
1. Open `specs/001-project-inventory/spec.md` for user stories, requirements e sucesso.
2. Review `research.md` para contexto de variáveis, endpoints e dependências.
3. Consult `data-model.md` para entender entidades (módulos, fluxos, serviços, telas, dependências, riscos).
4. Inspect API surface docs em `contracts/inventory.openapi.yaml` (OpenAPI 3.0). Use qualquer viewer (e.g., Insomnia/Stoplight) para renderizar.
5. Cross-check com código fonte:
   - Serviços: `Cardapio USP/DataAccess.m` (consultarSaldo, pixgerar, pixlistar, pixverificar, boletosEmAberto).
   - URLs: `Cardapio USP/Constants.m` + Info.plist chaves (`BASE_URL`, `RUCARD_URL`, `OAUTH_SERVICE_URL`, `USER_URL_STRING`, `OAUTH_*`).
   - Navegação/telas: `Cardapio USP/MainViewController.m`, `MenuViewController.m`, `BoletoViewController.m`, `MapViewController.m`, `InfoViewController.m`, etc.
6. Capture gaps e riscos na seção de riscos do inventário (hash hardcoded `rcuectairldq2017`, AFNetworking 2.x legado, ausência de testes XCTest).

## Validation
- Confirme que cada FR-001..FR-008 está coberta nas seções correspondentes.
- Verifique que todos os endpoints da `DataAccess` constam na tabela de serviços (método, path, baseURL, auth).
- Certifique-se de que todas as chaves sensíveis estão listadas com a fonte (Build Settings/Info.plist).
