#!/bin/bash
set -e

echo "🏗️  Building Lambda functions..."

# Créer le dossier de build
mkdir -p dist/lambdas

# Compter le nombre de lambdas
lambda_count=0

# Parcourir tous les dossiers dans src/lambdas/
for lambda_dir in src/lambdas/*/; do
  # Extraire le nom du lambda (enlever le chemin et le slash final)
  lambda_name=$(basename "$lambda_dir")
  
  # Vérifier si index.ts existe
  if [ ! -f "$lambda_dir/index.ts" ]; then
    echo "⚠️  Skipping $lambda_name (no index.ts found)"
    continue
  fi
  
  echo "📦 Building $lambda_name..."
  
  # Build avec esbuild
  npx esbuild "src/lambdas/$lambda_name/index.ts" \
    --bundle \
    --platform=node \
    --target=node20 \
    --outfile="dist/lambdas/$lambda_name/index.js" \
    --external:@aws-sdk/*
  
  # Créer le ZIP
  cd "dist/lambdas/$lambda_name"
  zip -r "../$lambda_name.zip" . > /dev/null
  cd - > /dev/null
  
  lambda_count=$((lambda_count + 1))
  echo "✅ $lambda_name built successfully"
done

echo ""
echo "🎉 $lambda_count Lambda function(s) built successfully!"
echo "📦 Packages disponibles dans dist/lambdas/"
ls -lh dist/lambdas/*.zip 2>/dev/null | awk '{print "   - " $9 " (" $5 ")"}'