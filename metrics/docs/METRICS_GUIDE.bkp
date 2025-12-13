# Guia de Coleta de Métricas - Cardápio USP iOS

**Versão:** 1.0  
**Data:** Dezembro 2025  
**Autor:** Vagner Machado  
**Projeto:** TCC MBA Esalq - Análise de Métricas de Software iOS

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Pré-requisitos](#pré-requisitos)
3. [Métricas Coletadas](#métricas-coletadas)
4. [Instalação das Ferramentas](#instalação-das-ferramentas)
5. [Configuração](#configuração)
6. [Execução](#execução)
7. [Análise dos Resultados](#análise-dos-resultados)
8. [Troubleshooting](#troubleshooting)
9. [Referências](#referências)

---

## 🎯 Visão Geral

Este guia documenta o processo completo de instalação, configuração e execução de ferramentas para coleta de métricas de qualidade e performance de código em projetos iOS (Objective-C/Swift).

### Contexto do Projeto

- **Linguagem Principal:** Objective-C (código legado)
- **Linguagem Secundária:** Swift (refatorações recentes)
- **Plataforma:** iOS 13.0+
- **Build System:** Xcode + CocoaPods
- **Framework de Testes:** XCTest

### Objetivos

Coletar métricas para análise de qualidade de software em diferentes marcos (milestones) do desenvolvimento:
- **M1:** Baseline inicial (v3.2.2)
- **M2, M3, etc.:** Marcos futuros

---

## ⚙️ Pré-requisitos

### Requisitos de Sistema

| Componente | Versão Mínima | Recomendado |
|------------|---------------|-------------|
| macOS | 10.15 (Catalina) | 13.0+ (Ventura) |
| Xcode | 11.0 | 14.0+ |
| Ruby | 2.6 | 3.0+ |
| Python | 3.7 | 3.10+ |
| Java | OpenJDK 11 | OpenJDK 17 |
| Homebrew | Latest | Latest |

### Verificação de Pré-requisitos

```bash
# Verificar versões instaladas
xcode-select --version
ruby --version
python3 --version
java --version
brew --version
```

### Instalação de Dependências Base

```bash
# Xcode Command Line Tools
xcode-select --install

# Homebrew (se não instalado)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Ruby (via Homebrew, se necessário)
brew install ruby
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Python 3
brew install python3

# Java OpenJDK 11
brew install openjdk@11
sudo ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk \
  /Library/Java/JavaVirtualMachines/openjdk-11.jdk
```

---

## 📊 Métricas Coletadas

### 1. Smoke Tests
- **Definição:** Testes básicos que verificam funcionalidades críticas
- **Ferramenta:** XCTest + xcresulttool
- **Output:** JSON com resultados de testes

### 2. Test Flakiness (Instabilidade de Testes)
- **Definição:** Testes que falham intermitentemente
- **Método:** Execução múltipla dos testes
- **Output:** Análise comparativa de múltiplas execuções

### 3. Code Coverage (Cobertura de Código)
- **Definição:** Percentual de código exercitado pelos testes
- **Ferramenta:** Xcode + Slather/xcov
- **Output:** HTML, XML (Cobertura), JSON

### 4. Cyclomatic Complexity (Complexidade Ciclomática)
- **Definição:** Número de caminhos independentes no código
- **Ferramentas:** OCLint, Lizard
- **Threshold:** 10 (warning), 20 (error)
- **Output:** JSON, HTML, CSV

### 5. Code Duplication (Duplicação de Código)
- **Definição:** Blocos de código repetidos
- **Ferramenta:** SonarQube
- **Threshold:** 3% aceitável, >5% crítico
- **Output:** Dashboard SonarQube

### 6. Code Smells
- **Definição:** Indicadores de problemas no design do código
- **Ferramentas:** OCLint, SonarQube
- **Categorias:** Maintainability, Reliability, Security
- **Output:** JSON, HTML, Dashboard

### 7. DORA Metrics
- **Deployment Frequency:** Frequência de deploys
- **Lead Time for Changes:** Tempo de commit até deploy
- **Change Failure Rate:** Taxa de falhas em mudanças
- **Mean Time to Recovery (MTTR):** Tempo médio de recuperação
- **Ferramenta:** Scripts Git customizados
- **Output:** Relatório textual

### 8. Architecture Inventory (Inventário de Arquitetura)
- **Definição:** Catálogo de componentes do sistema
- **Ferramentas:** SourceKitten, cloc
- **Output:** JSON com estrutura do código

### 9. Architecture Analysis (Análise de Arquitetura)
- **Definição:** Análise de dependências e estrutura
- **Ferramenta:** Periphery, SourceKitten
- **Output:** Código não utilizado, dependências

---

## 🛠️ Instalação das Ferramentas

### Script de Instalação Automatizada

Execute o script `install_tools.sh` disponível na raiz do projeto:

```bash
# Tornar o script executável
chmod +x install_tools.sh

# Executar instalação
./install_tools.sh
```

### Instalação Manual (alternativa)

Se preferir instalar manualmente:

```bash
# Homebrew tools
brew install swiftlint oclint sonar-scanner cloc sourcekitten openjdk@11 sonarqube
brew tap peripheryapp/periphery && brew install periphery

# Ruby gems
gem install slather xcov

# Python packages
pip3 install lizard
```

---

## ⚙️ Configuração

### 1. Criar Branch de Métricas

Para cada marco (M1, M2, etc.), crie uma branch específica:

```bash
# Navegar para o projeto
cd "/Users/vagner/Library/CloudStorage/Dropbox/_MBA Esalq/_TCC/Projeto/iOS"

# Criar branch a partir de um commit específico
# M1 exemplo: commit 51b5ea4 (v3.2.2)
git checkout -b m1-metrics 51b5ea432dc60346eb1312011117258e70613bca

# Para M2, M3, etc., use o commit hash correspondente
# git checkout -b m2-metrics <COMMIT_HASH>
```

### 2. Arquivos de Configuração

Os seguintes arquivos já estão disponíveis na raiz do projeto:

- `.oclint` - Configuração do OCLint
- `.slather.yml` - Configuração do Slather
- `sonar-project.properties` - Configuração do SonarQube

### 3. Configuração do SonarQube

```bash
# Iniciar SonarQube
brew services start sonarqube

# Aguardar inicialização (pode levar 1-2 minutos)
echo "Aguardando SonarQube iniciar..."
until curl -s http://localhost:9000 > /dev/null; do
    sleep 5
    echo "..."
done

echo "SonarQube iniciado em http://localhost:9000"
echo "Login padrão: admin / admin"
```

**Configuração Web (primeira vez):**

1. Acesse http://localhost:9000
2. Login: `admin` / `admin`
3. Altere a senha quando solicitado
4. Vá em "Administration" → "Projects" → "Management"
5. Crie um novo projeto com key: `cardapio-usp-m1`
6. Gere um token de autenticação em "My Account" → "Security"
7. Copie o token e adicione no `sonar-project.properties`:
   ```properties
   sonar.login=seu-token-aqui
   ```

---

## 🚀 Execução

### Script de Execução Completo

Execute o script `run_metrics.sh` disponível na raiz do projeto:

```bash
# Tornar o script executável (se ainda não for)
chmod +x run_metrics.sh

# Executar coleta de métricas
./run_metrics.sh
```

O script executará todas as etapas automaticamente:

1. Clean do projeto
2. Execução de testes com cobertura
3. Geração de relatórios de cobertura
4. Build para análise OCLint
5. Análise OCLint (code quality)
6. Análise de complexidade (Lizard)
7. Análise de linhas de código (cloc)
8. Análise de arquitetura
9. Extração de métricas de testes
10. Análise SonarQube

### Tempo Estimado

- **Instalação:** 10-15 minutos
- **Configuração:** 5 minutos
- **Execução completa:** 15-30 minutos (dependendo do tamanho do projeto)

---

## 📈 Análise dos Resultados

### Localização dos Relatórios

Todos os relatórios são gerados em: `./metrics-reports/`

### Relatórios Disponíveis

| Relatório | Arquivo | Formato |
|-----------|---------|---------|
| Code Coverage | `coverage-html/index.html` | HTML |
| Code Coverage | `cobertura.xml` | XML |
| OCLint | `oclint-report.html` | HTML |
| OCLint | `oclint-report.json` | JSON |
| Lizard | `lizard-complexity.html` | HTML |
| Lizard | `lizard-complexity.csv` | CSV |
| CLOC | `cloc-report.json` | JSON |
| Test Results | `test-results-raw.json` | JSON |
| SonarQube | http://localhost:9000 | Dashboard |

### Interpretação das Métricas

#### Code Coverage
- ✅ **Excelente:** > 80%
- ⚠️ **Bom:** 60-80%
- ❌ **Baixo:** < 60%

#### Cyclomatic Complexity
- **1-10:** Simples, fácil de testar
- **11-20:** Moderado, considerar refatoração
- **21-50:** Complexo, difícil de manter
- **>50:** Muito complexo, refatoração urgente

#### Code Duplication
- ✅ **Aceitável:** < 3%
- ⚠️ **Atenção:** 3-5%
- ❌ **Crítico:** > 5%

#### SonarQube Quality Gates
- ✅ **Passed:** Projeto atende todos os critérios
- ❌ **Failed:** Projeto não atende algum critério

### Visualização Rápida

```bash
# Abrir relatório de cobertura
open metrics-reports/coverage-html/index.html

# Abrir relatório OCLint
open metrics-reports/oclint-report.html

# Abrir relatório Lizard
open metrics-reports/lizard-complexity.html

# Ver dashboard SonarQube
open http://localhost:9000/dashboard?id=cardapio-usp-m1
```

---

## 🔧 Troubleshooting

### Problema: SonarQube não inicia

```bash
# Verificar status
brew services list | grep sonarqube

# Ver logs
tail -f /usr/local/var/log/sonarqube.log

# Reiniciar
brew services restart sonarqube
```

### Problema: OCLint não encontra arquivos

```bash
# Limpar build anterior
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -f compile_commands.json

# Rebuild completo
xcodebuild clean
xcodebuild -workspace "Cardapio USP.xcworkspace" -scheme "Cardapio USP" | tee xcodebuild.log
oclint-xcodebuild xcodebuild.log
```

### Problema: Slather não gera relatório

```bash
# Verificar configuração
cat .slather.yml

# Executar com verbose
slather coverage --show --verbose
```

### Problema: Testes falham no simulador

```bash
# Listar simuladores disponíveis
xcrun simctl list devices available

# Resetar simulador
xcrun simctl erase "iPhone 14"
```

### Problema: "Permission denied" ao executar scripts

```bash
# Dar permissão de execução
chmod +x install_tools.sh
chmod +x run_metrics.sh
```

---

## 📚 Referências

### Documentação Oficial

- **SwiftLint:** https://github.com/realm/SwiftLint
- **OCLint:** http://oclint.org
- **SonarQube:** https://docs.sonarqube.org
- **Slather:** https://github.com/SlatherOrg/slather
- **Lizard:** https://github.com/terryyin/lizard
- **Periphery:** https://github.com/peripheryapp/periphery
- **SourceKitten:** https://github.com/jpsim/SourceKitten

### Artigos e Guias

- **iOS Code Coverage:** https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/07-code_coverage.html
- **Cyclomatic Complexity:** https://en.wikipedia.org/wiki/Cyclomatic_complexity
- **DORA Metrics:** https://cloud.google.com/blog/products/devops-sre/using-the-four-keys-to-measure-your-devops-performance

### Thresholds Recomendados

| Métrica | Threshold | Fonte |
|---------|-----------|-------|
| Code Coverage | > 80% | Industry Standard |
| Cyclomatic Complexity | < 10 | McCabe |
| Function Length | < 50 lines | Clean Code |
| Code Duplication | < 3% | SonarQube |
| Technical Debt Ratio | < 5% | SonarQube |

---

## 📝 Checklist de Execução

### Preparação
- [ ] Homebrew instalado e atualizado
- [ ] Xcode Command Line Tools instalado
- [ ] Ruby 2.6+ instalado
- [ ] Python 3.7+ instalado
- [ ] Java 11+ instalado

### Instalação
- [ ] SwiftLint instalado
- [ ] OCLint instalado
- [ ] SonarQube instalado
- [ ] Slather instalado (gem)
- [ ] xcov instalado (gem)
- [ ] Lizard instalado (pip)
- [ ] cloc instalado
- [ ] SourceKitten instalado
- [ ] Periphery instalado

### Configuração
- [ ] Branch de métricas criada (m1-metrics, m2-metrics, etc.)
- [ ] `.oclint` criado
- [ ] `.slather.yml` criado
- [ ] `sonar-project.properties` criado
- [ ] SonarQube iniciado
- [ ] Token SonarQube gerado (se necessário)

### Execução
- [ ] Scripts tornados executáveis
- [ ] `./run_metrics.sh` executado
- [ ] Relatórios gerados verificados

### Análise
- [ ] Relatórios HTML revisados
- [ ] Métricas JSON extraídas
- [ ] Dashboard SonarQube verificado
- [ ] Comparação com marco anterior (se aplicável)
- [ ] Métricas documentadas

---

## 🎯 Próximos Passos

### Para Marcos Futuros (M2, M3, etc.)

1. **Identificar o commit do marco:**
   ```bash
   git log --oneline
   # Copiar o hash do commit desejado
   ```

2. **Criar nova branch:**
   ```bash
   git checkout -b m2-metrics <COMMIT_HASH>
   ```

3. **Atualizar configurações:**
   - Alterar `sonar.projectKey` para `cardapio-usp-m2`
   - Alterar `sonar.projectVersion` conforme necessário

4. **Executar coleta:**
   ```bash
   ./run_metrics.sh
   ```

5. **Comparar com M1:**
   - Utilizar script de comparação ou análise manual

---

## ✅ Conclusão

Este guia fornece um processo completo e reproduzível para coleta de métricas de qualidade de código em projetos iOS. As ferramentas e configurações podem ser reutilizadas em diferentes marcos do projeto, permitindo análise evolutiva da qualidade do código ao longo do tempo.

Para dúvidas ou problemas, consulte a seção de [Troubleshooting](#troubleshooting) ou as [Referências](#referências).

---

**Documento criado em:** Dezembro 2025  
**Versão:** 1.0  
**Última atualização:** 11/12/2025
