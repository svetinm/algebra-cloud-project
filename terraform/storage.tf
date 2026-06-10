resource "azurerm_storage_account" "storage" {
  name                     = "stalgebrasmprojekt01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = local.tags
}
resource "azurerm_storage_container" "blobcontainer" {
  name                  = "appblob"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}
resource "azurerm_storage_share" "fileshare" {
  name                 = "appfiles"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 50
}
