# 📚 Concepts Clés du Projet

> Guide conceptuel pour comprendre les technologies et patterns utilisés

---

## 🏗️ Infrastructure as Code (IaC)

### Qu'est-ce que c'est?

L'Infrastructure as Code est l'approche de gestion de l'infrastructure via du code au lieu de processus manuels.

### Avant IaC (Approche Manuelle)

```
1. Se connecter à la console AWS
2. Cliquer pour créer une Lambda
3. Configurer manuellement les paramètres
4. Créer une SQS queue à la main
5. Connecter manuellement Lambda à SQS
6. Documenter ce qu'on a fait (peut-être)
```

**Problèmes:**
- ❌ Pas reproductible
- ❌ Erreurs humaines
- ❌ Pas de traçabilité
- ❌ Impossible à versionner
- ❌ Difficile à collaborer
- ❌ Pas de review process

### Avec IaC (Terraform)

```hcl
resource "aws_lambda_function" "processor" {
  function_name = "process-transaction"
  runtime       = "nodejs20.x"
  # ...
}

resource "aws_sqs_queue" "transactions" {
  name = "transactions-queue"
}

resource "aws_lambda_event_source_mapping" "trigger" {
  event_source_arn = aws_sqs_queue.transactions.arn
  function_name    = aws_lambda_function.processor.arn
}
```

**Avantages:**
- ✅ Reproductible (même code = même infra)
- ✅ Versionné dans Git
- ✅ Review via Pull Requests
- ✅ Documenté automatiquement
- ✅ Testable
- ✅ Collaboration facile

---

## ☁️ Architecture Event-Driven

### Concept

Architecture où les composants communiquent via des **événements** plutôt que des appels directs.

### Architecture Monolithique (Traditionnelle)

```
Client → API → Service A → Service B → Service C → Database
         (appels synchrones, couplage fort)
```

**Problèmes:**
- Si Service B est down, tout casse
- Difficile à scaler
- Un bug se propage partout
- Déploiements risqués

### Architecture Event-Driven (Notre Projet)

```
Client → API Gateway → SQS → Lambda Validate → Kafka
                                                  ↓
                                            Step Functions
                                                  ↓
                                    ┌─────────┬───────┬────────┐
                                    ↓         ↓       ↓        ↓
                                  Fraud    Notif  Archive  Autre
```

