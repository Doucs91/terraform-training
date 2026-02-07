# 📚 Ressources et Références

Documentation et liens utiles pour chaque technologie du projet.

---

## 🏗️ Terraform

### Documentation Officielle
- **[Terraform Docs](https://developer.hashicorp.com/terraform/docs)** - Documentation complète
- **[HCL Syntax](https://developer.hashicorp.com/terraform/language/syntax/configuration)** - Langage Terraform
- **[CLI Commands](https://developer.hashicorp.com/terraform/cli/commands)** - Toutes les commandes
- **[Terraform Registry](https://registry.terraform.io/)** - Modules et providers

### Providers
- **[AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)** - Provider AWS
- **[Random Provider](https://registry.terraform.io/providers/hashicorp/random/latest/docs)** - Génération aléatoire
- **[Archive Provider](https://registry.terraform.io/providers/hashicorp/archive/latest/docs)** - Création de ZIPs

### Resources AWS
- **[aws_lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)**
- **[aws_sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue)**
- **[aws_api_gateway_rest_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api)**
- **[aws_sfn_state_machine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine)**
- **[aws_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)**

### Tutorials
- **[Get Started with Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started)**
- **[Terraform on AWS](https://developer.hashicorp.com/terraform/tutorials/aws)**
- **[Modules Tutorial](https://developer.hashicorp.com/terraform/tutorials/modules)**
- **[State Management](https://developer.hashicorp.com/terraform/tutorials/state)**

### Best Practices
- **[Terraform Best Practices](https://www.terraform-best-practices.com/)**
- **[Style Guide](https://developer.hashicorp.com/terraform/language/syntax/style)**
- **[Naming Conventions](https://www.terraform-best-practices.com/naming)**

---

## ☁️ AWS Services

### Lambda
- **[Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)**
- **[Lambda with Node.js](https://docs.aws.amazon.com/lambda/latest/dg/lambda-nodejs.html)**
- **[Lambda Event Sources](https://docs.aws.amazon.com/lambda/latest/dg/invocation-eventsourcemapping.html)**
- **[Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)**

### SQS
- **[SQS Developer Guide](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html)**
- **[SQS with Lambda](https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html)**
- **[Dead Letter Queues](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-dead-letter-queues.html)**

### Step Functions
- **[Step Functions Guide](https://docs.aws.amazon.com/step-functions/latest/dg/welcome.html)**
- **[Amazon States Language](https://states-language.net/spec.html)**
- **[Step Functions Patterns](https://docs.aws.amazon.com/step-functions/latest/dg/concepts-standard-vs-express.html)**
- **[Error Handling](https://docs.aws.amazon.com/step-functions/latest/dg/concepts-error-handling.html)**

### API Gateway
- **[API Gateway Guide](https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html)**
- **[REST API](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-rest-api.html)**
- **[Lambda Proxy Integration](https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html)**

### IAM
- **[IAM User Guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)**
- **[IAM Policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html)**
- **[IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)**

### S3
- **[S3 User Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)**
- **[S3 with Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)**

### CloudWatch
- **[CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html)**
- **[Lambda Logging](https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html)**

---

## 🔧 LocalStack

### Documentation
- **[LocalStack Docs](https://docs.localstack.cloud/)**
- **[Getting Started](https://docs.localstack.cloud/getting-started/)**
- **[AWS Service Coverage](https://docs.localstack.cloud/user-guide/aws/feature-coverage/)**
- **[Terraform with LocalStack](https://docs.localstack.cloud/user-guide/integrations/terraform/)**

### Configuration
- **[Docker Setup](https://docs.localstack.cloud/getting-started/installation/#docker)**
- **[Environment Variables](https://docs.localstack.cloud/references/configuration/)**
- **[Persistence](https://docs.localstack.cloud/references/persistence-mechanism/)**

### CLI
- **[awslocal CLI](https://github.com/localstack/awscli-local)**
- **[LocalStack CLI](https://docs.localstack.cloud/getting-started/installation/#localstack-cli)**

---

## 💻 TypeScript & Node.js

### TypeScript
- **[TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)**
- **[TypeScript for Node.js](https://nodejs.dev/en/learn/nodejs-with-typescript/)**
- **[tsconfig Reference](https://www.typescriptlang.org/tsconfig)**

### AWS SDK v3
- **[AWS SDK for JavaScript v3](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/)**
- **[SQS Client](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/client/sqs/)**
- **[Lambda Client](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/client/lambda/)**
- **[S3 Client](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/client/s3/)**
- **[Migration v2 to v3](https://docs.aws.amazon.com/sdk-for-javascript/v3/developer-guide/migrating-to-v3.html)**

### Lambda Types
- **[@types/aws-lambda](https://www.npmjs.com/package/@types/aws-lambda)**
- **[Lambda Handler Types](https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/aws-lambda)**

### Validation
- **[Zod](https://zod.dev/)** - Schema validation
- **[Zod Basics](https://zod.dev/?id=basic-usage)**

---

## 📦 Kafka

### Documentation
- **[Kafka Documentation](https://kafka.apache.org/documentation/)**
- **[Kafka Intro](https://kafka.apache.org/intro)**
- **[KafkaJS](https://kafka.js.org/)** - Kafka client pour Node.js

### KafkaJS
- **[Getting Started](https://kafka.js.org/docs/getting-started)**
- **[Producer](https://kafka.js.org/docs/producing)**
- **[Consumer](https://kafka.js.org/docs/consuming)**
- **[Admin](https://kafka.js.org/docs/admin)**

### Confluent Platform
- **[Confluent Docker Images](https://hub.docker.com/u/confluentinc)**
- **[Kafka with Docker](https://docs.confluent.io/platform/current/installation/docker/installation.html)**

---

## 🐳 Docker

### Documentation
- **[Docker Docs](https://docs.docker.com/)**
- **[Docker Compose](https://docs.docker.com/compose/)**
- **[Compose File Reference](https://docs.docker.com/compose/compose-file/)**
- **[Docker Networking](https://docs.docker.com/network/)**

### Images Utilisées
- **[LocalStack Image](https://hub.docker.com/r/localstack/localstack)**
- **[Confluent Kafka](https://hub.docker.com/r/confluentinc/cp-kafka)**
- **[Kafka UI](https://hub.docker.com/r/provectuslabs/kafka-ui)**

---

## 🧪 Testing

### Terratest
- **[Terratest](https://terratest.gruntwork.io/)**
- **[Getting Started](https://terratest.gruntwork.io/docs/getting-started/quick-start/)**
- **[Testing Terraform](https://terratest.gruntwork.io/docs/testing-best-practices/terraform/)**

### Jest
- **[Jest Documentation](https://jestjs.io/docs/getting-started)**
- **[Jest with TypeScript](https://jestjs.io/docs/getting-started#using-typescript)**

---

## 📖 Architecture & Patterns

### Event-Driven Architecture
- **[AWS Event-Driven Architecture](https://aws.amazon.com/event-driven-architecture/)**
- **[Event Sourcing Pattern](https://martinfowler.com/eaaDev/EventSourcing.html)**
- **[CQRS Pattern](https://martinfowler.com/bliki/CQRS.html)**

### Serverless
- **[AWS Serverless](https://aws.amazon.com/serverless/)**
- **[Serverless Patterns](https://serverlessland.com/patterns)**
- **[AWS Prescriptive Guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/serverless.html)**

### Microservices
- **[Microservices Patterns](https://microservices.io/patterns/index.html)**
- **[Circuit Breaker](https://martinfowler.com/bliki/CircuitBreaker.html)**
- **[Saga Pattern](https://microservices.io/patterns/data/saga.html)**

---

## 🎓 Learning Resources

### Courses
- **[Terraform Course](https://developer.hashicorp.com/terraform/tutorials)**
- **[AWS Training](https://aws.amazon.com/training/)**
- **[A Cloud Guru](https://acloudguru.com/)**

### Books
- **Terraform: Up & Running** by Yevgeniy Brikman
- **AWS Lambda in Action** by Danilo Poccia
- **Building Event-Driven Microservices** by Adam Bellemare

### Blogs
- **[HashiCorp Blog](https://www.hashicorp.com/blog)**
- **[AWS Architecture Blog](https://aws.amazon.com/blogs/architecture/)**
- **[LocalStack Blog](https://localstack.cloud/blog)**

---

## 🛠️ Tools

### CLI Tools
- **[Terraform](https://developer.hashicorp.com/terraform/install)**
- **[AWS CLI](https://aws.amazon.com/cli/)**
- **[awslocal](https://github.com/localstack/awscli-local)** - AWS CLI pour LocalStack
- **[jq](https://jqlang.github.io/jq/)** - JSON processor

### VS Code Extensions
- **[Terraform](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)** by HashiCorp
- **[AWS Toolkit](https://marketplace.visualstudio.com/items?itemName=AmazonWebServices.aws-toolkit-vscode)**
- **[Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)**

### Visualization
- **[Terraform Graph](https://developer.hashicorp.com/terraform/cli/commands/graph)**
- **[Graphviz](https://graphviz.org/)** - Pour visualiser le graph

---

## 🔍 Debugging & Troubleshooting

### Terraform Debugging
```bash
# Logs détaillés
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform.log
terraform apply

# Graphe de dépendances
terraform graph | dot -Tpng > graph.png
```

### LocalStack Debugging
```bash
# Logs LocalStack
docker-compose logs -f localstack

# Health check
curl http://localhost:4566/_localstack/health

# Liste des ressources
aws --endpoint-url=http://localhost:4566 lambda list-functions
```

### Lambda Debugging
```bash
# Logs CloudWatch
aws --endpoint-url=http://localhost:4566 logs tail \
  /aws/lambda/function-name --follow

# Invoke avec payload de test
aws --endpoint-url=http://localhost:4566 lambda invoke \
  --function-name my-function \
  --payload '{"test": "data"}' \
  response.json
```

---

## 🌐 Community

### Forums & Q&A
- **[Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-core/27)**
- **[AWS Forums](https://forums.aws.amazon.com/)**
- **[Stack Overflow - Terraform](https://stackoverflow.com/questions/tagged/terraform)**
- **[Stack Overflow - AWS Lambda](https://stackoverflow.com/questions/tagged/aws-lambda)**

### Slack/Discord
- **[LocalStack Slack](https://localstack.cloud/contact/)**
- **[HashiCorp Community](https://discuss.hashicorp.com/)**

### GitHub
- **[Terraform GitHub](https://github.com/hashicorp/terraform)**
- **[LocalStack GitHub](https://github.com/localstack/localstack)**
- **[AWS Terraform Provider](https://github.com/hashicorp/terraform-provider-aws)**

---

## 📋 Checklists

### Pre-Development
- [ ] Terraform installé (>= 1.6.0)
- [ ] Docker installé et running
- [ ] Node.js installé (>= 20.0.0)
- [ ] AWS CLI installé
- [ ] VS Code avec extensions recommandées

### Before Commit
- [ ] `terraform fmt -recursive`
- [ ] `terraform validate`
- [ ] `terraform plan` passe
- [ ] Tests passent
- [ ] Documentation mise à jour

### Before Deployment
- [ ] Code reviewed
- [ ] Tests d'intégration passent
- [ ] Terraform plan vérifié
- [ ] Backup du state (si prod)
- [ ] Rollback plan en place

---

**Utilisez ces ressources tout au long de votre apprentissage ! 📚**
