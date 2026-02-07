# 🏦 MCP-FCC Banking System - Infrastructure as Code

> **Système de Traitement de Transactions Bancaires avec Terraform & LocalStack**

Projet pédagogique complet pour maîtriser **Terraform**, **LocalStack**, et l'**architecture event-driven** en construisant un système bancaire de traitement de transactions.

---

## 🎯 Vue d'Ensemble

Ce projet est une **refonte complète** du système de transactions bancaires, mais cette fois **100% Infrastructure as Code** avec:

- ✅ **Terraform** - Toute l'infrastructure déclarée en code
- ✅ **LocalStack** - Développement local sans coûts AWS
- ✅ **Architecture Event-Driven** - Lambda, SQS, Step Functions, Kafka
- ✅ **TypeScript** - Fonctions Lambda et services
- ✅ **Approche Progressive** - 4 semaines d'apprentissage structuré

### Différence avec le projet "perfectionnement"

| Aspect | Perfectionnement | MCP-FCC (ce projet) |
|--------|------------------|---------------------|
| **Infrastructure** | Manuelle/Scripts | **Terraform (IaC)** |
| **Provisioning** | Docker Compose | **Terraform + LocalStack** |
| **Configuration** | Fichiers .env | **Variables Terraform** |
| **Déploiement** | Scripts bash | **terraform apply** |
| **Gestion état** | Aucune | **Terraform State** |
| **Multi-env** | Difficile | **Workspaces/Modules** |

---

## 🏗️ Architecture Cible

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  API Gateway    │ (Lambda + API Gateway)
└────────┬────────┘
         │
         ▼
┌────────────────┐
│   SQS Queue    │ → DLQ
└────────┬───────┘
         │
         ▼
┌────────────────────┐
│ Lambda: Validate   │
│   Transaction      │
└─────────┬──────────┘
          │
          ▼
     ┌────────┐
     │ Kafka  │ (sur EC2 avec Terraform)
     └───┬────┘
         │
         ▼
┌─────────────────────┐
│  Step Functions     │
│  Workflow           │
└──────┬──────────────┘
       │
       ▼
    ┌────┬────┬────┐
    │    │    │    │
    ▼    ▼    ▼    ▼
  Fraud Notif Archive
  Detect
```

**Tout provisionné et géré via Terraform !**

---

## 📚 Parcours d'Apprentissage (4 Semaines)

### 🗓️ Semaine 1: Fondations Terraform + Setup LocalStack
- Concepts Terraform (providers, resources, state)
- Configuration LocalStack
- Premiers modules (VPC, Security Groups)
- Déploiement d'une Lambda simple

### 🗓️ Semaine 2: Services AWS + Intégration
- SQS + Dead Letter Queue
- Lambda avec événements SQS
- S3 pour archives
- IAM roles et policies
- Modules réutilisables

### 🗓️ Semaine 3: Orchestration + Event Streaming
- Step Functions avec Terraform
- EC2 pour Kafka (Docker)
- Lambda consumers Kafka
- Intégration complète du workflow

### 🗓️ Semaine 4: Production Ready
- Testing de l'infrastructure (Terratest)
- Multi-environnements (workspaces)
- Remote state (S3 + DynamoDB)
- CI/CD avec GitHub Actions
- Monitoring et observabilité

---

## 🚀 Démarrage Rapide

### Prérequis

- **Terraform** >= 1.6.0 ([installer](https://developer.hashicorp.com/terraform/install))
- **Docker Desktop** (pour LocalStack)
- **AWS CLI** ([installer](https://aws.amazon.com/cli/))
- **Node.js** >= 20.0.0 (pour les Lambdas)
- **Make** (optionnel, pour les scripts)

### Installation

```bash
# 1. Cloner et se positionner
cd /home/sd/Documents/Dev/ci-cd/MCP-FCC-Test

# 2. Installer les dépendances Terraform
cd terraform
terraform init

# 3. Démarrer LocalStack
docker-compose up -d

# 4. Vérifier LocalStack
curl http://localhost:4566/_localstack/health

# 5. Déployer l'infrastructure
terraform plan -var-file=environments/local.tfvars
terraform apply -var-file=environments/local.tfvars

