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

echo "Step 1/6: Installing Homebrew tools..."
echo "--------------------------------------"

# SwiftLint (para arquivos Swift)
brew install swiftlint
check_status "SwiftLint"

# Ferramentas de análise
brew install cloc sourcekitten
check_status "cloc & SourceKitten"

# Periphery (análise de arquitetura)
brew tap peripheryapp/periphery
brew install periphery
check_status "Periphery"

# SonarScanner (sem SonarQube server)
brew install sonar-scanner
check_status "SonarScanner"

# Java (necessário para SonarQube)
brew install openjdk@11
check_status "OpenJDK 11"

echo ""
echo "Step 2/6: Installing OCLint manually..."
echo "--------------------------------------"

if [ ! -d "/usr/local/oclint-22.02" ]; then
    echo "Downloading OCLint..."
    cd /tmp
    curl -L -o oclint.tar.gz https://github.com/oclint/oclint/releases/download/v22.02/oclint-22.02-llvm-13.0.1-x86_64-darwin-macos-12.3-xcode-13.3.tar.gz
    
    if [ $? -eq 0 ]; then
        tar xf oclint.tar.gz
        sudo mv oclint-22.02 /usr/local/
        rm oclint.tar.gz
        
        # Adicionar ao PATH se ainda não estiver
        if ! grep -q "/usr/local/oclint-22.02/bin" ~/.zshrc; then
            echo 'export PATH="/usr/local/oclint-22.02/bin:$PATH"' >> ~/.zshrc
        fi
        
        export PATH="/usr/local/oclint-22.02/bin:$PATH"
        check_status "OCLint"
    else
        echo -e "${RED}✗${NC} OCLint download failed"
    fi
else
    echo -e "${GREEN}✓${NC} OCLint already installed"
    export PATH="/usr/local/oclint-22.02/bin:$PATH"
fi

echo ""
echo "Step 3/6: Installing Ruby gems..."
echo "--------------------------------------"

# Ferramentas de cobertura (com --user-install para evitar problemas de permissão)
gem install --user-install slather
check_status "Slather"

gem install --user-install xcov
check_status "xcov"

echo ""
echo "Step 4/6: Installing Python packages..."
echo "--------------------------------------"

# Análise de complexidade
pip3 install lizard
check_status "Lizard"

echo ""
echo "Step 5/6: Installing SonarQube (Docker)..."
echo "--------------------------------------"

if command -v docker &> /dev/null; then
    echo "Docker found. Installing SonarQube container..."
    
    # Verificar se container já existe
    if docker ps -a | grep -q sonarqube; then
        echo -e "${YELLOW}⚠${NC} SonarQube container already exists"
        echo "  To restart: docker start sonarqube"
    else
        docker run -d --name sonarqube \
            -p 9000:9000 \
            sonarqube:latest
        check_status "SonarQube (Docker)"
        echo -e "${BLUE}ℹ${NC} SonarQube will be available at http://localhost:9000 in 1-2 minutes"
    fi
else
    echo -e "${YELLOW}⚠${NC} Docker not found. Skipping SonarQube installation."
    echo "  To install Docker: https://www.docker.com/products/docker-desktop"
    echo "  Or download SonarQube manually: https://www.sonarqube.org/downloads/"
fi

echo ""
echo "Step 6/6: Configuring environment..."
echo "--------------------------------------"

# Configurar Java Home
if ! grep -q "JAVA_HOME" ~/.zshrc; then
    echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 11)' >> ~/.zshrc
fi
export JAVA_HOME=$(/usr/libexec/java_home -v 11)
check_status "Java Home configuration"

# Adicionar gems ao PATH
if ! grep -q "ruby/gems" ~/.zshrc; then
    echo 'export PATH="$HOME/.gem/ruby/3.4.0/bin:$PATH"' >> ~/.zshrc
fi
export PATH="$HOME/.gem/ruby/3.4.0/bin:$PATH"

echo ""
echo "======================================"
echo "  Verifying installations..."
echo "======================================"

echo -n "SwiftLint: "
swiftlint version 2>/dev/null || echo -e "${RED}Not found${NC}"

echo -n "OCLint: "
oclint --version 2>/dev/null || echo -e "${RED}Not found${NC}"

echo -n "SonarScanner: "
sonar-scanner --version 2>/dev/null | head -1 || echo -e "${RED}Not found${NC}"

echo -n "Slather: "
slather version 2>/dev/null || ~/.gem/ruby/3.4.0/bin/slather version 2>/dev/null || echo -e "${RED}Not found${NC}"

echo -n "xcov: "
xcov --version 2>/dev/null || ~/.gem/ruby/3.4.0/bin/xcov --version 2>/dev/null || echo -e "${RED}Not found${NC}"

echo -n "Lizard: "
lizard --version 2>/dev/null || echo -e "${RED}Not found${NC}"

echo -n "cloc: "
cloc --version 2>/dev/null | head -1 || echo -e "${RED}Not found${NC}"

echo -n "Periphery: "
periphery version 2>/dev/null || echo -e "${RED}Not found${NC}"

echo -n "SonarQube: "
if docker ps | grep -q sonarqube; then
    echo -e "${GREEN}Running (Docker)${NC}"
elif curl -s http://localhost:9000 > /dev/null 2>&1; then
    echo -e "${GREEN}Running${NC}"
else
    echo -e "${YELLOW}Not running${NC}"
fi

echo ""
echo "======================================"
echo "  Installation Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo ""
if docker ps | grep -q sonarqube || curl -s http://localhost:9000 > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} SonarQube: http://localhost:9000 (admin/admin)"
else
    echo -e "${YELLOW}!${NC} Start SonarQube:"
    if command -v docker &> /dev/null; then
        echo "    docker start sonarqube"
    else
        echo "    Install Docker Desktop first"
    fi
fi
echo ""
echo "To apply changes to your shell:"
echo "    source ~/.zshrc"
echo ""
echo "To run metrics collection:"
echo "    ./run_metrics.sh"
echo ""
