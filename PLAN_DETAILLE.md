# 📋 PLAN D'APPRENTISSAGE DÉTAILLÉ - 4 SEMAINES

> **Système de Transactions Bancaires avec Terraform & LocalStack**  
> De zéro à l'infrastructure complète en 4 semaines

---

## 🎯 Objectif Global

Construire un système complet de traitement de transactions bancaires en maîtrisant **Terraform** et l'**Infrastructure as Code**, tout en apprenant l'architecture **event-driven** AWS.

### Ce que vous allez apprendre

- ✅ Terraform de A à Z (débutant → avancé)
- ✅ LocalStack pour développement local
- ✅ Architecture AWS serverless complète
- ✅ Event-driven patterns avec Lambda, SQS, Step Functions
- ✅ Infrastructure testing et CI/CD
- ✅ Best practices DevOps et GitOps

---

## 📅 SEMAINE 1: Fondations Terraform + LocalStack

**Objectif:** Comprendre Terraform et déployer votre première infrastructure

---

### 🗓️ JOUR 1: Setup & Premiers Pas avec Terraform

#### ⏱️ Durée: 3-4 heures

#### Objectifs d'apprentissage
- Comprendre les concepts de base de Terraform
- Installer et configurer l'environnement
- Créer votre premier fichier Terraform
- Déployer sur LocalStack

---

#### **Tâche 1.1 - Installation de Terraform**

**📖 Théorie:**

**Infrastructure as Code (IaC)** signifie décrire votre infrastructure (serveurs, réseaux, bases de données) dans des fichiers de configuration plutôt que de la créer manuellement.

**Terraform** est un outil IaC qui:
- Utilise un langage déclaratif (HCL - HashiCorp Configuration Language)
- Gère le cycle de vie complet des ressources (create, update, delete)
- Maintient un "state" pour suivre l'infrastructure réelle
- Supporte 100+ cloud providers

**✅ Actions:**

```bash
# 1. Vérifier si Terraform est installé
terraform version

# 2. Si non installé, installer Terraform (Linux)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# 3. Vérifier l'installation
terraform version  # Doit afficher >= 1.6.0

# 4. Activer l'autocomplétion
terraform -install-autocomplete
```

**🔍 Vérifications:**
- [ ] `terraform version` fonctionne
- [ ] Version >= 1.6.0
- [ ] Autocomplétion activée

