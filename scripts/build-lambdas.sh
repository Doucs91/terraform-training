#!/bin/bash
set -e

echo "🏗️  Building Lambda functions..."

# Créer le dossier de build
mkdir -p dist/lambdas

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

# Build submit-transaction Lambda
echo "Building submit-transaction..."
npx esbuild src/lambdas/submit-transaction/index.ts \
  --bundle \
  --platform=node \
  --target=node20 \
  --outfile=dist/lambdas/submit-transaction/index.js \
  --external:@aws-sdk/*

cd dist/lambdas/submit-transaction
zip -r ../submit-transaction.zip .
cd -

echo "✅ Lambda functions built successfully!"
echo "📦 Packages disponibles dans dist/lambdas/"