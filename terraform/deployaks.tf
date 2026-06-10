resource "null_resource" "deploy_aks" {
  provisioner "local-exec" {
    command     = "powershell.exe -ExecutionPolicy Bypass -File ./run.ps1"
    working_dir = "${path.module}/../aks-app"
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_container_registry.acr
  ]
}
