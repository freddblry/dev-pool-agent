# 🛠️ Guide de dépannage

## ❌ Problèmes courants et solutions

### 1. L'agent n'apparaît pas en ligne dans Azure DevOps

**Symptômes :**
- L'agent n'est pas visible dans le pool
- Statut "Offline" dans Azure DevOps

**Solutions :**
```bash
# Vérifiez les logs cloud-init
sudo cat /var/log/cloud-init-output.log | grep -A 20 -B 5 "ERROR\|FAIL"

# Vérifiez le service agent
sudo systemctl status vsts-agent-*
sudo journalctl -u vsts-agent-* -n 50

# Testez la connectivité Azure DevOps
curl -I https://dev.azure.com/VOTRE-ORG

# Vérifiez la configuration de l'agent
cd /opt/azuredevops-agent
sudo -u azureuser ./config.sh remove
sudo -u azureuser ./config.sh  # Reconfiguration interactive
```

### 2. Échec de connexion SSH

**Symptômes :**
- `Connection refused` ou `Permission denied`
- Timeout de connexion

**Solutions :**
```bash
# Vérifiez l'IP publique
az vm show -d -g RESOURCE-GROUP -n VM-NAME --query publicIps -o tsv

# Testez la connectivité réseau
nc -zv IP-PUBLIQUE 22

# Vérifiez les règles NSG
az network nsg rule list --resource-group RESOURCE-GROUP --nsg-name nsg-VM-NAME

# Debug SSH avec verbosité
ssh -v azureuser@IP-PUBLIQUE
```

### 3. Erreurs Terraform

**Symptômes :**
- Échec lors de `terraform plan` ou `apply`
- Erreurs de provider ou de backend

**Solutions :**
```bash
# Réinitialisez Terraform
terraform init -reconfigure

# Vérifiez la configuration du backend
az storage account show --name STORAGE-ACCOUNT --resource-group RESOURCE-GROUP

# Debug avec logs détaillés
export TF_LOG=DEBUG
terraform plan
```

### 4. Problèmes GitHub Actions

**Symptômes :**
- Échec d'authentification Azure
- Erreurs de permissions

**Solutions :**
1. Vérifiez les secrets GitHub
2. Vérifiez la configuration OIDC :
   ```bash
   # Listez les federated credentials
   az ad app federated-credential list --id CLIENT-ID
   ```
3. Vérifiez les permissions du service principal :
   ```bash
   az role assignment list --assignee CLIENT-ID
   ```

### 5. Agent déconnecté fréquemment

**Causes possibles :**
- VM sous-dimensionnée
- Problèmes réseau
- Mises à jour système

**Solutions :**
```bash
# Vérifiez les ressources système
htop
df -h
free -h

# Vérifiez les logs système
sudo journalctl -f

# Redémarrez l'agent
cd /opt/azuredevops-agent
sudo ./svc.sh restart
```

### 6. Échec cloud-init

**Symptômes :**
- VM créée mais agent non configuré
- Erreurs dans les logs cloud-init

**Solutions :**
```bash
# Vérifiez le statut cloud-init
sudo cloud-init status

# Consultez les logs détaillés
sudo cat /var/log/cloud-init.log
sudo cat /var/log/cloud-init-output.log

# Relancez cloud-init manuellement
sudo cloud-init clean
sudo cloud-init init
sudo cloud-init modules --mode final
```

## 🔧 Commandes utiles

### Gestion de l'agent
```bash
# Statut du service
sudo systemctl status vsts-agent-*

# Redémarrage
sudo systemctl restart vsts-agent-*

# Logs en temps réel
sudo journalctl -u vsts-agent-* -f

# Configuration manuelle
cd /opt/azuredevops-agent
sudo -u azureuser ./config.sh
```

### Monitoring système
```bash
# Utilisation CPU/RAM
htop

# Espace disque
df -h

# Processus réseau
sudo netstat -tlnp

# Mises à jour disponibles
sudo apt list --upgradable
```

### Nettoyage
```bash
# Nettoyage des logs
sudo journalctl --vacuum-time=7d

# Nettoyage APT
sudo apt autoremove
sudo apt autoclean

# Nettoyage des anciens kernels
sudo apt autoremove --purge
```

## 📞 Support

Si vous rencontrez d'autres problèmes :

1. Consultez les [logs GitHub Actions](https://github.com/VOTRE-REPO/actions)
2. Vérifiez la [documentation Azure DevOps](https://docs.microsoft.com/azure/devops/pipelines/agents/linux-agent)
3. Ouvrez une issue dans ce repository avec :
   - Description du problème
   - Logs d'erreur
   - Configuration utilisée
