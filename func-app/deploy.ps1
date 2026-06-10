# deploy.ps1 – Pakira i deploya Function App kod
# VAŽNO: Zamijeni naziv resource grupe ako si promijenio u provider.tf

$ResourceGroup = "rg-algebra-project"
$FuncAppName   = "algebra-func-app-sm"

Write-Host "=== Pakiram Function App kod ===" -ForegroundColor Cyan

# Kreiraj ZIP arhivu od func-app foldera
$ZipPath = "$PSScriptRoot\function.zip"
if (Test-Path $ZipPath) { Remove-Item $ZipPath }
Compress-Archive -Path "$PSScriptRoot\*" -DestinationPath $ZipPath -Force

Write-Host "=== Deployam na Azure Function App ===" -ForegroundColor Cyan
az functionapp deployment source config-zip `
  --resource-group $ResourceGroup `
  --name $FuncAppName `
  --src $ZipPath

Write-Host "=== Provjera statusa ===" -ForegroundColor Cyan
az functionapp show `
  --resource-group $ResourceGroup `
  --name $FuncAppName `
  --query "{name:name, state:state, defaultHostName:defaultHostName}" `
  --output table

Write-Host "=== Gotovo! ===" -ForegroundColor Green