**📚 Documentation:**
- [Installation Terraform](https://developer.hashicorp.com/terraform/install)
- [Introduction à Terraform](https://developer.hashicorp.com/terraform/intro)

---

#### **Tâche 1.2 - Setup LocalStack avec Docker**

**📖 Théorie:**

**LocalStack** est un émulateur AWS qui tourne localement. Il permet de:
- Tester votre infrastructure sans frais AWS
- Développer rapidement sans latence réseau
- Éviter les erreurs coûteuses en production
- Travailler offline

**Services supportés:** Lambda, SQS, S3, DynamoDB, Step Functions, API Gateway, etc.

**✅ Actions:**

```bash
# 1. Créer le fichier docker-compose.yml
cd /home/sd/Documents/Dev/ci-cd/MCP-FCC-Test
```

Créez `docker-compose.yml`:

```yaml
version: '3.9'

services:
  # LocalStack - AWS Emulator
  localstack:
    image: localstack/localstack:latest
    container_name: mcp-fcc-localstack
    ports:
      - "4566:4566"      # LocalStack endpoint
      - "4510-4559:4510-4559"  # Services externes
    environment:
      - SERVICES=lambda,sqs,s3,stepfunctions,iam,logs,events,apigateway,dynamodb
      - DEBUG=1
      - LAMBDA_EXECUTOR=docker
      - DOCKER_HOST=unix:///var/run/docker.sock
      - PERSISTENCE=1
      - DATA_DIR=/var/lib/localstack/data
    volumes:
      - "./localstack-data:/var/lib/localstack"
      - "/var/run/docker.sock:/var/run/docker.sock"
    networks:
      - mcp-fcc-network

  # Kafka pour event streaming
  zookeeper:
    image: confluentinc/cp-zookeeper:7.6.0
    container_name: mcp-fcc-zookeeper
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - "2181:2181"
    networks:
      - mcp-fcc-network

  kafka:
    image: confluentinc/cp-kafka:7.6.0
    container_name: mcp-fcc-kafka
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
      - "9093:9093"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092,PLAINTEXT_INTERNAL://kafka:9093
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_INTERNAL:PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
    networks:
      - mcp-fcc-network

  # Kafka UI pour visualiser
  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    container_name: mcp-fcc-kafka-ui
    depends_on:
      - kafka
    ports:
      - "8080:8080"
    environment:
      KAFKA_CLUSTERS_0_NAME: local
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:9093
      KAFKA_CLUSTERS_0_ZOOKEEPER: zookeeper:2181
    networks:
      - mcp-fcc-network

networks:
  mcp-fcc-network:
    driver: bridge

volumes:
  localstack-data:
```

```bash
# 2. Démarrer LocalStack
docker-compose up -d

# 3. Vérifier que tout tourne
docker-compose ps

# 4. Tester LocalStack
curl http://localhost:4566/_localstack/health

# 5. Vérifier les logs
docker-compose logs -f localstack
```

**🔍 Vérifications:**
- [ ] 4 containers running (localstack, zookeeper, kafka, kafka-ui)
- [ ] LocalStack health check retourne OK
- [ ] Kafka UI accessible sur http://localhost:8080
- [ ] Pas d'erreurs dans les logs

**📚 Documentation:**
- [LocalStack Docs](https://docs.localstack.cloud/)
- [LocalStack avec Terraform](https://docs.localstack.cloud/user-guide/integrations/terraform/)

---

#### **Tâche 1.3 - Premier Fichier Terraform: Hello World**

**📖 Théorie:**

Un projet Terraform contient généralement:
- **providers.tf** - Configuration des providers (AWS, Azure, etc.)
- **main.tf** - Ressources principales
- **variables.tf** - Variables d'entrée
- **outputs.tf** - Valeurs de sortie
- **terraform.tfvars** - Valeurs des variables

Le **workflow Terraform** en 3 étapes:
1. `terraform init` - Initialise le projet, télécharge les providers
2. `terraform plan` - Prévisualise les changements
3. `terraform apply` - Applique les changements

**✅ Actions:**

```bash
# 1. Créer la structure
mkdir -p terraform/modules terraform/environments
cd terraform
```

Créez `providers.tf`:

```hcl
# Configuration du provider AWS pour LocalStack
terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Configuration LocalStack
  # Ces paramètres sont ignorés si use_localstack = false
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  # Endpoints LocalStack
  endpoints {
    apigateway     = var.use_localstack ? "http://localhost:4566" : null
    cloudformation = var.use_localstack ? "http://localhost:4566" : null
    cloudwatch     = var.use_localstack ? "http://localhost:4566" : null
    dynamodb       = var.use_localstack ? "http://localhost:4566" : null
    ec2            = var.use_localstack ? "http://localhost:4566" : null
    iam            = var.use_localstack ? "http://localhost:4566" : null
    lambda         = var.use_localstack ? "http://localhost:4566" : null
    s3             = var.use_localstack ? "http://localhost:4566" : null
    sqs            = var.use_localstack ? "http://localhost:4566" : null
    stepfunctions  = var.use_localstack ? "http://localhost:4566" : null
    sts            = var.use_localstack ? "http://localhost:4566" : null
  }

  # Credentials fake pour LocalStack
  access_key = var.use_localstack ? "test" : null
  secret_key = var.use_localstack ? "test" : null
}
```

Créez `variables.tf`:

```hcl
# Variables globales du projet

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "mcp-fcc-banking"
}

variable "environment" {
  description = "Environnement (local, dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "us-east-1"
}

variable "use_localstack" {
  description = "Utiliser LocalStack au lieu d'AWS"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags communs pour toutes les ressources"
  type        = map(string)
  default     = {}
}
```

Créez `main.tf` (première ressource simple):

```hcl
# Configuration principale du projet

# Resource de test: un bucket S3 simple
resource "aws_s3_bucket" "test_bucket" {
  bucket = "${var.project_name}-test-bucket-${var.environment}"

  tags = merge(
    var.tags,
    {
      Name        = "Test Bucket"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Random ID pour rendre les noms uniques
resource "random_id" "suffix" {
  byte_length = 4
}
```

Créez `outputs.tf`:

```hcl
# Outputs - Valeurs à afficher après le déploiement

output "test_bucket_name" {
  description = "Nom du bucket S3 de test"
  value       = aws_s3_bucket.test_bucket.id
}

output "test_bucket_arn" {
  description = "ARN du bucket S3 de test"
  value       = aws_s3_bucket.test_bucket.arn
}

output "environment" {
  description = "Environnement déployé"
  value       = var.environment
}

output "region" {
  description = "Région AWS utilisée"
  value       = var.aws_region
}
```

Créez `environments/local.tfvars`:

```hcl
# Configuration pour environnement local avec LocalStack

environment     = "local"
aws_region      = "us-east-1"
use_localstack  = true

tags = {
  Project     = "MCP-FCC Banking"
  Environment = "local"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
}
```

```bash
# 2. Initialiser Terraform
terraform init

# 3. Voir le plan
terraform plan -var-file=environments/local.tfvars

# 4. Appliquer (créer le bucket)
terraform apply -var-file=environments/local.tfvars

# 5. Vérifier que le bucket existe
aws --endpoint-url=http://localhost:4566 s3 ls

# 6. Voir les outputs
terraform output

# 7. Voir l'état
terraform show
```

**🔍 Vérifications:**
- [ ] `terraform init` réussit
- [ ] `terraform plan` affiche la création d'un bucket
- [ ] `terraform apply` crée le bucket sans erreur
- [ ] Le bucket apparaît dans LocalStack
- [ ] Les outputs s'affichent correctement
- [ ] Un fichier `terraform.tfstate` a été créé

**📚 Documentation:**
- [Terraform Workflow](https://developer.hashicorp.com/terraform/intro/core-workflow)
- [HCL Syntax](https://developer.hashicorp.com/terraform/language/syntax/configuration)
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

**🎓 Concepts Clés Appris:**
- ✅ Structure d'un projet Terraform
- ✅ Providers et configuration
- ✅ Resources (aws_s3_bucket)
- ✅ Variables et tfvars files
- ✅ Outputs
- ✅ Workflow: init → plan → apply
- ✅ State file (terraform.tfstate)

---

### 🗓️ JOUR 2: Lambda Functions avec Terraform

#### ⏱️ Durée: 4-5 heures

#### Objectifs d'apprentissage
- Créer des Lambda functions avec Terraform
- Packager du code TypeScript pour Lambda
- Gérer les IAM roles et permissions
- Déployer sur LocalStack

---

#### **Tâche 2.1 - Setup du Code TypeScript**

**📖 Théorie:**

Les **Lambda functions** sont du code qui s'exécute en réponse à des événements (requêtes HTTP, messages SQS, etc.).

Pour déployer une Lambda avec Terraform:
1. Écrire le code (TypeScript, Python, etc.)
2. Le packager en ZIP
3. Créer la ressource `aws_lambda_function` dans Terraform
4. Attacher un IAM role pour les permissions

**✅ Actions:**

```bash
# 1. Créer la structure pour le code source
cd /home/sd/Documents/Dev/ci-cd/MCP-FCC-Test
mkdir -p src/lambdas/hello-world
```

Créez `package.json` à la racine:

```json
{
  "name": "mcp-fcc-banking",
  "version": "1.0.0",
  "description": "Banking transaction system with Terraform",
  "scripts": {
    "build": "tsc",
    "build:lambdas": "./scripts/build-lambdas.sh",
    "test": "jest",
    "lint": "eslint . --ext .ts"
  },
  "devDependencies": {
    "@types/aws-lambda": "^8.10.134",
    "@types/node": "^20.11.16",
    "typescript": "^5.3.3",
    "esbuild": "^0.20.0"
  },
  "dependencies": {
    "@aws-sdk/client-sqs": "^3.511.0",
    "@aws-sdk/client-s3": "^3.511.0",
    "zod": "^3.22.4"
  }
}
```

Créez `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

```bash
# 2. Installer les dépendances
npm install
```

Créez `src/lambdas/hello-world/index.ts`:

```typescript
import { APIGatewayProxyEvent, APIGatewayProxyResult, Context } from 'aws-lambda';

/**
 * Lambda Handler simple pour tester le déploiement
 */
export const handler = async (
  event: APIGatewayProxyEvent,
  context: Context
): Promise<APIGatewayProxyResult> => {
  console.log('Event:', JSON.stringify(event, null, 2));
  console.log('Context:', JSON.stringify(context, null, 2));

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: 'Hello from MCP-FCC Banking System!',
      timestamp: new Date().toISOString(),
      environment: process.env.ENVIRONMENT || 'unknown',
      requestId: context.requestId,
    }),
  };
};
```

Créez `scripts/build-lambdas.sh`:

```bash
#!/bin/bash
set -e

echo "🏗️  Building Lambda functions..."

# Créer le dossier de build
mkdir -p dist/lambdas

# Build hello-world Lambda
echo "Building hello-world..."
npx esbuild src/lambdas/hello-world/index.ts \
  --bundle \
  --platform=node \
  --target=node20 \
  --outfile=dist/lambdas/hello-world/index.js \
  --external:@aws-sdk/*

# Créer le package ZIP
cd dist/lambdas/hello-world
zip -r ../hello-world.zip .
cd -

echo "✅ Lambda functions built successfully!"
echo "📦 Packages disponibles dans dist/lambdas/"
```

```bash
# 3. Rendre le script exécutable et builder
chmod +x scripts/build-lambdas.sh
npm run build:lambdas

# 4. Vérifier que le ZIP existe
ls -lh dist/lambdas/hello-world.zip
```

**🔍 Vérifications:**
- [ ] `npm install` réussit
- [ ] Script de build s'exécute sans erreur
- [ ] Fichier `dist/lambdas/hello-world.zip` existe
- [ ] Le ZIP contient `index.js`

**📚 Documentation:**
- [AWS Lambda avec Node.js](https://docs.aws.amazon.com/lambda/latest/dg/lambda-nodejs.html)
- [Lambda Event Types](https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/aws-lambda)

---

#### **Tâche 2.2 - Module Terraform pour Lambda**

**📖 Théorie:**

Les **modules Terraform** sont des composants réutilisables. Au lieu de copier-coller du code, vous créez un module et le réutilisez avec différents paramètres.

Structure d'un module:
```
modules/lambda/
  ├── main.tf       # Ressources
  ├── variables.tf  # Inputs
  └── outputs.tf    # Outputs
```

**✅ Actions:**

```bash
cd terraform
mkdir -p modules/lambda
```

Créez `modules/lambda/variables.tf`:

```hcl
# Variables d'entrée du module Lambda

variable "function_name" {
  description = "Nom de la fonction Lambda"
  type        = string
}

variable "description" {
  description = "Description de la fonction"
  type        = string
  default     = ""
}

variable "handler" {
  description = "Handler de la fonction (ex: index.handler)"
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = "Runtime Lambda (ex: nodejs20.x)"
  type        = string
  default     = "nodejs20.x"
}

variable "timeout" {
  description = "Timeout en secondes"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Mémoire allouée en MB"
  type        = number
  default     = 256
}

variable "source_file" {
  description = "Chemin vers le fichier ZIP de la Lambda"
  type        = string
}

variable "environment_variables" {
  description = "Variables d'environnement"
  type        = map(string)
  default     = {}
}

variable "iam_policy_statements" {
  description = "Statements IAM additionnels pour la Lambda"
  type        = any
  default     = []
}

variable "tags" {
  description = "Tags à appliquer"
  type        = map(string)
  default     = {}
}
```

Créez `modules/lambda/main.tf`:

```hcl
# Module Lambda réutilisable

# IAM Role pour la Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Policy de base pour logs CloudWatch
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.function_name}-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "arn:aws:logs:*:*:*"
        }
      ],
      var.iam_policy_statements
    )
  })
}

# Lambda Function
resource "aws_lambda_function" "function" {
  filename         = var.source_file
  function_name    = var.function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = var.handler
  source_code_hash = filebase64sha256(var.source_file)
  runtime         = var.runtime
  timeout         = var.timeout
  memory_size     = var.memory_size

  environment {
    variables = var.environment_variables
  }

  tags = merge(
    var.tags,
    {
      Name = var.function_name
    }
  )

  depends_on = [aws_iam_role_policy.lambda_policy]
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 7

  tags = var.tags
}
```

Créez `modules/lambda/outputs.tf`:

```hcl
# Outputs du module Lambda

output "function_name" {
  description = "Nom de la fonction Lambda"
  value       = aws_lambda_function.function.function_name
}

output "function_arn" {
  description = "ARN de la fonction Lambda"
  value       = aws_lambda_function.function.arn
}

output "function_invoke_arn" {
  description = "ARN d'invocation de la fonction"
  value       = aws_lambda_function.function.invoke_arn
}

output "function_role_arn" {
  description = "ARN du rôle IAM de la fonction"
  value       = aws_iam_role.lambda_role.arn
}

output "log_group_name" {
  description = "Nom du CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}
```

**🔍 Vérifications:**
- [ ] Structure du module créée
- [ ] Fichiers `variables.tf`, `main.tf`, `outputs.tf` présents
- [ ] Syntaxe HCL valide

---

#### **Tâche 2.3 - Utiliser le Module Lambda**

**✅ Actions:**

Modifiez `terraform/main.tf` pour utiliser le module:

```hcl
# Configuration principale du projet

# Resource de test: un bucket S3 simple
resource "aws_s3_bucket" "test_bucket" {
  bucket = "${var.project_name}-test-bucket-${var.environment}"

  tags = merge(
    var.tags,
    {
      Name        = "Test Bucket"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Random ID pour rendre les noms uniques
resource "random_id" "suffix" {
  byte_length = 4
}

# Module Lambda: Hello World
module "hello_world_lambda" {
  source = "./modules/lambda"

  function_name = "${var.project_name}-hello-world-${var.environment}"
  description   = "Lambda de test Hello World"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 10
  memory_size   = 128

  source_file = "../dist/lambdas/hello-world.zip"

  environment_variables = {
    ENVIRONMENT = var.environment
    PROJECT     = var.project_name
    LOG_LEVEL   = "INFO"
  }

  tags = var.tags
}
```

Mettez à jour `terraform/outputs.tf`:

```hcl
# Outputs - Valeurs à afficher après le déploiement

output "test_bucket_name" {
  description = "Nom du bucket S3 de test"
  value       = aws_s3_bucket.test_bucket.id
}

output "test_bucket_arn" {
  description = "ARN du bucket S3 de test"
  value       = aws_s3_bucket.test_bucket.arn
}

output "hello_world_lambda_name" {
  description = "Nom de la Lambda Hello World"
  value       = module.hello_world_lambda.function_name
}

output "hello_world_lambda_arn" {
  description = "ARN de la Lambda Hello World"
  value       = module.hello_world_lambda.function_arn
}

output "environment" {
  description = "Environnement déployé"
  value       = var.environment
}

output "region" {
  description = "Région AWS utilisée"
  value       = var.aws_region
}
```

```bash
# 1. Réinitialiser pour charger le module
cd terraform
terraform init

# 2. Voir le plan
terraform plan -var-file=environments/local.tfvars

# 3. Appliquer
terraform apply -var-file=environments/local.tfvars

# 4. Vérifier la Lambda dans LocalStack
aws --endpoint-url=http://localhost:4566 lambda list-functions

# 5. Tester la Lambda
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name mcp-fcc-banking-hello-world-local \
  --payload '{}' \
  response.json

cat response.json | jq .

# 6. Voir les logs
terraform output
```

**🔍 Vérifications:**
- [ ] `terraform plan` montre la création de la Lambda
- [ ] `terraform apply` réussit
- [ ] Lambda visible dans LocalStack
- [ ] Invocation de la Lambda retourne un message
- [ ] Outputs affichent les informations de la Lambda

**📚 Documentation:**
- [Terraform Modules](https://developer.hashicorp.com/terraform/language/modules)
- [AWS Lambda Resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)
- [IAM Roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)

**🎓 Concepts Clés Appris:**
- ✅ Modules Terraform réutilisables
- ✅ Ressource `aws_lambda_function`
- ✅ IAM Roles et Policies pour Lambda
- ✅ Variables d'environnement Lambda
- ✅ CloudWatch Log Groups
- ✅ Packaging de code pour Lambda
- ✅ Invoke Lambda depuis CLI

---

### 🗓️ JOUR 3: SQS Queues & Lambda Triggers

#### ⏱️ Durée: 4-5 heures

#### Objectifs d'apprentissage
- Créer des SQS queues avec Dead Letter Queue
- Connecter Lambda à SQS (event source mapping)
- Gérer les permissions IAM
- Créer un workflow simple: API → SQS → Lambda

---

#### **Tâche 3.1 - Module SQS avec Dead Letter Queue**

**📖 Théorie:**

**Amazon SQS** (Simple Queue Service) est un service de file d'attente de messages distribué. Il permet de:
- Découpler les composants d'une application
- Garantir la livraison des messages
- Gérer les pics de charge

**Dead Letter Queue (DLQ)** = File pour les messages qui ont échoué après plusieurs tentatives de traitement.

**Pattern courant:**
```
API Gateway → SQS Queue → Lambda Processing
                ↓ (échecs)
         Dead Letter Queue
```

**✅ Actions:**

```bash
cd terraform
mkdir -p modules/sqs
```

Créez `modules/sqs/variables.tf`:

```hcl
variable "queue_name" {
  description = "Nom de la queue SQS"
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "Timeout de visibilité (doit être >= au timeout de la Lambda)"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Durée de rétention des messages (4 jours par défaut)"
  type        = number
  default     = 345600
}

variable "max_receive_count" {
  description = "Nombre max de tentatives avant DLQ"
  type        = number
  default     = 3
}

variable "delay_seconds" {
  description = "Délai avant que le message soit visible"
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "Long polling wait time"
  type        = number
  default     = 10
}

variable "enable_dlq" {
  description = "Activer la Dead Letter Queue"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags à appliquer"
  type        = map(string)
  default     = {}
}
```

Créez `modules/sqs/main.tf`:

```hcl
# Module SQS avec Dead Letter Queue

# Dead Letter Queue (si activée)
resource "aws_sqs_queue" "dlq" {
  count = var.enable_dlq ? 1 : 0

  name                      = "${var.queue_name}-dlq"
  message_retention_seconds = 1209600  # 14 jours

  tags = merge(
    var.tags,
    {
      Name = "${var.queue_name}-dlq"
      Type = "DeadLetterQueue"
    }
  )
}

# Queue principale
resource "aws_sqs_queue" "queue" {
  name                       = var.queue_name
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  delay_seconds             = var.delay_seconds
  receive_wait_time_seconds = var.receive_wait_time_seconds

  # Configuration DLQ
  redrive_policy = var.enable_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = merge(
    var.tags,
    {
      Name = var.queue_name
      Type = "MainQueue"
    }
  )
}

# Policy pour autoriser Lambda à lire depuis la queue
resource "aws_sqs_queue_policy" "queue_policy" {
  queue_url = aws_sqs_queue.queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.queue.arn
      }
    ]
  })
}
```

Créez `modules/sqs/outputs.tf`:

```hcl
output "queue_id" {
  description = "ID de la queue"
  value       = aws_sqs_queue.queue.id
}

output "queue_arn" {
  description = "ARN de la queue"
  value       = aws_sqs_queue.queue.arn
}

output "queue_url" {
  description = "URL de la queue"
  value       = aws_sqs_queue.queue.url
}

output "dlq_arn" {
  description = "ARN de la DLQ (si activée)"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_url" {
  description = "URL de la DLQ (si activée)"
  value       = var.enable_dlq ? aws_sqs_queue.dlq[0].url : null
}
```

**🔍 Vérifications:**
- [ ] Module SQS créé avec variables, main, outputs
- [ ] Logique DLQ conditionnelle implémentée

---

#### **Tâche 3.2 - Lambda Process Transaction**

**📖 Théorie:**

Une Lambda peut être **déclenchée par SQS** automatiquement. Terraform crée l'**Event Source Mapping** qui connecte la queue à la Lambda.

**✅ Actions:**

Créez `src/lambdas/process-transaction/index.ts`:

```typescript
import { SQSEvent, SQSHandler, Context } from 'aws-lambda';

interface Transaction {
  transactionId: string;
  amount: number;
  currency: string;
  accountFrom: string;
  accountTo: string;
  timestamp: string;
}

/**
 * Lambda qui traite les transactions depuis SQS
 */
export const handler: SQSHandler = async (
  event: SQSEvent,
  context: Context
): Promise<void> => {
  console.log('Processing batch:', {
    recordCount: event.Records.length,
    requestId: context.requestId,
  });

  for (const record of event.Records) {
    try {
      const transaction: Transaction = JSON.parse(record.body);
      
      console.log('Processing transaction:', transaction);

      // Validation simple
      if (transaction.amount <= 0) {
        throw new Error('Invalid amount: must be positive');
      }

      if (!transaction.accountFrom || !transaction.accountTo) {
        throw new Error('Missing account information');
      }

      // Simuler le traitement
      await processTransaction(transaction);

      console.log('Transaction processed successfully:', transaction.transactionId);

    } catch (error) {
      console.error('Error processing transaction:', error);
      // Le message sera renvoyé dans la queue ou DLQ selon la config
      throw error;
    }
  }
};

async function processTransaction(transaction: Transaction): Promise<void> {
  // Simuler un délai de traitement
  await new Promise(resolve => setTimeout(resolve, 100));
  
  // Logique métier ici
  console.log(`Processing ${transaction.amount} ${transaction.currency}`);
  console.log(`From: ${transaction.accountFrom} → To: ${transaction.accountTo}`);
}
```

Mettez à jour `scripts/build-lambdas.sh`:

```bash
#!/bin/bash
set -e

echo "🏗️  Building Lambda functions..."

# Créer le dossier de build
mkdir -p dist/lambdas

# Build hello-world Lambda
echo "Building hello-world..."
npx esbuild src/lambdas/hello-world/index.ts \
  --bundle \
  --platform=node \
  --target=node20 \
  --outfile=dist/lambdas/hello-world/index.js \
  --external:@aws-sdk/*

cd dist/lambdas/hello-world
zip -r ../hello-world.zip .
cd -

# Build process-transaction Lambda
echo "Building process-transaction..."
npx esbuild src/lambdas/process-transaction/index.ts \
  --bundle \
  --platform=node \
  --target=node20 \
  --outfile=dist/lambdas/process-transaction/index.js \
  --external:@aws-sdk/*

cd dist/lambdas/process-transaction
zip -r ../process-transaction.zip .
cd -

echo "✅ Lambda functions built successfully!"
echo "📦 Packages disponibles dans dist/lambdas/"
```

```bash
# Build les Lambdas
npm run build:lambdas
```

**🔍 Vérifications:**
- [ ] Fichier `process-transaction/index.ts` créé
- [ ] Build réussit
- [ ] ZIP `process-transaction.zip` créé

---

#### **Tâche 3.3 - Intégration Terraform: SQS → Lambda**

**✅ Actions:**

Ajoutez dans `terraform/main.tf`:

```hcl
# ... (code existant) ...

# Module SQS: Transactions Queue
module "transactions_queue" {
  source = "./modules/sqs"

  queue_name                 = "${var.project_name}-transactions-${var.environment}"
  visibility_timeout_seconds = 60  # 2x le timeout de la Lambda
  max_receive_count          = 3
  enable_dlq                 = true

  tags = var.tags
}

# Module Lambda: Process Transaction
module "process_transaction_lambda" {
  source = "./modules/lambda"

  function_name = "${var.project_name}-process-transaction-${var.environment}"
  description   = "Process transactions from SQS queue"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  source_file = "../dist/lambdas/process-transaction.zip"

  environment_variables = {
    ENVIRONMENT = var.environment
    PROJECT     = var.project_name
  }

  # Permissions pour lire depuis SQS
  iam_policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility"
      ]
      Resource = module.transactions_queue.queue_arn
    }
  ]

  tags = var.tags
}

# Event Source Mapping: SQS → Lambda
resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = module.transactions_queue.queue_arn
  function_name    = module.process_transaction_lambda.function_name
  batch_size       = 10
  enabled          = true

  # Scaling configuration
  scaling_config {
    maximum_concurrency = 10
  }

  depends_on = [
    module.transactions_queue,
    module.process_transaction_lambda
  ]
}
```

Ajoutez les outputs dans `terraform/outputs.tf`:

```hcl
# ... (outputs existants) ...

output "transactions_queue_url" {
  description = "URL de la queue SQS des transactions"
  value       = module.transactions_queue.queue_url
}

output "transactions_dlq_url" {
  description = "URL de la Dead Letter Queue"
  value       = module.transactions_queue.dlq_url
}

output "process_transaction_lambda_name" {
  description = "Nom de la Lambda de traitement"
  value       = module.process_transaction_lambda.function_name
}
```

```bash
# 1. Appliquer les changements
cd terraform
terraform init
terraform apply -var-file=environments/local.tfvars

# 2. Vérifier les ressources
aws --endpoint-url=http://localhost:4566 sqs list-queues
aws --endpoint-url=http://localhost:4566 lambda list-functions

# 3. Tester: envoyer un message dans la queue
QUEUE_URL=$(terraform output -raw transactions_queue_url)

aws --endpoint-url=http://localhost:4566 sqs send-message \
  --queue-url $QUEUE_URL \
  --message-body '{
    "transactionId": "txn-001",
    "amount": 100.50,
    "currency": "CAD",
    "accountFrom": "ACC-12345",
    "accountTo": "ACC-67890",
    "timestamp": "2026-02-06T10:00:00Z"
  }'

# 4. Vérifier les logs de la Lambda (la Lambda devrait traiter automatiquement)
aws --endpoint-url=http://localhost:4566 logs tail \
  /aws/lambda/mcp-fcc-banking-process-transaction-local \
  --follow

# 5. Vérifier que le message a été supprimé de la queue
aws --endpoint-url=http://localhost:4566 sqs get-queue-attributes \
  --queue-url $QUEUE_URL \
  --attribute-names ApproximateNumberOfMessages
```

**🔍 Vérifications:**
- [ ] Queue SQS créée
- [ ] DLQ créée
- [ ] Lambda créée
- [ ] Event source mapping créé
- [ ] Message envoyé à la queue
- [ ] Lambda déclenchée automatiquement
- [ ] Message traité et supprimé
- [ ] Logs visibles dans CloudWatch

**📚 Documentation:**
- [AWS SQS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue)
- [Lambda Event Source Mapping](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping)
- [SQS with Lambda](https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html)

**🎓 Concepts Clés Appris:**
- ✅ SQS Queues et Dead Letter Queue
- ✅ Event Source Mapping
- ✅ Lambda déclenchée par SQS
- ✅ IAM permissions pour SQS
- ✅ Batch processing dans Lambda
- ✅ Error handling et retries

---

### 📚 Récapitulatif Semaine 1

**Vous avez appris:**

✅ **Terraform Basics**
- Installation et setup
- Structure de projet (providers, main, variables, outputs)
- Workflow: init → plan → apply → destroy
- State management

✅ **LocalStack**
- Configuration avec Docker
- Endpoints pour services AWS locaux
- Testing sans frais

✅ **Modules Terraform**
- Création de modules réutilisables
- Variables d'entrée et outputs
- Composition de modules

✅ **Lambda Functions**
- Packaging de code TypeScript
- Déploiement avec Terraform
- IAM roles et permissions
- Environment variables
- CloudWatch logs

✅ **SQS Queues**
- Queue principale et DLQ
- Event source mapping avec Lambda
- Message processing automatique

**Architecture actuelle:**
```
SQS Queue → Lambda Process Transaction
    ↓
  DLQ
```

**Prochaine semaine:** API Gateway, Step Functions, S3, architecture complète !

---

## 📅 SEMAINE 2: Services AWS Avancés + Architecture Event-Driven

**Objectif:** Construire le workflow complet de traitement des transactions

---

### 🗓️ JOUR 4: API Gateway + Lambda Validation

#### ⏱️ Durée: 4-5 heures

#### Objectifs
- Créer une API REST avec API Gateway
- Lambda pour recevoir les transactions
- Validation avec Zod
- Envoyer vers SQS

---

#### **Tâche 4.1 - Lambda Submit Transaction**

**📖 Théorie:**

**API Gateway** expose votre Lambda comme une API REST HTTP. Pattern:
```
Client HTTP → API Gateway → Lambda → SQS
```

**✅ Actions:**

Créez `src/lambdas/submit-transaction/index.ts`:

```typescript
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';
import { z } from 'zod';

// Schéma de validation
const TransactionSchema = z.object({
  amount: z.number().positive(),
  currency: z.string().length(3),
  accountFrom: z.string().min(1),
  accountTo: z.string().min(1),
});

// Client SQS
const sqsClient = new SQSClient({
  region: process.env.AWS_REGION || 'us-east-1',
  endpoint: process.env.SQS_ENDPOINT,
});

const QUEUE_URL = process.env.QUEUE_URL!;

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  try {
    console.log('Received event:', JSON.stringify(event, null, 2));

    // Parser le body
    if (!event.body) {
      return errorResponse(400, 'Missing request body');
    }

    const body = JSON.parse(event.body);

    // Valider avec Zod
    const validation = TransactionSchema.safeParse(body);
    if (!validation.success) {
      return errorResponse(400, 'Invalid transaction data', validation.error.errors);
    }

    const transaction = validation.data;

    // Ajouter metadata
    const enrichedTransaction = {
      transactionId: `txn-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      ...transaction,
      timestamp: new Date().toISOString(),
      status: 'PENDING',
    };

    // Envoyer vers SQS
    await sqsClient.send(
      new SendMessageCommand({
        QueueUrl: QUEUE_URL,
        MessageBody: JSON.stringify(enrichedTransaction),
      })
    );

    console.log('Transaction submitted:', enrichedTransaction.transactionId);

    return {
      statusCode: 202,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: 'Transaction submitted successfully',
        transactionId: enrichedTransaction.transactionId,
        status: 'PENDING',
      }),
    };

  } catch (error) {
    console.error('Error:', error);
    return errorResponse(500, 'Internal server error');
  }
};

function errorResponse(statusCode: number, message: string, details?: any): APIGatewayProxyResult {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
    body: JSON.stringify({
      error: message,
      details,
    }),
  };
}
```

Mettez à jour `scripts/build-lambdas.sh` pour inclure cette Lambda.

```bash
npm run build:lambdas
```

**🔍 Vérifications:**
- [ ] Lambda submit-transaction créée
- [ ] Build réussit
- [ ] ZIP créé

---

#### **Tâche 4.2 - Module API Gateway**

**✅ Actions:**

```bash
cd terraform
mkdir -p modules/api-gateway
```

Créez `modules/api-gateway/variables.tf`:

```hcl
variable "api_name" {
  description = "Nom de l'API Gateway"
  type        = string
}

variable "api_description" {
  description = "Description de l'API"
  type        = string
  default     = ""
}

variable "stage_name" {
  description = "Stage de déploiement (dev, prod, etc.)"
  type        = string
  default     = "api"
}

variable "lambda_invoke_arn" {
  description = "ARN d'invocation de la Lambda backend"
  type        = string
}

variable "lambda_function_name" {
  description = "Nom de la fonction Lambda"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}
```

Créez `modules/api-gateway/main.tf`:

```hcl
# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

# Resource /transactions
resource "aws_api_gateway_resource" "transactions" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "transactions"
}

# Method POST /transactions
resource "aws_api_gateway_method" "post_transaction" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.transactions.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration avec Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.transactions.id
  http_method             = aws_api_gateway_method.post_transaction.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

# Permission pour API Gateway d'invoquer Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.transactions.id,
      aws_api_gateway_method.post_transaction.id,
      aws_api_gateway_integration.lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
}

# Stage
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.stage_name

  tags = var.tags
}
```

Créez `modules/api-gateway/outputs.tf`:

```hcl
output "api_id" {
  description = "ID de l'API Gateway"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_endpoint" {
  description = "Endpoint de l'API"
  value       = aws_api_gateway_stage.stage.invoke_url
}

output "api_url" {
  description = "URL complète de l'API"
  value       = "${aws_api_gateway_stage.stage.invoke_url}/transactions"
}
```

Ajoutez dans `terraform/main.tf`:

```hcl
# ... (code existant) ...

# Lambda: Submit Transaction (API endpoint)
module "submit_transaction_lambda" {
  source = "./modules/lambda"

  function_name = "${var.project_name}-submit-transaction-${var.environment}"
  description   = "Receive transactions via API Gateway"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 10
  memory_size   = 256

  source_file = "../dist/lambdas/submit-transaction.zip"

  environment_variables = {
    ENVIRONMENT  = var.environment
    QUEUE_URL    = module.transactions_queue.queue_url
    AWS_REGION   = var.aws_region
    SQS_ENDPOINT = var.use_localstack ? "http://localhost:4566" : null
  }

  iam_policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "sqs:SendMessage",
        "sqs:GetQueueUrl"
      ]
      Resource = module.transactions_queue.queue_arn
    }
  ]

  tags = var.tags
}

# API Gateway
module "api_gateway" {
  source = "./modules/api-gateway"

  api_name        = "${var.project_name}-api-${var.environment}"
  api_description = "Banking Transactions API"
  stage_name      = var.environment

  lambda_invoke_arn    = module.submit_transaction_lambda.function_invoke_arn
  lambda_function_name = module.submit_transaction_lambda.function_name

  tags = var.tags
}
```

Ajoutez l'output:

```hcl
output "api_endpoint" {
  description = "URL de l'API"
  value       = module.api_gateway.api_url
}
```

```bash
# Déployer
cd terraform
terraform init
terraform apply -var-file=environments/local.tfvars

# Tester l'API
API_URL=$(terraform output -raw api_endpoint)

curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 250.00,
    "currency": "CAD",
    "accountFrom": "ACC-11111",
    "accountTo": "ACC-22222"
  }'

# Vérifier les logs
aws --endpoint-url=http://localhost:4566 logs tail \
  /aws/lambda/mcp-fcc-banking-process-transaction-local \
  --follow
```

**🔍 Vérifications:**
- [ ] API Gateway créée
- [ ] Lambda submit-transaction déployée
- [ ] POST /transactions fonctionne
- [ ] Transaction arrive dans SQS
- [ ] Lambda process-transaction se déclenche
- [ ] Logs visibles

**🎓 Concepts Appris:**
- ✅ API Gateway REST API
- ✅ Lambda avec API Gateway (AWS_PROXY)
- ✅ Validation avec Zod
- ✅ SQS SendMessage depuis Lambda
- ✅ Workflow complet: API → SQS → Lambda

---

### 🗓️ JOUR 5: Event Streaming avec Kafka

#### ⏱️ Durée: 4-5 heures

#### Objectifs d'apprentissage
- Comprendre l'event streaming et Kafka
- Créer des topics Kafka
- Publier des événements depuis Lambda
- Créer des consumers Kafka
- Intégrer Kafka dans le workflow

---

#### **Tâche 5.1 - Configuration Kafka**

**📖 Théorie:**

**Apache Kafka** est une plateforme distribuée d'event streaming qui permet de:
- Publier et souscrire à des flux d'événements (publish/subscribe)
- Stocker les événements de manière durable et fiable
- Traiter les événements en temps réel

**Architecture Kafka:**
```
Producer → Kafka Topic (partitions) → Consumer Group
                ↓
            Persistent Log
```

**Concepts clés:**
- **Topic**: Canal nommé pour les messages (ex: `transactions-events`)
- **Producer**: Publie des messages dans un topic
- **Consumer**: Lit les messages d'un topic
- **Partition**: Division d'un topic pour la scalabilité
- **Consumer Group**: Groupe de consumers qui se partagent le traitement

**✅ Actions:**

Le docker-compose.yml contient déjà Kafka, mais vérifions qu'il est actif:

```bash
# Vérifier que Kafka tourne
docker-compose ps kafka

# Accéder à Kafka UI
# Ouvrir http://localhost:8080 dans le navigateur
```

Créez `scripts/create-kafka-topics.js`:

```javascript
#!/usr/bin/env node

const { Kafka } = require('kafkajs');

const kafka = new Kafka({
  clientId: 'mcp-fcc-banking-admin',
  brokers: ['localhost:9092'],
  retry: {
    retries: 10,
    initialRetryTime: 300,
  },
});

const admin = kafka.admin();

async function createTopics() {
  try {
    console.log('🔌 Connecting to Kafka...');
    await admin.connect();
    console.log('✅ Connected to Kafka');

    const topics = [
      {
        topic: 'transactions-events',
        numPartitions: 3,
        replicationFactor: 1,
        configEntries: [
          { name: 'retention.ms', value: '604800000' }, // 7 days
          { name: 'compression.type', value: 'gzip' },
        ],
      },
      {
        topic: 'fraud-alerts',
        numPartitions: 2,
        replicationFactor: 1,
      },
      {
        topic: 'notifications',
        numPartitions: 2,
        replicationFactor: 1,
      },
    ];

    console.log('📋 Creating topics...');
    await admin.createTopics({
      topics,
      waitForLeaders: true,
    });

    console.log('✅ Topics created successfully:');
    topics.forEach((t) => console.log(`   - ${t.topic}`));

    // Lister tous les topics
    const existingTopics = await admin.listTopics();
    console.log('\n📚 All topics:', existingTopics);

    await admin.disconnect();
    console.log('✅ Disconnected from Kafka');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

createTopics();
```

Ajoutez la dépendance KafkaJS dans `package.json`:

```json
{
  "dependencies": {
    "@aws-sdk/client-sqs": "^3.511.0",
    "@aws-sdk/client-s3": "^3.511.0",
    "zod": "^3.22.4",
    "kafkajs": "^2.2.4"
  }
}
```

```bash
# Installer KafkaJS
npm install kafkajs

# Rendre le script exécutable
chmod +x scripts/create-kafka-topics.js

# Créer les topics
node scripts/create-kafka-topics.js

# Vérifier dans Kafka UI
# http://localhost:8080 → Topics
```

**🔍 Vérifications:**
- [ ] Kafka tourne (docker-compose ps)
- [ ] KafkaJS installé
- [ ] Topics créés (transactions-events, fraud-alerts, notifications)
- [ ] Topics visibles dans Kafka UI

**📚 Documentation:**
- [KafkaJS Docs](https://kafka.js.org/)
- [Kafka Introduction](https://kafka.apache.org/intro)

---

#### **Tâche 5.2 - Kafka Producer Service**

**📖 Théorie:**

Un **Producer** publie des messages dans Kafka. Dans notre architecture, la Lambda `process-transaction` va publier un événement dans Kafka après avoir traité la transaction.

**✅ Actions:**

Créez `src/shared/kafka.service.ts`:

```typescript
import { Kafka, Producer, Message, CompressionTypes } from 'kafkajs';

export interface KafkaConfig {
  clientId: string;
  brokers: string[];
}

export class KafkaService {
  private kafka: Kafka;
  private producer: Producer | null = null;

  constructor(config: KafkaConfig) {
    this.kafka = new Kafka({
      clientId: config.clientId,
      brokers: config.brokers,
      retry: {
        retries: 5,
        initialRetryTime: 300,
        maxRetryTime: 30000,
      },
    });
  }

  async connect(): Promise<void> {
    if (!this.producer) {
      this.producer = this.kafka.producer({
        allowAutoTopicCreation: false,
        compression: CompressionTypes.GZIP,
      });
      await this.producer.connect();
      console.log('Kafka producer connected');
    }
  }

  async disconnect(): Promise<void> {
    if (this.producer) {
      await this.producer.disconnect();
      this.producer = null;
      console.log('Kafka producer disconnected');
    }
  }

  async sendMessage(topic: string, message: any): Promise<void> {
    if (!this.producer) {
      await this.connect();
    }

    const kafkaMessage: Message = {
      key: message.transactionId || Date.now().toString(),
      value: JSON.stringify(message),
      timestamp: Date.now().toString(),
      headers: {
        'content-type': 'application/json',
      },
    };

    await this.producer!.send({
      topic,
      messages: [kafkaMessage],
    });

    console.log(`Message sent to Kafka topic: ${topic}`, {
      key: kafkaMessage.key,
      timestamp: kafkaMessage.timestamp,
    });
  }

  async sendBatch(topic: string, messages: any[]): Promise<void> {
    if (!this.producer) {
      await this.connect();
    }

    const kafkaMessages: Message[] = messages.map((msg) => ({
      key: msg.transactionId || Date.now().toString(),
      value: JSON.stringify(msg),
      timestamp: Date.now().toString(),
    }));

    await this.producer!.send({
      topic,
      messages: kafkaMessages,
    });

    console.log(`Batch of ${messages.length} messages sent to topic: ${topic}`);
  }
}

// Singleton instance pour Lambda (réutilise la connexion)
let kafkaServiceInstance: KafkaService | null = null;

export function getKafkaService(): KafkaService {
  if (!kafkaServiceInstance) {
    kafkaServiceInstance = new KafkaService({
      clientId: process.env.KAFKA_CLIENT_ID || 'mcp-fcc-banking',
      brokers: (process.env.KAFKA_BROKERS || 'localhost:9092').split(','),
    });
  }
  return kafkaServiceInstance;
}
```

**🔍 Vérifications:**
- [ ] Fichier `kafka.service.ts` créé
- [ ] Service avec singleton pattern
- [ ] Méthodes sendMessage et sendBatch
- [ ] Gestion de la connexion/déconnexion

---

#### **Tâche 5.3 - Publier dans Kafka depuis Lambda**

**✅ Actions:**

Modifiez `src/lambdas/process-transaction/index.ts`:

```typescript
import { SQSEvent, SQSHandler, Context } from 'aws-lambda';
import { getKafkaService } from '../../shared/kafka.service';

interface Transaction {
  transactionId: string;
  amount: number;
  currency: string;
  accountFrom: string;
  accountTo: string;
  timestamp: string;
  status: string;
}

// Instance Kafka réutilisée entre invocations Lambda (Lambda container reuse)
const kafkaService = getKafkaService();

/**
 * Lambda qui traite les transactions depuis SQS et publie dans Kafka
 */
export const handler: SQSHandler = async (
  event: SQSEvent,
  context: Context
): Promise<void> => {
  console.log('Processing batch:', {
    recordCount: event.Records.length,
    requestId: context.requestId,
  });

  // Connecter Kafka si pas déjà connecté
  await kafkaService.connect();

  for (const record of event.Records) {
    try {
      const transaction: Transaction = JSON.parse(record.body);
      
      console.log('Processing transaction:', transaction);

      // Validation simple
      if (transaction.amount <= 0) {
        throw new Error('Invalid amount: must be positive');
      }

      if (!transaction.accountFrom || !transaction.accountTo) {
        throw new Error('Missing account information');
      }

      // Simuler le traitement
      await processTransaction(transaction);

      // Publier l'événement dans Kafka
      const transactionEvent = {
        ...transaction,
        status: 'PROCESSED',
        processedAt: new Date().toISOString(),
        processorId: context.functionName,
      };

      await kafkaService.sendMessage('transactions-events', transactionEvent);

      console.log('Transaction processed and published to Kafka:', transaction.transactionId);

    } catch (error) {
      console.error('Error processing transaction:', error);
      
      // Publier une alerte de fraude potentielle en cas d'erreur
      await kafkaService.sendMessage('fraud-alerts', {
        transactionId: record.messageId,
        error: (error as Error).message,
        timestamp: new Date().toISOString(),
      });
      
      throw error; // Le message ira dans la DLQ
    }
  }
};

async function processTransaction(transaction: Transaction): Promise<void> {
  // Simuler un délai de traitement
  await new Promise(resolve => setTimeout(resolve, 100));
  
  // Logique métier ici
  console.log(`Processing ${transaction.amount} ${transaction.currency}`);
  console.log(`From: ${transaction.accountFrom} → To: ${transaction.accountTo}`);
}
```

Mettez à jour la configuration Terraform pour ajouter les variables d'environnement Kafka:

Dans `terraform/main.tf`, modifiez le module `process_transaction_lambda`:

```hcl
module "process_transaction_lambda" {
  source = "./modules/lambda"

  function_name = "${var.project_name}-process-transaction-${var.environment}"
  description   = "Process transactions from SQS queue and publish to Kafka"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 30
  memory_size   = 256

  source_file = "../dist/lambdas/process-transaction.zip"

  environment_variables = {
    ENVIRONMENT     = var.environment
    PROJECT         = var.project_name
    KAFKA_BROKERS   = "kafka:9093"  # Utilise le nom du service Docker
    KAFKA_CLIENT_ID = "${var.project_name}-${var.environment}"
  }

  # Permissions pour lire depuis SQS
  iam_policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ChangeMessageVisibility"
      ]
      Resource = module.transactions_queue.queue_arn
    }
  ]

  tags = var.tags
}
```

```bash
# Rebuild les Lambdas
npm run build:lambdas

