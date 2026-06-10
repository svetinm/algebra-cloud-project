terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      recover_soft_deleted_key_vaults = false
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-algebra-project"
  location = "West Europe"

  tags = local.tags
}
