resource "null_resource" "deploy_func" {
  provisioner "local-exec" {
    command     = "powershell.exe -ExecutionPolicy Bypass -File ./deploy.ps1"
    working_dir = "${path.module}/../func-app"
  }

  depends_on = [
    azurerm_windows_function_app.functionapp
  ]
}