# Redéployer
cd terraform
terraform apply -var-file=environments/local.tfvars

# Tester en envoyant une transaction
cd ..
API_URL=$(cd terraform && terraform output -raw api_endpoint)

curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 500.00,
    "currency": "CAD",
    "accountFrom": "ACC-11111",
    "accountTo": "ACC-22222"
  }'

# Vérifier les logs
for log_group in $(aws --endpoint-url=http://localhost:4566 logs describe-log-groups --log-group-name-prefix "/aws/lambda/mcp-fcc-banking" --query 'logGroups[].logGroupName' --output text); do
  echo "=== $log_group ==="
  aws --endpoint-url=http://localhost:4566 logs tail "$log_group" --since 2m
done

# Vérifier dans Kafka UI que le message est arrivé
# http://localhost:8080 → Topics → transactions-events → Messages
```

**🔍 Vérifications:**
- [ ] Lambda process-transaction modifiée
- [ ] KafkaService intégré
- [ ] Variables d'environnement Kafka configurées
- [ ] Rebuild et redéploiement réussis
- [ ] Transaction publiée dans Kafka
- [ ] Message visible dans Kafka UI

---

#### **Tâche 5.4 - Kafka Consumer**

**📖 Théorie:**

Un **Consumer** lit les messages depuis Kafka. Les consumers peuvent être organisés en **Consumer Groups** pour partager la charge de travail.

**✅ Actions:**

Créez `src/consumers/transaction-events.consumer.ts`:

```typescript
import { Kafka, Consumer, EachMessagePayload } from 'kafkajs';

interface TransactionEvent {
  transactionId: string;
  amount: number;
  currency: string;
  accountFrom: string;
  accountTo: string;
  status: string;
  processedAt: string;
}

export class TransactionEventsConsumer {
  private kafka: Kafka;
  private consumer: Consumer;

  constructor() {
    this.kafka = new Kafka({
      clientId: 'mcp-fcc-banking-consumer',
      brokers: (process.env.KAFKA_BROKERS || 'localhost:9092').split(','),
      retry: {
        retries: 5,
        initialRetryTime: 300,
      },
    });

    this.consumer = this.kafka.consumer({
      groupId: 'transaction-processors',
      sessionTimeout: 30000,
      heartbeatInterval: 3000,
    });
  }

  async connect(): Promise<void> {
    await this.consumer.connect();
    console.log('✅ Consumer connected to Kafka');
  }

  async disconnect(): Promise<void> {
    await this.consumer.disconnect();
    console.log('✅ Consumer disconnected from Kafka');
  }

  async subscribe(): Promise<void> {
    await this.consumer.subscribe({
      topic: 'transactions-events',
      fromBeginning: false, // Seulement les nouveaux messages
    });
    console.log('✅ Subscribed to transactions-events topic');
  }

  async run(): Promise<void> {
    await this.consumer.run({
      eachMessage: async (payload: EachMessagePayload) => {
        await this.handleMessage(payload);
      },
    });
  }

  private async handleMessage(payload: EachMessagePayload): Promise<void> {
    const { topic, partition, message } = payload;

    try {
      const event: TransactionEvent = JSON.parse(message.value!.toString());

      console.log('📩 Received transaction event:', {
        topic,
        partition,
        offset: message.offset,
        transactionId: event.transactionId,
        status: event.status,
        amount: event.amount,
      });

      // Traiter l'événement
      await this.processTransactionEvent(event);

      console.log('✅ Transaction event processed:', event.transactionId);
    } catch (error) {
      console.error('❌ Error processing message:', error);
      // En production: implémenter retry logic ou DLQ
    }
  }

  private async processTransactionEvent(event: TransactionEvent): Promise<void> {
    // Logique métier ici:
    // - Enregistrer dans une base de données
    // - Mettre à jour des analytics
    // - Déclencher d'autres workflows
    // - Envoyer des notifications
    
    console.log(`Processing event for transaction: ${event.transactionId}`);
    console.log(`Amount: ${event.amount} ${event.currency}`);
    console.log(`Status: ${event.status}`);
    console.log(`Processed at: ${event.processedAt}`);

    // Simuler un traitement
    await new Promise(resolve => setTimeout(resolve, 500));
  }
}

// Point d'entrée pour exécuter le consumer
async function main() {
  const consumer = new TransactionEventsConsumer();

  // Graceful shutdown
  const errorTypes = ['unhandledRejection', 'uncaughtException'];
  const signalTraps = ['SIGTERM', 'SIGINT', 'SIGUSR2'];

  errorTypes.forEach((type) => {
    process.on(type, async (e) => {
      try {
        console.log(`Process ${type}: ${e}`);
        await consumer.disconnect();
        process.exit(0);
      } catch (_) {
        process.exit(1);
      }
    });
  });

  signalTraps.forEach((type) => {
    process.once(type, async () => {
      try {
        console.log(`Process ${type} received`);
        await consumer.disconnect();
      } finally {
        process.kill(process.pid, type);
      }
    });
  });

  try {
    await consumer.connect();
    await consumer.subscribe();
    console.log('🚀 Consumer is running...');
    await consumer.run();
  } catch (error) {
    console.error('❌ Fatal error:', error);
    await consumer.disconnect();
    process.exit(1);
  }
}

// Exécuter si appelé directement
if (require.main === module) {
  main();
}

export default TransactionEventsConsumer;
```

Ajoutez un script dans `package.json`:

```json
{
  "scripts": {
    "build": "tsc",
    "build:lambdas": "./scripts/build-lambdas.sh",
    "consumer:transactions": "ts-node src/consumers/transaction-events.consumer.ts",
    "test": "jest",
    "lint": "eslint . --ext .ts"
  }
}
```

Installez ts-node:

```bash
npm install --save-dev ts-node
```

Testez le consumer:

```bash
# Dans un terminal séparé, lancer le consumer
npm run consumer:transactions

# Dans un autre terminal, envoyer une transaction
cd terraform
API_URL=$(terraform output -raw api_endpoint)

curl -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 750.00,
    "currency": "CAD",
    "accountFrom": "ACC-33333",
    "accountTo": "ACC-44444"
  }'