**Avantages:**
- ✅ Découplage total (services indépendants)
- ✅ Résilience (un service down n'affecte pas les autres)
- ✅ Scalabilité (chaque service scale indépendamment)
- ✅ Asynchrone (pas d'attente)
- ✅ Extensible (ajouter de nouveaux consumers facilement)

### Patterns Event-Driven

#### 1. **Publish-Subscribe (Pub/Sub)**

Un producteur publie des événements, plusieurs consumers les reçoivent.

```
Producer → Kafka Topic → Consumer 1 (Fraud Detection)
                      → Consumer 2 (Notification)
                      → Consumer 3 (Analytics)
```

#### 2. **Queue-Based (FIFO)**

Messages traités dans l'ordre par un seul consumer à la fois.

```
API → SQS Queue → Lambda (un message à la fois)
```

#### 3. **Event Sourcing**

Stocker tous les changements d'état comme une séquence d'événements.

```
Transaction Created → Transaction Validated → Transaction Processed
(chaque étape = événement permanent)
```

---

## 🔄 Workflow du Projet

### Flow Complet d'une Transaction

```
1. Client HTTP Request
   ↓
2. API Gateway (endpoint REST)
   ↓
3. Lambda Submit Transaction (validation, enrichissement)
   ↓
4. SQS Queue (découplage)
   ↓
5. Lambda Process Transaction (traitement)
   ↓
6. Kafka Topic (distribution)
   ↓
7. Step Functions (orchestration)
   ↓
8. Lambdas Parallèles:
   - Fraud Detection (analyse)
   - Send Notification (email/SMS)
   - Archive Transaction (S3)
   ↓
9. Response au client (async)
```

### Avantages de ce Flow

**Découplage:**
- API ne connaît que SQS
- Lambda ne connaît que Kafka
- Chaque composant est remplaçable

**Résilience:**
- SQS garde les messages si Lambda est down
- DLQ pour les messages en échec
- Retry automatique

**Scalabilité:**
- API Gateway scale automatiquement
- Lambda scale avec la charge
- SQS buffer les pics de charge

---

## 🎭 Services AWS Utilisés

### Lambda Functions

**C'est quoi?** Code qui s'exécute en réponse à des événements.

**Cas d'usage dans ce projet:**
- Submit Transaction (trigger: API Gateway)
- Process Transaction (trigger: SQS)
- Detect Fraud (trigger: Kafka via Step Functions)
- Send Notification (trigger: Step Functions)

**Avantages:**
- Pas de serveur à gérer
- Pay-per-use (gratuit jusqu'à 1M requêtes/mois)
- Scale automatique
- Intégration native avec autres services AWS

### SQS (Simple Queue Service)

**C'est quoi?** File d'attente de messages distribuée.

**Cas d'usage:**
- Buffer entre API et Lambda
- Gérer les pics de charge
- Dead Letter Queue pour messages en échec

**Patterns:**
```
Standard Queue: Livraison au moins une fois, ordre approximatif
FIFO Queue: Livraison exactement une fois, ordre strict
```

### Step Functions

**C'est quoi?** Orchestrateur de workflows serverless.

**Cas d'usage:**
- Coordonner plusieurs Lambdas
- Workflows complexes avec conditions
- Gestion d'erreurs et retries
- Workflows long-running

**Exemple de workflow:**
```json
{
  "StartAt": "FraudDetection",
  "States": {
    "FraudDetection": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:detect-fraud",
      "Next": "IsFraud?"
    },
    "IsFraud?": {
      "Type": "Choice",
      "Choices": [{
        "Variable": "$.isFraud",
        "BooleanEquals": true,
        "Next": "RejectTransaction"
      }],
      "Default": "ApproveTransaction"
    },
    "ApproveTransaction": {
      "Type": "Parallel",
      "Branches": [
        { "StartAt": "SendNotification", ... },
        { "StartAt": "ArchiveTransaction", ... }
      ],
      "End": true
    }
  }
}
```

### API Gateway

**C'est quoi?** Porte d'entrée pour vos APIs REST/WebSocket.

**Features:**
- Routing HTTP
- Rate limiting
- Authentication (IAM, Cognito, Lambda authorizers)
- CORS
- Caching
- Transformation de requêtes/réponses

### S3 (Simple Storage Service)

**C'est quoi?** Stockage d'objets (fichiers).

**Cas d'usage:**
- Archives des transactions
- Logs
- Terraform State (remote backend)

---

## 🔐 IAM (Identity & Access Management)

### Concept

IAM gère **qui** peut faire **quoi** sur **quelles ressources**.

### Components

**1. Roles**
```hcl
resource "aws_iam_role" "lambda_role" {
  name = "lambda-processor-role"
  
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}
```

**2. Policies**
```hcl
resource "aws_iam_role_policy" "lambda_sqs_policy" {
  role = aws_iam_role.lambda_role.id
  
  policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage"
      ]
      Resource = aws_sqs_queue.transactions.arn
    }]
  })
}
```

### Principe du Moindre Privilège

Donner uniquement les permissions nécessaires, rien de plus.

```hcl
# ❌ MAUVAIS: Trop de permissions
Action = ["sqs:*"]

# ✅ BON: Permissions spécifiques
Action = [
  "sqs:ReceiveMessage",
  "sqs:DeleteMessage"
]
```

---

## 📦 Kafka (Event Streaming)

### C'est quoi?

Kafka est une plateforme de streaming d'événements distribuée.

### Concepts Clés

**Topics:** Catégories pour organiser les événements
```
transactions-validated
fraud-alerts
notifications
```

**Partitions:** Division d'un topic pour parallélisme
```
Topic: transactions-validated
├── Partition 0 (messages 0, 3, 6, 9...)
├── Partition 1 (messages 1, 4, 7, 10...)
└── Partition 2 (messages 2, 5, 8, 11...)
```

**Producers:** Publient des événements
```typescript
await producer.send({
  topic: 'transactions-validated',
  messages: [{ value: JSON.stringify(transaction) }]
});
```

**Consumers:** Lisent les événements
```typescript
await consumer.subscribe({ topic: 'transactions-validated' });
await consumer.run({
  eachMessage: async ({ message }) => {
    const transaction = JSON.parse(message.value);
    await processTransaction(transaction);
  }
});
```

### Avantages

- ✅ Haut débit (millions d'événements/seconde)
- ✅ Persistance (événements stockés)
- ✅ Replay possible (relire des événements passés)
- ✅ Multiple consumers indépendants

### Dans ce Projet

```
Lambda Validate → Kafka Topic → Step Functions
                              → Lambda Analytics
                              → Lambda Audit
```

---

## 🧪 LocalStack

### C'est quoi?

LocalStack émule les services AWS localement, sans frais.

### Services Supportés

- ✅ Lambda
- ✅ SQS
- ✅ S3
- ✅ DynamoDB
- ✅ Step Functions
- ✅ API Gateway
- ✅ CloudWatch
- ⚠️ Pas tous les services AWS (80% environ)

### Pourquoi LocalStack?

**Développement:**
- Pas de frais AWS
- Rapide (local)
- Pas besoin d'Internet
- Itération rapide

**Tests:**
- Isolation complète
- Reproductible
- Nettoyage facile (restart container)

**Limitations:**
- Quelques bugs
- Pas 100% identique à AWS
- Certaines features manquantes

### Configuration

```yaml
# docker-compose.yml
services:
  localstack:
    image: localstack/localstack:latest
    ports:
      - "4566:4566"
    environment:
      - SERVICES=lambda,sqs,s3,stepfunctions
      - DEBUG=1
```

```hcl
# Terraform provider
provider "aws" {
  endpoints {
    lambda = "http://localhost:4566"
    sqs    = "http://localhost:4566"
  }
  
  access_key = "test"  # Fake credentials
  secret_key = "test"
}
```

---

## 🎯 Patterns & Best Practices

### 1. Idempotence

Une opération est **idempotente** si l'exécuter plusieurs fois donne le même résultat.

```typescript
// ❌ NON IDEMPOTENT
async function processTransaction(txn) {
  balance += txn.amount;  // Rejouer = mauvais résultat
}

// ✅ IDEMPOTENT
async function processTransaction(txn) {
  const existing = await getTransaction(txn.id);
  if (existing) return;  // Déjà traité
  
  balance += txn.amount;
  await saveTransaction(txn);
}
```

### 2. Circuit Breaker

Éviter d'appeler un service qui est down.

```typescript
class CircuitBreaker {
  async call(fn) {
    if (this.isOpen()) {
      throw new Error('Circuit is open');
    }
    
    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
}
```

### 3. Retry avec Backoff Exponentiel

```typescript
async function retryWithBackoff(fn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      
      const delay = Math.pow(2, i) * 1000;  // 1s, 2s, 4s
      await sleep(delay);
    }
  }
}
```

### 4. Dead Letter Queue (DLQ)

Queue pour les messages qui ont échoué après N tentatives.

```
Message → Queue principale
          ↓ (3 échecs)
          DLQ (pour analyse)
```

---

## 📊 Comparaison des Approches

### Terraform vs Scripts Bash

| Aspect | Terraform | Scripts Bash |
|--------|-----------|--------------|
| **Déclaratif** | ✅ Oui | ❌ Impératif |
| **Idempotent** | ✅ Oui | ⚠️ Dépend |
| **State Tracking** | ✅ Oui | ❌ Non |
| **Dépendances** | ✅ Auto | ❌ Manuel |
| **Preview** | ✅ terraform plan | ❌ Non |
| **Rollback** | ✅ Facile | ❌ Difficile |

### Lambda vs EC2

| Aspect | Lambda | EC2 |
|--------|--------|-----|
| **Gestion serveur** | ✅ Aucune | ❌ Totale |
| **Scaling** | ✅ Auto | ⚠️ Manuel |
| **Coût** | ✅ Pay-per-use | ⚠️ Always on |
| **Cold start** | ⚠️ Oui (< 1s) | ✅ Non |
| **Durée max** | ⚠️ 15 min | ✅ Illimitée |
| **Use case** | Event-driven | Long-running |

### SQS vs Kafka

| Aspect | SQS | Kafka |
|--------|-----|-------|
| **Managed** | ✅ Fully | ⚠️ Self-hosted |
| **Débit** | ⚠️ Moyen | ✅ Très haut |
| **Persistance** | ⚠️ Limitée | ✅ Configurable |
| **Replay** | ❌ Non | ✅ Oui |
| **Complexité** | ✅ Simple | ⚠️ Complexe |
| **Coût** | ✅ Low | ⚠️ Infrastructure |

---

## 🎓 Termes Importants

**API Gateway:** Porte d'entrée HTTP pour vos APIs

**ARN:** Amazon Resource Name (identifiant unique)

**ASL:** Amazon States Language (pour Step Functions)

**Backend:** Où Terraform stocke son state

**Cold Start:** Délai de démarrage d'une Lambda

**DLQ:** Dead Letter Queue (queue pour messages en échec)

**Event Source Mapping:** Connexion entre event source (SQS) et Lambda

**HCL:** HashiCorp Configuration Language (langage de Terraform)

**IaC:** Infrastructure as Code

**Idempotent:** Peut être exécuté plusieurs fois sans effet différent

**Lambda Layer:** Code partagé entre Lambdas

**Module:** Groupe réutilisable de ressources Terraform

**Provider:** Plugin Terraform pour un service (AWS, Azure, etc.)

**Resource:** Composant d'infrastructure (Lambda, SQS, etc.)

**Serverless:** Architecture sans gestion de serveurs

**State:** Fichier contenant l'état actuel de l'infrastructure

**Step Functions:** Service d'orchestration de workflows

**Terraform:** Outil Infrastructure as Code

**VPC:** Virtual Private Cloud (réseau isolé)

**Workspace:** Environnement Terraform isolé (dev, staging, prod)

---

**Maintenant que vous comprenez les concepts, passez au [PLAN_DETAILLE.md](../PLAN_DETAILLE.md) ! 🚀**
