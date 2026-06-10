# ─── Private DNS Zone for Function App ───────────────────────────────────────

resource "azurerm_private_dns_zone" "func_dns" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "func_dns_link" {
  name                  = "func-dns-link"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.func_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet_app.id
  registration_enabled  = false

  tags = local.tags
}

# ─── Private Endpoint for Function App ───────────────────────────────────────

resource "azurerm_private_endpoint" "func_pe" {
  name                = "func-private-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "func-private-connection"
    private_connection_resource_id = azurerm_windows_function_app.functionapp.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "func-dns-group"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.func_dns.id
    ]
  }

  tags = local.tags
}
