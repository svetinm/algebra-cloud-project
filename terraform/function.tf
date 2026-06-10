resource "azurerm_service_plan" "func" {
  name                = "func-app-service-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Windows"
  sku_name            = "B1"

  tags = local.tags
}

resource "azurerm_windows_function_app" "functionapp" {
  name                = "algebra-func-app-sm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  service_plan_id            = azurerm_service_plan.func.id

  virtual_network_subnet_id = azurerm_subnet.function_subnet.id

  site_config {
    application_stack {
      powershell_core_version = "7.4"
    }

    # Dozvoli pristup samo s tvog IP-a i AppGW subnetа
    ip_restriction {
      # VAŽNO: Zamijeni s tvojim javnim IP-om
      ip_address = "1.2.3.4/32"
      action     = "Allow"
      priority   = 100
      name       = "allow-my-ip"
    }

    ip_restriction_default_action     = "Deny"
    scm_ip_restriction_default_action = "Deny"
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "powershell"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  tags = local.tags
}
