# ─── Storage Account ─────────────────────────────────────────────────────────

resource "azurerm_storage_account" "storage" {
  name                     = "stalgebrasmprojekt01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices", "Logging", "Metrics"]

    virtual_network_subnet_ids = [
      azurerm_subnet.jump_subnet.id,
      azurerm_subnet.aks_subnet.id,
      azurerm_subnet.function_subnet.id,
    ]

    ip_rules = [
      # VAŽNO: Zamijeni s tvojim javnim IP-om
      "1.2.3.4"
    ]
  }

  tags = local.tags
}

# ─── Blob Container ───────────────────────────────────────────────────────────

resource "azurerm_storage_container" "blobcontainer" {
  name                  = "appblob"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# ─── File Share ───────────────────────────────────────────────────────────────

resource "azurerm_storage_share" "fileshare" {
  name                 = "appfiles"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 50
}
