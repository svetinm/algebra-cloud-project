# ─── Private DNS Zone for PostgreSQL ─────────────────────────────────────────

resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link_app" {
  name                  = "sql-dns-link-app"
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet_app.id
  resource_group_name   = azurerm_resource_group.rg.name

  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link_jump" {
  name                  = "sql-dns-link-jump"
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet_jump.id
  resource_group_name   = azurerm_resource_group.rg.name
}

# ─── PostgreSQL Flexible Server ───────────────────────────────────────────────

resource "azurerm_postgresql_flexible_server" "postgres" {
  name                          = "postgres-algebra-sm"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "16"
  delegated_subnet_id           = azurerm_subnet.db_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.sql_dns.id
  administrator_login           = "pgadmin"
  administrator_password        = azurerm_key_vault_secret.postgres_secret.value
  public_network_access_enabled = false

  sku_name = "B_Standard_B1ms"
  zone     = "1"

  backup_retention_days = 7

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.sql_dns_link_app
  ]

  tags = local.tags
}

# ─── PostgreSQL Database ──────────────────────────────────────────────────────

resource "azurerm_postgresql_flexible_server_database" "appdb" {
  name      = "appdb"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  collation = "en_US.utf8"
  charset   = "utf8"
}
