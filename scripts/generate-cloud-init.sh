#!/bin/bash

#======================================================================
# Générateur de fichier cloud-init pour Azure DevOps Agent
#======================================================================
# Ce script génère un fichier cloud-init basé sur les variables d'environnement
# Utilisé par GitHub Actions pour configurer dynamiquement l'agent
#======================================================================

set -euo pipefail

# Vérification des variables d'environnement requises
required_vars=("ADMIN_SSH_PUBLIC_KEY" "AZDO_ORG" "AZDO_PAT" "AZDO_AGENT_POOL" "VM_NAME" "VM_USER")

echo "🔍 Vérification des variables d'environnement..."
for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo "❌ Variable d'environnement manquante : $var"
        exit 1
    fi
done

echo "✅ Toutes les variables sont présentes"
echo "📝 Génération du fichier cloud-init..."

# Génération du fichier cloud-init.yml
cat > "${CLOUD_INIT_FILE:-cloud-init.yml}" << CLOUD_INIT_EOF
#cloud-config
# Configuration automatique pour agent Azure DevOps self-hosted
# VM: ${VM_NAME} | User: ${VM_USER} | Pool: ${AZDO_AGENT_POOL}

package_update: true
package_upgrade: true

packages:
  - curl
  - tar
  - jq
  - git
  - wget
  - unzip
  - build-essential
  - apt-transport-https
  - ca-certificates
  - gnupg
  - lsb-release

users:
  - name: ${VM_USER}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ${ADMIN_SSH_PUBLIC_KEY}

write_files:
  - path: /tmp/install-agent.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      set -euo pipefail
      
      echo "🔧 Installation de l'agent Azure DevOps..."
      
      # Création du répertoire agent
      mkdir -p /opt/azuredevops-agent
      cd /opt/azuredevops-agent
      
      # Téléchargement de la dernière version
      echo "📥 Téléchargement de l'agent..."
      wget -q https://vstsagentpackage.azureedge.net/agent/3.232.0/vsts-agent-linux-x64-3.232.0.tar.gz -O agent.tar.gz
      
      if [ ! -f agent.tar.gz ]; then
        echo "❌ Échec du téléchargement"
        exit 1
      fi
      
      # Extraction
      echo "📦 Extraction de l'agent..."
      tar xzf agent.tar.gz
      rm agent.tar.gz
      
      # Configuration des permissions
      chown -R ${VM_USER}:${VM_USER} /opt/azuredevops-agent
      
      # Configuration de l'agent
      echo "⚙️ Configuration de l'agent..."
      sudo -u ${VM_USER} bash -c '
        cd /opt/azuredevops-agent
        ./config.sh \
          --unattended \
          --url "https://dev.azure.com/${AZDO_ORG}" \
          --auth pat \
          --token "${AZDO_PAT}" \
          --pool "${AZDO_AGENT_POOL}" \
          --agent "${VM_NAME}" \
          --acceptTeeEula \
          --replace
      '
      
      if [ \$? -eq 0 ]; then
        echo "✅ Agent configuré avec succès"
      else
        echo "❌ Échec de la configuration de l'agent"
        exit 1
      fi
      
      # Installation et démarrage du service
      echo "🔄 Installation du service..."
      ./svc.sh install ${VM_USER}
      ./svc.sh start
      
      # Vérification
      sleep 10
      if ./svc.sh status | grep -q "active"; then
        echo "✅ Service démarré avec succès"
      else
        echo "⚠️ Problème avec le service"
        ./svc.sh status
      fi

runcmd:
  # Configuration des permissions SSH
  - chmod 700 /home/${VM_USER}/.ssh
  - chmod 600 /home/${VM_USER}/.ssh/authorized_keys
  - chown -R ${VM_USER}:${VM_USER} /home/${VM_USER}/.ssh
  
  # Exécution du script d'installation de l'agent
  - echo "🚀 Démarrage de l'installation de l'agent Azure DevOps..."
  - /tmp/install-agent.sh
  
  # Message de fin
  - echo "🎉 Configuration terminée ! Agent ${VM_NAME} prêt dans le pool ${AZDO_AGENT_POOL}"

timezone: Europe/Paris

# Redémarrage si nécessaire
power_state:
  delay: "+1"
  mode: reboot
  condition: True
CLOUD_INIT_EOF

echo "✅ Fichier cloud-init généré : ${CLOUD_INIT_FILE:-cloud-init.yml}"
