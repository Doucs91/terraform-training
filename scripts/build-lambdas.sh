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