# Observer les logs du consumer qui traite l'événement
```

**🔍 Vérifications:**
- [ ] Consumer créé avec Consumer Group
- [ ] Graceful shutdown implémenté
- [ ] Consumer traite les messages de Kafka
- [ ] Logs visibles montrant le traitement
- [ ] Messages visibles dans Kafka UI

**📚 Documentation:**
- [KafkaJS Consumer](https://kafka.js.org/docs/consuming)
- [Consumer Groups](https://kafka.apache.org/documentation/#consumergroups)

---

#### **Tâche 5.5 - Architecture Event-Driven Complète**

**📖 Théorie:**

Nous avons maintenant une architecture **event-driven** complète:

```
Client
  ↓
API Gateway
  ↓
Lambda Submit → SQS Queue
  ↓
Lambda Process → Kafka Topic
  ↓
Kafka Consumer(s) → Traitement final
```

**Avantages:**
- ✅ **Découplage**: Chaque composant est indépendant
- ✅ **Scalabilité**: Chaque étape peut scaler séparément
- ✅ **Résilience**: SQS + Kafka garantissent la livraison
- ✅ **Traçabilité**: Tous les événements sont loggés
- ✅ **Extensibilité**: Facile d'ajouter de nouveaux consumers

**✅ Actions:**

Créez un script de test end-to-end `scripts/test-workflow.sh`:

```bash
#!/bin/bash
set -e

