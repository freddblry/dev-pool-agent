#!/bin/bash

#======================================================================
# Configuration du backend Terraform dans Azure
#======================================================================
# Ce script crée les ressources Azure nécessaires pour stocker
# l'état Terraform de manière sécurisée
#======================================================================

set -euo pipefail

echo "🏗️ Configuration du backend Terraform Azure"
echo "============================================"

# Variables de configuration
RESOURCE_GROUP_NAME="rg-terraform-state"
STORAGE_ACCOUNT_NAME="stterraform$(date +%s | tail -c 6)"  # Nom unique
CONTAINER_NAME="tfstate"
LOCATION="West Europe"

echo "📋 Configuration :"
echo "  Resource Group : $RESOURCE_GROUP_NAME"
echo "  Storage Account : $STORAGE_ACCOUNT_NAME"
echo "  Container : $CONTAINER_NAME"
echo "  Location : $LOCATION"
echo ""

# Vérification de la connexion Azure
echo "🔍 Vérification de la connexion Azure..."
if ! az account show &>/dev/null; then
    echo "❌ Non connecté à Azure. Exécutez 'az login' d'abord."
    exit 1
fi

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "✅ Connecté à la souscription : $SUBSCRIPTION_ID"

# Création du Resource Group
echo "📁 Création du Resource Group..."
az group create \
  --name "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --tags Environment=terraform Backend=true ManagedBy=script

# Création du Storage Account
echo "💾 Création du Storage Account..."
az storage account create \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --name "$STORAGE_ACCOUNT_NAME" \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true \
  --kind StorageV2 \
  --access-tier Hot \
  --tags Environment=terraform Backend=true

# Création du container
echo "📦 Création du container..."
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --public-access off

echo ""
echo "✅ Backend Terraform configuré avec succès !"
echo ""
echo "📋 SECRETS GITHUB À CONFIGURER :"
echo "================================"
echo "TF_BACKEND_RG=$RESOURCE_GROUP_NAME"
echo "TF_BACKEND_SA=$STORAGE_ACCOUNT_NAME"
echo "TF_BACKEND_CONTAINER=$CONTAINER_NAME"
echo ""
echo "💡 Ajoutez ces valeurs dans les secrets GitHub de votre repository."
