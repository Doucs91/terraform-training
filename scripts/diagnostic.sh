#!/bin/bash
# Script de diagnostic pour MCP-FCC-Test

set -e

echo "🔍 MCP-FCC Banking System - Diagnostic"
echo "========================================"
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 est installé"
        return 0
    else
        echo -e "${RED}✗${NC} $1 n'est pas installé"
        return 1
    fi
}

check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Port $1 est occupé (service actif)"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} Port $1 est libre (service non actif?)"
        return 1
    fi
}

echo "1. Vérification des outils requis"
echo "-----------------------------------"
check_command terraform
check_command docker
check_command docker-compose
check_command node
check_command npm
check_command aws
check_command jq
echo ""

echo "2. Versions des outils"
echo "----------------------"
terraform version | head -1
docker --version
docker-compose --version
node --version
npm --version
echo ""

echo "3. État des containers Docker"
echo "------------------------------"
if docker-compose ps 2>/dev/null; then
    :
else
    echo -e "${YELLOW}⚠${NC} Docker Compose n'est pas initialisé"
fi
echo ""

echo "4. Vérification des ports"
echo "-------------------------"
check_port 4566  # LocalStack
check_port 9092  # Kafka
check_port 2181  # Zookeeper
check_port 8080  # Kafka UI
echo ""

echo "5. LocalStack Health Check"
echo "--------------------------"
if curl -s http://localhost:4566/_localstack/health &> /dev/null; then
    echo -e "${GREEN}✓${NC} LocalStack est accessible"
    curl -s http://localhost:4566/_localstack/health | jq -r '.services | to_entries[] | "\(.key): \(.value)"' | grep available
else
    echo -e "${RED}✗${NC} LocalStack n'est pas accessible sur localhost:4566"
fi
echo ""

echo "6. État Terraform"
echo "-----------------"
if [ -d "terraform/.terraform" ]; then
    echo -e "${GREEN}✓${NC} Terraform est initialisé"
    cd terraform
    if [ -f "terraform.tfstate" ]; then
        echo -e "${GREEN}✓${NC} State file existe"
        RESOURCE_COUNT=$(terraform state list 2>/dev/null | wc -l)
        echo "  Ressources déployées: $RESOURCE_COUNT"
    else
        echo -e "${YELLOW}⚠${NC} Aucun state file (rien déployé)"
    fi
    cd ..
else
    echo -e "${YELLOW}⚠${NC} Terraform n'est pas initialisé (terraform init requis)"
fi
echo ""

echo "7. Build des Lambdas"
echo "--------------------"
if [ -d "dist/lambdas" ]; then
    echo -e "${GREEN}✓${NC} Dossier dist/lambdas existe"
    LAMBDA_COUNT=$(find dist/lambdas -name "*.zip" 2>/dev/null | wc -l)
    echo "  Packages Lambda trouvés: $LAMBDA_COUNT"
    find dist/lambdas -name "*.zip" -exec ls -lh {} \; 2>/dev/null
else
    echo -e "${YELLOW}⚠${NC} Aucun build Lambda (npm run build:lambdas requis)"
fi
echo ""

echo "8. Espace disque"
echo "----------------"
df -h . | tail -1 | awk '{print "Disponible: " $4 " sur " $2 " (" $5 " utilisé)"}'
echo ""

echo "9. Résumé"
echo "---------"
ERRORS=0

if ! command -v terraform &> /dev/null; then ((ERRORS++)); fi
if ! command -v docker &> /dev/null; then ((ERRORS++)); fi
if ! curl -s http://localhost:4566/_localstack/health &> /dev/null; then ((ERRORS++)); fi

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Système prêt!${NC}"
    echo ""
    echo "Prochaines étapes:"
    echo "  cd terraform"
    echo "  terraform init"
    echo "  terraform apply -var-file=environments/local.tfvars"
else
    echo -e "${RED}✗ $ERRORS problème(s) détecté(s)${NC}"
    echo ""
    echo "Actions recommandées:"
    [ ! -x "$(command -v terraform)" ] && echo "  - Installer Terraform"
    [ ! -x "$(command -v docker)" ] && echo "  - Installer Docker"
    if ! curl -s http://localhost:4566/_localstack/health &> /dev/null; then
        echo "  - Démarrer LocalStack: docker-compose up -d"
    fi
fi
echo ""