echo "🧪 Testing Complete Event-Driven Workflow"
echo "========================================"

cd terraform

# Récupérer l'URL de l'API
API_URL=$(terraform output -raw api_endpoint)
echo "📍 API URL: $API_URL"

# Test 1: Transaction valide
echo ""
echo "📤 Test 1: Sending valid transaction..."
RESPONSE=$(curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 1200.00,
    "currency": "CAD",
    "accountFrom": "ACC-TEST-001",
    "accountTo": "ACC-TEST-002"
  }')

echo "Response: $RESPONSE"
TRANSACTION_ID=$(echo $RESPONSE | jq -r '.transactionId')
echo "✅ Transaction submitted: $TRANSACTION_ID"

# Attendre le traitement
echo "⏳ Waiting for processing..."
sleep 3

# Test 2: Transaction invalide (montant négatif)
echo ""
echo "📤 Test 2: Sending invalid transaction (negative amount)..."
curl -s -X POST $API_URL \
  -H "Content-Type: application/json" \
  -d '{
    "amount": -50.00,
    "currency": "CAD",
    "accountFrom": "ACC-TEST-003",
    "accountTo": "ACC-TEST-004"
  }' | jq .

# Vérifier les logs
echo ""
echo "📋 Checking Lambda logs..."
aws --endpoint-url=http://localhost:4566 logs tail \
  /aws/lambda/mcp-fcc-banking-process-transaction-local \
  --since 5m | grep "Transaction processed"

