# 📚 Guide Terraform pour le Projet MCP-FCC

> Concepts, bonnes pratiques et patterns Terraform spécifiques à ce projet

---

## 🎯 Vue d'Ensemble

Ce guide explique comment Terraform est utilisé dans ce projet et les concepts clés que vous devez comprendre.

---

## 📖 Concepts Terraform Essentiels

### 1. Infrastructure as Code (IaC)

**Avant IaC:** Créer manuellement des ressources via console web ou CLI
- Erreurs humaines
- Pas de traçabilité
- Impossible à reproduire
- Difficile à versionner

**Avec IaC (Terraform):**
```hcl
resource "aws_lambda_function" "my_function" {
  function_name = "process-transaction"
  runtime       = "nodejs20.x"
  handler       = "index.handler"
  # ...
}
```
- ✅ Déclaratif et reproductible
- ✅ Versionné dans Git
- ✅ Documenté automatiquement
- ✅ Testable
- ✅ Review via Pull Requests

---

### 2. Providers

Les **providers** sont des plugins qui permettent à Terraform de communiquer avec des APIs externes (AWS, Azure, GCP, etc.).

**Configuration dans ce projet:**
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  
  # Pour LocalStack
  endpoints {
    lambda = "http://localhost:4566"
    sqs    = "http://localhost:4566"
    # ...
  }
}
```

**Dans ce projet:**
- Provider AWS principal
- Configuré pour fonctionner avec LocalStack ET AWS réel
- Variable `use_localstack` pour switcher facilement

---

### 3. Resources

Les **resources** sont les composants d'infrastructure que vous voulez créer.

```hcl
resource "TYPE" "NAME" {
  argument1 = value1
  argument2 = value2
}
```

**Exemples dans ce projet:**
```hcl
# Lambda function
resource "aws_lambda_function" "process_transaction" {
  function_name = "process-transaction"
  runtime       = "nodejs20.x"
  # ...
}

# SQS Queue
resource "aws_sqs_queue" "transactions" {
  name = "transactions-queue"
  # ...
}
```

---

### 4. Variables

Les **variables** permettent de paramétrer votre infrastructure.

**Déclaration (`variables.tf`):**
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}
```

**Utilisation:**
```hcl
resource "aws_lambda_function" "func" {
  function_name = "my-func-${var.environment}"
  timeout       = var.lambda_timeout
}
```

**Passer des valeurs:**
```bash
# Via fichier tfvars
terraform apply -var-file=environments/local.tfvars

# Via CLI
terraform apply -var="environment=dev"

# Via variable d'environnement
export TF_VAR_environment=dev
terraform apply
```

---

### 5. Outputs

Les **outputs** exposent des informations après le déploiement.

```hcl
output "api_endpoint" {
  description = "URL de l'API"
  value       = aws_api_gateway_stage.main.invoke_url
}
```

**Utilisation:**
```bash
# Afficher tous les outputs
terraform output

# Afficher un output spécifique
terraform output api_endpoint

# Utiliser dans un script
API_URL=$(terraform output -raw api_endpoint)
curl $API_URL/health
```

---

### 6. State

Le **state** est un fichier JSON qui contient l'état actuel de votre infrastructure.

**Fichier: `terraform.tfstate`**

```json
{
  "version": 4,
  "terraform_version": "1.6.0",
  "resources": [
    {
      "type": "aws_lambda_function",
      "name": "process_transaction",
      "instances": [...]
    }
  ]
}
```

**⚠️ IMPORTANT:**
- **Ne JAMAIS éditer manuellement**
- **Ne JAMAIS commiter dans Git** (sauf backend remote)
- Contient des informations sensibles
- Terraform l'utilise pour savoir ce qui existe

**Evolution dans ce projet:**
- **Semaine 1-2:** State local (fichier)
- **Semaine 3:** State remote (S3 + DynamoDB)
- **Semaine 4:** State partagé en équipe

---

### 7. Modules

Les **modules** sont des groupes réutilisables de ressources.

