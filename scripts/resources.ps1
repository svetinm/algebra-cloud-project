# resources.ps1 – Lista sve Azure resurse u resource grupi
# VAŽNO: Zamijeni naziv resource grupe ako si promijenio

$ResourceGroup = "rg-algebra-project"

Write-Host "=== Azure resursi u grupi: $ResourceGroup ===" -ForegroundColor Cyan

az resource list `
  --resource-group $ResourceGroup `
  --query "[].{Name:name, Type:type, Location:location}" `
  --output table

Write-Host "`n=== Tagovi svih resursa ===" -ForegroundColor Cyan

az resource list `
  --resource-group $ResourceGroup `
  --query "[].{Name:name, Tags:tags}" `
  --output table