echo ""
echo "✅ Workflow test complete!"
echo "👉 Check Kafka UI: http://localhost:8080"
echo "👉 Topic: transactions-events"
```

```bash
# Rendre exécutable et tester
chmod +x scripts/test-workflow.sh
./scripts/test-workflow.sh
```

**🔍 Vérifications finales:**
- [ ] Script de test end-to-end fonctionne
- [ ] Transaction valide passe par tout le workflow
- [ ] Transaction invalide est rejetée
- [ ] Événements visibles dans Kafka UI
- [ ] Logs montrent le flux complet
- [ ] Consumer traite les événements

**🎓 Concepts Clés Appris:**
- ✅ Event Streaming avec Kafka
- ✅ Topics, Partitions, Consumer Groups
- ✅ Producers et Consumers KafkaJS
- ✅ Architecture Event-Driven complète
- ✅ Découplage et scalabilité
- ✅ Intégration Lambda → Kafka
- ✅ Consumer standalone Node.js

**📊 Architecture Actuelle:**

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │ HTTP POST
       ▼
┌──────────────────┐
│  API Gateway     │ (LocalStack)
│  + Lambda Submit │
└────────┬─────────┘
         │ SQS Message
         ▼
┌────────────────────┐
│  SQS Queue + DLQ   │
└────────┬───────────┘
         │ Event Source Mapping
         ▼
┌─────────────────────┐
│ Lambda Process      │
│ Transaction         │
└────────┬────────────┘
         │ Kafka Message
         ▼
┌─────────────────────┐
│  Kafka Topic        │
│ transactions-events │
└────────┬────────────┘
         │ Consumer Group
         ▼
┌─────────────────────┐
│  Kafka Consumer(s)  │
│  - Analytics        │
│  - Notifications    │
│  - Archiving        │
└─────────────────────┘
```

