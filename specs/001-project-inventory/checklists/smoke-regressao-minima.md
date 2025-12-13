# Plano de Smoke / Regressão Mínima — Cardapio USP (iOS)

**Objetivo**: Validar rapidamente se fluxos essenciais estão operacionais após mudanças. Execução alvo < 15 minutos, em simulador iPhone 14 (iOS 13+). Preferir dados/mocks determinísticos quando possível.

## Escopo de Fluxos
- Auth/Login (token/wsuserid obtido).
- Menu/Cardápio (listagem e navegação básica).
- Saldo (consultarSaldo).
- PIX: gerar, listar, verificar.
- Mapa/Localização (abre tela, mostra pontos; não validar rota externa).
- Info/Credits (abre tela; ver links). 

## Pré-condições
- App build em Debug com endpoints configurados (`BASE_URL`, `RUCARD_URL`, `OAUTH_*`, `USER_URL_STRING`).
- Usuário de teste válido (token ou hash conforme ambiente) ou mock configurado.
- Serviços externos acessíveis ou stubados; conexão ativa.
- Simulador resetado ou sessão limpa se login persistir.

## Casos de Smoke (sequência sugerida)
1) **Auth**: abrir app → acionar login → validar obtenção de token/wsuserid (sem crash, mensagem de erro ausente). 
2) **Menu**: entrar no menu principal → listas carregam → navegar para saldo/boleto/PIX sem crash.
3) **Saldo**: acionar consultarSaldo → exibir valor numérico plausível → erros tratados (mensagem amigável se falha).
4) **PIX gerar**: iniciar geração → receber payload/QR → estado "gerado" exibido.
5) **PIX listar/verificar**: listar PIX existentes → abrir um → verificar status → sem falhas de rede não tratadas.
6) **Mapa**: abrir tela → mapa renderiza → pontos carregam (não validar navegação externa).
7) **Info/Credits**: abrir tela → links/botões renderizam; sem crash.

## Regra de Resultado
- Passa: todos os 8 passos completam sem crash; mensagens de erro somente quando serviço fora; UI responde (sem spinners infinitos >10s).
- Falha: crash, tela vazia sem erro, bloqueio >10s, payload incoerente sem tratamento (ex.: nulo exibido cru).

## Evidências
- Capturar log da execução (`xcodebuild-test.log` se via UI test) ou gravação de tela curta; anotar se foi real vs. mock.

## Versão UI Test (opcional)
- Converter os 8 passos em UI tests (XCTest UI) com dados determinísticos; usar launch arguments para apontar mocks.

## Frequência
- Executar manualmente em PRs que tocam fluxos críticos ou semanalmente; automatizado em nightly se UI test disponível.

## Dados/Medições mínimas
- Tempo total de execução (target < 15 min manual; < 10 min automatizado).
- Contagem de falhas por ciclo; registrar causa (rede, dado, crash, regressão de código).
