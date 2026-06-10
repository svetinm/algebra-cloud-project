# ─── Log Analytics Workspace ──────────────────────────────────────────────────

resource "azurerm_log_analytics_workspace" "log_workspace" {
  name                = "log-workspace-algebra"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.tags
}

# ─── Azure Monitor Agent on Jump VM ──────────────────────────────────────────

resource "azurerm_virtual_machine_extension" "win_monitor" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.jump.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.22"
  auto_upgrade_minor_version = true

  tags = local.tags
}

# ─── Data Collection Rule ─────────────────────────────────────────────────────

resource "azurerm_monitor_data_collection_rule" "windows_dcr" {
  name                = "windows-dcr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  destinations {
    log_analytics {
      name                  = "la-dest"
      workspace_resource_id = azurerm_log_analytics_workspace.log_workspace.id
    }
  }

  data_flow {
    destinations = ["la-dest"]
    streams      = ["Microsoft-Perf"]
  }

  data_flow {
    destinations = ["la-dest"]
    streams      = ["Microsoft-Event"]
  }

  data_sources {
    performance_counter {
      name                          = "perf-datasource"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor Information(_Total)\\% Processor Time",
        "\\Processor Information(_Total)\\% Privileged Time",
        "\\Processor Information(_Total)\\% User Time",
        "\\System\\Processes",
        "\\Process(_Total)\\Thread Count",
        "\\System\\System Up Time",
      ]
    }

    windows_event_log {
      name    = "security-events"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Security!*[System[(band(Keywords,13510798882111488))]]"
      ]
    }
  }

  tags = local.tags
}

resource "azurerm_monitor_data_collection_rule_association" "vm_dcr_assoc" {
  name                    = "vm-dcr-assoc"
  target_resource_id      = azurerm_windows_virtual_machine.jump.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.windows_dcr.id

  depends_on = [
    azurerm_monitor_data_collection_rule.windows_dcr,
    azurerm_virtual_machine_extension.win_monitor
  ]
}

# ─── Diagnostic Settings ──────────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "kv_logs" {
  name                       = "kv-diag"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id

  enabled_log {
    category = "AuditEvent"
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_logs" {
  name                       = "storage-diag"
  target_resource_id         = "${azurerm_storage_account.storage.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id

  enabled_log {
    category_group = "allLogs"
  }
}