---

### 📚 Récapitulatif Semaine 1 (Mise à jour)

**Vous avez appris:**

✅ **Terraform Basics**
- Installation et setup
- Structure de projet (providers, main, variables, outputs)
- Workflow: init → plan → apply
- State management

✅ **LocalStack**
- Configuration avec Docker
- Endpoints pour services AWS locaux
- Testing sans frais

✅ **Modules Terraform**
- Création de modules réutilisables
- Variables d'entrée et outputs
- Composition de modules

✅ **Lambda Functions**
- Packaging de code TypeScript
- Déploiement avec Terraform
- IAM roles et permissions
- Environment variables
- CloudWatch logs

✅ **SQS Queues**
- Queue principale et DLQ
- Event source mapping avec Lambda
- Message processing automatique

✅ **API Gateway**
- REST API avec LocalStack
- Integration Lambda (AWS_PROXY)
- Validation avec Zod

✅ **Kafka Event Streaming** ⭐ NOUVEAU
- Topics, Partitions, Consumer Groups
- KafkaJS Producer et Consumer
- Event-driven architecture
- Intégration Lambda → Kafka
- Kafka UI pour monitoring

**Architecture complète:**
```
API Gateway → SQS → Lambda Process → Kafka → Consumers
                ↓
              DLQ
```

**Prochaine semaine:** Step Functions workflows, S3 archiving, Tests !

---

### 🗓️ JOUR 6-7: Step Functions + S3 + Tests

*(À détailler: orchestration de workflows avec Step Functions, archivage dans S3, et tests d'intégration)*

**Résumé du plan complet des 4 semaines:**

- **Semaine 1** ✅ (complété): Terraform, LocalStack, Lambda, SQS, API Gateway, Kafka
- **Semaine 2**: Step Functions workflows, S3, intégration complète, monitoring
- **Semaine 3**: Modules avancés, multi-environnements, remote state, tests infrastructure
- **Semaine 4**: CI/CD, monitoring avancé, optimisations, production readiness

---

**Ce plan continue sur 20+ pages avec chaque jour détaillé...**

Voulez-vous que je continue à détailler les jours 6-7 et les semaines 2-4, ou avez-vous des questions spécifiques ?
