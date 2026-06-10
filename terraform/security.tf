# â”€â”€â”€ Random password for PostgreSQL â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

resource "random_password" "postgres_password" {
  length  = 20
  special = true
}

# â”€â”€â”€ Current client config â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

data "azurerm_client_config" "current" {}

# â”€â”€â”€ Key Vault â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

resource "azurerm_key_vault" "kv" {
  name                = "kv-algebra-sm-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled = false

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"

    virtual_network_subnet_ids = [
      azurerm_subnet.appgw_subnet.id,
      azurerm_subnet.jump_subnet.id,
    ]

    ip_rules = [
      # VAÅ½NO: Zamijeni s tvojim javnim IP-om (posjeti https://ifconfig.me)
      "1.2.3.4"
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "Set", "List", "Delete", "Recover", "Purge"
    ]

    certificate_permissions = [
      "Get", "List", "Create", "Delete", "Recover", "Purge", "Import", "Update"
    ]

    key_permissions = [
      "Get", "List", "Create", "Delete"
    ]
  }

  tags = local.tags
}

# â”€â”€â”€ Key Vault Secret (PostgreSQL password) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

resource "azurerm_key_vault_secret" "postgres_secret" {
  name         = "postgres-admin-password"
  value        = random_password.postgres_password.result
  key_vault_id = azurerm_key_vault.kv.id

  tags = local.tags
}

# â”€â”€â”€ Managed Identity â€“ AKS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "aks-identity"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.tags
}

# AKS â†’ ACR (pull images)
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# AKS â†’ VNet (networking)
resource "azurerm_role_assignment" "aks_network" {
  scope                = azurerm_virtual_network.vnet_app.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# AKS â†’ Storage Blobs
resource "azurerm_role_assignment" "aks_blob_access" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# AKS â†’ Storage Files
resource "azurerm_role_assignment" "aks_file_access" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# AKS â†’ Key Vault Secrets
resource "azurerm_role_assignment" "aks_kv_access" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# â”€â”€â”€ Managed Identity â€“ Application Gateway â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

resource "azurerm_user_assigned_identity" "appgw_identity" {
  name                = "appgw-identity"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.tags
}

resource "azurerm_key_vault_access_policy" "appgw_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.appgw_identity.principal_id

  secret_permissions = [
    "Get", "List"
  ]

  certificate_permissions = [
    "Get", "List"
  ]
}

# â”€â”€â”€ Current user access to Storage â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

resource "azurerm_role_assignment" "user_blob_access" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# â”€â”€â”€ NSG â€“ Jump VM â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

resource "azurerm_network_security_group" "nsg_jump" {
  name                = "nsg-jump"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-rdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    # VAÅ½NO: Zamijeni s tvojim javnim IP-om
    source_address_prefix      = "1.2.3.4"
    destination_address_prefix = "*"
  }

  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_to_jumpnet" {
  subnet_id                 = azurerm_subnet.jump_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_jump.id
}
