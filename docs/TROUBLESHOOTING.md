# 🔧 Guide de Dépannage

Solutions aux problèmes courants rencontrés avec le projet.

---

## 🐌 Terraform Apply Très Lent avec LocalStack

### Symptômes
- `terraform apply` prend plusieurs minutes (>1 min)
- Les ressources restent en "Creating..." très longtemps
- Timeout errors

### Diagnostic
```bash
# Vérifier les logs LocalStack
docker-compose logs --tail=50 localstack

# Rechercher des erreurs comme:
# OperationNotFoundParserError: Unable to find operation for request to service s3: PUT /
```

### Solution

Le problème est causé par la configuration S3 path-style manquante.

**Ajouter dans `terraform/providers.tf` :**

```hcl
provider "aws" {
  region = var.aws_region

  # Configuration LocalStack
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  # Endpoints
  endpoints {
    s3 = var.use_localstack ? "http://s3.localhost.localstack.cloud:4566" : null
    # ... autres endpoints
  }

  # ✅ CRITIQUE: Force path-style pour S3 avec LocalStack
  s3_use_path_style = var.use_localstack

  # Credentials
  access_key = var.use_localstack ? "test" : null
  secret_key = var.use_localstack ? "test" : null
}
```

**Puis réappliquer :**
```bash
cd terraform
terraform init -upgrade
terraform apply -var-file=environments/local.tfvars
```

**Résultat attendu :** Création du bucket en < 5 secondes.

---

## 🐳 Docker Container Kafka en Exit 1

### Symptômes
```bash
docker-compose ps
# mcp-fcc-kafka   Exit 1
```

### Diagnostic
```bash
docker-compose logs kafka
```

### Solutions Possibles

#### 1. Zookeeper pas prêt
Kafka attend Zookeeper. Vérifier que Zookeeper tourne :
```bash
docker-compose ps zookeeper
docker-compose logs zookeeper
```

**Fix :**
```bash
docker-compose down
docker-compose up -d zookeeper
sleep 10
docker-compose up -d kafka
```

#### 2. Port 9092 déjà utilisé
```bash
sudo lsof -i :9092
```

**Fix :**
```bash
# Tuer le process
sudo kill -9 <PID>

# Ou changer le port dans docker-compose.yml
```

#### 3. Problème de mémoire
Kafka nécessite au moins 2GB RAM.

**Fix dans docker-compose.yml :**
```yaml
kafka:
  environment:
    KAFKA_HEAP_OPTS: "-Xmx512M -Xms512M"
```

---

## 🔌 LocalStack Health Check Échoue

### Symptômes
```bash
curl http://localhost:4566/_localstack/health
# Connection refused ou timeout
```

### Diagnostic
```bash
docker ps | grep localstack
docker-compose logs localstack
```

### Solutions

#### 1. Container pas démarré
```bash
docker-compose up -d localstack
docker-compose ps
```

#### 2. Port 4566 déjà utilisé
```bash
sudo lsof -i :4566
```

**Fix :**
```bash
sudo kill -9 <PID>
docker-compose restart localstack
```

#### 3. Attendre le démarrage complet
LocalStack prend 10-15 secondes pour démarrer.

```bash
# Attendre que le health check passe
while ! curl -s http://localhost:4566/_localstack/health > /dev/null; do
  echo "Waiting for LocalStack..."
  sleep 2
done
echo "LocalStack is ready!"
```

---

## ❌ Terraform: Error acquiring the state lock

### Symptômes
```
Error: Error acquiring the state lock
```

### Cause
Terraform a planté pendant un `apply` précédent et n'a pas relâché le lock.

### Solution
```bash
cd terraform
terraform force-unlock <LOCK_ID>

# Si ça ne marche pas (state local uniquement)
rm -f terraform.tfstate.lock.info
```

⚠️ **Attention :** Ne jamais faire ça si vous utilisez un remote state partagé en équipe !

---

## 🔐 AWS Credentials Error avec LocalStack

### Symptômes
```
Error: error configuring Terraform AWS Provider: failed to get shared config profile
```

### Solution

S'assurer que les credentials fake sont configurés :

```hcl
provider "aws" {
  # Pour LocalStack, utiliser credentials fake
  access_key = var.use_localstack ? "test" : null
  secret_key = var.use_localstack ? "test" : null
  
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack
}
```

**Alternative :** Créer un profil AWS fake

```bash
# ~/.aws/credentials
[localstack]
aws_access_key_id = test
aws_secret_access_key = test
```

```bash
export AWS_PROFILE=localstack
terraform apply
```

---

## 🚫 Lambda Function Not Found après Déploiement

### Symptômes
```bash
aws --endpoint-url=http://localhost:4566 lambda list-functions
# Lambda n'apparaît pas
```

### Diagnostic
```bash
# Voir l'état Terraform
terraform state list
terraform state show aws_lambda_function.my_function

# Logs LocalStack
docker-compose logs localstack | grep lambda
```

### Solutions

