#!/usr/bin/env bash
# deploy.sh - Script de deploiement complet StackNova Infra
# Usage : bash scripts/deploy.sh

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[deploy]${NC} $1"; }
error() { echo -e "${RED}[error]${NC} $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

log "=== Deploiement StackNova Infra - $(date) ==="

# ETAPE 1 : Terraform
log "Etape 1/3 - Initialisation Terraform..."
cd "$PROJECT_ROOT/terraform"
terraform init -input=false

log "Etape 2/3 - Application Terraform..."
terraform apply -auto-approve -input=false

terraform output

sleep 2

# ETAPE 2 : Ansible
log "Etape 3/3 - Configuration Ansible..."
cd "$PROJECT_ROOT"

if ! docker ps --filter "name=stacknova-recette" --filter "status=running" | grep -q stacknova-recette; then
  error "Le conteneur stacknova-recette n'est pas en cours d'execution. Abandon."
fi

ansible-playbook -i ansible/inventory.ini ansible/playbook.yml

log "=== Deploiement termine avec succes ==="
log "Application disponible sur : http://localhost:8080"
