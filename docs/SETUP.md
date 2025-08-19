# 📖 Guide de configuration détaillé

## 🎯 Vue d'ensemble

Ce guide vous accompagne pas à pas dans la configuration complète d'un agent Azure DevOps self-hosted sur Azure.

## 1️⃣ Prérequis

### Comptes et accès
- ✅ Compte Azure avec permissions Owner ou Contributor
- ✅ Organisation Azure DevOps
- ✅ Repository GitHub
- ✅ Azure CLI installé et configuré

### Outils locaux
```bash
# Installation Azure CLI (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Installation Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

## 2️⃣ Configuration Azure

### Connexion et souscription
```bash
# Connexion à Azure
az login

# Listez vos souscriptions
az account list --output table

# Sélectionnez la bonne souscription
az account set --subscription "nom-ou-id-souscription"
```

### Création du Service Principal pour GitHub Actions
```bash
# Création du service principal avec OIDC
az ad sp create-for-rbac \
  --name "sp-github-ado-agent" \
  --role "Contributor" \
  --scopes "/subscriptions/$(az account show --query id -o tsv)" \
  --sdk-auth false

# Notez les valeurs retournées pour les secrets GitHub
```

### Configuration OIDC pour GitHub
```bash
# Récupération de l'Object ID du service principal
SP_OBJECT_ID=$(az ad sp list --display-name "sp-github-ado-agent" --query "[0].id" -o tsv)

# Configuration des federated credentials
az ad app federated-credential create \
  --id $(az ad sp show --id $SP_OBJECT_ID --query appId -o tsv) \
  --parameters '{
    "name": "github-ado-agent",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:VOTRE-USERNAME/VOTRE-REPO:environment:production",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

## 3️⃣ Configuration Azure DevOps

### Création du Personal Access Token (PAT)
1. Allez dans Azure DevOps > User Settings > Personal Access Tokens
2. Créez un nouveau token avec les permissions :
   - **Agent Pools** : Read & manage
   - **Deployment Groups** : Read & manage (optionnel)
3. Notez le token généré (il ne sera plus visible)

### Vérification du pool d'agents
1. Allez dans Project Settings > Agent pools
2. Vérifiez que le pool existe (créez-le si nécessaire)
3. Notez le nom exact du pool

## 4️⃣ Configuration GitHub

### Secrets repository
Configurez ces secrets dans **Settings > Secrets and variables > Actions** :

```
AZURE_CLIENT_ID=12345678-1234-1234-1234-123456789012
AZURE_TENANT_ID=87654321-4321-4321-4321-210987654321
AZURE_SUBSCRIPTION_ID=abcdef12-3456-7890-abcd-ef1234567890
ADMIN_SSH_PUBLIC_KEY=ssh-rsa AAAAB3NzaC1yc2E...
AZDO_PAT=your-azure-devops-pat-token
TF_BACKEND_RG=rg-terraform-state
TF_BACKEND_SA=stterraformXXXXXX
TF_BACKEND_CONTAINER=tfstate
```

### Environnements GitHub
1. Allez dans **Settings > Environments**
2. Créez un environnement nommé **"production"**
3. Configurez les protection rules si nécessaire

## 5️⃣ Configuration du backend Terraform

```bash
# Exécutez le script de configuration
./scripts/setup-terraform-backend.sh

# Notez les valeurs retournées pour les secrets GitHub
```

## 6️⃣ Premier déploiement

1. **Via GitHub Actions** (recommandé) :
   - Allez dans Actions > "🚀 Deploy Azure DevOps Agent"
   - Cliquez "Run workflow"
   - Remplissez les paramètres
   - Lancez

2. **Via ligne de commande** :
   ```bash
   # Génération du cloud-init
   cd scripts
   export ADMIN_SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"
   export AZDO_ORG="votre-org"
   export AZDO_PAT="votre-pat"
   export AZDO_AGENT_POOL="Default"
   export VM_NAME="ado-agent-vm"
   export VM_USER="azureuser"
   ./generate-cloud-init.sh
   
   # Déploiement Terraform
   cd ../terraform
   terraform init [paramètres backend]
   terraform plan
   terraform apply
   ```

## 7️⃣ Vérification

### Test de connexion
```bash
# Récupérez l'IP publique
terraform output public_ip_address

# Testez la connexion SSH
ssh azureuser@<IP-PUBLIQUE>
```

### Vérification de l'agent
```bash
# Sur la VM
sudo systemctl status vsts-agent-*
sudo journalctl -u vsts-agent-* -f
```

### Dans Azure DevOps
- Vérifiez que l'agent apparaît "Online" dans le pool

## 🔧 Personnalisation

### Modification de la taille de VM
Éditez les options dans `.github/workflows/deploy.yml` :
```yaml
options:
  - Standard_B1s    # 1 vCPU, 1 GB RAM
  - Standard_B2s    # 2 vCPU, 4 GB RAM
  - Standard_B4ms   # 4 vCPU, 16 GB RAM
  - Standard_D2s_v3 # 2 vCPU, 8 GB RAM
```

### Ajout de logiciels supplémentaires
Modifiez le fichier `scripts/generate-cloud-init.sh` section `packages`.

### Configuration réseau
Modifiez `terraform/main.tf` pour ajuster les règles NSG selon vos besoins.
