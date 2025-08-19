# 🚀 Self-hosted Azure DevOps Agent on Azure

Ce projet automatise la création d'un agent Azure DevOps self-hosted sur une VM Ubuntu dans Azure, avec déploiement via GitHub Actions et Terraform.

## 🎯 Fonctionnalités

- ✅ VM Ubuntu 22.04 LTS configurée automatiquement
- ✅ Agent Azure DevOps installé et configuré
- ✅ Service système pour démarrage automatique
- ✅ Déploiement automatisé via GitHub Actions
- ✅ Gestion des secrets sécurisée
- ✅ Backend Terraform distant dans Azure

## 🚀 Démarrage rapide

### 1️⃣ Prérequis

- Compte Azure avec permissions de création de ressources
- Organisation Azure DevOps
- Repository GitHub
- Azure CLI installé localement

### 2️⃣ Configuration initiale

```bash
# 1. Clonez ce repository
git clone <votre-repo>
cd azure-devops-agent

# 2. Configurez l'authentification Azure
az login

# 3. Créez le backend Terraform
./scripts/setup-terraform-backend.sh

# 4. Configurez les secrets GitHub (voir section Configuration)
```

### 3️⃣ Déploiement

1. Allez dans l'onglet **Actions** de votre repository GitHub
2. Sélectionnez le workflow **"🚀 Deploy Azure DevOps Agent"**
3. Cliquez sur **"Run workflow"**
4. Remplissez les paramètres requis
5. Lancez le déploiement

## ⚙️ Configuration

### Secrets GitHub requis

Configurez ces secrets dans **Settings > Secrets and variables > Actions** :

| Secret | Description | Exemple |
|--------|-------------|---------|
| `AZURE_CLIENT_ID` | ID client du service principal | `12345678-1234-1234-1234-123456789012` |
| `AZURE_TENANT_ID` | ID tenant Azure | `87654321-4321-4321-4321-210987654321` |
| `AZURE_SUBSCRIPTION_ID` | ID souscription Azure | `abcdef12-3456-7890-abcd-ef1234567890` |
| `ADMIN_SSH_PUBLIC_KEY` | Clé publique SSH | `ssh-rsa AAAAB3NzaC1yc2E...` |
| `AZDO_PAT` | Personal Access Token Azure DevOps | `ghp_xxxxxxxxxxxxxxxxxxxx` |
| `TF_BACKEND_RG` | Resource Group du backend Terraform | `rg-terraform-state` |
| `TF_BACKEND_SA` | Storage Account du backend | `stterraformstate123` |
| `TF_BACKEND_CONTAINER` | Container du backend | `tfstate` |

### Variables d'environnement Azure DevOps

Lors du déploiement via GitHub Actions, vous devrez fournir :

- **Organisation Azure DevOps** : Nom de votre organisation
- **Pool d'agents** : Nom du pool (Default par défaut)
- **Nom de la VM** : Nom unique pour votre agent
- **Taille de VM** : Standard_B2s recommandé
- **Utilisateur admin** : azureuser par défaut

## 🔧 Utilisation locale (optionnelle)

Si vous préférez déployer depuis votre machine locale :

```bash
# 1. Naviguez vers le dossier terraform
cd terraform

# 2. Copiez et personnalisez les variables
cp terraform.tfvars.example terraform.tfvars
# Éditez terraform.tfvars avec vos valeurs

# 3. Générez le fichier cloud-init
cd ../scripts
./selfhosted-ado-agent.sh

# 4. Déployez avec Terraform
cd ../terraform
terraform init
terraform plan
terraform apply
```

## 🔍 Vérifications post-déploiement

1. **Connexion SSH** :
   ```bash
   ssh azureuser@<IP-VM>
   ```

2. **Statut de l'agent** :
   ```bash
   sudo systemctl status vsts-agent-*
   ```

3. **Dans Azure DevOps** :
   - Allez dans Project Settings > Agent pools
   - Vérifiez que votre agent apparaît "Online"

## 🗑️ Destruction

1. Utilisez le workflow **"🗑️ Destroy Azure DevOps Agent"**
2. Tapez exactement `DESTROY` pour confirmer
3. Spécifiez le nom de la VM à supprimer

## 📚 Documentation

- [Configuration détaillée](docs/SETUP.md)
- [Guide de dépannage](docs/TROUBLESHOOTING.md)

## 🛡️ Sécurité

- Clés SSH et PAT stockés comme secrets GitHub
- Accès SSH limité par Network Security Group
- Backend Terraform sécurisé dans Azure Storage
- Authentification OIDC pour GitHub Actions

## 💰 Coûts estimés

- VM Standard_B2s : ~30€/mois
- Stockage et réseau : ~5€/mois
- **Total estimé : ~35€/mois**

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou proposer une pull request.

## 📄 Licence

MIT License - voir le fichier LICENSE pour plus de détails.
