# Guia de Coleta de Métricas - Cardápio USP iOS

**Versão:** 1.1  
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

Este guia documenta o processo de instalação, configuração e execução das ferramentas de **coleta de métricas de qualidade** em projetos iOS (Objective-C/Swift), usando principalmente o **SonarCloud** como hub de análise.

### Contexto do Projeto

- **Linguagem Principal:** Objective-C (código legado)  
- **Linguagem Secundária:** Swift (refatorações recentes)  
- **Plataforma:** iOS 13.0+  
- **Build System:** Xcode + CocoaPods  
- **Framework de Testes:** XCTest  
- **Plataforma de Métricas:** SonarCloud (projeto `STI-USP_Cardapio`)

### Objetivos

Coletar métricas para análise de qualidade de software em diferentes marcos (milestones) do desenvolvimento:

- **M1:** Baseline inicial (v3.2.2)  
- **M2, M3, ...:** Marcos futuros, comparáveis com M1

---

## ⚙️ Pré-requisitos

### Requisitos de Sistema

| Componente | Versão Mínima | Recomendado |
|-----------|----------------|-------------|
| macOS     | 12.0           | 13.0+       |
| Xcode     | 14.0           | 15.0+       |
| Ruby      | 2.7            | 3.0+        |
| Python    | 3.8            | 3.10+       |
| Java      | OpenJDK 11     | OpenJDK 17  |
| Homebrew  | Latest         | Latest      |

### Verificação de Pré-requisitos

```bash
xcodebuild -version
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

# Python 3
brew install python

# Java (recomendado para SonarScanner)
brew install openjdk@17

# Export opcional do Java (se necessário)
echo 'export PATH="/usr/local/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## 📊 Métricas Coletadas

### 1. Smoke Tests

- **Definição:** Testes básicos que validam fluxos críticos (ex.: login, exibição de cardápio).  
- **Ferramenta:** XCTest (via `xcodebuild test`).  
- **Output:** Result bundle `.xcresult` + relatório de cobertura (quando disponível).

### 2. Test Flakiness (Instabilidade de Testes)

- **Definição:** Testes que falham intermitentemente entre execuções.  
- **Método:** Execução repetida de `xcodebuild test` + comparação de resultados.  
- **Output:** Logs agregados por execução (CSV/JSON).

### 3. Code Coverage (Cobertura de Código)

- **Definição:** Percentual de código exercitado pelos testes.  
- **Ferramentas:**
  - Xcode (gera `TestResults.xcresult`);
  - `xccov` + script `xccov-to-sonarqube-generic.sh` → relatório genérico.  
- **Output:**  
  - `metrics-reports/sonar-generic-coverage.xml` (usado pelo SonarCloud).  

> Obs.: em versões mais novas de Xcode, podem ocorrer limitações/bugs na geração de cobertura; ver seção de *Troubleshooting*.

### 4. Cyclomatic Complexity (Complexidade Ciclomática)

- **Definição:** Número de caminhos independentes no código.  
- **Ferramentas:**  
  - SonarCloud (via plugin CFamily para Obj-C);  
  - Opcional: Lizard para relatórios locais detalhados.  
- **Threshold de referência:** 10 (warning), 20 (alto risco).  

### 5. Code Duplication (Duplicação de Código)

- **Definição:** Blocos de código repetidos em diferentes pontos do sistema.  
- **Ferramenta principal:** SonarCloud (duplicação por arquivo e por projeto).  
- **Threshold:**  
  - < 3%: aceitável  
  - 3–5%: atenção  
  - > 5%: crítico  

### 6. Code Smells

- **Definição:** “Cheiros” de código que indicam problemas de design ou manutenibilidade.  
- **Ferramentas:**  
  - SonarCloud (Maintainability / Reliability / Security);  
  - SwiftLint (estilo e consistência local).  

### 7. DORA Metrics

- **Deployment Frequency**  
- **Lead Time for Changes**  
- **Change Failure Rate**  
- **Mean Time to Recovery (MTTR)**  

**Ferramenta:** scripts customizados em cima de Git (tags de release, commits e incidentes).  
**Output:** planilhas/CSV + texto de análise.

### 8. Architecture Inventory (Inventário de Arquitetura)

- **Definição:** Lista de módulos, camadas e volume de código por componente.  
- **Ferramentas:**  
  - SourceKitten (estruturação de símbolos Swift/Obj-C);  
  - `cloc` (contagem de linhas por linguagem/diretório).  
- **Output:** `metrics-reports/architecture-inventory.json` / `.csv`.

### 9. Architecture Analysis (Análise de Arquitetura)

- **Definição:** Identificação de código morto, dependências excessivas e violações de design.  
- **Ferramentas:**  
  - Periphery (código não utilizado, referências órfãs);  
  - SonarCloud (dependências e acoplamento via regras de design).

---

## 🛠️ Instalação das Ferramentas

### Script de Instalação Automatizada

Script sugerido na raiz do projeto: `install_tools.sh`

```bash
chmod +x install_tools.sh
./install_tools.sh
```

Exemplo de conteúdo (alto nível):

```bash
#!/usr/bin/env bash
set -e