#### 1. Vérifier que le ZIP existe
```bash
ls -lh ../dist/lambdas/*.zip
```

#### 2. Reconstruire la Lambda
```bash
npm run build:lambdas
terraform apply -replace=aws_lambda_function.my_function
```

#### 3. Vérifier les logs Lambda
```bash
aws --endpoint-url=http://localhost:4566 logs tail \
  /aws/lambda/my-function --follow
```

---

## 🌐 Cannot Connect to LocalStack from Container

### Symptômes
Une Lambda ou un service dans Docker ne peut pas atteindre LocalStack.

### Cause
Utiliser `localhost` depuis un container pointe vers le container lui-même.

### Solution

**Depuis un container :**
```typescript
// ❌ MAUVAIS
const endpoint = 'http://localhost:4566';

// ✅ BON (avec docker-compose network)
const endpoint = 'http://localstack:4566';

// ✅ BON (host.docker.internal sur Mac/Windows)
const endpoint = 'http://host.docker.internal:4566';
```

**Dans Terraform (depuis votre machine) :**
```hcl
# ✅ Utiliser localhost
endpoints {
  s3 = "http://localhost:4566"
}
```

---

## 📦 Module Not Found après terraform init

### Symptômes
```
Error: Module not found
```

### Solution
```bash
cd terraform
rm -rf .terraform
terraform init
```

---

## 🔄 Resource Already Exists

### Symptômes
```
Error: resource already exists
```

### Solution

#### Option 1: Importer la ressource existante
```bash
terraform import aws_s3_bucket.my_bucket my-bucket-name
```

#### Option 2: Détruire manuellement
```bash
aws --endpoint-url=http://localhost:4566 s3 rb s3://my-bucket-name --force
terraform apply
```

#### Option 3: Nettoyer LocalStack complètement
```bash
docker-compose down -v  # -v supprime les volumes
docker-compose up -d
terraform apply
```

---

## 💾 State Corruption

### Symptômes
```
Error: state file corrupted
```

### Solution (State Local)

**Restaurer depuis backup :**
```bash
cd terraform
cp terraform.tfstate.backup terraform.tfstate
terraform state list  # Vérifier
```

**Si pas de backup :**
```bash
# Sauvegarder le state corrompu
cp terraform.tfstate terraform.tfstate.corrupted

# Supprimer et recréer
rm terraform.tfstate
terraform import <resource_type>.<name> <id>
```

⚠️ **Prévention :** Toujours utiliser un remote state en production !

---

## 🔍 Debug Mode pour Terraform

### Activer les logs détaillés
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
terraform apply

# Voir les logs
tail -f terraform.log
```

### Niveaux de log
- `TRACE` - Très verbeux
- `DEBUG` - Debug
- `INFO` - Informations
- `WARN` - Avertissements
- `ERROR` - Erreurs seulement

---

## 🧹 Reset Complet du Projet

Si tout est cassé, reset complet :

```bash
# 1. Détruire l'infrastructure Terraform
cd terraform
terraform destroy -auto-approve

# 2. Arrêter et supprimer Docker
cd ..
docker-compose down -v

# 3. Nettoyer Terraform
cd terraform
rm -rf .terraform/
rm -f terraform.tfstate*
rm -f .terraform.lock.hcl

# 4. Nettoyer build
cd ..
rm -rf dist/
rm -rf node_modules/

# 5. Tout réinstaller
npm install
npm run build:lambdas

# 6. Redémarrer
docker-compose up -d
sleep 10

# 7. Réinitialiser Terraform
cd terraform
terraform init
terraform apply -var-file=environments/local.tfvars
```

---

## 📞 Obtenir de l'Aide

### Logs à Collecter

Avant de demander de l'aide, collecter :

```bash
# Terraform
terraform version
terraform state list
terraform output

# Docker
docker-compose ps
docker-compose logs --tail=100

# LocalStack
curl http://localhost:4566/_localstack/health

# Système
df -h  # Espace disque
docker info  # Info Docker
```

### Commandes de Diagnostic

```bash
# Tout en un
cd /home/sd/Documents/Dev/ci-cd/MCP-FCC-Test

echo "=== Docker Status ==="
docker-compose ps

echo "=== LocalStack Health ==="
curl -s http://localhost:4566/_localstack/health | jq .

echo "=== Terraform State ==="
cd terraform && terraform state list

echo "=== Recent Errors ==="
docker-compose logs --tail=20 | grep -i error
```

---

## 📚 Ressources

- **[LocalStack Docs](https://docs.localstack.cloud/)**
- **[Terraform AWS Provider Issues](https://github.com/hashicorp/terraform-provider-aws/issues)**
- **[Stack Overflow - LocalStack](https://stackoverflow.com/questions/tagged/localstack)**
- **[Stack Overflow - Terraform](https://stackoverflow.com/questions/tagged/terraform)**

---

**Problème non listé ?** Consultez les logs et cherchez le message d'erreur exact sur Google/Stack Overflow.
