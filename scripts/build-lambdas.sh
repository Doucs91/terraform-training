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
