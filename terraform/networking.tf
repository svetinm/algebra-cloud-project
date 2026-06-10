# ─── Virtual Networks ─────────────────────────────────────────────────────────

resource "azurerm_virtual_network" "vnet_app" {
  name                = "vnet-app-network"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = local.tags
}

resource "azurerm_virtual_network" "vnet_jump" {
  name                = "vnet-jump-network"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]

  tags = local.tags
}

# ─── Subnets ──────────────────────────────────────────────────────────────────

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_app.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_app.name
  address_prefixes     = ["10.0.2.0/24"]

  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "function_subnet" {
  name                 = "function-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_app.name
  address_prefixes     = ["10.0.3.0/24"]

  service_endpoints = ["Microsoft.Storage"]

  delegation {
    name = "function-delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "db_subnet" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_app.name
  address_prefixes     = ["10.0.4.0/24"]

  delegation {
    name = "postgres-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "private-endpoints"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_app.name
  address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_subnet" "jump_subnet" {
  name                 = "jump-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_jump.name
  address_prefixes     = ["10.1.1.0/24"]

  service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

# ─── VNet Peering ─────────────────────────────────────────────────────────────

resource "azurerm_virtual_network_peering" "app_to_jump" {
  name                      = "app-to-jump"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet_app.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_jump.id
}

resource "azurerm_virtual_network_peering" "jump_to_app" {
  name                      = "jump-to-app"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet_jump.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_app.id
}

# ─── Public IPs ───────────────────────────────────────────────────────────────

resource "azurerm_public_ip" "jump_pip" {
  name                = "jumpvm-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"

  tags = local.tags
}

resource "azurerm_public_ip" "appgw_pip" {
  name                = "appgw-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}
