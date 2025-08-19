terraform {
  required_version = ">= 1.5.0"

  # Backend Azure pour stocker l'état Terraform
  backend "azurerm" {
    # Configuration fournie via -backend-config dans GitHub Actions
  lock_timeout = "5m"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
