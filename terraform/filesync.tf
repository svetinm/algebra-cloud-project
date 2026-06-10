resource "azurerm_storage_sync" "storage_sync" {
  name                = "algebra-storage-sync"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = local.tags
}

resource "azurerm_storage_sync_group" "sync_group" {
  name            = "algebra-sync-group"
  storage_sync_id = azurerm_storage_sync.storage_sync.id
}

resource "azurerm_storage_sync_cloud_endpoint" "cloud_endpoint" {
  name                  = "algebra-cloud-endpoint"
  storage_sync_group_id = azurerm_storage_sync_group.sync_group.id
  storage_account_id    = azurerm_storage_account.storage.id
  file_share_name       = azurerm_storage_share.fileshare.name
}
