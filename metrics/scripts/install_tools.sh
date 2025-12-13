#!/bin/bash

echo "======================================"
echo "  iOS Metrics Tools Installation"
echo "======================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para verificar sucesso
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1 - FAILED"
    fi
}

echo "Step 1/4: Installing Homebrew tools..."
echo "--------------------------------------"

# Atualizar Homebrew (opcional, mas recomendado)
brew update

# SwiftLint (para arquivos Swift)
brew install swiftlint
check_status "SwiftLint"

# Ferramentas de contagem/análise de código
brew install cloc sourcekitten
check_status "cloc & SourceKitten"

# Periphery (análise de arquitetura / código não utilizado)
brew tap peripheryapp/periphery
brew install periphery
check_status "Periphery"

# SonarScanner (para SonarCloud)
brew install sonar-scanner
check_status "SonarScanner"

# jq para ajudar a inspecionar JSON de testes
brew install jq
check_status "jq"

# Java (necessário para SonarScanner)
brew install openjdk@17
check_status "OpenJDK 17"

# Python (se ainda não estiver instalado)
if ! command -v python3 &> /dev/null; then
    brew install python
    check_status "Python 3"
fi


echo ""
echo "Step 2/4: Installing Python packages..."
echo "--------------------------------------"

# Análise de complexidade (Lizard)
pip3 install --upgrade pip
pip3 install lizard
check_status "Lizard (pip3)"


echo ""
echo "Step 3/4: Configuring environment..."
echo "--------------------------------------"

# Configurar JAVA_HOME para JDK 17
if command -v /usr/libexec/java_home &> /dev/null; then
    if ! grep -q "JAVA_HOME" ~/.zshrc 2>/dev/null; then
        echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17)' >> ~/.zshrc
    fi
    export JAVA_HOME=$(/usr/libexec/java_home -v 17)
    check_status "Java Home (17) configuration"
else
    echo -e "${YELLOW}⚠${NC} /usr/libexec/java_home not found. JAVA_HOME not configured."
fi

# Nenhuma configuração de Ruby/gems é necessária no fluxo atual

echo ""
echo "Step 4/4: Verifying installations..."
echo "--------------------------------------"

echo -n "SwiftLint: "
swiftlint version 2>/dev/null || echo -e "${RED}Not found${NC}"

echo -n "SonarScanner: "
sonar-scanner --version 2>/dev/null | head -1 || echo -e "${RED}Not found${NC}"

echo -n "Lizard: "
lizard --version 2>/dev/null || echo -e "${RED}Not found${NC}"

echo -n "cloc: "
cloc --version 2>/dev/null | head -1 || echo -e "${RED}Not found${NC}"

echo -n "SourceKitten: "
sourcekitten version 2>/dev/null || echo -e "${RED}Not found${NC}"

echo -n "Periphery: "
periphery version 2>/dev/null || echo -e "${RED}Not found${NC}"

echo -n "jq: "
jq --version 2>/dev/null || echo -e "${RED}Not found${NC}"

# SonarQube local não faz mais parte do fluxo atual

echo ""
echo "======================================"
echo "  Installation Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo ""
echo "1) Recarregar o shell (ou abrir um novo terminal):"
echo "   source ~/.zshrc"
echo ""
echo "2) Exportar o token do SonarCloud (antes de rodar métricas):"
echo "   export SONAR_TOKEN=seu_token_do_sonarcloud"
echo ""
echo "3) Na pasta do projeto iOS, rodar a coleta de métricas:"
echo "   ./metrics/scripts/run_metrics.sh"
echo "   # OU use o link simbólico: ./run_metrics.sh"
echo ""
