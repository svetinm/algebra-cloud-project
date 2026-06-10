resource "random_uuid" "workbook_uuid" {}

resource "azurerm_application_insights_workbook" "workbook" {
  name                = random_uuid.workbook_uuid.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  display_name        = "algebra-monitoring-workbook"
  source_id           = lower(azurerm_log_analytics_workspace.log_workspace.id)

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "# Algebra Cloud Project – Monitoring Workbook\n\nCentralizirani pregled logova i metrika za sve resurse."
        }
      },
      {
        type = 3
        content = {
          version       = "KqlItem/1.0"
          query         = "Perf | where CounterName == \"% Processor Time\" | summarize avg(CounterValue) by bin(TimeGenerated, 5m), Computer | render timechart"
          title         = "CPU Utilizacija – Jump VM"
          visualization = "timechart"
        }
      },
      {
        type = 3
        content = {
          version       = "KqlItem/1.0"
          query         = "Event | where EventLevelName in ('Error', 'Warning', 'Critical') | project TimeGenerated, Computer, EventLevelName, RenderedDescription | order by TimeGenerated desc | take 50"
          title         = "Security logovi – Jump VM"
          visualization = "table"
        }
      },
      {
        type = 3
        content = {
          version       = "KqlItem/1.0"
          query         = "ContainerLog | project TimeGenerated, ContainerID, LogEntry | order by TimeGenerated desc | take 50"
          title         = "AKS Container Logovi"
          visualization = "table"
        }
      },
      {
        type = 3
        content = {
          version       = "KqlItem/1.0"
          query         = "StorageBlobLogs | where OperationName in ('GetBlob', 'PutBlob', 'DeleteBlob', 'ListBlobs') | project TimeGenerated, OperationName, CallerIpAddress, StatusCode | order by TimeGenerated desc | take 50"
          title         = "Storage Blob Pristup"
          visualization = "table"
        }
      },
      {
        type = 3
        content = {
          version       = "KqlItem/1.0"
          query         = "AzureDiagnostics | where ResourceProvider == \"MICROSOFT.KEYVAULT\" | project TimeGenerated, OperationName, CallerIPAddress, ResultType | order by TimeGenerated desc | take 50"
          title         = "Key Vault Pristup"
          visualization = "table"
        }
      }
    ]
  })

  tags = local.tags

  depends_on = [
    azurerm_log_analytics_workspace.log_workspace,
    azurerm_monitor_data_collection_rule_association.vm_dcr_assoc,
    azurerm_monitor_diagnostic_setting.storage_logs,
    azurerm_monitor_diagnostic_setting.kv_logs
  ]
}
