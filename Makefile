.PHONY: help setup validate deploy destroy clean

# Configuration par défaut
VM_NAME ?= ado-agent-vm
LOCATION ?= "West Europe"

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $1, $2}'

setup: ## Configure le backend Terraform et valide l'environnement
	@echo "🔧 Configuration de l'environnement..."
	./scripts/setup-terraform-backend.sh
	./scripts/validate-setup.sh

validate: ## Valide la configuration sans déployer
	@echo "🔍 Validation de la configuration..."
	./scripts/validate-setup.sh

deploy: ## Déploie l'infrastructure localement
	@echo "🚀 Déploiement local..."
	cd terraform && \
	terraform init && \
	terraform plan -var="vm_name=$(VM_NAME)" && \
	terraform apply -auto-approve -var="vm_name=$(VM_NAME)"

destroy: ## Détruit l'infrastructure
	@echo "🗑️ Destruction de l'infrastructure..."
	@read -p "Êtes-vous sûr de vouloir détruire $(VM_NAME) ? [y/N] " confirm && \
	if [ "$confirm" = "y" ]; then \
		cd terraform && terraform destroy -auto-approve -var="vm_name=$(VM_NAME)"; \
	else \
		echo "Destruction annulée"; \
	fi

clean: ## Nettoie les fichiers temporaires
	@echo "🧹 Nettoyage..."
	rm -f scripts/cloud-init.yml
	rm -f terraform/tfplan*
	rm -f terraform/.terraform.lock.hcl

ssh: ## Se connecte à la VM via SSH
	@echo "🔗 Connexion SSH..."
	@IP=$(cd terraform && terraform output -raw public_ip_address 2>/dev/null) && \
	if [ -n "$IP" ]; then \
		ssh azureuser@$IP; \
	else \
		echo "❌ Impossible de récupérer l'IP. La VM est-elle déployée ?"; \
	fi

status: ## Affiche le statut de l'infrastructure
	@echo "📊 Statut de l'infrastructure..."
	@cd terraform && terraform show -json 2>/dev/null | jq -r '.values.root_module.resources[] | select(.type == "azurerm_linux_virtual_machine") | "VM: \(.values.name) | Status: \(.values.vm_agent_version // "N/A")"' || echo "❌ Aucune infrastructure déployée"
