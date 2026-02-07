# Makefile pour MCP-FCC Banking System
.PHONY: help setup build deploy test clean

help: ## Afficher l'aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: ## Setup complet du projet
	@echo "🚀 Setup MCP-FCC Banking System..."
	@docker-compose up -d
	@sleep 5
	@npm install
	@cd terraform && terraform init
	@echo "✅ Setup complete!"

build: ## Build les Lambda functions
	@echo "🏗️  Building Lambda functions..."
	@npm run build:lambdas
	@echo "✅ Build complete!"

deploy-local: build ## Déployer sur LocalStack
	@echo "🚀 Deploying to LocalStack..."
	@cd terraform && terraform apply -var-file=environments/local.tfvars -auto-approve
	@echo "✅ Deployment complete!"

plan-local: ## Voir le plan Terraform (local)
	@cd terraform && terraform plan -var-file=environments/local.tfvars

destroy-local: ## Détruire l'infrastructure locale
	@echo "🗑️  Destroying local infrastructure..."
	@cd terraform && terraform destroy -var-file=environments/local.tfvars -auto-approve
	@echo "✅ Destroyed!"

test: ## Exécuter les tests
	@echo "🧪 Running tests..."
	@npm test

test-integration: deploy-local ## Tests d'intégration end-to-end
	@echo "🧪 Running integration tests..."
	@./scripts/test-transaction.sh

docker-up: ## Démarrer Docker (LocalStack + Kafka)
	@docker-compose up -d

docker-down: ## Arrêter Docker
	@docker-compose down

docker-logs: ## Voir les logs Docker
	@docker-compose logs -f

clean: ## Nettoyer (Docker + Terraform + build)
	@echo "🧹 Cleaning..."
	@docker-compose down -v
	@rm -rf dist/
	@rm -rf terraform/.terraform/
	@rm -f terraform/terraform.tfstate*
	@echo "✅ Cleaned!"

format: ## Formater le code (Terraform + TypeScript)
	@echo "✨ Formatting code..."
	@cd terraform && terraform fmt -recursive
	@npm run format
	@echo "✅ Formatted!"

validate: ## Valider Terraform
	@cd terraform && terraform validate

status: ## Voir le statut de l'infrastructure
	@echo "📊 Infrastructure Status:"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@cd terraform && terraform state list 2>/dev/null || echo "No Terraform state found"

outputs: ## Afficher les outputs Terraform
	@cd terraform && terraform output
