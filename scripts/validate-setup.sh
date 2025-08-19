#!/bin/bash

#======================================================================
# Script de validation de la configuration
#======================================================================
# Vérifie que tous les prérequis sont en place avant le déploiement
#======================================================================

set -euo pipefail

echo "🔍 Validation de la configuration du projet"
echo "==========================================="

# Vérification des outils requis
tools=("az" "terraform" "git" "ssh-keygen")
missing_tools=()

for tool in "${tools[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        missing_tools+=("$tool")
    fi
done

if [ ${#missing_tools[@]} -ne 0 ]; then
    echo "❌ Outils manquants : ${missing_tools[*]}"
    echo "Installez-les avant de continuer."
    exit 1
fi

echo "✅ Tous les outils requis sont installés"

# Vérification de la connexion Azure
echo "🔍 Vérification de la connexion Azure..."
if ! az account show &>/dev/null; then
    echo "❌ Non connecté à Azure. Exécutez 'az login'"
    exit 1
fi

echo "✅ Connecté à Azure"

# Vérification des clés SSH
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "⚠️ Aucune clé SSH trouvée. Génération d'une nouvelle clé..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo "✅ Clé SSH générée : ~/.ssh/id_rsa.pub"
else
    echo "✅ Clé SSH existante trouvée"
fi

# Affichage de la clé publique
echo ""
echo "🔑 CLÉPUBLIQUE SSH À AJOUTER DANS LES SECRETS GITHUB :"
echo "======================================================"
cat ~/.ssh/id_rsa.pub
echo ""

echo "🎯 Configuration validée ! Vous pouvez maintenant :"
echo "1. Configurer les secrets GitHub"
echo "2. Lancer le workflow de déploiement"