**Structure:**
```
modules/lambda/
├── variables.tf  # Inputs du module
├── main.tf       # Ressources
└── outputs.tf    # Outputs du module
```

**Utilisation:**
```hcl
module "my_lambda" {
  source = "./modules/lambda"
  
  # Inputs
  function_name = "process-transaction"
  runtime       = "nodejs20.x"
  timeout       = 30
}

# Accéder aux outputs
output "lambda_arn" {
  value = module.my_lambda.function_arn
}
```

**Avantages:**
- ✅ Réutilisabilité (DRY principle)
- ✅ Abstraction de la complexité
- ✅ Standards d'équipe
- ✅ Facilité de maintenance

---

### 8. Data Sources

Les **data sources** permettent de lire des informations existantes.

```hcl
# Lire une AMI existante
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Utiliser la data
resource "aws_instance" "server" {
  ami = data.aws_ami.ubuntu.id
}
```

**Dans ce projet:**
- Lire les AMI pour Kafka EC2
- Lire les VPC et subnets existants
- Lire les zones de disponibilité

---

### 9. Locals

Les **locals** sont des variables calculées localement.

```hcl
locals {
  common_tags = {
    Project     = "MCP-FCC Banking"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  lambda_name = "${var.project_name}-${var.function_name}-${var.environment}"
  
  is_production = var.environment == "prod"
}

resource "aws_lambda_function" "func" {
  function_name = local.lambda_name
  tags          = local.common_tags
  memory_size   = local.is_production ? 1024 : 256
}
```

---

### 10. Dependencies

Terraform gère automatiquement les dépendances entre ressources.

**Dépendances implicites:**
```hcl
resource "aws_sqs_queue" "queue" {
  name = "my-queue"
}

resource "aws_lambda_function" "processor" {
  function_name = "processor"
  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.queue.url  # Référence = dépendance
    }
  }
}
```

**Dépendances explicites:**
```hcl
resource "aws_lambda_event_source_mapping" "mapping" {
  # ...
  
  depends_on = [
    aws_iam_role_policy.lambda_sqs,
    aws_lambda_function.processor
  ]
}
```

---

## 🛠️ Workflow Terraform

### Commandes Essentielles

```bash
# 1. Initialiser (première fois ou après ajout de modules)
terraform init

# 2. Valider la syntaxe
terraform validate

# 3. Formater le code
terraform fmt -recursive

# 4. Voir le plan (prévisualisation)
terraform plan -var-file=environments/local.tfvars

# 5. Appliquer les changements
terraform apply -var-file=environments/local.tfvars

# 6. Voir l'état actuel
terraform show

# 7. Lister les ressources
terraform state list

# 8. Voir une ressource spécifique
terraform state show aws_lambda_function.my_func

# 9. Détruire tout
terraform destroy -var-file=environments/local.tfvars

# 10. Détruire une ressource spécifique
terraform destroy -target=aws_lambda_function.my_func
```

### Cycle de Développement

```
1. Écrire le code HCL
   ↓
2. terraform validate
   ↓
3. terraform fmt
   ↓
4. terraform plan
   ↓
5. Vérifier le plan
   ↓
6. terraform apply
   ↓
7. Tester l'infrastructure
   ↓
8. Commit dans Git
```

---

## 📁 Structure du Projet Terraform

```
terraform/
├── providers.tf          # Configuration des providers
├── backend.tf            # Configuration du backend (state)
├── variables.tf          # Variables globales
├── main.tf              # Configuration principale
├── outputs.tf           # Outputs globaux
│
├── modules/             # Modules réutilisables
│   ├── lambda/
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   ├── sqs/
│   ├── api-gateway/
│   └── step-functions/
│
├── environments/        # Configurations par environnement
│   ├── local.tfvars    # LocalStack
│   ├── dev.tfvars      # AWS Dev
│   ├── staging.tfvars  # AWS Staging
│   └── prod.tfvars     # AWS Prod
│
└── .terraform/         # Généré par terraform init (ne pas commiter)
```

---

## 🎯 Patterns Utilisés dans ce Projet