brew update

# Linters / análise estática
brew install swiftlint oclint lizard cloc sourcekitten
brew tap peripheryapp/periphery && brew install periphery

# SonarScanner (para SonarCloud)
brew install sonar-scanner

# Python deps (se necessários)
pip3 install --upgrade pip
pip3 install lizard

echo "Ferramentas instaladas."
```

### Instalação Manual (alternativa)

```bash
brew install swiftlint oclint lizard cloc sourcekitten sonar-scanner
brew tap peripheryapp/periphery && brew install periphery
pip3 install lizard
```

> **Não é mais necessário instalar o servidor SonarQube local.**  
> A análise é feita diretamente no **SonarCloud**.

---

## ⚙️ Configuração

### 1. Branch de Métricas por Marco

Para cada marco (M1, M2, etc.), é criada uma branch específica:

```bash
cd "/Users/vagner/Library/CloudStorage/Dropbox/_MBA Esalq/_TCC/Projeto/iOS"

# Exemplo M1 baseline (v3.2.2)
git checkout -b m1-metrics 51b5ea432dc60346eb1312011117258e70613bca

# M2, M3, etc.
# git checkout -b m2-metrics <COMMIT_HASH>
```

### 2. Arquivos de Configuração do Projeto

Na raiz do projeto iOS:

- `.swiftlint.yml` – regras de estilo do SwiftLint  
- `.oclint` (opcional) – configurações extras do OCLint  
- `sonar-project.properties` – configuração do SonarCloud  
- `fix_compile_commands.py` – script que ajusta o `compile_commands.json`  
- `scripts/` – diretório para scripts auxiliares (`run_metrics.sh`, etc.)

### 3. Configuração do SonarCloud

1. Acesse o SonarCloud (org `sti-usp`).  
2. Projeto: `STI-USP_Cardapio`.  
3. Gere um **token de usuário** (Account → Security).  

No `sonar-project.properties`:

```properties
# =====================================
# Project Information
# =====================================
sonar.projectKey=STI-USP_Cardapio
sonar.organization=sti-usp
sonar.projectName=Cardapio USP
sonar.projectVersion=3.2.2
sonar.sourceEncoding=UTF-8