# 6. Tester le système
npm run test:integration
```

---

## 📁 Structure du Projet

```
MCP-FCC-Test/
├── README.md                      # Ce fichier
├── PLAN_DETAILLE.md              # 📖 Plan d'apprentissage complet (4 semaines)
├── TERRAFORM_GUIDE.md            # 📚 Guide Terraform pour ce projet
├── docker-compose.yml            # LocalStack + Kafka
├── Makefile                      # Commandes utiles
│
├── terraform/                    # 🏗️ Infrastructure as Code
│   ├── main.tf                   # Configuration principale
│   ├── providers.tf              # AWS provider + LocalStack
│   ├── variables.tf              # Variables d'entrée
│   ├── outputs.tf                # Sorties
│   ├── backend.tf                # Configuration backend
│   │
│   ├── modules/                  # 🧩 Modules réutilisables
│   │   ├── lambda/               # Module Lambda générique
│   │   ├── sqs/                  # Module SQS + DLQ
│   │   ├── step-functions/       # Module Step Functions
│   │   ├── api-gateway/          # Module API Gateway
│   │   ├── kafka-cluster/        # Module Kafka sur EC2
│   │   └── monitoring/           # Module CloudWatch
│   │
│   ├── environments/             # 🌍 Configurations par environnement
│   │   ├── local.tfvars          # LocalStack
│   │   ├── dev.tfvars            # AWS Dev
│   │   ├── staging.tfvars        # AWS Staging
│   │   └── prod.tfvars           # AWS Prod
│   │
│   └── step-functions/           # Définitions Step Functions
│       └── transaction-workflow.asl.json
│
├── src/                          # 💻 Code source TypeScript
│   ├── lambdas/                  # Fonctions Lambda
│   │   ├── api-handler/          # Handler API Gateway
│   │   ├── validate-transaction/
│   │   ├── detect-fraud/
│   │   ├── send-notification/
│   │   └── archive-transaction/
│   │
│   ├── layers/                   # Lambda Layers
│   │   └── nodejs/               # Dépendances partagées
│   │
│   └── shared/                   # Code partagé
│       ├── types.ts
│       ├── utils.ts
│       └── constants.ts
│
├── tests/                        # 🧪 Tests
│   ├── unit/                     # Tests unitaires
│   ├── integration/              # Tests d'intégration
│   └── terraform/                # Tests Terraform (Terratest)
│
├── scripts/                      # 📜 Scripts utilitaires
│   ├── setup-localstack.sh       # Configuration LocalStack
│   ├── build-lambdas.sh          # Build des Lambdas
│   ├── test-transaction.sh       # Test end-to-end
│   └── cleanup.sh                # Nettoyage
│
└── docs/                         # 📚 Documentation
    ├── CONCEPTS.md               # Concepts clés expliqués
    ├── ARCHITECTURE.md           # Architecture détaillée
    ├── TROUBLESHOOTING.md        # Résolution de problèmes
    └── REFERENCES.md             # Liens et ressources
```

---

## 📖 Documentation

### Documents Principaux

1. **[PLAN_DETAILLE.md](PLAN_DETAILLE.md)** ⭐ **COMMENCEZ ICI**
   - Plan d'apprentissage complet sur 4 semaines
   - Tâches détaillées et ordonnées
   - Explications pédagogiques pour chaque concept
   - Critères de validation

2. **[TERRAFORM_GUIDE.md](TERRAFORM_GUIDE.md)**
   - Guide Terraform spécifique à ce projet
   - Bonnes pratiques
   - Patterns réutilisables

3. **[docs/CONCEPTS.md](docs/CONCEPTS.md)**
   - Infrastructure as Code expliqué
   - Terraform vs autres outils
   - LocalStack en détail
   - Event-driven architecture

4. **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**
   - Architecture complète du système
   - Diagrammes et flux de données
   - Décisions architecturales

---

## 🎓 Objectifs d'Apprentissage

À la fin de ce projet, vous maîtriserez:

### Terraform (IaC)
✅ Syntaxe HCL et structure des fichiers  
✅ Providers et ressources  
✅ Variables, outputs, data sources  
✅ Modules réutilisables  
✅ State management (local + remote)  
✅ Workspaces pour multi-environnements  
✅ Import de ressources existantes  
✅ Dépendances et graph  

### LocalStack
✅ Configuration et utilisation  
✅ Services AWS supportés  
✅ Debugging et troubleshooting  
✅ Limitations et workarounds  

### Architecture AWS Event-Driven
✅ Lambda functions et handlers  
✅ SQS queues et DLQ  
✅ Step Functions workflows  
✅ API Gateway  
✅ IAM roles et policies  
✅ CloudWatch logs et metrics  

### Kafka sur AWS
✅ Déploiement Kafka sur EC2  
✅ Intégration Lambda + Kafka  
✅ Topics et partitions  
✅ Producers et consumers  

### DevOps Practices
✅ Infrastructure as Code  
✅ Immutable infrastructure  
✅ Testing infrastructure (Terratest)  
✅ CI/CD pour Terraform  
✅ GitOps workflow  

---

## 🛠️ Commandes Utiles

### Terraform

```bash
# Initialiser le projet
terraform init

