# Configuração do SonarQube - Guia Rápido

## Status Atual
✅ SonarQube rodando em: http://localhost:9000
✅ sonar-scanner instalado: `/usr/local/bin/sonar-scanner`
✅ Container Docker: `sonarqube` (porta 9000)

## Passo 1: Primeiro Acesso

1. Abra o navegador em: http://localhost:9000
2. Login inicial:
   - **Usuário**: `admin`
   - **Senha**: `admin`
3. O sistema pedirá para alterar a senha - **ANOTE A NOVA SENHA**

## Passo 2: Criar Token de Autenticação

1. Após login, clique no ícone do usuário (canto superior direito)
2. Vá em: **My Account** → **Security**
3. Na seção **Generate Tokens**:
   - **Name**: `cardapio-usp-metrics`
   - **Type**: `Global Analysis Token` (ou `Project Analysis Token`)
   - **Expires**: Escolha validade (recomendo 90 dias)
4. Clique em **Generate**
5. **COPIE O TOKEN IMEDIATAMENTE** (não será mostrado novamente)

## Passo 3: Configurar Token no Projeto

Edite o arquivo `sonar-project.properties` e descomente/adicione:

```properties
sonar.login=SEU_TOKEN_AQUI
```

**Exemplo:**
```properties
sonar.login=squ_1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r
```

## Passo 4: Executar Análise

```bash
./run_metrics.sh
```

O script executará todas as métricas incluindo o envio para o SonarQube.

## Passo 5: Visualizar Resultados

1. Acesse: http://localhost:9000
2. O projeto `Cardapio USP - M1` aparecerá automaticamente
3. Explore:
   - **Overview**: Resumo geral com Quality Gate
   - **Issues**: Code smells, bugs, vulnerabilities
   - **Measures**: Métricas detalhadas (complexidade, duplicação, coverage)
   - **Code**: Navegação pelo código fonte

## Comandos Úteis Docker

```bash
# Ver status do container
docker ps -a | grep sonarqube

# Iniciar container (se parado)
docker start sonarqube

# Parar container
docker stop sonarqube

# Ver logs
docker logs sonarqube

# Reiniciar container
docker restart sonarqube

# Remover container (se precisar recriar)
docker stop sonarqube && docker rm sonarqube
```

## Criando Novo Container (se necessário)

```bash
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -p 9092:9092 \
  sonarqube:latest
```

## Troubleshooting

### SonarQube não inicia
```bash
# Ver logs completos
docker logs sonarqube -f

# Verificar recursos (SonarQube precisa de ~2GB RAM)
docker stats sonarqube
```

### Porta 9000 já em uso
```bash
# Encontrar processo usando a porta
lsof -i :9000

# Usar porta alternativa
docker run -d --name sonarqube -p 9001:9000 sonarqube:latest
# Ajustar sonar-project.properties: sonar.host.url=http://localhost:9001
```

### Token inválido ou expirado
1. Acesse http://localhost:9000
2. **My Account** → **Security** → **Revoke** token antigo
3. Gere novo token
4. Atualize `sonar-project.properties`

## Próximos Passos

Após configurar o token:

1. Execute `./run_metrics.sh` para gerar baseline M1
2. Revise os relatórios em `./metrics-reports/`
3. Acesse SonarQube para análise detalhada
4. Para próximos milestones (M2, M3):
   ```bash
   # Criar nova branch de métricas
   git checkout -b m2-metrics <COMMIT_HASH>
   
   # Atualizar sonar-project.properties
   # Alterar: sonar.projectKey=cardapio-usp-m2
   #          sonar.projectVersion=X.X.X
   
   # Executar coleta
   ./run_metrics.sh
   ```

## Referências

- **SonarQube Docs**: https://docs.sonarqube.org/latest/
- **Objective-C Plugin**: https://docs.sonarqube.org/display/PLUG/Objective-C+Plugin
- **Authentication**: https://docs.sonarqube.org/latest/user-guide/user-token/