# =====================================
# Source Code
# =====================================
sonar.sources=.
sonar.exclusions=**/Pods/**,**/Carthage/**,**/.build/**,**/DerivedData/**,**/*.generated.*,**/build-wrapper-dump.json,**/metrics-reports/**

# CFamily (Objective-C) via compilation database corrigida
sonar.cfamily.compile-commands=compile_commands.fixed.json

# Coverage genérica (quando disponível)
sonar.coverageReportPaths=metrics-reports/sonar-generic-coverage.xml

# =====================================
# Server Configuration
# =====================================
sonar.host.url=https://sonarcloud.io
```

O token **não** precisa ficar hard-coded aqui; é recomendado passar via linha de comando ou variável de ambiente:

```bash
export SONAR_TOKEN="seu-token-aqui"

sonar-scanner   -Dsonar.organization=sti-usp   -Dsonar.projectKey=STI-USP_Cardapio   -Dsonar.host.url=https://sonarcloud.io   -Dsonar.token="$SONAR_TOKEN"
```

### 4. Geração do `compile_commands.json` e correção

Para análise correta de Objective-C pelo SonarCloud:

1. Gerar `compile_commands.json` com `xcodebuild + xcpretty`:

   ```bash
   xcodebuild      -workspace "Cardapio USP.xcworkspace"      -scheme "Cardapio USP"      -configuration Debug      -sdk iphonesimulator      -destination "platform=iOS Simulator,name=iPhone 15"      clean build    | xcpretty --report json-compilation-database --output compile_commands.json
   ```

2. Ajustar o JSON com `fix_compile_commands.py` para corrigir entradas onde `file` vem nulo:

   ```bash
   python3 fix_compile_commands.py
   # Gera compile_commands.fixed.json
   ```

---

## 🚀 Execução

### Script de Execução Completa (`run_metrics.sh`)

Sugestão de fluxo:

```bash
chmod +x run_metrics.sh
./run_metrics.sh
```

Exemplo de passos internos do script (alto nível):

1. **Limpeza e build para gerar compile_commands:**

   ```bash
   xcodebuild      -workspace "Cardapio USP.xcworkspace"      -scheme "Cardapio USP"      -configuration Debug      -sdk iphonesimulator      clean build    | xcpretty --report json-compilation-database --output compile_commands.json

   python3 fix_compile_commands.py
   ```

2. **Execução de testes com cobertura (quando disponível):**

   ```bash
   mkdir -p metrics-reports

   xcodebuild      -workspace "Cardapio USP.xcworkspace"      -scheme "Cardapio USP"      -configuration Debug      -sdk iphonesimulator      -destination "platform=iOS Simulator,name=iPhone 15"      -enableCodeCoverage YES      test      -resultBundlePath metrics-reports/TestResults.xcresult
   ```

3. **Geração do relatório de cobertura genérico (se `xccov` encontrar cobertura):**

   ```bash
   xcrun xccov view --report metrics-reports/TestResults.xcresult >/dev/null 2>&1 &&    ./xccov-to-sonarqube-generic.sh metrics-reports/TestResults.xcresult      > metrics-reports/sonar-generic-coverage.xml ||    echo "Sem cobertura disponível neste run (XCCovErrorDomain)."
   ```

4. **SwiftLint (opcional, mas recomendado):**

   ```bash
   swiftlint || echo "SwiftLint não encontrado ou falha no lint."
   ```

5. **Lizard / cloc / Periphery (opcionais):**

   ```bash
   lizard Cardapio\ USP > metrics-reports/lizard-complexity.txt
   cloc . --json --out=metrics-reports/cloc-report.json
   # periphery scan ... (quando configurado)
   ```

6. **Execução do SonarScanner (SonarCloud):**

   ```bash
   sonar-scanner      -Dsonar.organization=sti-usp      -Dsonar.projectKey=STI-USP_Cardapio      -Dsonar.host.url=https://sonarcloud.io      -Dsonar.token="$SONAR_TOKEN"
   ```

---

## 📈 Análise dos Resultados

### Localização dos Arquivos

- Todos os artefatos locais de métricas ficam em: `./metrics-reports/`  
- A visão consolidada de qualidade fica no **SonarCloud**.

### Relatórios Locais (exemplo)

| Relatório           | Arquivo                                   | Formato |
|---------------------|-------------------------------------------|---------|
| Coverage (Sonar)    | `sonar-generic-coverage.xml`             | XML     |
| Lizard              | `lizard-complexity.txt` / `.csv`         | TXT/CSV |
| CLOC                | `cloc-report.json`                       | JSON    |
| Test Results (raw)  | `TestResults.xcresult`                   | Bundle  |

### SonarCloud

- Acessar o projeto: **SonarCloud → Org `sti-usp` → `STI-USP_Cardapio`**  
- Principais visões:
  - **Bugs / Vulnerabilities / Code Smells**  
  - **Coverage** (quando o XML for gerado com sucesso)  
  - **Duplications**  
  - **Maintainability / Reliability / Security ratings**  

---

## 🔧 Troubleshooting

### XCCovErrorDomain – “No coverage data in result bundle”

Sintoma:

```text
Error Domain=XCCovErrorDomain Code=0 "No coverage data in result bundle"
```

Possíveis causas:

- Test Plan sem cobertura habilitada para os targets.  
- Nenhum teste foi executado de fato (suite vazia).  
- Bug/limitação na versão do Xcode.

Ações:

1. Verificar no Xcode:
   - Se existe Test Plan → garantir `Code Coverage = On (All Targets)`.  
   - Se os targets de teste estão associados ao scheme usado no `xcodebuild`.

2. Executar:

   ```bash
   xcrun xccov view --report metrics-reports/TestResults.xcresult
   ```

   - Se também retornar erro → Xcode não gravou cobertura.  
   - Nesse caso, rodar Sonar **sem coverage** (linha `sonar.coverageReportPaths` pode ser temporariamente comentada).

### Erro CFamily – “0 C/C++/Objective-C files were analyzed”

Geralmente ligado a problema no `compile_commands.json`:

- Campo `"file"` nulo;  
- Caminhos inconsistentes entre build e análise.

Correção:

- Regenerar `compile_commands.json` com `xcodebuild + xcpretty`.  
- Rodar `fix_compile_commands.py` para gerar `compile_commands.fixed.json`.  
- Garantir que `sonar.cfamily.compile-commands=compile_commands.fixed.json` e que a análise é feita na mesma raiz de projeto usada pelo `xcodebuild`.

### Problemas com SonarCloud

- Conferir:
  - `sonar.projectKey` e `sonar.organization`;  
  - Token válido (`SONAR_TOKEN`);  
  - URL correta: `https://sonarcloud.io`.

---

## 📚 Referências

### Documentação Oficial

- **SonarCloud (C/Obj-C):**  
  https://docs.sonarcloud.io  
- **SonarScanner CLI:**  
  https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/scanners/sonarscanner/  
- **SwiftLint:**  
  https://github.com/realm/SwiftLint  
- **OCLint (opcional):**  
  http://oclint.org  
- **Lizard:**  
  https://github.com/terryyin/lizard  
- **Periphery:**  
  https://github.com/peripheryapp/periphery  
- **SourceKitten:**  
  https://github.com/jpsim/SourceKitten  

### Conceitos

- **Cyclomatic Complexity:**  
  https://en.wikipedia.org/wiki/Cyclomatic_complexity  
- **DORA Metrics:**  
  https://cloud.google.com/blog/products/devops-sre/using-the-four-keys-to-measure-your-devops-performance  

---

## 📝 Checklist de Execução

### Preparação

- [ ] Homebrew instalado e atualizado  
- [ ] Xcode + Command Line Tools instalados  
- [ ] Python 3 instalado  
- [ ] Java 11+ instalado  
- [ ] Token do SonarCloud disponível (`SONAR_TOKEN`)

### Instalação

- [ ] `install_tools.sh` executado (ou ferramentas instaladas manualmente)  
- [ ] `sonar-scanner` disponível no PATH  

### Configuração

- [ ] Branch de métricas criada (`m1-metrics`, `m2-metrics`, etc.)  
- [ ] `sonar-project.properties` configurado para `STI-USP_Cardapio`  
- [ ] `compile_commands.json` gerado e corrigido (`compile_commands.fixed.json`)  
- [ ] Test Plan com Code Coverage ON (quando cobertura for usada)

### Execução

- [ ] `run_metrics.sh` executado  
- [ ] `sonar-scanner` finalizado sem erros  
- [ ] Artefatos em `metrics-reports/` gerados

### Análise

- [ ] Métricas no SonarCloud revisadas  
- [ ] Duplicação, complexidade e smells analisados  
- [ ] Cobertura verificada (se disponível)  
- [ ] Resultados documentados para o marco (M1, M2, ...)

---

## 🎯 Próximos Passos

Para marcos futuros (M2, M3, ...):

1. Identificar o commit/tag correspondente à versão do app.  
2. Criar branch de métricas (`m2-metrics`, etc.).  
3. Atualizar `sonar.projectVersion` no `sonar-project.properties`.  
4. Rodar `run_metrics.sh`.  
5. Comparar métricas com o marco anterior (M1, M2, ...), focando em:
   - evolução de duplicação;  
   - complexidade;  
   - cobertura;  
   - volume de smells/bugs/vulnerabilities.