# Voir le plan d'exécution
terraform plan -var-file=environments/local.tfvars

# Appliquer les changements
terraform apply -var-file=environments/local.tfvars

# Détruire l'infrastructure
terraform destroy -var-file=environments/local.tfvars

# Valider la syntaxe
terraform validate

# Formater le code
terraform fmt -recursive

# Afficher l'état
terraform show

# Lister les ressources
terraform state list

# Graphe des dépendances
terraform graph | dot -Tpng > graph.png
```

### LocalStack

```bash
# Démarrer
docker-compose up -d

# Vérifier la santé
curl http://localhost:4566/_localstack/health

# Logs
docker-compose logs -f localstack

# Arrêter
docker-compose down

# Nettoyer les données
docker-compose down -v
```

### Tests

```bash
# Tests unitaires TypeScript
npm run test:unit

# Tests d'intégration
npm run test:integration

# Tests Terraform
cd tests/terraform && go test -v

# Test end-to-end complet
./scripts/test-transaction.sh
```

---

## 🚦 Workflow de Développement

### 1. Feature Branch
```bash
git checkout -b feature/add-notification-service
```

### 2. Développement Local
```bash
# Démarrer LocalStack
docker-compose up -d

# Développer et tester
terraform apply -var-file=environments/local.tfvars
./scripts/test-transaction.sh

# Itérer
```

### 3. Validation
```bash
# Format
terraform fmt -recursive

# Validate
terraform validate

# Tests
npm run test
cd tests/terraform && go test -v
```

### 4. Commit & Push
```bash
git add .
git commit -m "feat: add notification service lambda"
git push origin feature/add-notification-service
```

### 5. Pull Request
- CI/CD exécute les tests
- Terraform plan en commentaire
- Review et merge

---

## 🎯 Parcours Recommandé

### Pour les Débutants en Terraform

1. **Commencez par** [PLAN_DETAILLE.md](PLAN_DETAILLE.md) - Semaine 1
2. Suivez chaque étape dans l'ordre
3. Ne sautez pas les exercices
4. Lisez la documentation référencée

### Pour ceux qui Connaissent Terraform

1. Lisez [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
2. Parcourez [TERRAFORM_GUIDE.md](TERRAFORM_GUIDE.md)
3. Allez directement à la Semaine 2 ou 3 du plan
4. Concentrez-vous sur les patterns avancés

### Pour Ceux qui Veulent Juste Déployer

```bash
# Setup complet en une commande
make setup

# Déployer
make deploy-local

# Tester
make test

# Nettoyer
make clean
```

---

## 🤝 Comparaison avec le Projet "perfectionnement"

Ce projet **complète** le projet perfectionnement en ajoutant:

| Compétence | Perfectionnement | MCP-FCC (ce projet) |
|------------|------------------|---------------------|
| TypeScript/Node.js | ✅ Focus principal | ✅ Utilisé pour Lambdas |
| Event Architecture | ✅ Focus principal | ✅ Implémenté via IaC |
| Docker | ✅ Docker Compose | ✅ LocalStack + Kafka |
| **Infrastructure** | ❌ Manuelle | ✅ **Terraform (IaC)** |
| **Provisioning** | ❌ Scripts | ✅ **Déclaratif** |
| **Multi-env** | ⚠️ Difficile | ✅ **Workspaces** |
| **State Mgmt** | ❌ Aucun | ✅ **Terraform State** |
| **Testing Infra** | ❌ Aucun | ✅ **Terratest** |
| **CI/CD Infra** | ❌ Aucun | ✅ **GitHub Actions** |

**Recommandation:** Faire les deux projets pour une formation complète !

---

## 📦 Dépendances

### Terraform Providers

- `hashicorp/aws` >= 5.0
- `hashicorp/random` >= 3.0
- `hashicorp/archive` >= 2.0

### Outils Requis

- Terraform >= 1.6.0
- Docker >= 24.0
- Node.js >= 20.0
- AWS CLI >= 2.0
- jq (pour les scripts)

---

## 🐛 Résolution de Problèmes

Consultez [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) pour:

- Erreurs courantes Terraform
- Problèmes LocalStack
- Debugging Lambda
- Performance et optimisation

---

## 📜 Licence

MIT - Projet éducatif pour formation DevOps/Cloud

---

## 🌟 Prochaines Étapes

1. ⭐ **Lisez** [PLAN_DETAILLE.md](PLAN_DETAILLE.md)
2. 🚀 **Suivez** la Semaine 1 du plan
3. 💻 **Codez** et apprenez progressivement
4. ✅ **Validez** chaque étape
5. 🎓 **Maîtrisez** Terraform et l'architecture cloud !

**Bon apprentissage ! 🚀**
