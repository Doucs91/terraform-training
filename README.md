# MCP-FCC-Test

Projet de simulation de transactions financières avec détection de fraude utilisant AWS Lambda, SQS, Kafka et LocalStack pour le développement local.

## Architecture

- **API Gateway** → Point d'entrée pour soumettre des transactions
- **SQS** → Queue pour le traitement asynchrone des transactions
- **Lambda Functions** → Traitement des transactions et détection de fraude
- **Kafka** → Event streaming pour la publication des événements de transaction
- **LocalStack** → Émulation des services AWS en local
- **Docker Compose** → Orchestration des services (LocalStack, Kafka, Zookeeper, Kafka UI)

## Prérequis

- Node.js 18+
- Docker et Docker Compose
- Terraform 1.0+
- AWS CLI configuré (ou LocalStack)
- npm ou yarn

## Installation et Lancement

### 1. Cloner le projet et installer les dépendances

```bash
cd /home/sd/Documents/Dev/ci-cd/MCP-FCC-Test
npm install
```

### 2. Lancer les conteneurs Docker

Démarrer LocalStack, Kafka, Zookeeper et Kafka UI :

```bash
docker-compose up -d
```

Vérifier que tous les services sont démarrés :

```bash
docker-compose ps
```

Vous devriez voir 4 services en cours d'exécution :
- `localstack` (port 4566)
- `zookeeper` (port 2181)
- `kafka` (ports 9092/9093)
- `kafka-ui` (port 8080)

### 3. Builder les Lambdas

Compiler et packager les fonctions Lambda :

```bash
npm run build:lambdas
```

Les fichiers ZIP des Lambdas seront créés dans `build/lambdas/` :
- `submit-transaction.zip`
- `process-transaction.zip`

### 4. Déployer l'infrastructure avec Terraform

Initialiser Terraform :

```bash
cd terraform
terraform init
```

Déployer l'infrastructure sur LocalStack :

```bash
terraform apply -auto-approve
```

Récupérer l'URL de l'API Gateway :

```bash
terraform output api_endpoint
```

Exemple de sortie : `http://localhost:4566/restapis/abc123/dev/_user_request_`

### 5. Créer les topics Kafka

Exécuter le script de création des topics :

```bash
cd ..
node scripts/create-kafka-topics.js
```

Les topics suivants seront créés :
- `transactions-events` (3 partitions, rétention 7 jours)
- `fraud-alerts` (2 partitions)
- `notifications` (2 partitions)

Vérifier dans Kafka UI : http://localhost:8080

### 6. Tester avec Postman

#### A. Soumettre une transaction

**Méthode** : POST  
**URL** : `<API_ENDPOINT>/transactions` (remplacer par l'output de Terraform)  
**Headers** :
```
Content-Type: application/json
```

**Body** (JSON) :
```json
{
  "amount": 150.50,
  "currency": "EUR",
  "merchantId": "merchant-123",
  "userId": "user-456"
}
```

**Réponse attendue** (200 OK) :
```json
{
  "message": "Transaction submitted successfully",
  "transactionId": "uuid-generated",
  "status": "pending"
}
```

#### B. Vérifier le traitement

1. **SQS Queue** - Vérifier que le message a été traité :
```bash
aws --endpoint-url=http://localhost:4566 sqs get-queue-attributes \
  --queue-url $(terraform output -raw transactions_queue_url) \
  --attribute-names ApproximateNumberOfMessages
```

2. **Kafka UI** - Vérifier les événements dans http://localhost:8080
   - Aller dans "Topics" → "transactions-events"
   - Vérifier les messages publiés

3. **CloudWatch Logs** - Vérifier les logs Lambda :
```bash
aws --endpoint-url=http://localhost:4566 logs tail /aws/lambda/process-transaction-dev --follow
```

#### C. Test de transaction frauduleuse

**Body** (montant élevé pour déclencher l'alerte) :
```json
{
  "amount": 15000.00,
  "currency": "USD",
  "merchantId": "merchant-999",
  "userId": "user-suspicious"
}
```

Vérifier le topic `fraud-alerts` dans Kafka UI.

## Scripts disponibles

```bash
# Builder les Lambdas
npm run build

# Lancer le consumer Kafka (transactions-events)
npm run consumer:transactions

# Tester LocalStack
scripts/test-local.sh

# Déployer un Lambda spécifique
scripts/deploy-lambda.sh process-transaction
```

## Monitoring

- **Kafka UI** : http://localhost:8080
- **LocalStack Dashboard** : http://localhost:4566/_localstack/health
- **CloudWatch Logs** : Via AWS CLI avec endpoint LocalStack

## Nettoyage

Détruire l'infrastructure Terraform :

```bash
cd terraform
terraform destroy -auto-approve
```

Arrêter les conteneurs Docker :

```bash
docker-compose down
```

Supprimer les volumes (attention, supprime les données) :

```bash
docker-compose down -v
```

## Troubleshooting

### Les conteneurs ne démarrent pas

```bash
docker-compose logs
```

### Terraform échoue à créer les ressources

Vérifier que LocalStack est démarré :
```bash
curl http://localhost:4566/_localstack/health
```

### Les topics Kafka ne sont pas créés

Attendre 30 secondes après `docker-compose up` puis relancer :
```bash
node scripts/create-kafka-topics.js
```

### L'API Gateway ne répond pas

Vérifier l'URL avec :
```bash
cd terraform
terraform output api_endpoint
```

Tester l'endpoint :
```bash
curl -X POST <API_ENDPOINT>/transactions \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "currency": "EUR", "merchantId": "m1", "userId": "u1"}'
```