### 1. Module Pattern

Tous les composants réutilisables sont des modules:

```hcl
# ✅ BON: Utiliser des modules
module "lambda" {
  source        = "./modules/lambda"
  function_name = "my-func"
}

# ❌ ÉVITER: Répéter le code
resource "aws_lambda_function" "func1" { ... }
resource "aws_iam_role" "role1" { ... }
resource "aws_lambda_function" "func2" { ... }
resource "aws_iam_role" "role2" { ... }
```

### 2. Environment Pattern

Un fichier tfvars par environnement:

```
environments/
├── local.tfvars     # use_localstack = true
├── dev.tfvars       # use_localstack = false, small instances
├── staging.tfvars   # medium instances
└── prod.tfvars      # large instances, backups enabled
```

```bash
# Déployer en local
terraform apply -var-file=environments/local.tfvars

# Déployer en prod
terraform apply -var-file=environments/prod.tfvars
```

### 3. Naming Convention

```hcl
# Format: {project}-{resource}-{environment}
resource "aws_lambda_function" "func" {
  function_name = "${var.project_name}-${var.function_name}-${var.environment}"
  # Exemple: mcp-fcc-banking-process-transaction-local
}
```

### 4. Tagging Strategy

```hcl
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
  }
}

resource "aws_lambda_function" "func" {
  tags = merge(
    local.common_tags,
    {
      Component = "Transaction Processing"
    }
  )
}
```

### 5. Conditional Resources

```hcl
# Créer seulement en production
resource "aws_cloudwatch_alarm" "high_error_rate" {
  count = var.environment == "prod" ? 1 : 0
  # ...
}

# Ou avec for_each
resource "aws_backup_plan" "main" {
  for_each = var.enable_backups ? { main = {} } : {}
  # ...
}
```

---

## 🔧 LocalStack vs AWS

### Configuration Duale

```hcl
provider "aws" {
  region = var.aws_region

  # LocalStack endpoints (seulement si use_localstack = true)
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  
  endpoints {
    lambda = var.use_localstack ? "http://localhost:4566" : null
    sqs    = var.use_localstack ? "http://localhost:4566" : null
    s3     = var.use_localstack ? "http://localhost:4566" : null
    # ...
  }
  
  # Credentials fake pour LocalStack
  access_key = var.use_localstack ? "test" : null
  secret_key = var.use_localstack ? "test" : null
}
```

### Différences LocalStack vs AWS

| Feature | LocalStack | AWS Réel |
|---------|-----------|----------|
| **Coût** | Gratuit | Payant |
| **Vitesse** | Rapide (local) | Plus lent (réseau) |
| **Offline** | ✅ Oui | ❌ Non |
| **Services** | ~80% AWS | 100% AWS |
| **Limitations** | Quelques bugs | Aucune |
| **Usage** | Dev/Test | Prod |

### Quand Utiliser Quoi

**LocalStack (use_localstack = true):**
- ✅ Développement local
- ✅ Tests unitaires/intégration
- ✅ Apprentissage sans frais
- ✅ Itération rapide

**AWS Réel (use_localstack = false):**
- ✅ Staging
- ✅ Production
- ✅ Tests de performance
- ✅ Services non supportés par LocalStack

---

## ⚠️ Bonnes Pratiques

### 1. State Management

```bash
# ✅ BON: Toujours utiliser un backend remote en équipe
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "mcp-fcc/terraform.tfstate"
    region = "us-east-1"
  }
}

# ❌ ÉVITER: State local en équipe (conflits)
```

### 2. Variables Sensibles

```hcl
# ✅ BON: Marquer comme sensitive
variable "database_password" {
  type      = string
  sensitive = true
}

# ✅ BON: Ne pas commiter les secrets
# .gitignore
*.tfvars
!environments/*.tfvars  # Sauf si pas de secrets
terraform.tfstate*
```

### 3. Outputs Utiles

