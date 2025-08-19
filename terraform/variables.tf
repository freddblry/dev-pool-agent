variable "vm_name" {
  description = "Nom de la machine virtuelle et de l'agent Azure DevOps"
  type        = string
  default     = "ado-agent-vm"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,15}$", var.vm_name))
    error_message = "Le nom de la VM doit contenir entre 3 et 15 caractères alphanumériques ou tirets."
  }
}

variable "vm_size" {
  description = "Taille de la machine virtuelle Azure"
  type        = string
  default     = "Standard_B2s"
}

variable "location" {
  description = "Région Azure pour déployer les ressources"
  type        = string
  default     = "West Europe"
}

variable "admin_username" {
  description = "Nom d'utilisateur administrateur de la VM"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "Clé publique SSH pour l'accès administrateur"
  type        = string
  sensitive   = true
}

variable "allowed_ssh_ips" {
  description = "Liste des adresses IP autorisées pour SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # ⚠️ Restreignez en production !
}

# Tags par défaut appliqués à toutes les ressources
variable "default_tags" {
  description = "Tags par défaut pour toutes les ressources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "azure-devops-agent"
    ManagedBy   = "terraform"
  }
}
