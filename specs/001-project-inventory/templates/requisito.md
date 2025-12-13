# Template de Requisito (testável)

## Identificação
- ID: REQ-xxx
- Título: <breve>
- Prioridade: P1/P2/P3
- Domínio/Fluxo: menu | saldo | boleto | pix | auth | mapa | info

## Descrição
- O usuário deve poder ... (descreva objetivo observável)

## Critérios de Aceitação (testáveis)
1. Dado ... Quando ... Então ... (resultado verificável)
2. ...

## Restrições / Regras de Negócio
- ...

## Dados / Estados
- Entradas necessárias (ex.: token, wsuserid, dados de boleto/PIX)
- Pré-condições (ex.: login ativo, rede disponível)
- Pós-condições (ex.: saldo exibido, status atualizado)

## Observabilidade
- Logs: campos-chave a registrar
- Métricas: sucesso/erro, latência p95
- Tracing: spans necessários (se aplicável)

## Rastreabilidade
- Casos de teste ligados: TC-xxx
- Checklist aplicado: Pronto para testar / Pronto para lançar
- Artefatos relacionados: UI mock, API spec, etc.