```hcl
# ✅ BON: Outputs clairs et complets
output "api_endpoint" {
  description = "URL complète de l'API pour tester"
  value       = "${module.api_gateway.api_endpoint}/transactions"
}

# ❌ ÉVITER: Outputs cryptiques
output "a" {
  value = aws_api_gateway_rest_api.x.id
}
```

### 4. Documentation

```hcl
# ✅ BON: Commenter les ressources complexes
resource "aws_lambda_function" "processor" {
  # Cette Lambda traite les transactions depuis SQS
  # et envoie les résultats vers Kafka
  function_name = "processor"
  
  # Timeout élevé car appels externes Kafka
  timeout = 60
}
```

### 5. Validation

```bash
# Toujours valider avant de commiter
terraform fmt -recursive
terraform validate
terraform plan
```

---

## 🚀 Commandes Avancées

### Import de Ressources Existantes

```bash
# Importer une Lambda existante
terraform import module.my_lambda.aws_lambda_function.function my-function-name

# Importer une SQS queue
terraform import module.queue.aws_sqs_queue.queue https://sqs.us-east-1.amazonaws.com/123456789/my-queue
```

### Graphe de Dépendances

```bash
# Générer un graphe visuel
terraform graph | dot -Tpng > graph.png
```

### Debugging

```bash
# Logs détaillés
export TF_LOG=DEBUG
terraform apply

# Logs dans un fichier
export TF_LOG=TRACE
export TF_LOG_PATH=terraform.log
terraform apply
```

### Taint/Untaint

```bash
# Forcer la recréation d'une ressource
terraform taint aws_lambda_function.my_func
terraform apply

# Annuler un taint
terraform untaint aws_lambda_function.my_func
```

---

## 📊 Exemple Complet

Voici un exemple complet montrant tous les concepts:

```hcl
# providers.tf
terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "mcp-fcc/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = local.common_tags
  }
}

# variables.tf
variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "mcp-fcc-banking"
}

variable "environment" {
  description = "Environnement"
  type        = string
  
  validation {
    condition     = contains(["local", "dev", "staging", "prod"], var.environment)
    error_message = "Environment must be local, dev, staging, or prod."
  }
}

# locals.tf
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  lambda_config = {
    local = { memory = 128, timeout = 10 }
    dev   = { memory = 256, timeout = 30 }
    prod  = { memory = 1024, timeout = 60 }
  }
}

# main.tf
module "lambda" {
  source = "./modules/lambda"
  
  function_name = "${var.project_name}-processor-${var.environment}"
  memory_size   = local.lambda_config[var.environment].memory
  timeout       = local.lambda_config[var.environment].timeout
  
  tags = local.common_tags
}

# outputs.tf
output "lambda_arn" {
  description = "ARN de la Lambda processor"
  value       = module.lambda.function_arn
}
```

---

## 📚 Ressources Additionnelles

- **[Terraform Documentation](https://developer.hashicorp.com/terraform/docs)**
- **[Terraform Registry](https://registry.terraform.io/)** - Modules et providers
- **[Terraform Best Practices](https://www.terraform-best-practices.com/)**
- **[LocalStack Docs](https://docs.localstack.cloud/)**
- **[AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)**

---

## 🎓 Progression d'Apprentissage

### Débutant (Semaine 1)
- [ ] Installer Terraform
- [ ] Comprendre providers, resources, variables, outputs
- [ ] Workflow: init → plan → apply
- [ ] Créer première Lambda avec Terraform

### Intermédiaire (Semaine 2)
- [ ] Créer des modules réutilisables
- [ ] Utiliser data sources
- [ ] Gérer les dépendances
- [ ] Déployer une architecture multi-ressources

### Avancé (Semaine 3)
- [ ] Remote state (S3 + DynamoDB)
- [ ] Workspaces pour multi-environnements
- [ ] Import de ressources existantes
- [ ] Testing avec Terratest

### Expert (Semaine 4)
- [ ] CI/CD pour Terraform
- [ ] GitOps workflow
- [ ] Modules partagés en équipe
- [ ] Monitoring de l'infrastructure

---

**Bon apprentissage avec Terraform ! 🚀**
